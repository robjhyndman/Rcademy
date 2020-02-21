#' Obtain citations based on DOIs using CrossRef data
#'
#' @description Return CrossRef citation information for items in
#' data frame of publications using DOIs.
#'
#' @param doi Unquoted column containing DOIs
#'
#' @return A vector of citation counts from CrossRef OpenURL
#'
#' @author Rob J Hyndman
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' mypubs <- read_orcid("0000-0002-2140-5352") %>%
#'   mutate(cr_cites = citations(doi))
#'}
#'

citations <- function(doi) {
  miss <- is.na(doi)
  cites <- rep(NA, length(doi))
  cites[!miss] <- rcrossref::cr_citation_count(doi[!miss])$count
  return(cites)
}

