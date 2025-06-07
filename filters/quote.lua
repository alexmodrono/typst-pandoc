-- Pandoc Lua filter for handling quote divs
-- Converts .quote divs to Typst sidebar-quote or standard blockquotes

-- Global variable to store the bibliography
local bibliography = {}

-- Function to load bibliography from a BibTeX file
function load_bibliography()
  -- Try to get bibliography files from metadata
  local meta = PANDOC_DOCUMENT.meta
  if meta.bibliography then
    local bib_files = meta.bibliography
    if type(bib_files) == "string" then
      bib_files = {bib_files}
    elseif type(bib_files) == "table" then
      -- Convert from Pandoc format if needed
      if bib_files[1] and bib_files[1].text then
        local temp = {}
        for _, item in ipairs(bib_files) do
          table.insert(temp, pandoc.utils.stringify(item))
        end
        bib_files = temp
      end
    end
    -- Bibliography files will be automatically loaded by Pandoc
    return true
  end
  return false
end

function Div(div)
  -- Check if this is a quote div
  if div.classes:includes("quote") then
    local author = div.attributes.author
    local content = div.content
    
    -- If no author specified, treat as regular blockquote
    if not author then
      return pandoc.BlockQuote(content)
    end
    
    -- Check output format
    if FORMAT == "typst" then
      -- Handle Typst output
      local author_str
      
      -- Check if author is a citation (starts with @)
      if author:match("^@") then
        -- Extract citation key (remove @)
        local citation_key = author:sub(2)
        author_str = "#cite(<" .. citation_key .. ">)"
      else
        -- Regular author, wrap in quotes
        author_str = '"' .. author .. '"'
      end
      
      -- Create the Typst raw block
      local typst_code = "#v(-1em)\n#sidebar-quote(author: [*" .. author_str .. "*])["
      
      -- Convert content to Typst and add to the block
      local typst_content = pandoc.write(pandoc.Pandoc(content), "typst")
      typst_code = typst_code .. typst_content .. "]"
      
      return pandoc.RawBlock("typst", typst_code)
      
    else
      -- Handle other formats (epub, html, etc.)
      local quote_content = {}
      
      -- Add the main content
      for i, block in ipairs(content) do
        table.insert(quote_content, block)
      end
      
      -- Check if author is a citation
      if author:match("^@") then
        -- Create the citation as a markdown string within a paragraph
        -- This approach ensures it gets processed by citeproc
        local citation_markdown = "— [" .. author .. "]"
        local temp_doc = pandoc.read(citation_markdown, "markdown")
        
        -- Extract the content from the parsed paragraph and create a new one with attributes
        local parsed_para = temp_doc.blocks[1]
        local author_para = pandoc.Para(
          parsed_para.content,
          pandoc.Attr("", {}, {{"style", "text-align: right"}})
        )
        
        table.insert(quote_content, author_para)
      else
        -- Regular author attribution
        local author_para = pandoc.Para(
          pandoc.List({pandoc.Str("— " .. author)}),
          pandoc.Attr("", {}, {{"style", "text-align: right"}})
        )
        table.insert(quote_content, author_para)
      end
      
      return pandoc.BlockQuote(quote_content)
    end
  end
  
  -- Return unchanged if not a quote div
  return div
end