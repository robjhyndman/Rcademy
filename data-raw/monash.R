# Download faculty quality journal lists from https://www.intranet.monash/business/research/research-standards

library(tidyverse)
library(pdftools)
library(rcademy)
library(stringr)

# Read pdf file
pdf_file <- here::here("data-raw/Faculty-Quality-Journals-List_020823_approved.pdf")
text <- pdf_text(pdf_file)
# Extract all lines and extract journals named in each group
data <- unlist(strsplit(text, "\n") ) |>
  str_remove_all("") |>
  str_trim()
# Remove all empty elements
data <- data[data != ""]
# Find where the group lists are
gp_headings <- which(data %in% c("Group 1+","Group 1","Group 2")) + 1

# Group 1+
Group1p <- data[gp_headings[1]:(gp_headings[2]-2)]
# Truncate AER line
Group1p[grepl("American Economic Review", Group1p)] <- "American Economic Review"

# Group 1
Group1 <- data[(gp_headings[2]+2):(gp_headings[3]-16)]

# Group 2
Group2 <- data[(gp_headings[3]+2):(NROW(data)-14)]

# Create faculty data frame
faculty <- bind_rows(
   tibble(title = Group1p, group="Group 1+"),
   tibble(title = Group1, group="Group 1"),
   tibble(title = Group2, group="Group 2")
  )

# Add in ABDC journals
faculty <- faculty |>
  full_join(abdc) |>
  mutate(
    rank = as.character(rank),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1", B = "Group 3", C="Group 3"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3"))
  ) |>
  select(title, group)

# Remove JRSSB which appears twice
faculty <- faculty |>
  filter(!(group == "Group 1" & str_detect(title, "Royal Statistical Society")))

# Add in CORE journals that are not already included
core_subset <- core_journals |>
  bind_rows(core) |>
  anti_join(faculty) |>
  select(title, rank)
faculty <- faculty |>
  full_join(core_subset) |>
  mutate(
    rank = as.character(rank),
    group = as.character(group),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3"))
  ) |>
  select(title, group)

# Add in faculty-evaluated non-ABDC journal list
text <- here::here("data-raw/Non-ABDC-Quality-Journal-List-23July2024.pdf") |>
  pdf_text()
text <- unlist(strsplit(text, "\n") ) |>
  str_remove_all("") |>
  str_trim()
# Remove stray lines
text <- text[-(1:2)]
text <- text[!grepl("August 2023", text)]
text <- text[!grepl("2024 based on", text)]
text <- text[!grepl("retain Group", text)]
text <- text[text != "Group 1"]
text <- text[text != "Group 2"]
text <- text[text != ""]
# Find journal titles
non_abdc <- tibble(
  title = str_extract(text, "^[^\\d]*") |> str_trim(),
  group = str_extract(text, "Unranked|Group (1\\+?|2)")
)
# Connect broken titles
broken <- which(is.na(non_abdc$group))
non_abdc$title[broken-1] <- paste(non_abdc$title[broken-1], non_abdc$title[broken])
non_abdc <- non_abdc[-broken,]
# Drop unranked journals
non_abdc <- non_abdc |>
  filter(group!= "Unranked") |>
  mutate(group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3")))
# Add to the list
faculty <- faculty |>
  full_join(non_abdc)

# Add in ERA2010 journals that are not already included
era_subset <- era2010 |>
  anti_join(faculty) |>
  select(title, rank) |>
  filter(rank <= "A") |>
  filter(!str_detect(title, "Royal Statistical Society"))
faculty <- faculty |>
  full_join(era_subset) |>
  mutate(
    rank = as.character(rank),
    group = as.character(group),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2","Group 3"))
  ) |>
  select(title, group)

# Filter out journals with missing groups or Group 3
monash <- faculty |>
  filter(!is.na(group)) |>
  filter(group != "Group 3") |>
  rename(rank = group) |>
  distinct()
# Remove IME which appears twice
monash <- monash |>
  filter(!(rank == "Group 2" & str_detect(title, "Insurance: Mathematics and Economics")))

# Remove PNAS which appears twice
monash <- monash |>
  filter(title != "Proceedings of the National Academy of Sciences of USA")

# save into rcademy
usethis::use_data(monash, overwrite = TRUE)
