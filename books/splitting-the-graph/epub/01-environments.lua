-- book-environments.lua
--
-- Maps this book's LaTeX environments onto pandoc AST nodes, and stops the
-- build when it meets one nobody has ruled on.
--
-- Read with -f latex+raw_tex. Without raw_tex, pandoc parses an unknown
-- environment's body as prose: a code listing arrives as paragraphs with its
-- indentation and line breaks gone, which is wrong in a way nothing reports.
-- With raw_tex the same environment arrives here as a RawBlock holding the
-- literal source, which is what makes an exact conversion possible.
--
-- Everything happens inside Pandoc() so the order of the passes is written
-- down rather than inherited from pandoc's traversal order. Reading the
-- metadata first matters: as separate filter functions, Meta runs after the
-- blocks have already been walked, and figure_dir would arrive too late.

-- Verbatim environments -> CodeBlock, with the skylighting language to tag it.
-- pandoc highlights with skylighting, not Pygments, so SPEC decision 31's
-- workaround does not carry over: skylighting has a real graphql definition,
-- measured at zero error tokens on this book's SDL, so graphqlsdl can say what
-- it is instead of borrowing ruby's lexer.
local VERBATIM = {
  graphqlsdl = 'graphql',
}

-- Box environments -> Div, styled from the EPUB stylesheet.
--
-- These are the names pandoc hands over, which are not always the names the
-- chapters are written in: chaptersummary and problemsummary are
-- \newenvironment wrappers and pandoc expands them before a filter sees
-- anything, so both arrive as summarybox. onhc14 is \newtcolorbox, which
-- pandoc does not expand, so it keeps its own name. None of this is guesswork
-- - the refusal at the bottom of this file reported each one.
local DIVS = {
  onhc14 = 'callout-hc14',
}

-- Boxes whose first brace group is a title rather than body text.
local TITLED_DIVS = {
  summarybox = 'summary',
}

-- Environments with nothing for a reflowable EPUB to show. Listed so that
-- dropping them is a decision on the record rather than an accident.
--
-- titlepage: the EPUB takes its title, author and cover from metadata, not
--   from the typeset title page, which is a page-geometry construction.
local IGNORE = {
  titlepage = true,
}

local unknown = {}

local function environment_name(text)
  return text:match('^%s*\\begin%s*{([%a%d@%*]+)}')
end

-- Strip \begin{env}[opts] and the trailing \end{env}, then remove the
-- indentation the whole block shares - minted's autogobble, done here.
local function environment_body(text, name)
  local body = text
  body = body:gsub('^%s*\\begin%s*{' .. name .. '}', '', 1)
  body = body:gsub('^%b[]', '', 1)
  body = body:gsub('\\end%s*{' .. name .. '}%s*$', '', 1)
  body = body:gsub('^\r?\n', '')
  body = body:gsub('%s+$', '')

  local indent = nil
  for line in body:gmatch('[^\n]+') do
    if line:match('%S') then
      local n = #line:match('^ *')
      if indent == nil or n < indent then indent = n end
    end
  end
  if indent and indent > 0 then
    local gobbled = {}
    for line in (body .. '\n'):gmatch('([^\n]*)\n') do
      table.insert(gobbled, line:sub(indent + 1))
    end
    body = table.concat(gobbled, '\n'):gsub('%s+$', '')
  end
  return body
end

local function first_brace_group(text, name)
  local rest = text:gsub('^%s*\\begin%s*{' .. name .. '}', '', 1)
  local group = rest:match('^%s*(%b{})')
  return group and group:sub(2, -2) or nil
end

