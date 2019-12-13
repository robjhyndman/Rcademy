#' Compute h-index given papers and citations
#'
#' Take a numerical vector of citation counts and return the h-index
#'
#' @export
#' @rdname compute_hindex
#' @param citations List of citations for all publications
#' @return numerical value
#' @examples
#' \dontrun{
#' compute_hindex(read_scholar("XSyW00YAAAAJ")$cites)
#' }
#'

# Get tibble of all altemtric
compute_hindex <- function(citations) {
  x <- sort(citations, decreasing = TRUE)
  return(min(x[x >= seq(x)]))
}
