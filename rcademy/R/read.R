#' @importFrom RefManageR ReadBib
#' @importFrom easyPubMed get_pubmed_ids fetch_pubmed_data table_articles_byAuth
#' @importFrom stringr str_remove_all str_replace_all str_trim
#' @importFrom scholar get_publications
#' @importFrom rorcid works orcid_id identifiers
#' @importFrom tibble as_tibble
#' @importFrom magrittr `%>%`
#'
NULL
#' Read bibliographies
#'
#' Create tables of publications from bib files, or from PubMed, Orcid or Google Scholar

#' @param filename The filename of a bib file (i.e., in BibTeX format)
#'
#' @return A tibble containing one row per publication. Columns include title, authors, year, journal, etc.
#'
#' @export
#'
#' @author Rob J Hyndman
#' @examples
#'
#' \dontrun{
#'
#' mypubs <- read_bib("mypubs.bib")
#' mypubs <- read_pubmed("Rob Hyndman")
#' mypubs <- read_scholar("vamErfkAAAAJ")
#' mypubs <- read_orcid("0000-0002-9341-7985")
#' }

read_bib <- function(filename) {
  filename %>%
    RefManageR::ReadBib(check = FALSE) %>%
    as_tibble() %>%
    mutate(
      title = stringr::str_remove_all(title, "[{}]"),
      title = stringr::str_replace_all(title, "\\&", "and"),
      journal = stringr::str_replace_all(journal, "\\\\&", "and")
    )
}

#' @export
#' @rdname read_bib
#' @param query A character string containing a search query to pass to PubMed
#'

read_pubmed <- function(query) {
  query %>%
    easyPubMed::get_pubmed_ids() %>%
    easyPubMed::fetch_pubmed_data(encoding = "ASCII") %>%
    easyPubMed::table_articles_byAuth(
      included_authors = "first",
      max_chars = 0,
      autofill = FALSE
    ) %>%
    as_tibble() %>%
    pull(doi) %>%
    unique() %>%
    crossref_table()
}

# read_scholar <- function(user) {
#   df <- gcite::gcite_user_info(user = user, secure = FALSE)$paper_df
#   colnames(df)[2] <- "date"
#   df %>%
#     mutate(
#       year = lubridate::year(anytime::anydate(date))
#     ) %>%
#     as_tibble()
# }


#' @export
#' @rdname read_bib
#' @param id A character string specifying the Google Scholar ID or Orcid ID

read_scholar <- function(id) {
  scholar::get_publications(id) %>%
    dplyr::mutate(
      author = author %>% as.character() %>% stringr::str_trim(),
    )
}

#' @export
#' @rdname read_bib

read_orcid <- function(id) {

  # Read works from orcid and store as a tibble
  d <- works(orcid_id(orcid = id))
  if (nrow(d) == 0) {
    return(d)
  }

  # Get DOIs
  dois <- identifiers(d, type = "doi") # get DOIs, not available for all papers
  dois <- unique(tolower(dois))
  #  dois <- dois[duplicated(tolower(dois)) == FALSE] # remove duplicates
  dois <- remove_f1000_dois(dois)

  crossref_table(dois)
}


