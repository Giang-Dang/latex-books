-- 01-environments.lua - do trung thuc trong XAI
--
-- Maps this book's LaTeX environments onto pandoc AST nodes, and stops the
-- build when it meets one nobody has ruled on.
--
-- Read with -f latex+raw_tex. Without raw_tex, pandoc parses an unknown
-- environment's body as prose and reports nothing, so a box or a question list
-- arrives as paragraphs with its shape gone.
--
-- This book carries no code, so it needs no listing rules. What it does carry
-- and splitting-the-graph does not is mathematics, theorem environments and a
-- pseudo-code float, and most of that pandoc already handles: \newtheorem
-- environments become Divs that pandoc has already numbered ("Dinh nghia 1.1"),
-- and display maths becomes MathML. The two places it needs help are recorded
-- against each rule below.

-- Box environments -> Div, styled from the EPUB stylesheet.
local DIVS = {
  tomtat = 'summary',
}

-- Environments that are a list under another name. cauhoids is
-- \newlist{cauhoids}{enumerate}{1}, so it is an enumerate and reading it back
-- as one costs nothing and keeps pandoc's own list handling.
local LISTS = {
  cauhoids = 'enumerate',
}

-- Environments with nothing for a reflowable EPUB to show.
--
-- titlepage: the EPUB takes its title and author from metadata; the typeset
--   title page is a page-geometry construction.
local IGNORE = {
  titlepage = true,
}

-- algpseudocode's control words, and what each one reads as in the EPUB. The
-- book sets \floatname{algorithm}{Thuat toan}, so the float is Vietnamese and
-- these are too.
local PSEUDOCODE = {
  Require = 'Đầu vào:',
  Ensure  = 'Đầu ra:',
  State   = '',
  Return  = 'Trả về',
  For     = 'Với',
  EndFor  = 'Hết vòng lặp',
  While   = 'Trong khi',
  EndWhile = 'Hết vòng lặp',
  If      = 'Nếu',
  Else    = 'Ngược lại',
  EndIf   = 'Hết điều kiện',
}

local unknown = {}

local function environment_name(text)
  return text:match('^%s*\\begin%s*{([%a%d@%*]+)}')
end

local function environment_body(text, name)
  local body = text
  body = body:gsub('^%s*\\begin%s*{' .. name .. '}', '', 1)
  body = body:gsub('^%b[]', '', 1)
  body = body:gsub('\\end%s*{' .. name .. '}%s*$', '', 1)
  return (body:gsub('^\r?\n', ''):gsub('%s+$', ''))
end

-- Pull \caption{...} and \label{...} out of a float's body, returning them and
-- what is left.
local function take_caption_and_label(body)
  local caption = body:match('\\caption%s*(%b{})')
  local label = body:match('\\label%s*{(.-)}')
  body = body:gsub('\\caption%s*%b{}', '', 1):gsub('\\label%s*%b{}', '', 1)
  return caption and caption:sub(2, -2) or nil, label, body
end

-- The algorithm float. One in this book, but the book names the float in
-- Vietnamese, which says the author expects more.
--
-- Each algpseudocode line becomes a list item rather than a line of
-- preformatted text, because the lines carry inline maths - $f$, $\mathcal{Z}$
-- - and reading each one back as LaTeX keeps that as MathML instead of
-- flattening it to characters.
local function convert_algorithm(text)
  local caption, label, body = take_caption_and_label(environment_body(text, 'algorithm'))
  body = body:gsub('\\begin%s*{algorithmic}%s*%b[]', '', 1)
             :gsub('\\begin%s*{algorithmic}', '', 1)
             :gsub('\\end%s*{algorithmic}', '', 1)

  -- Each control word starts a line and owns the text up to the next one, so
  -- the positions are collected first and the text sliced between them. A
  -- single pattern cannot express that: Lua patterns have no alternation, and
  -- the lines themselves contain backslashes.
  local marks = {}
  for position, command in body:gmatch('()\\(%a+)') do
    if PSEUDOCODE[command] ~= nil then
      table.insert(marks, {
        command = command,
        starts = position,
        content = position + #command + 1,
      })
    end
  end

  local items = {}
  for i, mark in ipairs(marks) do
    local stop = marks[i + 1] and (marks[i + 1].starts - 1) or #body
    local rest = body:sub(mark.content, stop)
    -- The pseudo-code names its subroutines in small caps inside maths, as
    -- algpseudocode expects: $w \gets \textsc{K-LASSO}(\mathcal{Z},K)$.
    -- texmath has no \textsc and gives up on the whole formula, so the name is
    -- set upright instead. \mathrm is the closest thing MathML offers to "this
    -- is a name, not a product of variables".
    rest = rest:gsub('\\textsc%s*(%b{})', '\\mathrm%1')
    local word = PSEUDOCODE[mark.command]
    local parsed = pandoc.read(rest, 'latex+raw_tex').blocks
    local content = {}
    if word ~= '' then
      table.insert(content, pandoc.Strong({ pandoc.Str(word) }))
      table.insert(content, pandoc.Space())
    end
    if parsed[1] and parsed[1].content then
      for _, inline in ipairs(parsed[1].content) do
        table.insert(content, inline)
      end
    end
    table.insert(items, { pandoc.Plain(content) })
  end

  local blocks = {}
  if caption then
    local parsed = pandoc.read(caption, 'latex+raw_tex').blocks
    if parsed[1] and parsed[1].content then
      table.insert(blocks, pandoc.Para(parsed[1].content))
    end
  end
  table.insert(blocks, pandoc.OrderedList(items))
  return pandoc.Div(blocks, pandoc.Attr(label or '', { 'algorithm' }))
