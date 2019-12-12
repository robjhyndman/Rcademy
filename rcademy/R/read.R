# Functions to read bibliographies

read_bib <- function(filename, check=FALSE) {
  filename %>%
    RefManageR::ReadBib(check = check) %>%
    as_tibble() %>%
    mutate(
      title = stringr::str_remove_all(title, "[{}]"),
    )
}

read_pubmed <- function(query) {
  query %>%
    easyPubMed::get_pubmed_ids() %>%
    easyPubMed::fetch_pubmed_data(encoding = "ASCII") %>%
    easyPubMed::table_articles_byAuth(included_authors = "all",
                          max_chars = 100,
                          autofill = TRUE) %>%
    as_tibble()
}

read_scholar <- function(id) {

}

# Tests
test1 <- read_bib("data-raw/rjhpubs.bib")
test2 <- read_orcid("0000-0002-2140-5352")
test3 <- read_pubmed("Rob Hyndman[AU] OR RJ Hyndman[AU]")

