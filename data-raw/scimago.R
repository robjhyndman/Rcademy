# Save recent SCIMAGO journal rankings
library(dplyr)
library(tidyverse)
library(janitor)
library(readxl)

# Download data for all years for safe-keeping
year <- seq(1999, as.numeric(format(Sys.Date(), "%Y"))-1)
for(i in seq_along(year)) {
  url <- "https://www.scimagojr.com/journalrank.php?year=" |>
    paste0(year[i], "&out=xls")
  # Files are actually csv even though we ask for xls
  filename <- here::here("data-raw", paste0("scimagojr-", year[i], ".csv"))
  # Only download if the file does not already exist
  if(!file.exists(filename)) {
    download.file(url, filename, mode="w")
  }
}
# Check last year is not a replicate of previous year
# This occurs when last year has not yet been added to Scimago
scimago <- read_csv2(filename)
df2 <- read_csv2(here::here("data-raw",paste0("scimagojr-", max(year)-1, ".csv")))
if(identical(scimago, df2)) {
  # Remove duplicate file
  fs::file_delete(filename)
  year <- head(year, -1)
  scimago <- df2
}

# Use most recent data, clean up names and add year
scimago <- scimago |>
  clean_names()
year <- scimago |>
  select(matches(".*[12][0-9]{3}$")) |>
  colnames() |>
  str_extract("[12][0-9]{3}$") |>
  as.numeric()
scimago <- scimago |>
  rename_all(~ str_replace(., "[12][0-9]{3}$", "year")) |>
  mutate(year = year) |>
  # Split up category information
  separate(
    categories,
    into=paste0("Cat_",1:14),
    sep = ";",
    remove = FALSE,
    fill = "right"
  ) |>
  mutate(
    across(Cat_1:Cat_14, \(x) stringr::str_remove(x, pattern="\\(Q[0-4]\\)")),
    across(Cat_1:Cat_14, \(x) stringr::str_trim(x)),
    across(Cat_1:Cat_14, \(x) na_if(x, y=""))
  )

# Find unique categories
categories <- scimago |>
  select(Cat_1:Cat_14) |>
  unlist() |>
  unique() |>
  na.omit() |>
  c() |>
  sort()

# Compute ranks and percentiles within categories
find_cat_rank <- function(df, category) {
  df |>
    filter(
        Cat_1 == category |
        Cat_2 == category |
        Cat_3 == category |
        Cat_4 == category |
        Cat_5 == category |
        Cat_6 == category |
        Cat_7 == category |
        Cat_8 == category |
        Cat_9 == category |
        Cat_10 == category |
        Cat_11 == category |
        Cat_12 == category |
        Cat_13 == category |
        Cat_14 == category
    ) |>
    arrange(rank) |>
    mutate(
      category = category,
      cat_rank = row_number(),
      cat_percentile = cat_rank / max(cat_rank) * 100
    ) |>
    select(sourceid, title, category, cat_rank, cat_percentile)
}
cat_ranks <- tibble()
for(i in seq_along(categories)) {
  cat_ranks <- cat_ranks |>
    bind_rows(find_cat_rank(scimago, categories[i]))
}
# What category does each journal rank highest?
highest_cat_ranks <- cat_ranks |>
  group_by(sourceid) |>
  filter(cat_percentile == min(cat_percentile)) |>
  slice_head(n=1) |>
  ungroup()

# Add category ranks to scimago
scimago <- scimago |>
  left_join(highest_cat_ranks, by=c("sourceid","title")) |>
  select(year, rank:categories, category, cat_rank, cat_percentile) |>
  rename(
    highest_category = category,
    highest_rank = cat_rank,
    highest_percentile = cat_percentile
  )

# Save the result
usethis::use_data(scimago, overwrite = TRUE)
