
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rcademy

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rcademy)](https://CRAN.R-project.org/package=rcademy)
[![R build
status](https://github.com/ropenscilabs/rcademy/workflows/R-CMD-check/badge.svg)](https://github.com/ropenscilabs/rcademy/actions)
<!-- badges: end -->

This package was developed during *ozunconf19* and *numbat hackathon
2020*, to provide tools and ideas that will help gather the information
required to apply for *academic promotion*.

This document was produced by Chris Brown, Belinda Fabian, Rob Hyndman,
Maria Prokofiave, Nick Tierney, Huong Ly Tong, and Melina Vidoni,

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ropenscilabs/Rcademy")
```

## Applications for promotion

Typically, an application for academic promotion will require you to
provide evidence of your performance in Research, Teaching, Engagement
and (for senior appointments) Leadership. The rest of this document
summarises what sort of things you could include in each of these
sections.

## Research

For research, you will need a list of publications, the number of
citations, and the ranking of the journals in which you have published

You can obtain a list of your publication from various sources, either a
bib file, or from an online list such as PubMed, Google Scholar or
Orcid. Normally you would only need to use one of these.

``` r
library(tidyverse)
#> ── Attaching packages ──────────────────────────────────────────────────────── tidyverse 1.3.0 ──
#> ✓ ggplot2 3.3.1     ✓ purrr   0.3.4
#> ✓ tibble  3.0.1     ✓ dplyr   1.0.0
#> ✓ tidyr   1.1.0     ✓ stringr 1.4.0
#> ✓ readr   1.3.1     ✓ forcats 0.5.0
#> ── Conflicts ─────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(rcademy)
```

``` r
mypubs_bib <- read_bib("mypubs.bib")
mypubs_pubmed <- read_pubmed("Rob Hyndman")
mypubs_scholar <- read_scholar("vamErfkAAAAJ")
mypubs_orcid <- read_orcid("0000-0002-2140-5352")
```

Each of these functions will return a tibble, with one row per
publication and the columns providing information such as title,
authors, year of publication, etc. The different sources provide some
different information, and it is often useful to combine them. We will
use the last two of these (from Google Scholar and ORCID) in the
following examples.

``` r
mypubs_orcid
#> # A tibble: 142 x 8
#>    journal            title             year volume issue pages type   doi      
#>    <chr>              <chr>            <dbl> <chr>  <chr> <chr> <chr>  <chr>    
#>  1 International Jou… On continuous-t…  1992 <NA>   <NA>  <NA>  <NA>   <NA>     
#>  2 Journal of Time S… YULE-WALKER EST…  1993 14     3     281-… journ… 10.1111/…
#>  3 Journal of Applie… Approximations …  1994 31     4     1103… journ… 10.2307/…
#>  4 Journal of Foreca… Highest-density…  1995 14     5     431-… journ… 10.1002/…
#>  5 The American Stat… Sample Quantile…  1996 50     4     361   journ… 10.2307/…
#>  6 The American Stat… Sample Quantile…  1996 50     4     361-… journ… 10.1080/…
#>  7 The American Stat… Computing and G…  1996 50     2     120   journ… 10.2307/…
#>  8 The American Stat… Computing and G…  1996 50     2     120-… journ… 10.1080/…
#>  9 Journal of Comput… Estimating and …  1996 5      4     315-… journ… 10.1080/…
#> 10 Journal of the Ro… Some properties…  1997 <NA>   <NA>  <NA>  <NA>   <NA>     
#> # … with 132 more rows
mypubs_scholar
#> # A tibble: 289 x 8
#>    title         author        journal    number  cites  year cid          pubid
#>    <chr>         <chr>         <chr>      <chr>   <dbl> <dbl> <chr>        <chr>
#>  1 Forecasting … S Makridakis… "John Wil… ""       5826  1998 73093598359… u5HH…
#>  2 Another look… RJ Hyndman, … "Internat… "22 (4…  3160  2006 13549848342… 9yKS…
#>  3 Automatic ti… RJ Hyndman, … "Journal … ""       2162  2007 16678312313… YsMS…
#>  4 Forecasting:… RJ Hyndman, … "OTexts"   ""       2109  2018 71756992424… CrVL…
#>  5 Forecasting … RJ Hyndman, … "Springer… ""       1063  2008 88418756642… UeHW…
#>  6 Detecting tr… J Verbesselt… "Remote s… "114 (…  1003  2010 47121712280… 5nxA…
#>  7 25 years of … JG De Gooije… "Internat… "22 (3…   935  2006 33143054759… Tyk-…
#>  8 Sample quant… RJ Hyndman, … "The Amer… "50 (4…   880  1996 25243146458… u-x6…
#>  9 A state spac… RJ Hyndman, … "Internat… "18 (3…   782  2002 44453997602… 2osO…
#> 10 forecast: Fo… RJ Hyndman, … ""         ""        739  2018 16844150736… UbXT…
#> # … with 279 more rows
```

In general, ORCID will provide higher quality data, along with DOIs, but
has no citation information and covers fewer publications than Google
Scholar. A few papers may have two DOIs — for example, when they appear
on both JStor and a journal website. We will remove these.

``` r
library(tidystringdist)
dups <- mypubs_orcid %>% 
  select(title, year) %>% 
  mutate_all(tolower) %>%
  duplicated()
mypubs_orcid <- mypubs_orcid %>% filter(!dups)
```

We will try to combine the two tibbles using fuzzy joining on the title
and year fields.

``` r
mypubs <- mypubs_scholar %>% 
  # First remove any publications without years 
  filter(!is.na(year)) %>%
  # Now find matching entries
  fuzzyjoin::stringdist_left_join(mypubs_orcid,
    by = c(title = "title", year = "year"),
    max_dist = 2, ignore_case = TRUE) %>%
  # Keep any columns where ORCID missing
  mutate(
    title.y = if_else(is.na(title.y), title.x, title.y),
    journal.y = if_else(is.na(journal.y), journal.x, journal.y),
    year.y = if_else(is.na(year.y), year.x, year.y),
  ) %>%
  # Keep the ORCID columns
  select(!ends_with(".x")) %>%
  rename_all(~str_remove_all(.x,".y"))
mypubs
#> # A tibble: 301 x 13
#>    author number cites cid   pubid journal title  year volume issue pages pe   
#>    <chr>  <chr>  <dbl> <chr> <chr> <chr>   <chr> <dbl> <chr>  <chr> <chr> <chr>
#>  1 S Mak… ""      5826 7309… u5HH… "John … Fore…  1998 <NA>   <NA>  <NA>  <NA> 
#>  2 RJ Hy… "22 (…  3160 1354… 9yKS… "Inter… Anot…  2006 22     4     679-… jour…
#>  3 RJ Hy… ""      2162 1667… YsMS… "Journ… Auto…  2008 <NA>   <NA>  <NA>  <NA> 
#>  4 RJ Hy… ""      2109 7175… CrVL… "OText… Fore…  2018 <NA>   <NA>  <NA>  <NA> 
#>  5 RJ Hy… ""      1063 8841… UeHW… "Sprin… Fore…  2008 <NA>   <NA>  <NA>  <NA> 
#>  6 J Ver… "114 …  1003 4712… 5nxA… "Remot… Dete…  2010 114    1     106-… jour…
#>  7 JG De… "22 (…   935 3314… Tyk-… "Inter… 25 y…  2006 22     3     443-… jour…
#>  8 RJ Hy… "50 (…   880 2524… u-x6… "The A… Samp…  1996 50     4     361   jour…
#>  9 RJ Hy… "18 (…   782 4445… 2osO… "Inter… A st…  2002 18     3     439-… jour…
#> 10 RJ Hy… ""       739 1684… UbXT… ""      fore…  2018 <NA>   <NA>  <NA>  <NA> 
#> # … with 291 more rows, and 1 more variable: doi <chr>
```

You can add journal rankings for each publication, choosing between
ABDC, CORE and SCImago.

``` r
mypubs <- mypubs %>%
  mutate(
    abdc_ranking = rank_abdc(journal),
    core_ranking = rank_core(journal),
    scimago_ranking = rank_core(journal)
  )
```

Then you can create a table of the number of papers by rank.

``` r
mypubs %>%
  filter(!is.na(abdc_ranking)) %>%
  count(abdc_ranking) 
```

The tibble contains Google scholar citations for all papers, you can use
the data obtained with `read_scholar()` which contains a `cites` column.
We can also obtain CrossRef citations via the `citations()` function
which uses the DOI codes.

``` r
mypubs %>%
  mutate(cr_cites = citations(doi)) %>%
  select(title, year, cites, cr_cites) %>%
  arrange(desc(cites))
#> # A tibble: 301 x 4
#>    title                                                     year cites cr_cites
#>    <chr>                                                    <dbl> <dbl>    <dbl>
#>  1 Forecasting methods and applications                      1998  5826       NA
#>  2 Another look at measures of forecast accuracy             2006  3160     1461
#>  3 Automatic time series forecasting: The forecast package…  2008  2162       NA
#>  4 Forecasting: principles and practice                      2018  2109       NA
#>  5 Forecasting with exponential smoothing: the state space…  2008  1063       NA
#>  6 Detecting trend and seasonal changes in satellite image…  2010  1003      648
#>  7 25 years of time series forecasting                       2006   935      597
#>  8 Sample Quantiles in Statistical Packages                  1996   880      100
#>  9 A state space framework for automatic forecasting using…  2002   782      349
#> 10 forecast: Forecasting functions for time series and lin…  2018   739       NA
#> # … with 291 more rows
```

Altmetrics can also be useful. For this, you will need the list of your
DOIs.

``` r
mypubs %>% 
  get_altmetrics(doi) %>%
  select(title, cited_by_tweeters_count) %>%
  arrange(desc(cited_by_tweeters_count))
#> # A tibble: 39 x 2
#>    title                                                    cited_by_tweeters_c…
#>    <chr>                                                                   <dbl>
#>  1 Handgun Acquisitions in California After Two Mass Shoot…                   41
#>  2 Exploring the sources of uncertainty: Why does bagging …                   16
#>  3 Associations between outdoor fungal spores and childhoo…                   15
#>  4 Point and interval forecasts of mortality rates and lif…                   12
#>  5 A Feature‐Based Procedure for Detecting Technical Outli…                   12
#>  6 Forecasting Time Series With Complex Seasonal Patterns …                    8
#>  7 Forecasting with temporal hierarchies                                       7
#>  8 Do human rhinovirus infections and food allergy modify …                    6
#>  9 A note on upper bounds for forecast-value-added relativ…                    6
#> 10 Grouped Functional Time Series Forecasting: An Applicat…                    5
#> # … with 29 more rows
```

The `scholar` package provides tools for obtaining your profile
information.

``` r
scholar::get_profile("vamErfkAAAAJ")
#> $id
#> [1] "vamErfkAAAAJ"
#> 
#> $name
#> [1] "Rob J Hyndman"
#> 
#> $affiliation
#> [1] "Professor of Statistics, Monash University"
#> 
#> $total_cites
#> [1] 31532
#> 
#> $h_index
#> [1] 63
#> 
#> $i10_index
#> [1] 150
#> 
#> $fields
#> [1] "verified email at monash.edu - homepage"
#> 
#> $homepage
#> [1] "http://robjhyndman.com/"
#> 
#> $coauthors
#>  [1] "George Athanasopoulos"        "Ralph Snyder"                
#>  [3] "Han Lin Shang"                "Kate Smith-Miles"            
#>  [5] "Keith Ord"                    "Spyros Makridakis"           
#>  [7] "Bircan Erbas"                 "Fotios Petropoulos"          
#>  [9] "Christoph Bergmeir"           "Heather Booth"               
#> [11] "Jan Verbesselt"               "Souhaib Ben Taieb"           
#> [13] "Darius Culvenor"              "Mitchell O'Hara-Wild"        
#> [15] "Muhammad Akram"               "Michael Abramson"            
#> [17] "Leonie Tickle"                "Shyamali  Chandrika Dharmage"
#> [19] "Roman Ahmed"                  "Glenn Newnham"
```

## Teaching

The teaching section will usually involve collecting data on your
teaching performance and teaching innovations.

#### Teaching performance

  - Student evaluations
  - Emails from grateful students
  - Peer review reports

#### Teaching innovations

  - Development of new subjects or degrees
  - New teaching methods or materials

#### Supervision

  - Honours students supervised
  - Masters students supervised
  - PhD students supervised

Note that a list of PhD students may go in the Research section rather
than the Teaching section.

## Engagement

This section includes suggestions for engagement activities that could
be included in academic promotion applications. These examples are
indicative only and do not provide a list of expectations. Engagement is
interpreted in a broad sense to include discipline, industry, government
and community engagement.

#### Engagement with Industry

  - Partnerships with organisations: for profit, not-for-profit,
    volunteering
  - Consulting projects -\> could list value of projects, reports
    completed
  - Participation in project development programs e.g. CSIRO On Prime
  - Patents
  - Service on industry boards and/or committees at the local, state or
    national level

#### Engagement with Government

  - Policy development, such as changes resulting from your work
  - Advocacy programs e.g. Science Meets Parliament
  - Service with government bodies

#### Engagement with Public

  - Public presentations - list of locations
  - Blogging (own blog or collaborative), with stats available from blog
    backend e.g. views, visitors, followers.
  - Twitter. Such as number of followers from profile, [Twitter
    analytics](https://analytics.twitter.com) shows impressions,
    engagement rate, likes, retweets, replies (only allows viewing of
    the last 90 days of data).
  - Community programs e.g. National Science Week, etc.
  - Media appearances e.g. appearances on TV, radio, web.
  - Writing for general audience e.g. The Conversation, university news
    platforms (e.g. The Lighthouse).
  - Public works e.g. art installations, consulting on museum exhibit.
  - Service on community boards and/or committees at the local, state or
    national level.

#### Engagement with Professional Community

  - Contributions to community support websites e.g. Stack Overflow
  - Data science competitions e.g. Kaggle
  - Community engagement projects e.g. citizen science
  - Community development e.g. meetup groups, RLadies, rOpenSci,
    hackathons
  - Creation of software packages/tools for open use

#### Engagement with Schools

  - Curriculum development e.g. STEM at School.
  - Interactions with school students e.g. Skype a Scientist (discussing
    science with students).
  - University events e.g. Open Day.

#### Contributions to enhancing the employability of graduates

  - Establishing student links with industry/professional societies.
  - Participating in professional practice teaching e.g. teamwork,
    communication, problem solving, grant writing.

#### Engagement/leadership within one’s profession or discipline

  - Professional society membership & activity.
  - Membership of professional or foundation boards/councils
  - Peer review *(It should go into the research section)*. This can
    include: journal article review, ARC college of experts, grant
    review panels.

## Leadership

This section includes examples of leadership activities in academic
promotion applications.

  - University committee (e.g. department, faculty, university-level).
    List how many events/meetings you have in a year.
  - Board membership, and list position, length of service.
  - Conference organisation. List your role (e.g. scientific committee,
    symposium chair), scale of conference (e.g number of attendees,
    funding, international/local).
  - Leading projects and initiatives (e.g. sustainability, diversity
    inclusion initiatives).
  - Event organisation (e.g. writing retreat).
  - Training events (e.g. university management course). List the
    course, completion date.
  - Leadership roles in external professional or industry associations
  - Mentoring. List how many mentees you have, length of relationship,
    where they are working now.
