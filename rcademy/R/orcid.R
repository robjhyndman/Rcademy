# orcid.R
# Take ORCID ID and make a list of papers
# use rcrossref to get better formatted data
# Borrowed from Adrian Barnett. https://github.com/agbarnett/helping.funders
# Updated December 2019 by Rob Hyndman

# set token as an environmental variable (March 2018)
# x <- "07073399-4dcc-47b3-a0a8-925327224519"
# Sys.setenv(ORCID_TOKEN=x)

## Test IDs
# orcid.id = '0000-0003-1602-4544'
# orcid.id = '0000-0001-8369-1238' # Suzanne
# orcid.id = '0000-0003-0152-4394' # Richard
# orcid.id = '0000-0002-7129-0039' # Sue
# orcid.id = '0000-0003-2434-4206' # David Moher
# orcid.id ='0000-0002-2358-2440' # ginny
# orcid.id ='0000-0001-6339-0374' # me
# orcid.id = '0000-0002-5559-3267' # nick
# orcid.id='0000-0001-7733-287X'
# orcid.id = '0000-0002-5808-4249' #Jenny
# orcid.id='0000-0001-7564-073X' # Paul
# orcid.id='0000-0003-3637-2423' # Anisa
# orcid.id='0000-0002-6020-9733' # Lionel
# orcid.id='0000-0002-0630-3825'

