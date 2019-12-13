# read core
core <- readr::read_csv("CORE.csv", col_names = FALSE)
core <- core [,c(2, 5)]

# add heading to core
colnames(core) <- c("journal", "rank")

# remove whitespace
core$journal <- stringr::str_trim(core$journal)
core$journal <- stringr::str_replace_all(core$journal,"\\n","")
core$journal <- stringr::str_replace(core$journal, "IFIP\\?","IFIP ")

# save into rcademy
usethis::use_data(core, overwrite = TRUE)

