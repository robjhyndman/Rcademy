# orcid.R
# Take ORCID ID and make a list of papers
# use rcrossref to get better formatted data
# Original code borrowed from Adrian Barnett. https://github.com/agbarnett/helping.funders
# Rewritten December 2019 by Rob Hyndman

read_orcid <- function(orcid.id) {

  # Read works from orcid and store as a tibble
  d <- works(orcid_id(orcid = orcid.id))
  if (nrow(d) == 0) {
    return(d)
  }

  # Get DOIs
  dois <- identifiers(d, type = "doi") # get DOIs, not available for all papers
  dois <- unique(tolower(dois))
#  dois <- dois[duplicated(tolower(dois)) == FALSE] # remove duplicates
  dois <- remove_f1000_dois(dois)

  crossref_table(dois)
}

# Get nicely formatted data for papers with a DOIs using crossref
crossref_table <- function(dois) {
  cdata.nonbibtex <- cr_works(dois)$data
  colnames(cdata.nonbibtex) <- tolower(colnames(cdata.nonbibtex))

  # Format papers
  papers <- cdata.nonbibtex %>%
    select(issued, created, container.title,
           publisher, title, volume, issue, page, doi, type) %>%
    purrr::pmap_dfr(format_paper) %>%
    mutate(
      title = as.character(title),
      journal = as.character(journal),
      year = as.numeric(as.character(year)),
      volume = as.character(volume),
      issue = as.character(issue),
      pages = as.character(pages),
      doi = as.character(doi)
    )

  return(papers)
}


# remove F1000 DOIs where there is second version (keep latest version)
remove_f1000_dois <- function(dois) {
  not.f1000 <- dois[!str_detect(string = dois, pattern = "f1000")]
  f1000 <- dois[str_detect(string = dois, pattern = "f1000")]
  if (length(f1000) > 0) { # only if some F1000 journals
    split.f1000 <- str_split(f1000, pattern = "\\.", n = Inf, simplify = TRUE) # split by .
    split.f1000 <- data.frame(split.f1000, stringsAsFactors = FALSE)
    split.f1000$X3 <- as.numeric(split.f1000$X3)
    split.f1000$X4 <- as.numeric(split.f1000$X4)
    split.f1000 <- dplyr::group_by(split.f1000, X3) %>%
      dplyr::arrange(X3, X4) %>%
      filter(row_number() == n()) %>%
      mutate(doi = paste(X1, ".", X2, ".", X3, ".", X4, sep = ""))
    # concatenate back F1000 and not F1000
    dois <- c(not.f1000, split.f1000$doi)
  }
  if (length(f1000) == 0) {
    dois <- not.f1000
  }
  return(dois)
}

format_paper <- function(issued, created, container.title,
                         publisher, title, volume, issue, page, doi, type) {
      # year
      idates <- issued
      if(is.na(idates))
        idates <- created
      dlengths <- nchar(idates)
      idates[dlengths == 4] <- paste(idates[dlengths == 4], "-01-01", sep = "") # add years and months as needed
      idates[dlengths == 7] <- paste(idates[dlengths == 7], "-01", sep = "")
      year <- format(as.Date(idates), "%Y")
      # journal
      journal <- container.title
      # Identify bioRxiv (couldn't find another way, needs updating)
      if (is.na(journal) & publisher == "Cold Spring Harbor Laboratory")
        journal <- "bioRxiv"

      tibble(journal = journal, title = title, year = year, volume = volume, issue = issue, pages = pages, type = type, doi = doi)
}


# Following not yet working.
# Idea is to add a column saying if named author is first author, last author, or neither.

order_authors <- function(...) {

  # make alternative versions of name
  reverse <- paste(bio[[1]]$name$`family-name`$value, ", ",
    substr(bio[[1]]$name$`given-names`$value, 1, 1), ".",
    sep = ""
  )
  simple <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), ". ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s0 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), " ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s1 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), ".[A-Z] ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s2 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), ". [A-Z] ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s3 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), ". [A-Z]. ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s4 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), ".[A-Z]. ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s5 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), " [A-Z] ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  s6 <- paste(substr(bio[[1]]$name$`given-names`$value, 1, 1), "[A-Z] ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  middle <- paste(bio[[1]]$name$`given-names`$value, " [A-Z]. ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  middle1 <- paste(bio[[1]]$name$`given-names`$value, " [A-Z] ",
    bio[[1]]$name$`family-name`$value,
    sep = ""
  )
  name.to.search <- tolower(c(name, reverse, simple, s0, s1, s2, s3, s4, s5, s6, middle, middle1))
  index <- grep(paste(name.to.search, sep = "", collapse = "|"), tolower(authors[, 1])) # first column of authors
  papers$First.author <- 0
  papers$First.author[index] <- 1
  # last author
  authors.na <- authors
  authors.na[authors.na == ""] <- NA # version with missing authors
  last <- apply(authors.na, 1, function(x) tail(na.omit(x), 1)) # extract last authors
  index <- grep(paste(name.to.search, sep = "", collapse = "|"), tolower(last)) #
  papers$Last.author <- 0
  papers$Last.author[index] <- 1
  papers$Last.author[papers$First.author == 1] <- 0 # Single author papers are only flagged as first author papers

  # work out author order - so that it can be bolded in report
  matches <- str_match(pattern = paste(name.to.search, sep = "", collapse = "|"), string = tolower(authors))
  matches <- matrix(matches, nrow = nrow(papers))
  author.order <- (is.na(matches) == F) %*% 1:ncol(matches) # which columns are not zero

  return(author.order)
}
