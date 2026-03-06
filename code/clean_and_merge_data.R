# clean_and_merge_data.R
#
# This script replaces the two Stata .do files that previously cleaned and merged
# the paternity data. It reads three Excel files, cleans variable names, merges
# the data, and saves the result as a CSV.
#
# Inputs:
#   - data/paternity-table/paternity_table.xlsx
#   - data/paternity-table/seasonality_data.xlsx
#   - data/paternity-table/demographic_morphological_data.xlsx
#
# Output:
#   - data/paternity-table/paternity_table_merged.csv
#
# Original Stata files preserved for reference in code/stata/

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# Set paths relative to the code/ directory (where this script and the Rmd live)
data_dir <- file.path("..", "data", "paternity-table")

# =============================================================================
# STEP 1: Import and clean the paternity table
# (Replaces: Paternity table cleaning file.do)
# =============================================================================

paternity <- read_excel(
  file.path(data_dir, "paternity_table.xlsx"),
  sheet = "Sheet1"
)

# Rename columns from Excel headers to analysis variable names
paternity <- paternity %>%
  rename(
    entrynumber = `Entry number`,
    js_or_sr = `JS or SR`,
    dateofentry = `Date Added/Changed`,
    study_overlap = `Overlap with other study?`,
    study_overlap_name = `If overlap, what study does it overlap with?`,
    newest_biggest = `If overlap, is this the largest/newest study?`,
    exclude_entry = `Any reason to exclude entry from analysis?`,
    suborder = Suborder,
    infraorder = Infraorder,
    parvorder = Parvorder,
    family = Family,
    common_name = `Species common name`,
    sci_name_inpaper = `Species scientific name (according to paper)`,
    genus_10ktrees = Genus_10ktrees,
    species_10ktrees = species_10ktrees,
    subspecies_10ktrees = subspecies_10ktrees,
    field_site = `Name of field site`,
    country = Country,
    condition = Condition,
    social_grp = `Name of social group`,
    grp_composition = `Group composition`,
    n_paternities = `N paternities tested`,
    n_alphaprimary = `Number attributed to alpha or primary (at time of siring)`,
    n_residents_knownrank = `Number attributed to other residents whose rank (at time of siring) was known`,
    n_residents_unknownrank = `Number attributed to residents whose rank (at time of siring) was unknown`,
    n_tested_undetermined = `Number for whom paternity was tested but specific sire was unassigned`,
    n_egp = `Number of extragroup paternities (EGP)`,
    n_egp_ambiguous = `Number that cannot be confidently assigned as either resident or EGP`,
    res_males_sampled = `Were all resident males sampled?`,
    n_sired_mostsuccess = `Number sired by most successful male`,
    n_sired_othermales = `Number sired by all other (not most successful) males`,
    mean_sire_rank = `Mean rank of sires, for males whose rank at time of conception was known, for infants for whom paternity was assigned (MM groups only)`,
    meanrank_standard = `Mean rank standardized?`,
    nonacs_b = `Nonac's B-index`,
    nonacs_b_t2 = `Nonac's B-index, time 2`,
    nonacs_b_t3 = `Nonac's B-index, time 3`,
    ci_b_low = `CI  for B-index_low`,
    ci_b_high = `CI for B-index_high`,
    ci_b_low_t2 = `CI for B-index_low_t2`,
    ci_b_high_t2 = `CI for B-index_high_t2`,
    ci_b_low_t3 = `CI for B-index_low_t3`,
    ci_b_high_t3 = `CI for B-index_high_t3`,
    nonacsb_p = `p level for B index`,
    nonacsb_p_t2 = `p level for B index_t2`,
    nonacsb_p_t3 = `p level for B index_t3`,
    paternity_conf_strict = `Paternity confidence strict`,
    paternity_conf_relax = `Paternity confidence relaxed`,
    loci_lo = `Minimum # loci`,
    loci_hi = `Maximum # loci`,
    sample_matrix_1 = `Sample matrix 1`,
    sample_matrix_2 = `Sample matrix 2`,
    sample_matrix_3 = `Sample matrix 3`,
    sample_matrix_4 = `Sample matrix 4`,
    sample_matrix_5 = `Sample matrix 5`,
    sample_matrix_6 = `Sample matrix 6`,
    datasource = `Data source`,
    year_first = `Earliest year sampled`,
    year_last = `Latest year sampled`,
    n_yrs_sampled = `Years sampled (n)`,
    long_or_cross = `Longitudinal or cross_sectional?`,
    reference = Source,
    publicationyear = `Publication year`,
    notes = Notes
  )

