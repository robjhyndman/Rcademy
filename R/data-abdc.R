#' ABDC Journal Quality List
#'
#' This is a dataset that contains the quality list of rankings of the
#'   Australian Business Deans Council (ABDC). You can read more about this list
#'   [here](https://abdc.edu.au/abdc-journal-quality-list/).
#'
#' Format: a data frame with `r NROW(abdc)` observations on the following 7 variables:
#' \describe{
#'   \item{`title`: }{Title of the journal}
#'   \item{`publisher`: }{Publishing house}
#'   \item{`issn`: }{International Standard Serial Number}
#'   \item{`issn_online`: }{ISSN Online - as ISSN, but for the online, rather
#'         than print version}
#'   \item{`year_inception`: }{Year the journal started}
#'   \item{`field_of_research`: }{Field of Research Code as provided by the
#'         Australian Bureau of Statistics}
#'   \item{`rank`: }{In order of best to lowest rank: A*, A, B, or C}
#'  }
#' @name abdc
#' @docType data
#' @usage data(abdc)
#' @source \url{https://abdc.edu.au/abdc-journal-quality-list/}
#' @keywords datasets
#' @examples
#' library(dplyr)
#' abdc |>
#'   filter(field_of_research == "0104") |>
#'   arrange(rank)
"abdc"
