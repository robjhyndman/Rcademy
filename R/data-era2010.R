#' ERA2010 Journal List
#'
#' This is a dataset that contains the list of journal rankings from
#' the ARC Excellence in Research for Australia 2010 round.
#'
#' Format: a data frame with `NROW(era2010)` rows and the following 4 variables:
#' \describe{
#'   \item{`eraid`: }{ERA ID of the journal}
#'   \item{`title`: }{Title of the journal}
#'   \item{`issn`: }{International Standard Serial Number}
#'   \item{`field_of_research`: }{Field of Research Code as provided by the
#'         Australian Bureau of Statistics}
#'   \item{`rank`: }{In order of best to lowest rank: A*, A, B, or C}
#'  }
#' @name era2010
#' @docType data
#' @usage data(era2010)
#' @source \url{https://www.righttoknow.org.au/request/journal_list_relating_to_the_201}
#' @keywords datasets
#' @examples
#' library(dplyr)
#' era2010 |>
#'   filter(field_of_research == "0104") |>
#'   arrange(rank)
"era2010"
