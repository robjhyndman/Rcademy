#' @export
#' @rdname compute_hindex
#' @param scholar_citations List of citations for all publications
#' @examples
#' compute_hindex(read_scholar("XSyW00YAAAAJ")$cites))
#'

# Get tibble of all altemtric
compute_hindex <- function(scholar_citations) {

  scholar_citations
  x <- sort(scholar_citations, decreasing = TRUE)
  h <- 0
  while (h < x[h+1]) {
    #print(c(h,x[h]))
    h = h+1
  }
  h

}
