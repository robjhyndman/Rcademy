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
#'
#' @param filename The filename of a bib file (i.e., in BibTeX format)
#'
#' @return A tibble containing one row per publication. Columns include title, authors, year, journal, etc.
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
#'
#' @export
#'

read_bib <- function(filename) {
  df <- RefManageR::ReadBib(filename, check = FALSE)
  df <- as_tibble(df)
  dplyr::mutate(df,
      title = stringr::str_remove_all(df$title, "[{}]"),
      title = stringr::str_replace_all(df$title, "\\\\&", "and"),
      journal = stringr::str_replace_all(df$journal, "\\\\&", "and"),
      journal = stringr::str_replace_all(df$journal, "\\\\$", "$")
  )
}

#' @rdname read_bib
#' @param query A character string containing a search query to pass to PubMed
#' @export
#'

read_pubmed <- function(query) {
  df <- query %>%
    easyPubMed::get_pubmed_ids() %>%
    easyPubMed::fetch_pubmed_data(encoding = "ASCII") %>%
    easyPubMed::table_articles_byAuth(
      included_authors = "first",
      max_chars = 0,
      autofill = FALSE
    )
  dois_to_papers(unique(df$doi))
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

#' @rdname read_bib
#' @param id A character string specifying the Google Scholar ID or Orcid ID
#' @export

read_scholar <- function(id) {
  df <- scholar::get_publications(id)
  df$author <- stringr::str_trim(as.character(df$author))
  df
}

#' @rdname read_bib
#' @export

read_orcid <- function(id) {

  # Read works from orcid and store as a tibble
  d <- rorcid::works(rorcid::orcid_id(orcid = id))
  if (nrow(d) == 0) {
    return(d)
  }

  # Get DOIs
  dois <- rorcid::identifiers(d, type = "doi") # get DOIs, not available for all papers
  dois <- unique(tolower(dois))
  #  dois <- dois[duplicated(tolower(dois)) == FALSE] # remove duplicates
  dois <- remove_f1000_dois(dois)

  dois_to_papers(dois)
}




#' @export
#' @rdname read_altmetrics
#' @param doi_list A list of DOI strings for which to return a tibble of Altmetrics

# Get tibble of all altemtric
read_altmetrics <- function(doi_list) {

  alm <- function(x)  rAltmetric::altmetrics(doi = ids) %>% altmetric_data()
  results <- purrr::pmap(doi_list, alm)
  tidyr::unnest(tibble(results),cols=c(results))

}
