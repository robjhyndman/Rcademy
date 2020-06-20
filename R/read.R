#' @importFrom RefManageR ReadBib
#' @importFrom easyPubMed get_pubmed_ids fetch_pubmed_data table_articles_byAuth
#' @importFrom stringr str_remove_all str_replace_all str_trim
#' @importFrom scholar get_publications
#' @importFrom rorcid works orcid_id identifiers
#' @importFrom tibble as_tibble
#' @importFrom tidyr unnest
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
#' mypubs <- read_pubmed("Huang Ly Tong")
#' mypubs <- read_scholar("EUdX6oIAAAAJ")
#' mypubs <- read_orcid("0000-0002-8462-0105")
#' }
#'
#' @export
#'

read_bib <- function(filename) {
  df <- RefManageR::ReadBib(filename, check = FALSE)
  df <- as_tibble(df)
  dplyr::mutate(df,
    title = stringr::str_remove_all(df$title, "[{}]"),
    title = stringr::str_replace_all(df$title, "\\\\", ""),
    journal = stringr::str_replace_all(df$journal, "\\\\", "")
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
  dois <- unique(tolower(df$doi))
  dois <- dois[dois != ""]

  dois_to_papers(dois)
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
  tibble::as_tibble(df) %>%
    dplyr::mutate_if(is.factor, as.character)
}

#' @rdname read_bib
#' @export

read_orcid <- function(id) {

  # Read works from orcid and store as a tibble
  d <- rorcid::orcid_id(orcid = id) %>%
    rorcid::works()
  if (nrow(d) == 0) {
    return(as_tibble(d))
  }

  # Get DOIs where they exist
  dois <- rorcid::identifiers(d, type = "doi") # get DOIs, not available for all papers
  dois <- unique(tolower(dois))
  #  dois <- dois[duplicated(tolower(dois)) == FALSE] # remove duplicates
  dois <- remove_f1000_dois(dois)
  dois <- dois[dois != ""]

  output_with_dois <- suppressWarnings(dois_to_papers(dois)) %>%
    tibble::as_tibble()

  # Now find details for papers without dois
  output_no_dois <- d %>%
    tibble::as_tibble() %>%
    dplyr::transmute(
      journal = `journal-title.value`,
      title = `title.title.value`,
      year = as.numeric(`publication-date.year.value`),
      type = type,
    ) %>%
    dplyr::anti_join(output_with_dois, by = c("journal", "title", "year", "type"))

  dplyr::bind_rows(output_with_dois, output_no_dois) %>%
    dplyr::arrange(year) %>%
    dplyr::mutate(
      title = clean_hyphens(title)
    )
}

#' Find Altmetrics
#'
#' Get a tibble of all altmetrics given a list of DOIs
#'
#' @export
#' @rdname get_altmetrics
#' @param data  A data frame or tibble containing a bibliography.
#' @param doi  The column containing DOI values
#' @return A tibble of altmetrics
#' @examples
#' \dontrun{
#' njtpubs %>%
#'   get_altmetrics(doi)
#' }
#'
get_altmetrics <- function(data, doi) {
  dois <- dplyr::pull(data, {{ doi }})
  dois <- na.omit(dois)
  alm <- function(x) {
    z <- try(rAltmetric::altmetrics(doi = x), silent = TRUE)
    if ("try-error" %in% class(z)) {
      return(NULL)
    } else {
      return(rAltmetric::altmetric_data(z))
    }
  }
  results <- purrr::map_dfr(as.list(dois), alm) %>%
    as_tibble() %>%
    dplyr::mutate_at(dplyr::vars(tidyr::starts_with("cited")), as.numeric)
  return(results)
}
