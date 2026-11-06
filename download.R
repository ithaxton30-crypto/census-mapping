library(tidycensus)
library(tigris)
library(sf)
library(dplyr)

options(tigris_use_cache = TRUE)
year <- 2024

race_vars <- c(
  "White" = "B03002_003",
  "Black" = "B03002_004",
  "Hispanic" = "B03002_012",
  "Asian" = "B03002_006"
)

# 1. Duval County, FL (by census tract)
duval_tracts <- get_acs(
  geography = "tract",
  state = "FL",
  county = "Duval",
  year = year,
  survey = "acs5",
  variables = race_vars,
  summary_var = "B03002_001",
  geometry = TRUE
) |>
  mutate(
    area = "Duval County, FL",
    percent = 100 * estimate / summary_est
  )

# 2. Jacksonville city, FL (tracts within Jacksonville city limits)
jax_boundary <- places(state = "FL", cb = TRUE, year = year) |>
  filter(NAME == "Jacksonville") |>
  st_transform(st_crs(duval_tracts))

jax_tracts <- st_intersection(duval_tracts, st_geometry(jax_boundary)) |>
  mutate(area = "Jacksonville, FL")

# 3. State of Florida (by county)
fl_counties <- get_acs(
  geography = "county",
  state = "FL",
  year = year,
  survey = "acs5",
  variables = race_vars,
  summary_var = "B03002_001",
  geometry = TRUE
) |>
  mutate(
    area = "Florida",
    percent = 100 * estimate / summary_est
  )

saveRDS(
  list(duval = duval_tracts, jacksonville = jax_tracts, florida = fl_counties),
  "race_ethnicity_maps_2024.rds"
)


