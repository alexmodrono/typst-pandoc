-- dropcap.lua
-- A Pandoc Lua filter that wraps the first paragraph after each H1
-- in a Typst dropcap, but only when FORMAT == "typst".

-- Only run this filter when the output format is exactly "typst"
if FORMAT ~= "typst" then
  return {}
end

-- A flag that remembers: did we just see a level-1 header?
local just_saw_h1 = false

-- Whenever we see a Header of level 1, set the flag.
function Header(el)
  if el.level == 1 then
    just_saw_h1 = true
  else
    just_saw_h1 = false
  end
  return el
end

-- Whenever we see a paragraph, check the flag.
-- If we just saw an H1, wrap this Para in raw Typst dropcap markers.
function Para(el)
  if just_saw_h1 then
    -- reset the flag so only the *first* paragraph after the heading is wrapped
    just_saw_h1 = false

    -- Insert a RawBlock with the opening dropcap syntax
    local open_dropcap = pandoc.RawBlock("typst", "#dropcap(height: 2, justify: true, gap: 4pt, hanging-indent: 0em, overhang: 0pt)[")
    -- Insert a RawBlock with the closing bracket
    local close_dropcap = pandoc.RawBlock("typst", "]")

    -- Return a sequence: [ RawBlock("#dropcap()["),
    --                         the original Para,
    --                         RawBlock("]") ]
    return { open_dropcap, el, close_dropcap }
  end

  -- Otherwise, leave the paragraph unchanged
  return el
end
