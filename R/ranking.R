# Combine list of publications against journal rankings
# Options for ABDC, CORE and SCIMAGOJR

#' Find rankings of journals from Scimago, Core or ABDC. Fuzzy matching is used to
#' find
#'
#' @param journal A character vector containing journal names.
#' @param source Which journal rankings list to use?
#'
#' @return A character vector of the same length as `journal` containing rankings.
#'
#' @author Rob J Hyndman
#' @examples
#'
#' \dontrun{
#' mypubs <- read_pubmed("Rob Hyndman")
#' mypubs <- mypubs %>%
#'   mutate(
#'     abdc_ranking = ranking(journal, source="abdc"),
#'     core_ranking = ranking(journal, source="core"),
#'     scimago_ranking = ranking(journal, source="scimago")
#'   )
#' }
#'
#' @export
#'

ranking <- function(journal, source=c("scimagojr","abdc","core")) {
  source <- match.arg(source)
  if(source=='abdc')
    jrankings <- abdc
  else if(source=='core')
    jrankings <- core
  else if(source=='scimagojr')
    jrankings <- scimagojr
  else
    stop("Unknown rankings")

  mydf <- tibble::tibble(journal=journal, ranking=NA_character_)
  miss <- is.na(mydf$journal)
  fix <- fuzzyjoin::stringdist_left_join(mydf[!miss,], jrankings, by='journal',
                                    ignore_case=TRUE, distance_col='distance')
  fix$distance[is.na(fix$distance)] <- 0
  fix <- fix[fix$distance==0,]
  mydf$ranking[!miss] <- fix$rank
  return(mydf$ranking)
}

