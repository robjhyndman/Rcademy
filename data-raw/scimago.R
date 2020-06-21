# Save recent SCIMAGO journal rankings
library(dplyr)
# Using RJH fork with data updated to 2019
# devtools::install_github("robjhyndman/sjrdata")
# Original: "ikashnitsky/sjrdata"

# for use in rank_ functions
# title is journal
# rank is the sjr_best_quartile

library(sjrdata)
scimago <- sjrdata::sjr_journals %>%
  filter(year == max(year)) %>%
  tidyr::separate(categories,
                  into=paste0("Cat_",1:14),
                  sep = ";",
                  remove = FALSE,
                  fill = "right") %>%
  mutate(
    across(Cat_1:Cat_14, stringr::str_remove, pattern="\\(Q[0-4]\\)"),
    across(Cat_1:Cat_14, stringr::str_trim),
    across(Cat_1:Cat_14, na_if, y="")
  )
scimago

# Unique categories
categories <- scimago %>%
  select(Cat_1:Cat_14) %>%
  unlist() %>%
  unique() %>%
  na.omit() %>%
  c() %>%
  sort()
categories

# Compute ranks and percentiles within categories
find_cat_rank <- function(df, category) {
  df %>%
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
    ) %>%
    arrange(rank) %>%
    mutate(
      category = category,
      cat_rank = row_number(),
      cat_percentile = cat_rank / max(cat_rank) * 100
    ) %>%
    select(sourceid, title, category, cat_rank, cat_percentile)
}
cat_ranks <- tibble()
for(i in seq_along(categories)) {
  cat_ranks <- cat_ranks %>%
    bind_rows(find_cat_rank(scimago, categories[i]))
}
highest_cat_ranks <- cat_ranks %>%
  group_by(sourceid) %>%
  filter(cat_percentile == min(cat_percentile)) %>%
  slice_head(1) %>%
  ungroup()

# Add category ranks to scimago
scimago <- scimago %>%
  left_join(highest_cat_ranks, by=c("sourceid","title")) %>%
  select(year:categories, category, cat_rank, cat_percentile) %>%
  rename(
    highest_category = category,
    highest_rank = cat_rank,
    highest_percentile = cat_percentile
  )

# Save the result
usethis::use_data(scimago, overwrite = TRUE)
