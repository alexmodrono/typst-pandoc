# Makefile for Typst + Pandoc project (with target-specific Lua filters)

# ------------------------------------------------------------
#  Variables
# ------------------------------------------------------------
OUTPUT_DIR   := output
BOOK_NAME    := sample-book

# All Markdown files under contents/, sorted lex order (001,002,…)
CONTENTS     := $(shell find contents -type f -name '*.md' | sort)

METADATA     := metadata.yaml
TEMPLATE     := templates/layman
PROJECT_ROOT := $(CURDIR)

TYP_FILE     := $(OUTPUT_DIR)/$(BOOK_NAME).typ
PDF_FILE     := $(OUTPUT_DIR)/$(BOOK_NAME).pdf
EPUB_FILE    := $(OUTPUT_DIR)/$(BOOK_NAME).epub

# ------------------------------------------------------------
#  Lua filters
# ------------------------------------------------------------
# 1. Any *.lua in filters/ are “global” filters (applied to all targets).
TOP_FILTERS   := $(wildcard filters/*.lua)

# 2. Typst-specific filters live in filters/typst/
TYPST_FILTERS := $(wildcard filters/typst/*.lua)

# 3. For Typst builds, we want BOTH global + typst-specific filters:
ALL_TYPST_FILTERS := $(TOP_FILTERS) $(TYPST_FILTERS)

# 4. For EPUB (or other non-Typst) builds, we use only the global filters:
EPUB_FILTERS := $(TOP_FILTERS)

# Helper macros to turn a list of .lua files into “--lua-filter=…” flags
define LUA_FLAGS
$(foreach f,$(1),--lua-filter=$(f))
endef

# ------------------------------------------------------------
#  Default target: build both PDF and EPUB
# ------------------------------------------------------------
.PHONY: all
all: pdf epub

# ------------------------------------------------------------
#  PDF / Typst target
# ------------------------------------------------------------
.PHONY: pdf
pdf: $(PDF_FILE)
	@echo "📄 PDF is up to date: $(PDF_FILE)"

# Build PDF from Typst. It needs the .typ first.
$(PDF_FILE): $(TYP_FILE) | $(OUTPUT_DIR)
	@echo "🚀 Compiling Typst → PDF..."
	typst compile --root="$(PROJECT_ROOT)" "$<" "$@"
	@echo "✅ PDF generated: $@"

# Build .typ via Pandoc, loading both global Lua filters and typst-specific filters
$(TYP_FILE): $(CONTENTS) $(METADATA) $(TEMPLATE).typ $(ALL_TYPST_FILTERS) | $(OUTPUT_DIR)
	@echo "🖋  Generating Typst source (with Lua filters)…"
	pandoc $(CONTENTS) \
		--metadata-file=$(METADATA) \
		--to=typst \
		--filter pandoc-crossref \
		$(call LUA_FLAGS,$(ALL_TYPST_FILTERS)) \
		--template=$(TEMPLATE).typ \
		--output="$@"
	@echo "✅ Typst source generated: $@"

# ------------------------------------------------------------
#  EPUB target
# ------------------------------------------------------------
.PHONY: epub
epub: $(EPUB_FILE)
	@echo "📱 EPUB is up to date: $(EPUB_FILE)"

# Generate EPUB, loading only the “global” Lua filters
$(EPUB_FILE): $(CONTENTS) $(METADATA) $(EPUB_FILTERS) | $(OUTPUT_DIR)
	@echo "📚 Generating EPUB (with global filters)…"
	pandoc $(CONTENTS) \
		--metadata-file=$(METADATA) \
		--to=epub3 \
		--mathml \
		--template=$(TEMPLATE).template \
		--bibliography=bibliography.bib \
		--resource-path=.:img:contents/../img \
		--citeproc \
		--split-level=1 \
		--filter pandoc-crossref \
		$(call LUA_FLAGS,$(EPUB_FILTERS)) \
		--output="$@"
	@echo "✅ EPUB generated: $@"

# ------------------------------------------------------------
#  Clean target
# ------------------------------------------------------------
.PHONY: clean
clean:
	@echo "🧹 Cleaning output directory…"
	rm -rf $(OUTPUT_DIR)/*
	@echo "✅ Clean complete."

# ------------------------------------------------------------
#  Watch target (requires fswatch)
# ------------------------------------------------------------
.PHONY: watch
watch:
	@echo "🔄 Starting watch mode—initial build first."
	@$(MAKE) pdf
	@echo "👀 Watching contents/, metadata.yaml, template, and filters for changes…"
	@fswatch -o contents/ $(METADATA) $(TEMPLATE).typ filters/ | \
		while read -r _; do \
		  $(MAKE) pdf; \
		done

# ------------------------------------------------------------
#  Ensure output directory exists
# ------------------------------------------------------------
$(OUTPUT_DIR):
	@mkdir -p $(OUTPUT_DIR)

# ------------------------------------------------------------
#  Convenience: show what would be rebuilt
# ------------------------------------------------------------
.PHONY: status
status:
	@$(MAKE) --dry-run all

# ------------------------------------------------------------
#  Phony targets list
# ------------------------------------------------------------
.PHONY: all pdf epub clean watch status