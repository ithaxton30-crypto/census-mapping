library(tidycensus)
library(dplyr)
library(readr)

year <- 2024

# B25063 contains gross-rent ranges; B25064 contains median gross rent.
rent_variables <- load_variables(year, "acs5") |>
  filter(
    grepl("^B25063_[0-9]{3}$", name) |
      name == "B25064_001"
  ) |>
  select(name, label)

rent_data <- get_acs(
  geography = "place",
  state = "FL",
  year = year,
  variables = rent_variables$name,
  geometry = FALSE
) |>
  filter(NAME == "Sarasota city, Florida") |>
  left_join(rent_variables, by = c("variable" = "name")) |>
  select(NAME, variable, label, estimate, moe)

if (nrow(rent_data) == 0) {
  stop("No ACS rent data found for Sarasota city, Florida.")
}

write_csv(rent_data, "sarasota_rent_2024.csv")
