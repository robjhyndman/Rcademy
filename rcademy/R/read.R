read_bib <- function(filename) {
  filename %>%
    ReadBib() %>%
    as_tibble() %>%
    mutate(
      title = stringr::str_remove_all(title, "[{}]"),
    )
}

read_orcid <- function(id) {
  id %>%
    orcid_id() %>%
    works()
}


read_scholar <- function(id) {

}

read_orcid("0000-0002-9341-7985")


#ranking(journal,  source=c("abcd","scimagojr","core"))
