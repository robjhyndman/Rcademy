#' @keywords internal
"_PACKAGE"

#' @importFrom graphics title
#' @importFrom stats complete.cases na.omit
#' @importFrom utils page tail write.csv
#' @importFrom dplyr mutate select
#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`
NULL

if (getRversion() >= "2.15.1") utils::globalVariables(c("."))
globalVariables(
  c(
    "abdc",
    "core",
    "core_journals",
    "era2010",
    "monash",
    "scimago",
    "conference",
    "distance",
    "sjr_best_quartile",
    "year",
    "journal-title.value",
    "publication-date.year.value",
    "type",
    "title.title.value",
    "bind_rows",
    "journal",
    "title.x",
    "lowertitle"
  )
)