local function convert_raw_block(el)
  if el.format ~= 'latex' and el.format ~= 'tex' then return nil end

  local name = environment_name(el.text)
  if not name then
    -- A bare command rather than an environment: \clearpage, \index and the
    -- like, none of which a reflowable EPUB can act on.
    return {}
  end

  if IGNORE[name] then return {} end

  local language = VERBATIM[name]
  if language then
    return pandoc.CodeBlock(environment_body(el.text, name), pandoc.Attr('', { language }))
  end

  local class = DIVS[name]
  if class then
    local inner = pandoc.read(environment_body(el.text, name), 'latex+raw_tex')
    return pandoc.Div(inner.blocks, pandoc.Attr('', { class }))
  end

  local titled = TITLED_DIVS[name]
  if titled then
    local title = first_brace_group(el.text, name) or ''
    local rest = el.text
      :gsub('^%s*\\begin%s*{' .. name .. '}', '', 1)
      :gsub('^%s*%b{}', '', 1)
      :gsub('\\end%s*{' .. name .. '}%s*$', '', 1)
    local blocks = pandoc.read(rest, 'latex+raw_tex').blocks
    local parsed_title = pandoc.read(title, 'latex').blocks
    if parsed_title[1] and parsed_title[1].content then
      table.insert(blocks, 1, pandoc.Para({ pandoc.Strong(parsed_title[1].content) }))
    end
    return pandoc.Div(blocks, pandoc.Attr('', { titled }))
  end

  -- Not a refusal yet: record it and carry on, so that one run reports every
  -- environment needing a decision instead of only the first one. Pandoc()
  -- below refuses on the collected set.
  unknown[name] = (unknown[name] or 0) + 1
  return {}
end

-- A figure is written the same way throughout this book: a bare tikzpicture
-- pulled in with \input{figures/tikz/NAME}, inside a figure environment
-- labelled \label{fig:NAME}. Nothing draws TikZ in an EPUB, so each picture is
-- rendered to SVG before pandoc runs and swapped in here.
--
-- The name comes from the figure's own label rather than the \input path,
-- because the flattening step has already inlined the picture and the path is
-- gone. That makes the label-to-filename convention load-bearing, so it is
-- checked rather than assumed.
local function convert_figure(fig, figure_dir)
  local has_picture = false
  fig:walk {
    RawBlock = function(el)
      if (el.format == 'latex' or el.format == 'tex')
        and environment_name(el.text) == 'tikzpicture' then
        has_picture = true
      end
    end,
  }
  if not has_picture then return nil end

  local name = fig.identifier:match('^fig:(.+)$')
  if not name then
    error(string.format(
      'book-environments.lua: a figure holds a tikzpicture but its label is ' ..
      '%q, not of the form \\label{fig:NAME}. The rendered SVG is found by ' ..
      'that name, so the label has to carry it.', fig.identifier))
  end

  local alt = pandoc.utils.stringify(fig.caption and fig.caption.long or {})
  local image = pandoc.Image({ pandoc.Str(alt) }, figure_dir .. '/' .. name .. '.svg')
  local rendered = pandoc.Figure(
    { pandoc.Plain({ image }) }, fig.caption, pandoc.Attr())
  -- Pandoc's EPUB splitter maps Div identifiers to their chapter files but
  -- not Figure identifiers. Put the anchor on a wrapper so a reference from
  -- another chapter becomes chNNN.xhtml#fig:... rather than a dead local link.
  return pandoc.Div(
    { rendered }, pandoc.Attr(fig.identifier, { 'epub-figure' }))
end

function Pandoc(doc)
  local figure_dir = 'figures'
  if doc.meta.figure_dir then
    figure_dir = pandoc.utils.stringify(doc.meta.figure_dir)
  end

  -- Figures first: convert_figure looks for a tikzpicture RawBlock inside, and
  -- the RawBlock pass below would otherwise have consumed it.
  doc = doc:walk {
    Figure = function(fig) return convert_figure(fig, figure_dir) end,
  }

  doc = doc:walk { RawBlock = convert_raw_block }

  local names = {}
  for name, count in pairs(unknown) do
    table.insert(names, string.format('  %-20s %d occurrence(s)', name, count))
  end
  if #names > 0 then
    table.sort(names)
    error(string.format(
      'book-environments.lua: no rule for %d LaTeX environment(s):\n%s\n' ..
      'Add each to VERBATIM, DIVS, TITLED_DIVS or IGNORE in this filter. ' ..
      'Nothing is dropped quietly, which is why this stops the build.',
      #names, table.concat(names, '\n')))
  end

  return doc
end
