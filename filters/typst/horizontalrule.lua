-- hr-to-line.lua
-- A Pandoc Lua filter that replaces horizontal rules (`---`, `***`, etc.)
-- with a Typst line: `#line(length: 100%)`.

return {
  {
    HorizontalRule = function()
      -- Emit a raw Typst block instead of the default horizontal rule
      return pandoc.RawBlock("typst", "#line(length: 100%)")
    end
  }
}
