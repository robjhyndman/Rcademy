library(readxl)
library(here)
library(dplyr)

# data downloaded from https://abdc.edu.au/research/abdc-journal-list
abdc <- read_xlsx(here("data-raw",
                       "abdc_jql_2019_0612-1.xlsx"),
                  skip = 7,
                  .name_repair = janitor::make_clean_names) %>%
  rename(journal = journal_title,
         rank = x2019_rating)

# save into rcademy
usethis::use_data(abdc, overwrite = TRUE)
