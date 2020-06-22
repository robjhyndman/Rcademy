#' Find rankings of journals from the ABDC, CORE, or SCImago lists.
#'
#' Fuzzy matching is used to find the requested journal from the ABDC, CORE,
#'   or SCImago lists. For more information on each of these, see:
#'   \itemize{
#'   \item{\cite{\link{abdc}}: }{for more information on the abdc list}
#'   \item{\cite{\link{core}}: }{for more information on the core list}
#'   \item{\cite{\link{scimago}}: }{for more information on the scimago list}
#'   }
#'
#' @param journal A character vector containing journal names.
#' @param warning A logical value indicating whether to return warnings when `journal` contains
#' missing values.
#'
#' @return A character vector of the same length as `journal` containing
#'   rankings.
#'
#' @author Rob J Hyndman, Nicholas Tierney
#' @name rank_journal
#' @examples
#' # Look up individual journals
#' rank_abdc("Annals of statistics")
#' rank_core("International Conference on Machine Learning")
#' rank_scimago("International Journal of Forecasting")
#'
#' # Add rankings to a data frame of publications
#' library(dplyr)
#' njtpubs %>%
#'   mutate(
#'     scimago_ranking = rank_scimago(journal, warning = FALSE)
#'   )
#' @export
rank_abdc <- function(journal, warning = FALSE) {
  ranking(journal, source = "abdc", warning)
}

#' @rdname rank_journal
#' @export
rank_scimago <- function(journal, warning = FALSE) {
  ranking(journal, source = "scimago", warning)
}

#' @rdname rank_journal
#' @export
rank_core <- function(journal, warning = FALSE) {
  ranking(journal, source = "core", warning)
}


ranking <- function(journal, source, warning = FALSE) {
  if (warning) {
    warn_if_journal_missing(journal)
  }

  jr_rank <- tibble::tibble(
    journal = journal,
    ranking = NA_character_
  )

  miss <- is.na(journal)

  # source <- match.arg(source)
  if (source == "abdc") {
    jrankings <- abdc
  }
  else if (source == "core") {
    jrankings <- core %>%
      dplyr::rename(journal = conference)
  }
  else if (source == "scimago") {
    jrankings <- scimago %>%
      dplyr::rename(journal = title)
  }
  else {
    stop(glue::glue("You have provided {source}, however we do not \\
                    have that ranking system, only abdc, core, and scimago."))
  }

  # Change "&" and "and", and omit "the" and "of"
  # Also omit anything in parentheses
  jrankings <- jrankings %>%
    mutate(
      journal = stringr::str_replace_all(journal, "\\sthe\\s", " "),
      journal = stringr::str_replace_all(journal, "^The\\s", " "),
      journal = stringr::str_replace_all(journal, "\\sof\\s", " "),
      journal = stringr::str_replace_all(journal, "&", "and"),
      journal = stringr::str_remove_all(journal, "\\([A-Za-z\\s]*\\)"),
      journal = stringr::str_trim(journal)
    )
  jr_rank <- jr_rank %>%
    mutate(
      journal = stringr::str_replace_all(journal, "\\sthe\\s", " "),
      journal = stringr::str_replace_all(journal, "^The\\s", " "),
      journal = stringr::str_replace_all(journal, "\\sof\\s", " "),
      journal = stringr::str_replace_all(journal, "&", "and"),
      journal = stringr::str_remove_all(journal, "\\([A-Za-z\\s]*\\)"),
      journal = stringr::str_trim(journal)
    )

  jr_rank_join <- fuzzyjoin::stringdist_left_join(
    x = jr_rank[!miss, ],
    y = jrankings,
    by = "journal",
    ignore_case = TRUE,
    distance_col = "distance",
    max_dist = 10,
    method = "lcs"
  ) %>%
    # cast distance to integer
    dplyr::mutate(
      distance = as.integer(distance),
      # set distance measures to 0 if missing
      distance = dplyr::if_else(
        condition = is.na(distance),
        true = 0L,
        false = distance
      )
    ) %>%
    # Find closest match
    rename(journal = journal.x) %>%
    select(journal, rank, distance) %>%
    group_by(journal) %>%
    filter(distance == min(distance)) %>%
    ungroup() %>%
    unique() %>%
    group_by(journal) %>%
    filter(rank == min(rank)) %>%
    ungroup()

  # now return the ranking
  final_rank <- jr_rank %>%
    dplyr::left_join(jr_rank_join, by = "journal")

  if (source == "scimago") {
    final_rank <- dplyr::mutate(final_rank,
      ranking = factor(sjr_best_quartile,
        levels = c(
          "Q1",
          "Q2",
          "Q3",
          "Q4"
        )
      )
    )
  } else {
    final_rank <- dplyr::mutate(final_rank,
      ranking = factor(rank,
        levels = c(
          "A*",
          "A",
          "B",
          "C"
        )
      )
    )
  }

  # return a warning if it hasn't found a single journal
  if (all(is.na(final_rank$ranking))) {
    warning("No journals found")
  }
  return(final_rank$ranking)
}
