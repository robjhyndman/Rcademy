# Functions to read bibliographies

read_bib <- function(filename, check=FALSE) {
  filename %>%
    RefManageR::ReadBib(check = check) %>%
    as_tibble() %>%
    mutate(
      title = stringr::str_remove_all(title, "[{}]"),
      title = stringr::str_replace_all(title, "\\&", "and"),
      journal = stringr::str_replace_all(journal, "\\\\&", "and")
    )
}

read_pubmed <- function(query) {
  query %>%
    easyPubMed::get_pubmed_ids() %>%
    easyPubMed::fetch_pubmed_data(encoding = "ASCII") %>%
    easyPubMed::table_articles_byAuth(included_authors = "first",
                          max_chars = 0,
                          autofill = FALSE) %>%
    as_tibble() %>%
    pull(doi) %>%
    unique() %>%
    crossref_table()
}

read_scholar <- function(user) {
  df <- gcite::gcite_user_info(user = user, secure = FALSE)$paper_df
  colnames(df)[2] <- "date"
  df %>%
    mutate(
      year = lubridate::year(anytime::anydate(date))
    ) %>%
    as_tibble()
}

# Tests
test1 <- read_bib("data-raw/rjhpubs.bib")
#test2 <- read_orcid("0000-0002-2140-5352")
test2 <- read_orcid("0000-0002-9341-7985")
test3 <- read_pubmed("Rob Hyndman[AU] OR RJ Hyndman[AU]")
test4 <- read_scholar("uERvKpYAAAAJ")

