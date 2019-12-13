# read abdc
abdc <- readxl::read_xlsx("abdc_jql_2019_0612-1.xlsx", skip=7)

# change column names in abdc
colnames(abdc)[1] <- "journal"
colnames(abdc)[7] <- "rank"

# save into rcademy
usethis::use_data(abdc, overwrite = TRUE)