# Drop empty columns and entry number (matches Stata: drop bl bm bn entrynumber)
paternity <- paternity %>%
  select(-entrynumber, -any_of(c("...64", "...65", "...66")))

# Remove any fully empty columns that may have come through
paternity <- paternity %>%
  select(where(~ !all(is.na(.))))

# Create genus_species_subspecies (matches Stata gen + replace logic)
paternity <- paternity %>%
  mutate(
    genus_10ktrees_str = genus_10ktrees,
    species_10ktrees_str = species_10ktrees,
    subspecies_10ktrees_str = subspecies_10ktrees,
    genus_species_subspecies = case_when(
      is.na(subspecies_10ktrees) | subspecies_10ktrees == "" ~
        paste(genus_10ktrees, species_10ktrees, sep = "_"),
      TRUE ~
        paste(genus_10ktrees, species_10ktrees, subspecies_10ktrees, sep = "_")
    )
  )

# =============================================================================
# STEP 2: Import and clean the seasonality data
# (Replaces first section of: Merge paternity & demo:morpho tables.do)
# =============================================================================

seasonality <- read_excel(
  file.path(data_dir, "seasonality_data.xlsx"),
  sheet = "Sheet1"
)

# Trim whitespace from column names (the "species " column has a trailing space in Excel)
names(seasonality) <- trimws(names(seasonality))

# Rename and select relevant columns
seasonality <- seasonality %>%
  rename(
    species_full = species,
    gestation_length = `Gestation length (d)`,
    litter_size = `Litter size`,
    mean_rainfall_mm = `Mean precipitation (mm)`,
    seasonality_5c = `Seasonality natural habitat (5 category classification)`,
    seasonality_5c_2 = `Seasonality natural habitat (5 category classification, 2nd classification)`,
    seasonality_3c = `Seasonality natural habitat (3 category classification)`
  )

# Drop source and notes columns (matches Stata: drop c e g *_source notes)
seasonality <- seasonality %>%
  select(-any_of(c("gestation_length_source", "litter_size_source",
                    "rainfall_source", "seasonality_source", "Notes"))) %>%
  select(where(~ !all(is.na(.))))

# Split species into genus and species (matches Stata: split species, parse(" "))
seasonality <- seasonality %>%
  mutate(
    genus_10ktrees_str = word(species_full, 1),
    species_10ktrees_str = word(species_full, 2)
  ) %>%
  select(-species_full)

# =============================================================================
# STEP 3: Import and clean the demographics/morphology data
# (Replaces second section of: Merge paternity & demo:morpho tables.do)
# =============================================================================

demographics <- read_excel(
  file.path(data_dir, "demographic_morphological_data.xlsx"),
  sheet = "Sheet1"
)

# Drop source columns, notes, and the redundant species name column
demographics <- demographics %>%
  select(-any_of(c("Species scientific name (in our table)",
                    "philopatry_source", "multilevel_source", "pairbond_type_source",
                    "testes_source", "mass_source", "grpsize_source",
                    "grp_composition_source", "canine_source", "notes")))

# Rename mass variables to drop the _g suffix (Rmd expects names without _g)
demographics <- demographics %>%
  rename(
    testes_mass = testes_mass_g,
    mean_male_mass = mean_male_mass_g,
    mean_female_mass = mean_female_mass_g
  )

# =============================================================================
# STEP 4: Merge seasonality into demographics (1:1 on genus + species)
# (Replaces: merge 1:1 genus_10ktrees_str species_10ktrees_str)
# =============================================================================

demo_seasonal <- left_join(
  demographics,
  seasonality,
  by = c("genus_10ktrees_str", "species_10ktrees_str")
)

# =============================================================================
# STEP 5: Merge demographics+seasonality into paternity (m:1 on genus + species)
# (Replaces: merge m:1 genus_10ktrees_str species_10ktrees_str)
# =============================================================================

paternity_merged <- left_join(
  paternity,
  demo_seasonal,
  by = c("genus_10ktrees_str", "species_10ktrees_str")
)

# Handle any duplicate columns from the merge (e.g., subspecies_10ktrees_str)
# Keep the paternity table version if there are conflicts
if ("subspecies_10ktrees_str.y" %in% names(paternity_merged)) {
  paternity_merged <- paternity_merged %>%
    select(-subspecies_10ktrees_str.y) %>%
    rename(subspecies_10ktrees_str = subspecies_10ktrees_str.x)
}

# =============================================================================
# STEP 6: Save the merged dataset
# =============================================================================

write.csv(paternity_merged, file.path(data_dir, "paternity_table_merged.csv"),
          row.names = FALSE)

message("Data cleaning and merging complete.")
message("Output saved to: data/paternity-table/paternity_table_merged.csv")
