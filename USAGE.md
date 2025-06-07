# Using the Typst-Pandoc Template

This guide explains how to use this template to create beautiful documents in multiple formats.

## Quick Start

1. Install prerequisites:
   ```bash
   brew install pandoc typst
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/example/typst-pandoc
   cd typst-pandoc
   ```

3. Build your document:
   ```bash
   make pdf    # Create PDF output
   make epub   # Create EPUB output
   make all    # Create both formats
   make watch  # Watch for changes and rebuild
   ```

## Directory Structure

- `contents/`: Your markdown files (numbered for order)
- `img/`: Images and other media files
- `templates/`: Typst and HTML templates
- `filters/`: Lua filters for Pandoc
- `output/`: Generated files
- `metadata.yaml`: Book metadata
- `bibliography.bib`: Bibliography entries

## Features

### 1. Text Formatting

- **Bold**, *italic*, and ***bold italic*** text
- ~~Strikethrough~~ and `inline code`
- Multiple levels of headings

### 2. Lists

- Bullet points
- Numbered lists
- Definition lists
- Nested lists

### 3. Tables

- Basic tables
- Column alignment
- Complex tables with merged cells

### 4. Code Blocks

- Syntax highlighting
- Line numbers
- Code annotations

### 5. Special Features

- Chat interface with user/AI messages
- LaTeX-style math equations
- Cross-references
- Footnotes
- Citations
- Custom divs for notes/warnings
- Drop caps
- Margin notes
- Page headers/footers

### 6. Images

- Basic image inclusion
- Width/height control
- Captions
- Alt text

## Command Reference

```bash
make pdf          # Build PDF only
make epub         # Build EPUB only
make all          # Build all formats
make watch        # Watch for changes
make clean        # Remove output files
```

## Customization

### Metadata

Edit `metadata.yaml` to set:
- Title
- Author(s)
- Publication date
- Copyright
- Cover image
- Language

### Styling

Edit templates in `templates/` to customize:
- Page layout
- Typography
- Colors
- Spacing

## Best Practices

1. Name content files numerically (001.chapter1.md, 002.chapter2.md)
2. Keep images in the img/ folder
3. Use relative paths for images
4. Add all references to bibliography.bib
5. Test both PDF and EPUB outputs

## Troubleshooting

Common issues and solutions:

1. **Missing images**
   - Check file paths are relative to content file
   - Verify image exists in img/ folder

2. **Bibliography errors**
   - Ensure BibTeX entries are valid
   - Check citation keys match

3. **Build failures**
   - Check Pandoc is installed
   - Verify Typst installation
   - Look for syntax errors in markdown

## Support

For more help:
1. Check the example files in `contents/`
2. Read the Pandoc and Typst documentation
3. File an issue on GitHub
