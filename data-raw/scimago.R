# Save recent SCIMAGO journal rankings

scimagojr <- dplyr::filter(sjrdata::sjr_journals, year==max(year))
colnames(scimagojr)[4] <- "journal"
scimagojr$rank <- scimagojr$sjr_best_quartile

usethis::use_data(scimagojr, overwrite = TRUE)

