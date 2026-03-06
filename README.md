# Distribution of genetic paternity among male primates

**Authors:** Stacy Rosenbaum, Nicholas Grebe, Joan B. Silk

**Status:** In preparation

## Overview

This repository contains data, code, and supplementary materials for a comparative analysis of genetic paternity distribution across wild non-human primates. The project compiles paternity data from ~100 published studies spanning several decades and uses Bayesian phylogenetic models to examine how competition and monopolizability shape paternity patterns.

## Repository structure

```
primate-paternity-metanalysis/
├── data/
│   ├── paternity-table/       # Paternity data and demographic/morphological info
│   └── phylogeny/             # Phylogenetic tree and covariance matrix (10kTrees)
├── code/
│   ├── paternity_analysis.Rmd # Main analysis and manuscript (R Markdown)
│   ├── clean_and_merge_data.R # Data cleaning and merging script (R)
│   └── references.bib         # Bibliography for the manuscript
├── output/
│   ├── model-objects/         # Cached Bayesian model fits (.rds)
│   ├── plots/                 # Figures
│   └── tables/                # Summary tables
└── literature/
    ├── paternity-table-sources/    # Source PDFs for studies in the dataset
    ├── paternity-table-sources.bib # BibTeX file for paternity table references
    └── paternity-table-bibliography.Rmd # Renders the source bibliography
```

## Reproducing the analysis

The analysis pipeline has two stages, both in R:

**1. Data preparation**

`code/clean_and_merge_data.R` imports the raw Excel data, renames and labels variables, merges seasonality and demographic/morphological data with the paternity table, and outputs a cleaned CSV. This script is called automatically by the R Markdown file (via `source()`), so it does not need to be run separately.

**2. Analysis and manuscript**

Open `code/paternity_analysis.Rmd` in RStudio and knit. The default output format is HTML; .docx and PDF are also available (use the dropdown next to the Knit button, or call `rmarkdown::render()` with a specific `output_format`). The Rmd reads the cleaned data, fits Bayesian models using `brms`, and generates all figures and tables. On first run, model fitting will be slow. Fitted models are cached as `.rds` files in `output/model-objects/` and will be loaded automatically on subsequent runs.

Required R packages: `dplyr`, `readxl`, `gt`, `brms`, `tidybayes`, `tidyr`, `ggplot2`, `ape`, `phytools`, `ggtree`, `patchwork`, `posterior`, `stringr`.

## Data

The primary dataset (`data/paternity-table/paternity_table.xlsx`) is a compilation of genetic paternity results from studies of wild primate populations. Each row represents a social group within a study (or in some cases, multiple social groups combined), and columns record the number of paternities tested, paternities attributed to alpha/primary males, extra-group paternities, and associated metadata (species, field site, group composition, study methods, etc.).

Phylogenetic data are from [10kTrees](https://10ktrees.nunn-lab.org/) (Version 3).
