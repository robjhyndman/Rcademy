#' CORE (Computing Research and Education) list of conference rankings
#'
#' A dataset, `core` is provided, which contains the list of conference rankings
#'   according to the CORE executive committee. It is mostly used in
#'   the function, [ranking()]. The details of the CORE organisation,
#'   and its procedure for ranking is provided below.
#'
#' CORE is an association of university departments of computer science in
#'   Australia and New Zealand. Prior to 2004 it was known as the Computer
#'   Science Association, CSA.
#'
#' The CORE Conference Ranking provides assessments of major conferences in the
#'   computing disciplines. The rankings are managed by the CORE Executive
#'   Committee, with periodic rounds for submission of requests for addition or
#'   reranking of conferences. Decisions are made by academic committees based
#'   on objective data requested as part of the submission process. Conference
#'   rankings are determined by a mix of indicators, including citation rates,
#'   paper submission and acceptance rates, and the visibility and research
#'   track record of the key people hosting the conference and managing its
#'   technical program. A more detailed statement categorizing the ranks A*, A,
#'   B, and C can be found [here](http://bit.ly/core-rankings).
#'
#' Format: A data frame with 972 observations and two variables:
#' \itemize{
#'   \item{`conference:`}{ Character with all}
#'   \item{`rank:`}{ Conferences are assigned to one of the following categories:
#'     \itemize{
#'      \item{A*: flagship conference, a leading venue in a discipline area}
#'      \item{A: excellent conference, and highly respected in a discipline area}
#'      \item{B: good conference, and well regarded in a discipline area}
#'      \item{C: other ranked conference venues that meet minimum standards}
#'     }
#'   }
#'   }
#' @name core
#' @docType data
#' @usage data(core)
#' @source \url{http://portal.core.edu.au/conf-ranks/?search=&by=all&source=CORE2021}
#' @keywords datasets
#' @examples
#' core
"core"

