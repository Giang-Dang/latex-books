-- 02-crossrefs.lua - do trung thuc trong XAI
--
-- Turns this book's 349 LaTeX cross-references into EPUB links.
--
-- Read with -f latex+raw_tex, and run after 01-environments.lua, which is what
-- gives equations and the algorithm float an identifier to point at.
--
-- pandoc already does part of the work: \label on a sectioning command becomes
-- that heading's id. What it does not do is render \ref, so without raw_tex the
-- reference is dropped and the sentence closes over the hole. With raw_tex it
-- arrives as a RawInline and this file resolves it.
--
-- This book references more kinds of thing than a prose book does:
--
--   ch  137   sec  87   def  41   fig  38   eq  29
--   app   8   tab   5   thm   2   prop  1   alg  1
--
-- Headings and figures are numbered here. Theorem-family environments are not:
-- pandoc reads \newtheorem itself and has already written "Dinh nghia 1.1" into
-- the Div, so the number is taken from what it rendered rather than counted
-- again. Two counters that disagree is worse than one counter.

local numbers = {}   -- identifier -> "3.2"
local titles = {}    -- identifier -> heading text, for unnumbered targets
local aliases = {}   -- a loose \label -> the id of the thing it names

-- A \label only becomes a heading's id when it directly follows the sectioning
-- command. Chapter 5 writes
--
--   \chapter{Attribution theo gradient: Integrated Gradients va Grad-CAM}
--   % The full title overruns the running-head measure; ...
--   \chaptermark{Attribution theo gradient}
--   \label{ch:attribution-theo-gradient}
--
-- because its title is too long for the running head. pandoc leaves that label
-- loose, and three \ref point at it. So a label that arrives while a heading is
-- still the thing being labelled is recorded as an alias for that heading.
--
-- "Still" is tracked rather than assumed: any block that a reader would see as
-- content ends it, so a stray label further down the chapter cannot silently
-- claim the chapter's number.
local pending_header = nil

-- The level mapping is measured: with --top-level-division=chapter this book
-- produces level 1 = \part, 2 = \chapter, 3 = \section, 4 = \subsection.
local chapter_label = nil
local chapter_count, appendix_count = 0, 0
local section_count, subsection_count = 0, 0
local figure_count, equation_count, table_count, algorithm_count = 0, 0, 0, 0

-- \part opens the numbered body. The preface is a \chapter as well, but it
-- sits in \frontmatter ahead of every part, and pandoc keeps no record of
-- that, so "before the first part" stands in for "outside the numbering".
local body_started = false

local function letter(n)
  return string.char(string.byte('A') + n - 1)
end

local function reset_chapter_counters()
  section_count, subsection_count = 0, 0
  figure_count, equation_count, table_count, algorithm_count = 0, 0, 0, 0
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
      chapter_label = nil
    elseif id:match('^app:') then
      appendix_count = appendix_count + 1
      chapter_label = letter(appendix_count)
    else
      chapter_count = chapter_count + 1
      chapter_label = tostring(chapter_count)
    end
    reset_chapter_counters()
    if id ~= '' and chapter_label then numbers[id] = chapter_label end
    return
  end

  if not chapter_label then return end

  if header.level == 3 then
    section_count = section_count + 1
    subsection_count = 0
    if id ~= '' then numbers[id] = chapter_label .. '.' .. section_count end
  elseif header.level == 4 then
    subsection_count = subsection_count + 1
    if id ~= '' then
      numbers[id] = chapter_label .. '.' .. section_count .. '.' .. subsection_count
    end
  end
end

-- The book class numbers figures, equations, tables and floats within the
-- chapter, so each is <chapter>.<n> and each counter restarts at a chapter.
local function counted(id, count)
  if id ~= '' and chapter_label then
    numbers[id] = chapter_label .. '.' .. count
  end
end

-- A theorem-family Div as pandoc builds it opens with a Para whose Strong
-- holds the name and the number it worked out: "Dinh nghia 1.1". That number
-- is the one the printed book shows, so it is read back rather than recomputed.
local THEOREM_CLASSES = {
  definition = true, example = true, theorem = true,
  lemma = true, proposition = true, corollary = true, remark = true,
}

