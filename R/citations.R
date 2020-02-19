#' Match list of citations with Google Scholar citation data
#'
#' @description Add Google Scholar citation information for items in file of publications.
#' Uses fuzzy matching on title. Keeps non-matches for manual curation.
#'
#' @param mypubs A data frame of publications.
#' @param id Google Scholar ID as a text string.
#'
#' @return A data frame of matched and non-matched publications from both inputs.
#'
#' @author Belinda K Fabian
#'
#' @export
#'
#' @importFrom fuzzyjoin stringdist_full_join
#'
#' @examples
#'
#' \dontrun{
#'
#' mypubs <- read_pubmed("Rob Hyndman")
#' matchedPubs <- match_citations(myPubs, "vamErfkAAAAJ")
#'}
#'

match_citations <- function(mypubs, id){
  # Remove missing years
  scholar <- read_scholar(id) %>% filter(!is.na(year))
  mypubs <- mypubs %>% filter(!is.na(year))
  joined <- fuzzyjoin::stringdist_left_join(mypubs, scholar,
              by = c(title = "title", year = "year"),
              max_dist = 1)
  return(joined)
}
