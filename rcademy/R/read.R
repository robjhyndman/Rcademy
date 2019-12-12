read_bib <- function(filename) {
  filename %>%
    ReadBib() %>%
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
                          autofill = TRUE)
}

read_scholar <- function(id) {

}

# Tests
test1 <- read_orcid("0000-0002-9341-7985")
test2 <- read_pubmed("Lucy D'Agostino McGowan[AU] OR LD McGowan[AU]")

#ranking(journal,  source=c("abcd","scimagojr","core"))
