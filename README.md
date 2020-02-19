
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcademy

<!-- badges: start -->

<!-- badges: end -->

This package was developed during *ozunconf19* and *numbat hackathon
2020*, to provide tools that will help gather the information required
to apply for *academic promotion*. Though this is quite general, it is
mostly focused in Australian requisites.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ropenscilabs/Rcademy")
```

## Examples

This document was produced by Rob Hyndman, Maria Prokofiave, Chris
Brown, Belinda Fabian, Melina Vidoni, and Huong Ly Tong

``` r
library(tidyverse)
#> ── Attaching packages ──────────────────────────────────────────────────── tidyverse 1.3.0 ──
#> ✓ ggplot2 3.3.0.9000     ✓ purrr   0.3.3     
#> ✓ tibble  2.1.3          ✓ dplyr   0.8.4     
#> ✓ tidyr   1.0.2          ✓ stringr 1.4.0     
#> ✓ readr   1.3.1          ✓ forcats 0.4.0
#> ── Conflicts ─────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(rcademy)
```

### Research

For research, you will need a list of publications, the number of
citations, and the ranking of journals.

First, you can read your information from various sources, either a bib
file, or from an online list such as PubMed, Google Scholar or Orcid.
Normally you would only need to use one of these.

``` r
mypubs <- read_bib("mypubs.bib")
mypubs <- read_pubmed("Rob Hyndman")
mypubs <- read_scholar("vamErfkAAAAJ")
mypubs <- read_orcid("0000-0002-2140-5352")
```

We will use the last of these as an example here.

You can add journal rankings for each publication, choosing between
ABDC, CORE and SCImago.

``` r
mypubs <- mypubs %>%
  mutate(
    abdc_ranking = ranking(journal, source="abdc"),
    core_ranking = ranking(journal, source="core"),
    scimago_ranking = ranking(journal, source="scimago")
  )
```

Then you can create a table of the number of papers under each ranking
system.

``` r
mypubs %>%
  pivot_longer(contains("ranking"), 
               names_to = "method", names_pattern = "(.*)_ranking",
               values_to = "rank", values_drop_na = TRUE) %>%
  count(method, rank)
#> # A tibble: 8 x 3
#>   method  rank      n
#>   <chr>   <chr> <int>
#> 1 abdc    A        38
#> 2 abdc    A*       13
#> 3 abdc    B         3
#> 4 abdc    C         1
#> 5 core    B         1
#> 6 scimago Q1       71
#> 7 scimago Q2       11
#> 8 scimago Q3        2
```

To obtain Google citations for all papers, you can use the data obtained
with `read_scholar()` which contains a `cites` column. Otherwise you can
try some fuzzy matching of your list of publications against Google
Scholar.As the fuzzy matching on paper title and year is not always
accurate, all of the matched and unmatched papers are included in the
output for further manual curation.

``` r
mypubs %>%
  match_citations("vamErfkAAAAJ")
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
#> [1] 29296
#> 
#> $h_index
#> [1] 62
#> 
#> $i10_index
#> [1] 141
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
#>  [7] "Bircan Erbas"                 "Christoph Bergmeir"          
#>  [9] "Fotios Petropoulos"           "Heather Booth"               
#> [11] "Jan Verbesselt"               "Souhaib Ben Taieb"           
#> [13] "Mitchell O'Hara-Wild"         "Darius Culvenor"             
#> [15] "Muhammad Akram"               "Michael Abramson"            
#> [17] "Leonie Tickle"                "Shyamali  Chandrika Dharmage"
#> [19] "Roman Ahmed"                  "Glenn Newnham"
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
#>  4 A Feature‐Based Procedure for Detecting Technical Outli…                   12
#>  5 Point and interval forecasts of mortality rates and lif…                   12
#>  6 Forecasting with temporal hierarchies                                       7
#>  7 Forecasting Time Series With Complex Seasonal Patterns …                    7
#>  8 A note on upper bounds for forecast-value-added relativ…                    6
#>  9 Do human rhinovirus infections and food allergy modify …                    6
#> 10 Grouped Functional Time Series Forecasting: An Applicat…                    5
#> # … with 29 more rows
```

### Teaching

The teaching section will usually involve collecting data on your
teaching performance and teaching innovations.

Teaching performance is usually measured via student evaluations and
possibly peer reviews.

Other evidence of good teaching may involve emails from students, or
details of innovative curriculum development or teaching methods.

A list of honours, masters and PhD students that you have supervised is
also worth including.

The package provides a function to help with compiling emails for use in
this section. First, you’ll need to download a PDF file of every email
you think is relevant. Keep all the emails in the same folder. Then, use
the following function to parse all emails and return a tibble.

``` r
emails <- parse_pdf_emails("Some/Folder/Path/Here")
```

### Engagement

This section includes suggestions for engagement activities that could
be included in academic promotion applications. These examples are
indicative only and do not provide a list of expectations. Engagement is
interpreted in a broad sense to include discipline, industry, government
and community engagement.

*Engagement with Industry*

  - Partnerships with organisations: for profit, not-for-profit,
    volunteering
  - Consulting projects -\> could list value of projects, reports
    completed
  - Participation in project development programs e.g. CSIRO On Prime
  - Patents
  - Service on industry boards and/or committees at the local, state or
    national level

*Engagement with Government*

  - Policy development, such as changes resulting from your work
  - Advocacy programs e.g. Science Meets Parliament
  - Service with government bodies

*Engagement with Public*

  - Public presentations - list of locations
  - Blogging (own blog or collaborative), with stats available from blog
    backend e.g. views, visitors, followers.
  - Twitter. Such as number of followers from profile, [Twitter
    analytics](https://analytics.twitter.com) shows impressions,
    engagament rate, likes, retweets, replies (only allows viewing of
    the last 90 days of data).
  - Community programs e.g. National Science Week, etc.
  - Media appearances e.g. appearances on TV, radio, web.
  - Writing for general audience e.g. The Conversation, university news
    platforms (e.g. The Lighthouse).
  - Public works e.g. art installations, consulting on museum exhibit.
  - Service on community boards and/or committees at the local, state or
    national level.

*Engagement with Professional Community*

  - Contributions to community support websites e.g. Stack Overflow
  - Data science competitions e.g. Kaggle
  - Community engagement projects e.g. citizen science
  - Community development e.g. meetup groups, RLadies, rOpenSci,
    hackathons
  - Creation of software packages/tools for open use

*Engagement with Schools*

  - Curriculum development e.g. STEM at School.
  - Interactions with school students e.g. Skype a Scientist (discussing
    science with students).
  - University events e.g. Open Day.

*Contributions to enhancing the employability of graduates*

  - Establishing student links with industry/professional societies.
  - Participating in professional practice teaching e.g. teamwork,
    communication, problem solving, grant writing.

*Engagement/leadership within one’s profession or discipline*

  - Professional society membership & activity.
  - Membership of professional or foundation boards/councils
  - Peer review *(It should go into the research section)*. This can
    include: journal article review, ARC college of experts, grant
    review panels.

### Leadership

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
