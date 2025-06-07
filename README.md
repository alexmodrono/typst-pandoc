# typst-pandoc

A repository for building a sample book using Markdown, Pandoc, and Typst. It demonstrates how to:

* Organize chapters in a `contents/` folder (with numeric prefixes for ordering)
* Use Pandoc to convert Markdown → Typst → PDF & Markdown → EPUB.
* Customize the Typst template for advanced page layout, sidebars, drop caps, etc.
* Manage bibliographic citations
* Bundle images and custom fonts
* Automate builds via a `Makefile`

[See the example PDF to get a glimpse of what can be achieved with this.](https://github.com/alexmodrono/typst-pandoc/blob/main/.github/sample-book.pdf)

## Getting Started

### Requirements

- Pandoc and Typst for building the book

### Quick Setup

The easiest way to get started is to:
1. Edit `metadata.yaml` to set your book's information
2. Modify the files in `contents/` to add your content
3. Update `bibliography.bib` with your references
4. Build the book using the commands below

## Building the Book

To build the book, simply run:

```bash
make
```

This will generate both PDF and EPUB versions in the `output/` directory.

For development, you can:
```bash
make watch
```

This will watch for changes and rebuild automatically.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Prerequisites](#prerequisites)
4. [How It Works](#how-it-works)
   1. [Chapter Ordering](#chapter-ordering)
   2. [Building with the Makefile](#building-with-the-makefile)
   3. [Custom Typst Template](#custom-typst-template)
   4. [Metadata and Bibliography](#metadata-and-bibliography)
5. [Adding or Splitting a Chapter](#adding-or-splitting-a-chapter)
6. [Directory‐level Quick Start](#directory‐level-quick-start)
7. [License & Attribution](#license--attribution)

---

## 1. Project Overview

This project illustrates a full “Markdown → Pandoc → Typst → PDF/EPUB” pipeline for authoring a multi‐chapter book. Each chapter lives as a separate Markdown file in `contents/`, prefixed with a number (e.g. `001.introduction.md`, `002.background.md`, …). Pandoc collects and concatenates these files in ascending numeric order, applies front‐matter metadata, and emits a single Typst (`.typ`) file. Finally, Typst compiles that `.typ` into a richly‐formatted PDF. Optionally, Pandoc also generates an EPUB from the same Markdown sources.

Key goals:

* **Maintainable chapter ordering** via filename prefixes (`001`, `002`, … `050`).
* **Reusable Typst template** (`templates/layman.typ`) with advanced layout features (drop caps, sidebars, margin notes, custom headers/footers, etc.). Any other template can be easily used. 
* **Automated build** using a `Makefile`, so you can type `make pdf`, `make epub`, or `make watch` with minimal typing.
* **Bibliographic citations** pulled from `bibliography.bib` and rendered in Typst.
* **Bundled images** (cover, figures, user/chat icons) under `img/` (Typst can reference these without duplication).

---

## 2. Repository Structure

```text
.
├── contents/                   # Source chapters (Markdown), named 001.*, 002.*, …
│   ├── 001.advanced-topics.md
│   ├── 002.complex-theory.md
│   └── ... (more .md files)
│
├── img/                        # Images used by Typst (cover, icons, figures, etc.)
│   ├── ... your images here.
│
├── output/                     # Build artifacts (PDF, EPUB, Typst source)
│   ├── sample-book.typ
│   ├── sample-book.pdf
│   └── sample-book.epub
│
├── templates/                  # Typst template and bibliography
│   ├── layman.typ                # Custom Typst template defining page styles
│
├── build.sh                    # (Optional) Bash script to run Pandoc + Typst
├── Makefile                    # Primary build automation (recommended)
├── metadata.yaml               # Front‐matter metadata (title/author/lang/publisher/etc.)
├── bibliography.bib.yaml 	# BibTeX file for citations
└── README.md                   # (This file) Project description & instructions
```

---

## 3. Prerequisites

Before building, ensure you have the following installed and in your `PATH`:

1. **Pandoc** ≥ 2.18 (for `--to=typst` support)
2. **Typst** (CLI tool `typst compile`)
3. **fswatch** (for `make watch`, optional)
4. **GNU Make** (for the supplied `Makefile`)

If you plan to generate an EPUB, you may also want:

* A CSL style file (e.g. `apa.csl`).
* A modern EPUB reader (to verify results).

---

## 4. How It Works

### 4.1. Chapter Ordering

* **Filename convention**: Every Markdown chapter under `contents/` is prefixed by a numeral (`001.`, `002.`, ...).
* **Sorting step** (in the Makefile):

  ```makefile
  CHAPTERS := $(shell find contents -type f -name '*.md' | sort)
  ```

  This `find … | sort` command returns all `.md` files in lexicographic order (i.e. `001.*` comes before `002.*`, etc.).
* When you add `003.some-new-chapter.md` or insert `002.5.another-topic.md`, `sort` will automatically place them in ascending order. No need to batch-rename all subsequent files.

### 4.2. Building with the Makefile

The `Makefile` defines several phony targets:

* **`make all`** (the default):

  1. Generates `output/sample-book.typ` from all Markdown under `contents/`.
  2. Compiles that Typst source into `output/sample-book.pdf`.
  3. Generates `output/sample-book.epub` from the same `.md` files.

* **`make pdf`**:

  * Rebuilds only the PDF (and re-runs the Typst step if any `.md`, `metadata.yaml`, or `templates/book.typ` changed).

* **`make epub`**:

  * Regenerates just the EPUB (Pandoc → EPUB3).

* **`make watch`**:

  * Runs `make pdf` once, then watches the `contents/` folder, `metadata.yaml`, and `templates/layman.typ` for changes. Whenever any of those change, it re-runs `make pdf`. Useful when editing chapters in real time.

* **`make clean`**:

  * Deletes everything under `output/`.

* **`make status`**:

  * Runs `make --dry-run all` to show what would be rebuilt, without actually running commands.

#### Key Makefile snippets

```makefile
# 1. Find & sort all Markdown chapters (lex order based on 001,002,…):
CHAPTERS := $(shell find contents -type f -name '*.md' | sort)

# 2. Typst (.typ) depends on all chapters, metadata, and template:
$(OUTPUT_DIR)/$(BOOK_NAME).typ: $(CHAPTERS) metadata.yaml templates/book.typ | $(OUTPUT_DIR)
	pandoc $(CHAPTERS) \
		--metadata-file=metadata.yaml \
		--to=typst \
		--template=templates/layman.typ \
		--output="$@"

# 3. PDF depends on Typst source:
$(OUTPUT_DIR)/$(BOOK_NAME).pdf: $(OUTPUT_DIR)/$(BOOK_NAME).typ | $(OUTPUT_DIR)
	typst compile --root="$(CURDIR)" "$<" "$@"

# 4. EPUB depends on all chapters & metadata:
$(OUTPUT_DIR)/$(BOOK_NAME).epub: $(CHAPTERS) metadata.yaml | $(OUTPUT_DIR)
	pandoc $(CHAPTERS) \
		--metadata-file=metadata.yaml \
		--to=epub3 \
		--epub-chapter-level=1 \
		--output="$@"
```

> Note: `--root="$(CURDIR)"` tells Typst “look for images, bibliography, and other assets relative to the repository root,” not just under `output/`.

### 4.3. Custom Typst Template

The file `templates/layman.typ` is a fully-featured Typst template that defines:

* **Document metadata** (`title`, `authors`, `publisher`, `date`, etc.)
* **Front and back covers**, using `#let front-cover()` and `#let intro-page(...)` macros
* **Margin notes** (`sidebar-note`, `sidebar-quote`) that alternate left/right on odd/even pages
* **Drop caps** in prologue sections (`prologue-page`)
* **Chapter headings** with Roman numerals, centered and styled
* **Footers** that show page numbers and the current chapter
* **Custom lists**, “page summaries,” and “chat boxes” (for illustrative AI dialogue)
* **Bibliography insertion** at the end via `bibliography("../bibliography.bib", style: "apa")`

Some highlights:

* **Margins & page numbering**:

  ```typst
  #let (in-margin, out-margin) = (2cm, 1.75in)
  set page(
    width: 17.5cm,
    height: 24cm,
    numbering: "1",
    number-align: bottom + center,
    margin: (
      inside: in-margin,
      outside: out-margin,
    ),
    footer: context [
      … custom footer logic using #counter(page) …
    ]
  )
  ```
* **Chapter heading style**:

  ```typst
  set heading(numbering: "1.1.1.", supplement: [Chapter])
  show heading: it => {
    if it.level == 1 {
      #pagebreak()
      #pad(
        top: 2em,
        bottom: 3em,
        align(center)[
          #set text(font: "Barlow", weight: "bold")
          #measurable(size: 10pt, [C H A P T E R #h(.5em) #counter(heading).display("I")])
          #text(22pt, it.body)
        ]
      )
    } else {
      it
    }
  }
  ```
* **Bibliography** (APA style):

  ```typst
  bibliography("../bibliography.bib", style: "apa")
  ```

  Pandoc’s built-in citation processor (`citeproc: true`) converts Markdown citations (`[@doe2020]`) to Typst’s `#cite(<doe2020>)` and inserts the above call under the “References” heading.

### 4.4. Metadata and Bibliography

**`metadata.yaml`** (front-matter for the entire book):

```yaml
title: "Sample Book"
author: "Authors of Sample Book"
date: "2025"
publication_date: "2025-06-21"
lang: "en"
description: "A sample book demonstrating Typst and EPUB generation"
identifier: "sample-book-2025"
publisher: "Self Published"
```

Pandoc reads this metadata via `--metadata-file=metadata.yaml`. In the Typst template, we refer to template variables using Mustache syntax:

```typst
#show: book.with(
  title: "$title$",
  authors: (
$for(author)$
  "$author$"$sep$, 
$endfor$
  ),
  copyright: [
    Copyright © $publication$
    … more license text …
  ]
)

$body$
```

* `$title$`, `$publisher$`, and each `$author$` come straight from `metadata.yaml`.
* Pandoc’s `$for(author)$ … $endfor$` loop builds an array of author names, which gets passed into the Typst macro as `authors: ("Author 1", "Author 2")`.

**`templates/bibliography.bib`** is a standard BibTeX file containing entries like:

```bibtex
@article{doe2020,
  author  = {Doe, Jane},
  title   = {A Great Paper},
  journal = {Journal of Examples},
  year    = {2020},
}
```

* To cite “Doe 2020” in Markdown:

  ```markdown
  As shown in Doe’s experiment [@doe2020].
  ```
* Because we use `citeproc: true` (either in YAML or by passing `--citeproc`), Pandoc transforms `[@doe2020]` → `#cite(<doe2020>)` in Typst.
* At the end of the book, `#bibliography("../bibliography.bib", style: "apa")` prints a properly formatted reference list.

---

## 5. Adding or Splitting a Chapter

### 5.1. Adding a New Chapter

1. Create a new Markdown file under `contents/` with the next available three-digit prefix. For example, if you have up to `050.conclusion.md`, name the next file `051.new-chapter-title.md`.
2. Write your chapter content in Markdown as usual.
3. Run:

   ```bash
   make pdf
   make epub
   ```

   or simply:

   ```bash
   make
   ```

   Make will pick up `051.new-chapter-title.md` automatically (because `find contents -type f -name '*.md' | sort` sees it after `050.conclusion.md`).

### 5.2. Splitting an Existing Chapter

Because we rely on three-digit prefixes (001, 002, …, 050), inserting or splitting requires minimal renumbering:

* **Example**: You have `001.intro.md`, `002.background.md`, …, `050.conclusion.md`. You want to split `001.intro.md` into two halves.

  1. Rename the original file (or copy) into two new files:

     * `001a.intro-part1.md`
     * `001b.intro-part2.md`
  2. Remove or archive the old `001.intro.md`.
  3. Ensure the new files appear in numerical order:

     ```
     001a.intro-part1.md
     001b.intro-part2.md
     002.background.md
     003.some-chapter.md
     …
     ```
  4. Run `make` (Make will see `001a`, `001b`, `002` in the correct sequence).
* **Minimal renaming**: Because we used decimal suffixes (`001a`/`001b`) instead of renumbering everything to `002`/`003`…, the downstream prefixes (“002.background.md” onward) need not change.

> **Tip**: Always pick a naming scheme for splits that sorts lexicographically between `001` and `002`. Examples: `001a`, `001.5`, `001-1`, etc.

---

## 6. Directory‐level Quick Start

1. **Clone the repository**:

   ```bash
   git clone https://github.com/alexmodrono/typst-pandoc
   cd typst-pandoc
   ```

2. **Inspect or edit metadata**:

   * Open `metadata.yaml` and set `title`, `author`, and other fields as desired.
   * If you want a different license or publisher info, edit the “license text” under `$show: book.with(...)` in `templates/layman.typ`.

3. **Add or update chapters** in `contents/` (naming them with a three-digit prefix).

   * E.g. `contents/001.intro.md`, `contents/002.background.md`, etc.
   * Write standard Markdown, with optional “raw Typst” blocks if you need advanced formatting:

     ````markdown
     ```{=typst}
     #let foo = "bar"
     #foo
     ```
     ````

4. **Build the book**:

   ```bash
   make
   ```

   * This generates `output/sample-book.typ`, `output/sample-book.pdf`, and `output/sample-book.epub`.
   * The PDF will live at `output/sample-book.pdf`.
   * The EPUB will live at `output/sample-book.epub`.

5. **Preview the PDF** in your favorite viewer.

6. **Open the EPUB** in an EPUB reader (e.g., Calibre, Apple Books, Firefox, or an online validator).

---

## 7. License & Attribution

* The Typst template (`templates/book.typ`) uses custom macros (e.g., `sidebar-note`, `dropcap`, `chat-box`, etc.) authored by this project’s maintainers.
* The sample bibliography (`templates/bibliography.bib`) is provided for demonstration under a standard open‐source license (check the contents if you wish to reuse).
* Feel free to copy, adapt, or extend this workflow for your own book or documentation.

---

**Enjoy authoring your book!** If you run into issues, double-check:

* Chapter filenames (they must end in `.md` and begin with a three-digit number).
* `metadata.yaml` (valid YAML and matching keys).
* That `pandoc`, `typst`, and `make` are installed and on your `PATH`.

Happy writing!
