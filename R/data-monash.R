#' Monash Business School Journal Quality List
#'
#' This is a dataset that contains the list of quality journal rankings from the
#'   Monash Business School. In most cases, it follows
#'   ABDC with A* equal to Group 1 and A equal to Group 2.
#'   The "Group 1+" category contains a small set of the highest rank journals.
#'
#' Format: a data frame with `NROW(monash)` observations on the following 2 variables:
#' \describe{
#'   \item{`title`: }{Title of the journal}
#'   \item{`rank`: }{In order of best to lowest rank: Group 1+, Group 1, Group 2}
#'  }
#' @name monash
#' @docType data
#' @usage data(monash)
#' @source Monash Business School
#' @keywords datasets
#' @examples
#' library(dplyr)
#' library(stringr)
#' monash |>
#'   filter(str_detect(title, "Statist")) |>
#'   arrange(rank)
"monash"
