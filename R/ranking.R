#' Find rankings of journals from the ABDC, ERA2010, CORE, SCImago or Monash lists.
#'
#' Fuzzy matching is used to find the requested journal from the ABDC, ERA2010, CORE,
#'   SCImago or Monash lists. For more information on each of these, see:
#'   \itemize{
#'   \item{\cite{\link{abdc}}: }{for more information on the ABDC list}
#'   \item{\cite{\link{era2010}}: }{for more information on the ERA2010 list}
#'   \item{\cite{\link{core}}: }{for more information on the CORE list}
#'   \item{\cite{\link{scimago}}: }{for more information on the SCImago list}
#'   \item{\cite{\link{monash}}: }{for more information on the Monash list}
#'   }
#'
#' @param title A character vector containing (partial) journal names.
#' @param source A character string indicating which ranking data base to use. Default \code{"all"}.
#' @param only_best A logical variable. If \code{TRUE}, only returns the best match found.
#' @param return_dist A logical variable. If \code{TRUE}, returns the distance between the \code{title} and the matches found.
#' @param fuzzy Should fuzzy matching be used. If \code{FALSE}, partial exact matching is used.
#' Otherwise, full fuzzy matching is used.
#' @param warning A logical value indicating whether to return warnings when `title` contains
#' missing values.
#' @param ... Other arguments are passed to \code{agrepl} (if \code{fuzzy} is \code{TRUE}), or \code{grepl} otherwise.
#'
#' @return The `rank_xxx()` functions return a character vector of the same length as `title` containing
#'   the rankings from the specified `source` database. The `journal_ranking()` function returns a tibble
#'   containing the matching journal titles and associated rankings from the specified database.
#'
#' @author Rob J Hyndman
#' @name rank_scimago
#' @examples
#' # Return ranking for individual journals or conferences
#' rank_abdc("Annals of Statistics")
#' rank_era2010("Biometrika")
#' rank_core("International Conference on Machine Learning")
#' rank_scimago("International Journal of Forecasting")
#' rank_monash("Annals")
#'
#' # Add rankings to a data frame of publications
#' library(dplyr)
#' njtpubs %>%
#'   mutate(scimago = rank_scimago(journal, warning = FALSE))
#'
#' # Return rankings from all sources for journals that match a search string
#' journal_ranking("Forecasting")
#' @export
rank_abdc <- function(title, fuzzy = TRUE, warning = FALSE) {
  fuzzy_ranking(title, source = "abdc", fuzzy=fuzzy, warning=warning)
}

#' @rdname rank_scimago
#' @export
rank_era2010 <- function(title, fuzzy = TRUE, warning = FALSE) {
  fuzzy_ranking(title, source = "era2010", fuzzy=fuzzy, warning=warning)
}

#' @rdname rank_scimago
#' @export
rank_scimago <- function(title, fuzzy = TRUE, warning = FALSE) {
  fuzzy_ranking(title, source = "scimago", fuzzy=fuzzy, warning=warning)
}

#' @rdname rank_scimago
#' @export
rank_core <- function(title, fuzzy = TRUE, warning = FALSE) {
  fuzzy_ranking(title, source = "core", fuzzy=fuzzy, warning=warning)
}

#' @rdname rank_scimago
#' @export
rank_monash <- function(title, fuzzy = TRUE, warning = FALSE) {
  fuzzy_ranking(title, source = "monash", fuzzy=fuzzy, warning=warning)
}

# Find and return ranking of closest journals using fuzzy matching
fuzzy_ranking <- function(title, source, fuzzy = TRUE, warning = FALSE, ...) {
  miss <- is.na(title)
  if (warning & any(miss)) {
    warning("There are missing journal entries.")
  }
  source <- tolower(source)
  if(!(source %in% c("abdc","era2010","core","scimago","monash"))) {
    stop(glue::glue("You have provided {source}, however we do not \\
      have that ranking system, only abdc, era2010, core, and scimago."))
  }
  # Find all matches
  ranks <- rep(NA_character_, length(title))
  for(i in seq_along(title)) {
    if(!is.na(title[i])) {
      suppressWarnings(
        jrankings <- journal_ranking(title[i], source=source, fuzzy=fuzzy, only_best=TRUE, ...)
      )
      if(length(jrankings) > 0)
        ranks[i] <- as.character(jrankings$rank[1])
    }
  }
  return(ranks)
}

#' @name rank_scimago
#' @export
journal_ranking <- function(
  title,
  source = c("all","abdc","era2010","core","scimago","monash"),
  fuzzy=TRUE,
  only_best = FALSE,
  return_dist = FALSE,
  ...) {
  source <- match.arg(source)
  if(source == "all") {
    # Combine all data sources
    jrankings <- dplyr::bind_rows(
      abdc %>% mutate(source = "ABDC", rank = as.character(rank)) %>% dplyr::select(title, rank, source),
      era2010 %>% mutate(source = "ERA2010", rank = as.character(rank)) %>% dplyr::select(title, rank, source),
      core %>% mutate(source = "CORE", rank = as.character(rank)) %>% dplyr::select(title, rank, source),
      core_journals %>% mutate(source = "CORE", rank = as.character(rank)) %>% dplyr::select(title, rank, source),
      scimago %>% mutate(source = "SCIMAGO", rank = as.character(sjr_best_quartile)) %>% dplyr::select(title, rank, source),
      monash %>% mutate(source = "MONASH", rank = as.character(rank)) %>% dplyr::select(title, rank, source),
    )
  } else if(source == "abdc") {
    jrankings <- abdc %>% mutate(source = "ABDC")
  } else if(source == "era2010") {
    jrankings <- era2010 %>% mutate(source = "ERA2010")
  } else if(source == "monash") {
    jrankings <- monash %>% mutate(source = "MONASH")
  } else if(source == "core") {
    jrankings <- dplyr::bind_rows(
      core %>% mutate(source = "CORE"),
      core_journals %>% mutate(source = "CORE") %>% dplyr::select(title, rank, source)
    )
  } else if(source == "scimago") {
    jrankings <- scimago %>%
      dplyr::mutate(rank = sjr_best_quartile) %>%
      mutate(source = "SCIMAGO")
  } else
    stop("Unknown source. This shouldn't happen.")

  jrankings <- jrankings %>%
    dplyr::select(title, rank, source) %>%
    dplyr::mutate(title = clean_journal_names(title)) %>%
    dplyr::arrange(title, source)
  if(fuzzy) {
    idx <- agrepl(title, jrankings$title, ignore.case = TRUE, ...)
  } else {
    idx <- grepl(title, jrankings$title, ignore.case=TRUE, ...)
  }
  jrankings <- jrankings[idx,]
  # return a warning if it hasn't found a single journal
  if(!any(idx)) {
    warning("No journals found")
  } else if(return_dist | only_best) {
    dist <- c(utils::adist(title, jrankings$title, ignore.case = TRUE, ...))
    jrankings <- jrankings %>% mutate(dist = dist)
    if(only_best)
      jrankings <- jrankings[dist == min(dist),]
    if(!return_dist)
      jrankings <- jrankings %>% dplyr::select(-dist)
  }
  return(jrankings)
}
