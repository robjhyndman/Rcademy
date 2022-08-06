# Faculty quality journals list 2019
library(tidyverse)
library(pdftools)
library(rcademy)

# Read pdf file
pdf_file <- here::here("data-raw/2019-Quality-Journals-List-revised.pdf")
text <- pdf_text(pdf_file)
# Extract all lines and extract journals named in each group
data <- unlist(strsplit(text, "\n") ) %>%
  str_remove_all("") %>%
  str_trim()
# Remove all empty elements
data <- data[data != ""]
# Find where the group lists are
gp_headings <- which(data %in% c("Group 1+","Group 1","Group 2")) + 1
Group1p <- data[gp_headings[1]:(gp_headings[2]-2)]
# Fix AER line
Group1p[6] <- "American Economic Review"
# Combine PNAS lines
Group1p <- c(Group1p[1:43],paste(Group1p[44:45],collapse=" "),Group1p[46:length(Group1p)])
Group1 <- data[(gp_headings[2]+1):(gp_headings[3]-11)]
Group2 <- data[(gp_headings[3]+1):(NROW(data)-9)]
# Add the actuarial journals
Group1 <- c(Group1,
            "Insurance: Mathematics & Economics",
            "ASTIN Bulletin",
            "North American Actuarial Journal",
            "Scandinavian Actuarial Journal"
          )
# Create faculty data frame
faculty <- bind_rows(
   tibble(title = Group1p, group="Group 1+"),
   tibble(title = Group1, group="Group 1"),
   tibble(title = Group2, group="Group 2")
  )
# Add in ABDC journals
faculty <- faculty %>%
  full_join(abdc) %>%
  mutate(
    rank = as.character(rank),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1", B = "Group 3", C="Group 3"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3"))
  ) %>%
  select(title, group)
# Remove JRSSB which appears twice
faculty <- faculty %>%
  filter(!(group == "Group 1" & str_detect(title, "Royal Statistical Society")))
# Add in CORE journals that are not already included
core_subset <- core_journals %>%
  bind_rows(core) %>%
  anti_join(faculty) %>%
  select(title, rank)
faculty <- faculty %>%
  full_join(core_subset) %>%
  mutate(
    rank = as.character(rank),
    group = as.character(group),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3"))
  ) %>%
  select(title, group)

# Add in ERA2010 journals that are not already included
era_subset <- era2010 %>%
  anti_join(faculty) %>%
  select(title, rank) %>%
  filter(rank <= "A") %>%
  filter(!str_detect(title, "Royal Statistical Society"))
faculty <- faculty %>%
  full_join(era_subset) %>%
  mutate(
    rank = as.character(rank),
    group = as.character(group),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3"))
  ) %>%
  select(title, group)

# Filter out journals with missing groups or Group 3
monash <- faculty %>%
  filter(!is.na(group)) %>%
  filter(group != "Group 3") %>%
  rename(rank = group) %>%
  distinct()
# Remove IME which appears twice
monash <- monash %>%
  filter(!(rank == "Group 2" & str_detect(title, "Insurance: Mathematics and Economics")))

# Remove PNAS which appears twice
monash <- monash %>%
  filter(title != "Proceedings of the National Academy of Sciences of USA")

# save into rcademy
usethis::use_data(monash, overwrite = TRUE)

