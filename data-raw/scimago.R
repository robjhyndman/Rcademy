# Save recent SCIMAGO journal rankings
library(dplyr)
library(sjrdata)
scimago <- sjrdata::sjr_journals %>%
  # When updated on 2020/02/19, the latest year for the data was 2018
  filter(year == max(year))

# for use in rank_ functions
# title is journal
# rank is the sjr_best_quartile

usethis::use_data(scimago, overwrite = TRUE)

