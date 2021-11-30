library(readxl)
library(here)
library(dplyr)

# data downloaded from https://abdc.edu.au/research/abdc-journal-list
abdc <- here("data-raw","abdc_jql_2019_0612-1.xlsx") %>%
  read_xlsx(skip = 7, .name_repair = janitor::make_clean_names) %>%
  rename(
    title = journal_title,
    rank = x2019_rating
  ) %>%
  mutate(rank = factor(rank, levels=c("A*","A","B","C"), ordered=TRUE)) %>%
  arrange(rank, title)

# save into rcademy
usethis::use_data(abdc, overwrite = TRUE)
