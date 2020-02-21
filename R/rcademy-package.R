#' @keywords internal
"_PACKAGE"

#' @importFrom graphics title
#' @importFrom stats complete.cases na.omit
#' @importFrom utils page tail write.csv
#' @importFrom dplyr mutate select
#' @importFrom magrittr `%>%`
NULL

#' @export
magrittr::`%>%`

if (getRversion() >= "2.15.1") utils::globalVariables(c("."))
globalVariables(
  c(
    "abdc",
    "core",
    "scimago",
    "conference",
    "distance",
    "sjr_best_quartile",
    "year",
    "journal-title.value",
    "publication-date.year.value",
    "type",
    "title.title.value"
  )
)
