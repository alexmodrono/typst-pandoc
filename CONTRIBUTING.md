# Contributing to Libro

Thank you for your interest in contributing to this book project! This document provides guidelines and instructions for contributing.

## Prerequisites

Before you begin, ensure you have the following installed:
- Pandoc (for Markdown processing)
- Typst (for PDF generation)
- Make (for build automation)

## Project Structure

- `contents/`: Markdown files for book chapters
- `filters/`: Pandoc Lua filters for custom processing
- `templates/`: Typst templates for styling
- `img/`: Images used in the book
- `bibliography.bib`: Bibliography entries
- `metadata.yaml`: Book metadata

## How to Contribute

1. **Fork the Repository**
   - Create your own fork of the project
   - Clone it locally

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Add/edit content in the `contents/` directory
   - Follow the existing file naming convention (###.chapter-name.md)
   - Add images to `img/` if needed
   - Update bibliography.bib if you add new citations

4. **Build and Test**
   ```bash
   make clean
   make
   ```
   Ensure the book builds successfully and looks correct.

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

6. **Submit a Pull Request**
   - Push your changes to your fork
   - Create a Pull Request from your branch to the main repository

## Style Guidelines

- Use consistent Markdown formatting
- Place images in the `img/` directory
- Add citations to `bibliography.bib` in BibTeX format
- Follow existing chapter structure and formatting

## Questions?

If you have questions or need help, please open an issue in the repository.

Thank you for contributing!
