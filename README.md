# Distribution of genetic paternity among male primates

**Authors:** Stacy Rosenbaum, Nicholas Grebe, Joan B. Silk

**Status:** In preparation

## Overview

This repository contains data, code, and supplementary materials for a comparative analysis of genetic paternity distribution across wild non-human primates. The project compiles paternity data from over 100 published studies spanning several decades and uses Bayesian phylogenetic models to examine how group composition and ecological factors shape male reproductive skew.

## Repository structure

```
primate-paternity-metanalysis/
├── data/
│   ├── paternity-table/       # Paternity data and demographic/morphological info
│   └── phylogeny/             # Phylogenetic tree and covariance matrix (10kTrees)
├── code/
│   ├── r/                     # R Markdown analysis and bibliography
│   └── stata/                 # Stata scripts for data cleaning and merging
├── output/
│   ├── model-objects/         # Cached Bayesian model fits (.rds)
│   ├── plots/                 # Figures
│   └── tables/                # Summary tables
└── literature/
    └── paternity-table-sources/  # Source PDFs for studies in the dataset
```

## Reproducing the analysis

The analysis pipeline has two stages:

**1. Data preparation (Stata)**

Run the following scripts from `code/stata/`, in order:

- `Paternity table cleaning file.do` — imports the Excel data, renames and labels variables, and saves a cleaned `.dta` file.
- `Merge paternity & demo:morpho tables.do` — merges seasonality, demographic, and morphological data with the paternity table.

**2. Analysis and manuscript (R)**

Open `code/paternity_analysis.Rmd` in RStudio and knit to HTML. The Rmd reads the cleaned data, fits Bayesian models using `brms`, and generates all figures and tables. On first run, model fitting may take several hours. Fitted models are cached as `.rds` files in `output/model-objects/` and will be loaded automatically on subsequent runs.

Required R packages: `dplyr`, `gt`, `brms`, `tidybayes`, `tidyr`, `ggplot2`, `ape`, `phytools`, `haven`, `ggtree`, `patchwork`, `posterior`.

## Data

The primary dataset (`data/paternity-table/Paternity table 6.6.2025.xlsx`) is a compilation of genetic paternity results from studies of wild primate populations. Each row represents a social group within a study, and columns record the number of paternities tested, paternities attributed to alpha/primary males, extra-group paternities, and associated metadata (species, field site, group composition, study methods, etc.).

Phylogenetic data are from [10kTrees](https://10ktrees.nunn-lab.org/) (Version 3).
