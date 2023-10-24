# Faculty quality journals list 2019
# plus non-ABDC journal rankings added in 2023
# Files downloaded from https://www.intranet.monash/business/research/research-standards
# Plus A* for JSS, JRSSA, Annals of Applied Statistics as per confirmation guidelines.

library(tidyverse)
library(pdftools)
library(stringdist)
library(rcademy)

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
Group1p <- unique(data[gp_headings[1]:(gp_headings[2]-2)])
AER <- which(stringr::str_detect(Group1p, "American Economic Review"))
Group1p[AER] <- "American Economic Review"
Group1 <- data[(gp_headings[2]):(gp_headings[3]-2)]
AJIL <- which(stringr::str_detect(Group1, "American Journal of International Law"))
law <- which(stringr::str_detect(Group1, "Law journal articles published in the top ranked"))
Group1 <- Group1[AJIL:(law-1)]
Group2 <- data[(gp_headings[3]+2):NROW(data)]
law <- which(stringr::str_detect(Group2, "Law journal articles published in"))
Group2 <- Group2[seq(law-1)]
# Add the actuarial journals and analytics journals
Group1 <- c(Group1,
            "Insurance: Mathematics & Economics",
            "ASTIN Bulletin",
            "North American Actuarial Journal",
            "Scandinavian Actuarial Journal",
            "Journal of Statistical Software",
            "Journal of the Royal Statistical Society, Series A",
            "Annals of Applied Statistics"
          )
# Non-ABDC list
pdf_file <- here::here("data-raw/Non-ABDC-Quality-Journal-List_100823.pdf")
text <- pdf_text(pdf_file)[[2]] |>
  str_split("\n") |>
  unlist() |>
  tail(-2) |>
  str_trim()
# Remove empty lines
text <- text[text != ""]
# Remove lines starting with lower case (continuation of sentences)
text <- text[!str_detect(text, "^[a-z]")]
# Find lines with no ISBN (continuation of preceding lines)
no_isbn <- which(!str_detect(text, "[0-9]"))
titles <- str_extract(text, "^[a-zA-Z&\\s]*") |> str_trim()
group1 <- str_detect(text, "Group 1")
group2 <- str_detect(text, "Group 2")
titles[no_isbn-1] <- paste0(titles[no_isbn-1], " ", titles[no_isbn])
titles <- titles[-no_isbn]
group1 <- group1[-no_isbn]
group2 <- group2[-no_isbn]
Group1 <- c(Group1, titles[group1])
Group2 <- c(Group2, titles[group2])
Unranked <- titles[!group1 & !group2]

# Create faculty data frame
faculty <- bind_rows(
   tibble(title = Group1p, group="Group 1+"),
   tibble(title = Group1, group="Group 1"),
   tibble(title = Group2, group="Group 2")
  ) |>
  filter(!(title %in% Unranked)) |>
  bind_rows(
    tibble(title = Unranked, group = "Group 3")
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

# Title case for titles
monash <- monash |>
  mutate(
    title = str_to_title(title, locale="en_AU"),
    title = str_replace(title, " And ", " & "),
    title = str_replace(title, " Of ", " of "),
    title = str_replace(title, " In ", " in "),
    title = str_replace(title, " The ", " the "),
    title = str_replace(title, " For ", " for "),
    title = str_replace(title, " To ", " to "),
    title = str_replace(title, " With ", " with "),
    title = str_replace(title, " A ", " a "),
    title = str_replace(title, " An ", " an "),
    title = str_replace(title, " On ", " on "),
    title = str_replace(title, " At ", " at "),
    title = str_replace(title, " By ", " by "),
    title = str_replace(title, " From ", " from "),
    title = str_replace(title, " Into ", " into "),
    title = str_replace(title, "Ieee ", "IEEE ")
  ) |>
  distinct()

# Remove Oxford commas
monash <- monash |>
  mutate(title = str_replace(title, ", &", " &")) |>
  distinct()

# Remove double spaces
monash <- monash |>
  mutate(title = str_replace_all(title, "  ", " ")) |>
  distinct()

# Remove some duplicates
monash <- monash |>
  mutate(
    title = if_else(title == "Accounting, Organisations & Society",
               "Accounting, Organizations & Society", title),
    title = if_else(title == "Entrepreneurship Theory & Practice",
               "Entrepreneurship: Theory & Practice", title),
    title = if_else(title == "Transportation Research Part C: Emerging Technologies",
                    "Transportation Research. Part C: Emerging Technologies", title),
    title = if_else(title == "Journal of Law Economics & Organization",
                    "Journal of Law, Economics and Organization", title),
    title = if_else(title == "Journal of Transport, Economics & Policy",
                    "Journal of Transport Economics & Policy", title),
    title = if_else(title == "Population Space & Place",
                    "Population, Space and Place", title)
  ) |>
  distinct()

# Find near matches in journal names
near_matches <- function(data) {
  data |>
    mutate(row = row_number()) %>%
    cross_join(., .) |>
    filter(row.x < row.y) |>
    mutate(title.dist = stringdist(title.x, title.y)) |>
    filter(title.dist < 2) |>
    select(title.x, title.y, rank.x, rank.y)
}

# Find journals with multiple groups and remove lower ranked lines
low_rank <- near_matches(monash) |>
  filter(rank.x != rank.y, title.x == title.y) |>
  transmute(title = title.x, rank = min(as.character(rank.x),as.character(rank.y)))
monash <- monash |>
  anti_join(low_rank, by=c("title","rank"))


# Find journals with similar titles
near_matches(monash)

# save into rcademy
usethis::use_data(monash, overwrite = TRUE)
