-- Restore column spans marked before pandoc parses the flattened LaTeX.
--
-- Pandoc does not parse a tabular containing \multicolumn at all, which also
-- loses the surrounding float's caption and label. release_epub.py rewrites a
-- spanning cell as a temporary link plus empty placeholder cells. This filter
-- removes the marker, assigns the real colspan and drops the placeholders.

local PREFIX = 'epub-colspan:'

local function marker_span(cell)
  local span
  local cleaned = {}
  for _, block in ipairs(cell.contents) do
    table.insert(cleaned, pandoc.walk_block(block, {
      Link = function(link)
        if link.target:sub(1, #PREFIX) ~= PREFIX then return nil end
        if span then error('tables.lua: more than one colspan marker in a cell') end
        span = tonumber(link.target:sub(#PREFIX + 1))
        if not span or span < 1 then
          error('tables.lua: invalid colspan marker ' .. link.target)
        end
        return link.content
      end,
    }))
  end
  cell.contents = cleaned
  return span
end

local function process_rows(rows)
  for _, row in ipairs(rows) do
    local cells = pandoc.List()
    local skip = 0
    for _, cell in ipairs(row.cells) do
      if skip > 0 then
        if pandoc.utils.stringify(cell.contents) ~= '' then
          error('tables.lua: colspan placeholder cell is not empty')
        end
        skip = skip - 1
      else
        local span = marker_span(cell)
        if span then
          cell.col_span = span
          skip = span - 1
        end
        cells:insert(cell)
      end
    end
    if skip > 0 then
      error('tables.lua: colspan extends past the end of its row')
    end
    row.cells = cells
  end
end

function Table(table_block)
  process_rows(table_block.head.rows)
  for _, body in ipairs(table_block.bodies) do
    process_rows(body.head)
    process_rows(body.body)
  end
  process_rows(table_block.foot.rows)
  return table_block
end
