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
gp_headings <- which(data %in% c("Group 1+","Group 1","Group 2")) + 1
Group1p <- data[gp_headings[1]:(gp_headings[2]-2)]
Group1 <- data[(gp_headings[2]+1):(gp_headings[3]-11)]
Group2 <- data[(gp_headings[3]+1):(NROW(data)-9)]
# Create faculty data frame
faculty <- bind_rows(
   tibble(title = Group1p, group="Group 1+"),
   tibble(title = Group1, group="Group 1"),
   tibble(title = Group2, group="Group 2")
  )
# Add in ABDC journals
faculty <- faculty %>%
  full_join(abdc %>% filter(rank <= "A")) %>%
  mutate(
    rank = as.character(rank),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2"))
  ) %>%
  select(title, group)

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
    group = factor(group, levels=c("Group 1+","Group 1","Group 2"))
  ) %>%
  select(title, group)

# Add in ERA2010 journals that are not already included
era_subset <- era2010 %>%
  anti_join(faculty) %>%
  select(title, rank) %>%
  filter(rank <= "A")
faculty <- faculty %>%
  full_join(era_subset) %>%
  mutate(
    rank = as.character(rank),
    group = as.character(group),
    group = if_else(is.na(group), rank, group),
    group = recode(group, A = "Group 2", `A*` = "Group 1"),
    group = factor(group, levels=c("Group 1+","Group 1","Group 2"))
  ) %>%
  select(title, group)

# Filter out journals with missing groups
monash <- faculty %>%
  filter(!is.na(group)) %>%
  rename(rank = group) %>%
  distinct()

# save into rcademy
usethis::use_data(monash, overwrite = TRUE)