local function theorem_number(div)
  local first = div.content[1]
  if not (first and first.content) then return nil end
  local text = pandoc.utils.stringify(first.content)
  return text:match('([%d%.]+)')
end

-- Every \label anywhere inside a block, in the order they appear.
local function labels_in(block)
  local found = {}
  pandoc.walk_block(block, {
    RawInline = function(el)
      if el.format ~= 'latex' and el.format ~= 'tex' then return nil end
      local label = el.text:match('\\label%s*{(.-)}')
      if label then table.insert(found, label) end
    end,
    RawBlock = function(el)
      if el.format ~= 'latex' and el.format ~= 'tex' then return nil end
      local label = el.text:match('\\label%s*{(.-)}')
      if label then table.insert(found, label) end
    end,
  })
  return found
end

-- Is this block only LaTeX the reader never sees? \chaptermark and a bare
-- \label are; a paragraph of prose is not.
local function is_apparatus(block)
  if block.t == 'RawBlock' then return true end
  if block.t ~= 'Plain' and block.t ~= 'Para' then return false end
  for _, inline in ipairs(block.content) do
    local t = inline.t
    if t ~= 'RawInline' and t ~= 'Space' and t ~= 'SoftBreak' and t ~= 'LineBreak' then
      return false
    end
  end
  return true
end

-- Pass one, walked explicitly rather than through doc:walk, because the order
-- matters and doc:walk does not promise to visit a Header before the inlines
-- of the paragraph beneath it.
local function survey_blocks(blocks)
  for _, block in ipairs(blocks) do
    local t = block.t
    if t == 'Header' then
      on_header(block)
      pending_header = block.identifier ~= '' and block or nil
    elseif t == 'Figure' then
      figure_count = figure_count + 1
      counted(block.identifier, figure_count)
      pending_header = nil
    elseif t == 'Table' then
      table_count = table_count + 1
      counted(block.identifier, table_count)
      pending_header = nil
    elseif t == 'Div' then
      local class = block.classes[1]
      if class == 'equation' then
        equation_count = equation_count + 1
        counted(block.identifier, equation_count)
      elseif class == 'algorithm' then
        algorithm_count = algorithm_count + 1
        counted(block.identifier, algorithm_count)
      elseif class and THEOREM_CLASSES[class] then
        -- pandoc numbers these itself and leaves the \label loose inside, with
        -- no id on the Div. Attaching it is what makes 41 \ref{def:...} and
        -- their neighbours resolvable at all.
        local found = labels_in(block)
        if found[1] then
          block.identifier = found[1]
          numbers[found[1]] = theorem_number(block) or ''
        end
      else
        survey_blocks(block.content)
      end
      pending_header = nil
    elseif pending_header and is_apparatus(block) then
      for _, label in ipairs(labels_in(block)) do
        aliases[label] = pending_header.identifier
        numbers[label] = numbers[pending_header.identifier]
        titles[label] = titles[pending_header.identifier]
      end
    else
      pending_header = nil
    end
  end
end

function Pandoc(doc)
  survey_blocks(doc.blocks)

  -- The loose \label of a theorem is consumed above but still sits in the
  -- document; dropping it here keeps it out of the reader's way.
  doc = doc:walk {
    RawInline = function(el)
      if el.format ~= 'latex' and el.format ~= 'tex' then return nil end
      if el.text:match('^%s*\\label%s*{.-}%s*$') then return {} end
    end,
  }

  -- Pass two: each \ref becomes a link. An unresolved reference stops the
  -- build; an EPUB that reads "theo dinh nghia" with nothing after it is the
  -- exact failure this file exists to remove.
  return doc:walk {
    RawInline = function(el)
      if el.format ~= 'latex' and el.format ~= 'tex' then return nil end
      local target = el.text:match('^%s*\\ref%s*{(.-)}%s*$')
      if not target then return nil end

      local text = numbers[target]
      if text == nil or text == '' then text = titles[target] end
      if not text then
        error(string.format(
          '02-crossrefs.lua: \\ref{%s} points at a label nothing in the book '
          .. 'carries. Either it is misspelled, or it sits on something this '
          .. 'filter does not number.', target))
      end
      -- A loose label is not an anchor of its own; the link goes to whatever
      -- it was labelling.
      return pandoc.Link(pandoc.Str(text), '#' .. (aliases[target] or target))
    end,
  }
end
