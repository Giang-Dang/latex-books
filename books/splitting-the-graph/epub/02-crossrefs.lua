-- book-crossrefs.lua
--
-- Turns this book's 431 LaTeX cross-references into EPUB links.
--
-- Read with -f latex+raw_tex, and run after book-environments.lua so that
-- references inside converted boxes are seen too.
--
-- pandoc already does half the work: \label{sec:loop} on a sectioning command
-- becomes that heading's id, so the link targets exist before this filter
-- runs. What pandoc does not do is the other half. \ref is not something its
-- LaTeX reader renders, so without raw_tex it is dropped and the sentence
-- closes over the hole - "See section  and chapter ." reads as finished text
-- and nothing is reported. With raw_tex the reference arrives as a RawInline
-- and this file resolves it.
--
-- Numbering is computed here rather than taken from --number-sections,
-- because the number has to exist as link text whether or not the headings
-- themselves are numbered in the EPUB.
--
-- The level mapping is measured, not assumed. With --top-level-division=chapter
-- this book produces: level 1 = \part, 2 = \chapter, 3 = \section,
-- 4 = \subsection. Chapters are what \ref names 339 times out of 431, so
-- getting level 2 rather than level 1 is the difference between "chapter 3"
-- and "chapter 1.3".

local numbers = {}   -- identifier -> "3.2"
local titles = {}    -- identifier -> heading text, for unnumbered targets

local chapter_label = nil
local chapter_count = 0
local appendix_count = 0
local section_count = 0
local subsection_count = 0
local figure_count = 0

-- \part opens the numbered body. The preface is a \chapter too, but it sits in
-- \frontmatter ahead of every part, and pandoc keeps no record of that, so
-- "before the first part" is what stands in for "not part of the numbering".
local body_started = false

local function letter(n)
  return string.char(string.byte('A') + n - 1)
end

local function on_header(header)
  local id = header.identifier
  if id ~= '' then titles[id] = pandoc.utils.stringify(header.content) end

  if header.level == 1 then
    body_started = true
    return
  end

  if header.level == 2 then
    if not body_started then
      chapter_label = nil        -- frontmatter: referenced by title, not number
    elseif id:match('^app:') then
      appendix_count = appendix_count + 1
      chapter_label = letter(appendix_count)
    else
      chapter_count = chapter_count + 1
      chapter_label = tostring(chapter_count)
    end
    section_count, subsection_count, figure_count = 0, 0, 0
    if id ~= '' and chapter_label then numbers[id] = chapter_label end
    return
  end

  if not chapter_label then return end

  if header.level == 3 then
    section_count = section_count + 1
    subsection_count = 0
    if id ~= '' then
      numbers[id] = chapter_label .. '.' .. section_count
    end
  elseif header.level == 4 then
    subsection_count = subsection_count + 1
    if id ~= '' then
      numbers[id] = chapter_label .. '.' .. section_count .. '.' .. subsection_count
    end
  end
end

local function on_figure(fig)
  if not chapter_label then return end
  figure_count = figure_count + 1
  if fig.identifier ~= '' then
    numbers[fig.identifier] = chapter_label .. '.' .. figure_count
  end
end

local function on_div(div)
  if div.classes[1] == 'epub-figure' then on_figure(div) end
end

local function reference_target(text)
  return text:match('^%s*\\ref%s*{(.-)}%s*$')
end

function Pandoc(doc)
  -- Pass one, in reading order: every heading and rendered figure wrapper gets
  -- the number a reader of the printed book would see beside it. The wrapper
  -- carries the identifier so pandoc's EPUB splitter can route cross-chapter
  -- links to the document containing the target.
  doc:walk { Header = on_header, Div = on_div }

  -- Pass two: each \ref becomes a link.
  --
  -- An unresolved reference stops the build. The alternative is an EPUB that
  -- reads "See section" with nothing after it, which is the exact failure this
  -- filter exists to remove, so a typo in a label must not reintroduce it.
  return doc:walk {
    RawInline = function(el)
      if el.format ~= 'latex' and el.format ~= 'tex' then return nil end
      local target = reference_target(el.text)
      if not target then return nil end

      local text = numbers[target] or titles[target]
      if not text then
        error(string.format(
          'book-crossrefs.lua: \\ref{%s} points at a label that nothing in ' ..
          'the book carries. Either it is misspelled, or it sits on something ' ..
          'this filter does not number (only headings and figures are ' ..
          'numbered).', target))
      end
      return pandoc.Link(pandoc.Str(text), '#' .. target)
    end,
  }
end
