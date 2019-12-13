# Combine list of publications against journal rankings
# Options for ABDC, CORE and SCIMAGOJR

ranking <- function(journal, source=c("scimagojr","abdc","core")) {
  source <- match.arg(source)
  if(source=='abdc')
    jrankings <- abdc
  else if(source=='core')
    jrankings <- core
  else if(source=='scimagojr') {
    jrankings <- sjrdata::sjr_journals
    colnames(jrankings)[4] <- "journal"
    jrankings$rank <- jrankings$sjr_best_quartile
  } else
    stop("Unknown rankings")

  mydf <- tibble::tibble(journal=journal, ranking="")
  miss <- is.na(mydf$journal)
  fix <- fuzzyjoin::stringdist_left_join(mydf[!miss,], jrankings, by='journal')
  mydf$ranking[!miss] <- fix$rank
  return(mydf$ranking)
}

# ranking(df$journal, source='abdc')
# ranking(df$journal, source='core')
# ranking(df$journal, source='sci')
