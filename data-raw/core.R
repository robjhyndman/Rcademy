library(tidyverse)
library(here)
library(stringr)

# function to remove whitespace, replace linebreaks and replace certain strings
str_trim_linebreak_etc <- function(x) {
  stringr::str_trim(x) |>
    stringr::str_replace_all("\\n", "") |>
    stringr::str_replace("IFIP\\?", "IFIP ")
}

# Read core conference rankings
# file downloaded from http://portal.core.edu.au/conf-ranks/?search=&by=all&source=CORE2023&sort=atitle&page=1
core <- here("data-raw", "CORE.csv") |>
  read_csv(col_names = FALSE) |>
  select(conference = X2, rank = X5) |>
  transmute(
    title = str_trim_linebreak_etc(conference),
    rank = factor(rank, levels=c("A*","A","B","C"), ordered=TRUE)
  ) |>
  arrange(rank, title)

# Read core journal rankings
# file downloaded from http://portal.core.edu.au/jnl-ranks/?search=&by=all&source=CORE2020&sort=atitle&page=1
core_journals <- here("data-raw", "CORE_journals.csv") |>
  read_csv() |>
  rename(field_of_research=for1, issn = ISSN1) |>
  mutate(rank = factor(rank, levels=c("A*","A","B","C"), ordered=TRUE)) |>
  select(title, field_of_research, issn, rank) |>
  arrange(rank, title)

# save into rcademy
usethis::use_data(core, overwrite = TRUE)
usethis::use_data(core_journals, overwrite = TRUE)
