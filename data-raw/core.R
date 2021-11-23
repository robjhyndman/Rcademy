# file downloaded from http://portal.core.edu.au/conf-ranks/?search=&by=all&source=CORE2021&sort=atitle&page=1
library(tidyverse)
library(here)
library(stringr)

# function to remove whitespace, replace linebreaks and replace certain strings
str_trim_linebreak_etc <- function(x) {
  stringr::str_trim(x) %>%
    stringr::str_replace_all("\\n", "") %>%
    stringr::str_replace("IFIP\\?", "IFIP ")
}

# read core
core <- here("data-raw", "CORE.csv") %>%
  read_csv(col_names = FALSE) %>%
  select(conference = X2, rank = X5) %>%
  mutate(
    conference = str_trim_linebreak_etc(conference),
    rank = factor(rank, levels=c("A*","A","B","C"))
  ) %>%
  arrange(rank, conference)

core_journals <- here("data-raw", "CORE_journals.csv") %>%
  read_csv() %>%
  rename(journal = title, field_of_research=for1, issn = ISSN1) %>%
  mutate(rank = factor(rank, levels=c("A*","A","B","C"))) %>%
  select(journal, field_of_research, issn, rank) %>%
  arrange(rank, journal)

# save into rcademy
usethis::use_data(core, overwrite = TRUE)
usethis::use_data(core_journals, overwrite = TRUE)
