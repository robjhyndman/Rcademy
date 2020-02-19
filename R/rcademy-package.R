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

if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
globalVariables(
    c("abdc",
      "core",
      "scimagojr",
      "year")
)
