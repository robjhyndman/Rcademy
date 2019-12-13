# set working directory
# setwd("~/Documents/4. R scripts/Rcademy/Rcademy/rcademy/data-raw")

# read core
core <- read.csv("CORE.csv", stringsAsFactors = FALSE, header = FALSE)
core <- core [,c(2, 5)]
# add heading to core
colnames(core) <- c("journal", "rank")

# read abdc
abdc <- read_xlsx("abdc_jql_2019_0612-1.xlsx", col_names = FALSE)
abdc <- abdc[-c(1),]

# turn first row into column name
colnames(abdc) <- abdc[1,]
abdc <- abdc[c(-1),]

# change column names in abdc
colnames(abdc)[1] <- "journal"
colnames(abdc)[7] <- "rank" 

# save into rcademy
usethis::use_data(core, abdc, overwrite = TRUE)
