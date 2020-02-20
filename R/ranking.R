# Combine list of publications against journal rankings
# Options for ABDC, CORE and SCIMAGOJR

#' Find rankings of journals from Scimago, Core or ABDC. Fuzzy matching is used to
#' find the requested journal.
#'
#' @param journal A character vector containing journal names.
#' @param source Which journal rankings list to use?
#'
#' @return A character vector of the same length as `journal` containing
#'   rankings.
#'
#' @author Rob J Hyndman, Nicholas Tierney
#' @examples
#'
#' \dontrun{
#' mypubs <- read_pubmed("Rob Hyndman")
#' mypubs <- mypubs %>%
#'   mutate(
#'     abdc_ranking = ranking(journal, source="abdc"),
#'     core_ranking = ranking(journal, source="core"),
#'     scimago_ranking = ranking(journal, source="scimagojr")
#'   )
#' }
#' @export
ranking <- function(journal, source) {

  warn_if_journal_missing(journal)

  jr_rank <- tibble::tibble(journal = journal,
                            ranking = NA_character_)

  miss <- is.na(journal)

  # source <- match.arg(source)
  if (source == 'abdc') {
    jrankings <- abdc
  }
  else if (source == 'core') {
    jrankings <- core %>%
      dplyr::rename(journal = conference)
  }
  else if (source == 'scimagojr') {
    jrankings <- scimagojr %>%
      dplyr::rename(journal = title)
  }
  else {
    stop(glue::glue("You have provided {source}, however we do not \\
                    have that ranking system, only abdc, core, and scimagojr."))
  }

  jr_rank_join <- fuzzyjoin::stringdist_left_join(
    x = jr_rank[!miss, ],
    y = jrankings,
    by = "journal",
    ignore_case = TRUE,
    distance_col = "distance"
    ) %>%
    # cast distance to integer
    dplyr::mutate(distance = as.integer(distance),
    # set distance measures to 0 if missing
                  distance = dplyr::if_else(condition = is.na(distance),
                                            true = 0L,
                                            false = distance)) %>%
    # only keep those with exact matches
    dplyr::filter(distance == 0)

  # now return the ranking...but this is fragile if the positions don't match.
  # jr_rank$ranking[!miss] <- jr_rank_join$rank
  final_rank <-  dplyr::left_join(jr_rank,
                                  jr_rank_join,
                                  by = c("journal" = "journal.x"))

  if (source == "scimagojr") {
    final_rank <- dplyr::mutate(final_rank,
                                ranking = factor(sjr_best_quartile,
                                                 levels = c("Q1",
                                                            "Q2",
                                                            "Q3",
                                                            "Q4")))
  }

  if (source != "scimagojr") {
    final_rank <- dplyr::mutate(final_rank,
                                ranking = factor(rank,
                                                 levels = c("A*",
                                                            "A",
                                                            "B",
                                                            "C")))
  }

  # return a warning if it hasn't found a single journal
  if (all(is.na(final_rank$ranking))) {
    warning("No journals found")
  }
    return(final_rank$ranking)
}

#' Find rankings of journals from the ABDC, core, or scimagojr lists.
#'
#' Fuzzy matching is used to find the requested journal from the ABDC, CORE,
#'   or scimagojr lists. For more information on each of these, see:
#'   \itemize{
#'   \item{`?abdc`: }{for more information on the abdc list}
#'   \item{`?core`: }{for more information on the core list}
#'   \item{`?scimagojr`: }{for more information on the scimagojr list}
#'   }
#'
#' @param journal A character vector containing journal names.
#'
#' @return A character vector of the same length as `journal` containing
#'   rankings.
#'
#' @author Rob J Hyndman, Nicholas Tierney
#' @name rank_journal
#' @export
#' @examples
#' rank_abdc("Annals of statistics")
#' rank_core("Annals of statistics")
#' rank_scimagojr("Annals of statistics")
rank_abdc <- function(journal){
  ranking(journal, source = "abdc")
}

#' @rdname rank_journal
#' @export
rank_scimagojr <- function(journal){
  ranking(journal, source = "scimagojr")
}

#' @rdname rank_journal
#' @export
rank_core <- function(journal){
  ranking(journal, source = "core")
}
