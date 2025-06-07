-- align-filter.lua
-- A Pandoc Lua filter that converts Divs like:
--   ::: {.align position}
--   text
--   :::
-- into:
--   • For HTML targets:  <div align="position">text</div>
--   • For Typst targets: #align("position")[text]

local function is_align_div(elem)
  -- Check if this Div has a class "align" and at least one other class
  if not elem.classes then
    return false
  end
  local has_align = false
  local position = nil

  for _, cls in ipairs(elem.classes) do
    if cls == "align" then
      has_align = true
    else
      -- The first non-"align" class we encounter is treated as the position
      position = cls
    end
  end

  return has_align and (position ~= nil), position
end

function Div(elem)
  local ok, position = is_align_div(elem)
  if not ok then
    -- Not an {.align ...} Div, so leave it unchanged
    return nil
  end

  if FORMAT:match("html") then
    -- For HTML output, produce <div align="position">…</div>
    local new_attr = pandoc.Attr("", {}, { align = position })
    return pandoc.Div(elem.content, new_attr)

  elseif FORMAT:match("typst") then
    -- For Typst output, wrap content inside #align("position")[ … ]
    local open_tag  = pandoc.RawBlock("typst", string.format('#align("%s")[', position))
    local close_tag = pandoc.RawBlock("typst", "]")

    -- Insert: open_tag, then all inner blocks, then close_tag
    return pandoc.ListConcat({ pandoc.List({ open_tag }), elem.content, pandoc.List({ close_tag }) })

  else
    -- For any other format (PDF/LaTeX/Docx), leave as-is
    return nil
  end
end
