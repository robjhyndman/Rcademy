#' CORE (Computing Research and Education) lists of conference and journal rankings
#'
#' Two datasets are provided: `core` and `core_journals`, which contains lists of
#' conference and journal rankings respectively, according to the CORE executive committee.
#' These are used in [rank_core()]. The details of the CORE organisation,
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
#' Format of `core`: A data frame with `NROW(core)` observations and two variables:
#' \describe{
#'   \item{`title:`}{Title of the conference}
#'   \item{`rank:`}{Conferences are assigned to one of the following categories:
#'     \itemize{
#'      \item{A*: flagship conference, a leading venue in a discipline area}
#'      \item{A: excellent conference, and highly respected in a discipline area}
#'      \item{B: good conference, and well regarded in a discipline area}
#'      \item{C: other ranked conference venues that meet minimum standards}
#'     }
#'   }
#' }
#' Format of `core_journals`: A data frame with `NROW(core_journals)` observations and five variables:
#' \describe{
#'   \item{`title:`}{Title of the journal}
#'   \item{`field_of_research`: }{Field of Research Code as provided by the
#'         Australian Bureau of Statistics}
#'   \item{`issn`: }{International Standard Serial Number}
#'   \item{`rank`: }{In order of best to lowest rank: A*, A, B, or C}
#' }
#' @name core
#' @docType data
#' @source \url{https://www.core.edu.au/conference-portal}
#' \url{}
#' @keywords datasets
#' @examples
#' core
#' core_journals
"core"

#' @rdname core
"core_journals"
