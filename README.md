
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rcademy

<!-- badges: start -->

<!-- badges: end -->

This package was developed during *ozunconf19* and *numbat hackathon
2020*, to provide tools and ideas that will help gather the information
required to apply for *academic promotion*. Though this is quite
general, it is mostly focused in Australian requisites.

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

``` r
mypubs <- read_bib("mypubs.bib")
mypubs <- read_pubmed("Rob Hyndman")
mypubs <- read_scholar("vamErfkAAAAJ")
mypubs <- read_orcid("0000-0002-2140-5352")
```

Each of these functions will return a tibble, with one row per
publication and the columns providing information such as title,
authors, year of publication, etc. We will use the last of these as an
example here.

``` r
mypubs
#> # A tibble: 110 x 8
#>    journal        title               year volume issue pages   type   doi      
#>    <chr>          <chr>              <dbl> <chr>  <chr> <chr>   <chr>  <chr>    
#>  1 Data Mining a… On normalization …  2019 34     2     309-354 journ… 10.1007/…
#>  2 Water Resourc… A Feature‐Based P…  2019 55     11    8547-8… journ… 10.1029/…
#>  3 IEEE Power an… Visualizing Big E…  2018 16     3     18-25   journ… 10.1109/…
#>  4 Computational… A note on the val…  2018 120    <NA>  70-83   journ… 10.1016/…
#>  5 Stat           Bivariate smoothi…  2018 7      1     e199    journ… 10.1002/…
#>  6 International… Crude oil price f…  2018 34     4     665-677 journ… 10.1016/…
#>  7 European Jour… Exploring the sou…  2018 268    2     545-554 journ… 10.1016/…
#>  8 Journal of th… Optimal Forecast …  2018 114    526   804-819 journ… 10.1080/…
#>  9 Journal of th… A note on upper b…  2017 68     9     1082-1… journ… 10.1057/…
#> 10 Journal of Al… Associations betw…  2017 139    4     1140-1… journ… 10.1016/…
#> # … with 100 more rows
```

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

Then you can create a table of the number of papers by rank.

``` r
mypubs %>%
  filter(!is.na(abdc_ranking)) %>%
  count(abdc_ranking) 
#> # A tibble: 4 x 2
#>   abdc_ranking     n
#>   <fct>        <int>
#> 1 A*              13
#> 2 A               38
#> 3 B                3
#> 4 C                1
```

To obtain Google citations for all papers, you can use the data obtained
with `read_scholar()` which contains a `cites` column. Otherwise you can
try some fuzzy matching of your list of publications against Google
Scholar. As the fuzzy matching on title and year is not always accurate,
all of the matched and unmatched papers are included in the output for
further manual curation.

``` r
mypubs %>%
  match_citations("vamErfkAAAAJ") %>%
  select(title.x, year.x, cites) %>%
  arrange(desc(cites))
#> # A tibble: 111 x 3
#>    title.x                                                          year.x cites
#>    <chr>                                                             <dbl> <dbl>
#>  1 Another look at measures of forecast accuracy                      2006  2916
#>  2 Detecting trend and seasonal changes in satellite image time se…   2010   925
#>  3 25 years of time series forecasting                                2006   895
#>  4 A state space framework for automatic forecasting using exponen…   2002   746
#>  5 Robust forecasting of mortality and fertility rates: A function…   2007   555
#>  6 Phenological change detection while accounting for abrupt and g…   2010   452
#>  7 Optimal combination forecasts for hierarchical time series         2011   256
#>  8 Stochastic population forecasts using functional data models fo…   2008   254
#>  9 Bandwidth selection for kernel conditional density estimation      2001   237
#> 10 The price elasticity of electricity demand in South Australia      2011   205
#> # … with 101 more rows
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

Note that a list of PhD students would often go in the Research section
rather than the teaching section.

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
