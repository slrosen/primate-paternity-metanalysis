# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Comparative analysis of genetic paternity distribution across wild non-human primates. Compiles paternity data from ~100 published studies and uses Bayesian phylogenetic models (brms) to examine how competition and monopolizability shape paternity patterns. The manuscript and analysis are combined in a single R Markdown file.

## Build / Render Commands

The main analysis is an R Markdown document that serves as both the analysis pipeline and manuscript:

```bash
# Render to PDF (default) — run from the code/ directory
Rscript -e 'rmarkdown::render("paternity_analysis.Rmd")'

# Render to Word or HTML
Rscript -e 'rmarkdown::render("paternity_analysis.Rmd", output_format="word_document")'
Rscript -e 'rmarkdown::render("paternity_analysis.Rmd", output_format="html_document")'

# Render supplementary materials to PDF
Rscript -e 'rmarkdown::render("supplementary_materials.Rmd")'
```

Output is written to `output/` (configured via custom knit function in the YAML header). There is no test suite or linting setup.

## Architecture

**Two-stage pipeline (both in R):**

1. **`code/clean_and_merge_data.R`** — Data cleaning script that reads three Excel files from `data/paternity-table/`, merges them, and writes `paternity_table_merged.csv`. This is `source()`'d automatically by the Rmd; it does not need to be run separately.

2. **`code/paternity_analysis.Rmd`** — Main file containing the full analysis and manuscript text. Loads the cleaned CSV, fits Bayesian models with `brms`, and generates all figures and tables. Also writes a processed `paternity_table.csv` to `data/paternity-table/` for public access. All paths in the Rmd are relative to `code/`.

3. **`code/supplementary_materials.Rmd`** — Contains model diagnostics, posterior predictive checks, and sensitivity analyses. Sources the same data cleaning script and loads cached model objects from the main analysis.

**Model caching:** Fitted brms models are saved as `.rds` files in `output/model-objects/` and reloaded on subsequent knits. These files are gitignored. First-run model fitting is slow (hours).

**Phylogenetic data:** Tree and covariance matrix from 10kTrees (Version 3) live in `data/phylogeny/`.

**Bibliography:** `code/references.bib` is used by the Rmd for citations. A separate `literature/paternity-table-sources.bib` covers the primary data sources. Citation keys in both bib files use the underscore format: `Author_etal_Year` for 3+ authors, `Author1_Author2_Year` for two authors, `Author_Year` for single authors.

## Key R Packages

`brms`, `tidybayes`, `ape`, `phytools`, `ggtree`, `patchwork`, `posterior`, `gt`, `readxl`

## Working Directory Note

Both R scripts assume the working directory is `code/`. All relative paths (e.g., `../data/`) are relative to that directory.