# main function
read_orcid <- function(orcid.id) {
  ret <- list() # start with blank output

  # a) select person
  bio <- orcid_id(orcid = orcid.id, profile = "profile") # get basics
  name <- paste(
    bio[[1]]$`name`$`given-names`$value,
    bio[[1]]$`name`$`family-name`$value
  )
  name <- gsub("  ", " ", name) # remove double space
  name <- gsub(" $", "", name) # remove trailing space

  # b) select works
  d <- works(orcid_id(orcid = orcid.id)) # get works as a tibble

  # if no papers then end function here
  if (nrow(d) == 0) {
    ret$name <- name
    ret$papers <- NULL
    ret$authors <- NULL
    return(ret)
  }

  # hide all this in a dummy function for now, as it's not used
  use.ids <- function() {
    ids <- NULL
    for (k in 1:nrow(d)) {
      this <- d[k, ]$`external-ids.external-id`[[1]]
      if (is.null(this) == F & length(this) > 0) {
        # First get doi
        this.id <- subset(this, `external-id-type` == "doi")
        if (nrow(this.id) == 1) {
          this.frame <- data.frame(type = "doi", id = this.id$`external-id-value`)
        }
        if (nrow(this.id) == 0) {
          this.id <- subset(this, `external-id-type` == "pmid")
          if (nrow(this.id) == 1) {
            this.frame <- data.frame(type = "pmid", id = this.id$`external-id-value`)
          }
        }
        if (nrow(this.id) == 0) {
          # cat('No doi,',k,'\n')
          this.frame <- NULL
        }
        # concatenate
        ids <- rbind(ids, this.frame)
      }
    }
  } # end of dummy use.ids function

  # unlist(plyr::llply(d$`external-ids.external-id`, function(x){`external-id-value`}))

  # may need to revert to a loop
  # for (k in 1:nrow(d)){
  #  unlist(plyr::llply(aff, function(x){x$'affilname'})
  # }
  dois <- identifiers(d, type = "doi") # get DOIs, not available for all papers
  dois <- dois[duplicated(tolower(dois)) == FALSE] # remove duplicates
  # eids = identifiers(d, type='eid') # get Scopus IDs, not available for all papers

  # remove F1000 DOIs where there is second version (keep latest version)
  not.f1000 <- dois[!str_detect(string = dois, pattern = "f1000")]
  f1000 <- dois[str_detect(string = dois, pattern = "f1000")]
  if (length(f1000) > 0) { # only if some F1000 journals
    split.f1000 <- str_split(f1000, pattern = "\\.", n = Inf, simplify = TRUE) # split by .
    split.f1000 <- data.frame(split.f1000, stringsAsFactors = F)
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

  # d) get nicely formatted data for papers with a DOIs using crossref
  cdata.nonbibtex <- cr_works(dois)$data
  # add Open Access status (March 2018)
  cdata.nonbibtex$OA <- NA
  # run with fail
  n.match <- count <- 0
  while (n.match != nrow(cdata.nonbibtex) & count < 3) { # run three times max
    OAs <- purrr::map_df(
      cdata.nonbibtex$DOI,
      plyr::failwith(f = function(x) roadoi::oadoi_fetch(x, email = "a.barnett@qut.edu.au"))
    )
    n.match <- nrow(OAs)
    count <- count + 1
    # cat(n.match, ', count', count, '\n') # tracking warning
  }
  if (n.match != nrow(cdata.nonbibtex)) {
    oa.warning <- TRUE
  }
  if (n.match == nrow(cdata.nonbibtex)) {
    oa.warning <- FALSE
    cdata.nonbibtex$OA <- OAs$is_oa # Is there an OA copy? (logical)
  }

  # e) format papers with separate matrix for authors ###
  papers <- bib.authors <- NULL
  # e2) ... now for non bibtex from crossref
  authors.crossref <- NULL
  if (nrow(cdata.nonbibtex) > 0) {
    authors.crossref <- matrix(data = "", nrow = nrow(cdata.nonbibtex), ncol = 300) # start with huge matrix
    for (k in 1:nrow(cdata.nonbibtex)) { # loop needed
      # authors, convert from tibble
      fauthors <- cdata.nonbibtex$author[[k]]
      fam.only <- FALSE # flag for family only
      if (is.null(fauthors) == FALSE) {
        if ("family" %in% names(fauthors) & length(names(fauthors)) <= 2) { # changed to allow 'sequence' (Sep 2018)
          fauthors <- fauthors$family
          fam.only <- TRUE
        }
      }
      if (fam.only == FALSE & ("given" %in% names(fauthors) == FALSE) & is.null(fauthors) == FALSE) {
        fauthors <- dplyr::filter(fauthors, is.na(name) == FALSE) # not missing
        fauthors <- paste(fauthors$name)
      }
      if (fam.only == FALSE & "given" %in% names(fauthors) & is.null(fauthors) == FALSE) {
        fauthors <- filter(fauthors, is.na(family) == FALSE) # not missing
        fauthors <- select(fauthors, given, family)
        fauthors <- paste(fauthors$given, fauthors$family) # does include NA - to fix
      }
      if (is.null(fauthors) == FALSE) {
        if (length(fauthors) > ncol(authors.crossref)) {
          fauthors <- fauthors[1:ncol(authors.crossref)]
        } # truncate where author numbers are huge (jan 2018)
        authors.crossref[k, 1:length(fauthors)] <- fauthors
      }
      # year (was based on created, fixed January 2018)
      idates <- cdata.nonbibtex$issued[k]
      cdates <- cdata.nonbibtex$created[k]
      if (is.na(idates)) {
        idates <- cdates
      } # if missing use created date
      dlengths <- nchar(idates)
      idates[dlengths == 4] <- paste(idates[dlengths == 4], "-01-01", sep = "") # add years and months as needed
      idates[dlengths == 7] <- paste(idates[dlengths == 7], "-01", sep = "")
      year <- format(as.Date(idates), "%Y")
      ## journal
      journal <- cdata.nonbibtex$container.title[k]
      # Identify bioRxiv (couldn't find another way, needs updating)
      if (is.na(journal)) {
        if (cdata.nonbibtex$publisher[k] == "Cold Spring Harbor Laboratory") (journal <- "bioRxiv")
      }
      # title
      title <- as.character(cdata.nonbibtex$title[k])
      # volume/issue/pages
      volume <- cdata.nonbibtex$volume[k]
      issue <- cdata.nonbibtex$issue[k]
      pages <- cdata.nonbibtex$page[k]
      # doi
      DOI <- cdata.nonbibtex$DOI[k]
      # OA
      OA <- cdata.nonbibtex$OA[k]
      # type
      type <- cdata.nonbibtex$type[k]
      # put it all together
      frame <- data.frame(Journal = journal, Title = title, Year = year, Volume = volume, Issue = issue, Pages = pages, Type = type, DOI = DOI, OA = OA)
      papers <- rbind(papers, frame)
    }
  }

  # f) combine authors and remove empty columns
  authors <- authors.crossref
  to.find <- which(colSums(authors == "") == nrow(authors))
  if (length(to.find) == 0) {
    fmin <- ncol(authors) + 1
  } # all columns full
  if (length(to.find) > 0) {
    fmin <- min(to.find)
  } # find first empty column
  authors <- authors[, 1:(fmin - 1)]
  if (nrow(papers) == 1) {
    authors <- matrix(authors)
    authors <- t(authors)
  }

  # remove duplicates (again, just a safety net, should have been caught earlier)
  if (nrow(papers) > 1) {
    dups <- duplicated(tolower(papers$Title))
    papers <- papers[!dups, ]
    authors <- authors[!dups, ]
  }

  # remove later versions of paper with almost identical DOI _ TO DO

  ## count first author papers
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

  # for appearances
  papers$Title <- as.character(papers$Title)
  papers$Journal <- as.character(papers$Journal)
  if (class(papers$Year) == "factor") {
    papers$Year <- as.numeric(as.character(papers$Year))
  }
  if (class(papers$Volume) == "factor") {
    papers$Volume <- as.character(papers$Volume)
  }
  if (class(papers$Issue) == "factor") {
    papers$Issue <- as.character(papers$Issue)
  }
  if (class(papers$Pages) == "factor") {
    papers$Pages <- as.character(papers$Pages)
  }
  if (class(papers$DOI) == "factor") {
    papers$DOI <- as.character(papers$DOI)
  }

  ## need to remove/change special characters like: … and -- from title

  # replace NAs is authors with ''
  authors[is.na(authors) == T] <- ""

  # give a consistent number of columns to author matrix
  blank <- matrix("", nrow = nrow(authors), ncol = 50) # 50 authors max
  if (ncol(authors) > 50) {
    authors <- authors[, 1:50]
  } # truncate at 50 if over 50 authors on a paper
  blank[, 1:ncol(authors)] <- authors
  authors <- blank

  # return
  ret$name <- name
  ret$papers <- papers
  ret$oa.warning <- oa.warning
  ret$authors <- authors # separate matrix so that authors can be selected
  ret$author.order <- author.order

  # return
  return(ret)
}
