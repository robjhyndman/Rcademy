#' @keywords internal
"_PACKAGE"

#' @importFrom graphics title
#' @importFrom stats complete.cases na.omit
#' @importFrom utils page tail write.csv
#' @importFrom dplyr mutate select
#' @importFrom magrittr `%>%`
NULL

#' Australian Business Deans Council Rankings
#'
#' Journal rankings according to the Australian Business Deans Council (ABDC)
#'
#'
#' @format tibble
#' @source Australian Business Deans Council
#' @keywords datasets
#' @examples
#' abdc %>%
#'   filter(`Field of Research` == "0104") %>%
#'   arrange(rank)
#'
"abdc"