end

local function convert_raw_block(el)
  if el.format ~= 'latex' and el.format ~= 'tex' then return nil end

  local name = environment_name(el.text)
  if not name then
    -- A bare command: \centering, \medskip, \index, \printbibliography and the
    -- rest of the page-shaping vocabulary, none of which a reflowable EPUB can
    -- act on.
    return {}
  end

  if IGNORE[name] then return {} end

  local class = DIVS[name]
  if class then
    local inner = pandoc.read(environment_body(el.text, name), 'latex+raw_tex')
    return pandoc.Div(inner.blocks, pandoc.Attr('', { class }))
  end

  local as_list = LISTS[name]
  if as_list then
    local rewritten = el.text
      :gsub('\\begin%s*{' .. name .. '}', '\\begin{' .. as_list .. '}', 1)
      :gsub('\\end%s*{' .. name .. '}', '\\end{' .. as_list .. '}', 1)
    return pandoc.read(rewritten, 'latex+raw_tex').blocks
  end

  if name == 'algorithm' then
    return convert_algorithm(el.text)
  end

  unknown[name] = (unknown[name] or 0) + 1
  return {}
end

-- Figures, as in splitting-the-graph: a bare tikzpicture pulled in with
-- \input{figures/tikz/NAME} inside a figure labelled \label{fig:NAME}, and the
-- picture rendered to SVG before pandoc runs.
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
      '01-environments.lua: a figure holds a tikzpicture but its label is %q, '
      .. 'not of the form \\label{fig:NAME}. The rendered SVG is found by that '
      .. 'name, so the label has to carry it.', fig.identifier))
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

-- Display maths, and the one thing pandoc cannot do for itself here.
--
-- Every numbered equation in this book carries its \label inside the
-- environment, which is where LaTeX wants it. pandoc's maths writer cannot
-- read that and gives up on the whole equation:
--
--   [WARNING] Could not convert TeX math \begin{equation}\label{eq:...}...,
--   rendering as TeX
--
-- and the reader gets the LaTeX source. Measured: with the \label removed the
-- same equation converts to MathML. So the label comes out of the maths and
-- becomes the identifier of a Div around it, which is also what gives
-- 02-crossrefs.lua something to point 29 \ref{eq:...} at.
local function lift_equation_label(block)
  local label
  -- Rebuilt through walk_block rather than by assigning to inline.text while
  -- iterating block.content: an inline reached that way is a copy, and the
  -- edit does not reach the document.
  local cleaned = pandoc.walk_block(block, {
    Math = function(math)
      if math.mathtype ~= 'DisplayMath' then return nil end
      local found = math.text:match('\\label%s*{(.-)}')
      if not found then return nil end
      label = found
      return pandoc.Math(math.mathtype, (math.text:gsub('\\label%s*%b{}%s*', '', 1)))
    end,
  })
  if not label then return nil end
  return pandoc.Div({ cleaned }, pandoc.Attr(label, { 'equation' }))
end

function Pandoc(doc)
  local figure_dir = 'figures'
  if doc.meta.figure_dir then
    figure_dir = pandoc.utils.stringify(doc.meta.figure_dir)
  end

  -- Figures first: convert_figure looks for the tikzpicture RawBlock inside,
  -- which the RawBlock pass would otherwise have consumed.
  doc = doc:walk {
    Figure = function(fig) return convert_figure(fig, figure_dir) end,
  }
  doc = doc:walk { Para = lift_equation_label }
  doc = doc:walk { RawBlock = convert_raw_block }

  local names = {}
  for name, count in pairs(unknown) do
    table.insert(names, string.format('  %-20s %d occurrence(s)', name, count))
  end
  if #names > 0 then
    table.sort(names)
    error(string.format(
      '01-environments.lua: no rule for %d LaTeX environment(s):\n%s\n'
      .. 'Add each to DIVS, LISTS or IGNORE in this filter. Nothing is dropped '
      .. 'quietly, which is why this stops the build.',
      #names, table.concat(names, '\n')))
  end

  return doc
end
