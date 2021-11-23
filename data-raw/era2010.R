library(here)
library(dplyr)

# data downloaded from https://www.righttoknow.org.au/request/journal_list_relating_to_the_201
era2010 <- readr::read_csv(here("data-raw", "era2010.csv")) %>%
  janitor::clean_names() %>%
  rename(
    journal = title,
    issn = issn1,
    field_of_research = fo_r1
  ) %>%
  select(eraid, journal, issn, field_of_research, rank) %>%
  mutate(rank = factor(rank, levels=c("A*","A","B","C"))) %>%
  arrange(rank, journal)

# save into rcademy
usethis::use_data(era2010, overwrite = TRUE)
