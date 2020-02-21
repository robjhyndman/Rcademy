warn_if_journal_missing <- function(journal) {
  if (any(is.na(journal))) {
    warning("There are missing journal entries.")
  }
}
