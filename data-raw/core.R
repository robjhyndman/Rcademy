# file downloaded from http://portal.core.edu.au/conf-ranks/?search=&by=all&source=CORE2018&sort=atitle&page=1
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
core <- read_csv(here("data-raw", "CORE.csv"),
  col_names = FALSE
) %>%
  select(
    conference = X2,
    rank = X5
  ) %>%
  mutate(conference = str_trim_linebreak_etc(conference))

# save into rcademy
usethis::use_data(core, overwrite = TRUE)
