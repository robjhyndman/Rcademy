# Rcademy

This package was developed during _ozunconf19_, to provide functions that will help gather the information required to apply for _academic promotion_. Though this is quite general, it is mostly focused in Australian requisites.

## Installation
You can install the development version from GitHub with:

```{r}
# install.packages("devtools")
devtools::install_github("ropenscilabs/Rcademy")
```

## Research

Contributors: Rob Hyndman, Maria Prokofiave, Chris Brown and Belinda Fabian

For research, you will need a list of publications, the number of citations, and the ranking of journals. 

First, you can read your information from various sources, either a bib file, or from an online list such as PubMed, Google Scholar or Orcid. Normally you would only need to use one of these.

```{r}
mypubs <- read_bib("mypubs.bib")
mypubs <- read_pubmed("HUONG LY TONG")
mypubs <- read_scholar("EUdX6oIAAAAJ")
mypubs <- read_orcid("0000-0002-8462-0105")

# For this one, you need the list of your DOIs
# It will give you a tibble with publication data
library(dplyr)
doi_list <- list(mypubs$doi)
aTibble <- read_altmetrics(doi_list)

# With citations you can compute your H-Index
compute_hindex(read_scholar("EUdX6oIAAAAJ")$cites)
```

You can combine your list of publications against the journal rankings. You can choose between ABDC, CORE and SCIMAGOJR. You can use it as follows, and then combine it with a loop.

```{r}
mypubs <- mypubs %>%
  mutate(
    abdc_ranking = ranking(journal, source="abdc"),
    core_ranking = ranking(journal, source="core"),
    scimago_ranking = ranking(journal, source="scimago")
  )
```

Then you can create a table of the number of papers under each ranking system. For example ..


Once you have your list of publications, it can be compared against the information available on Google Scholar to obtain the citations for each output. As the fuzzy matching on paper title and year is not always accurate, all of the matched and unmatched papers are included in the output for further manual curation. 

```{r}
mypubs <- read_pubmed("HUONG LY TONG")
matchedPubs <- matchCitations(mypubs, "EUdX6oIAAAAJ")
```


## Teaching

Contributors: Melina Vidoni

The teaching section will allow you to collect the following data:

- Student emails that are evidence of good teaching
- HDRs and Honours students and completions

### Email Gathering
First, you'll need to download the PDF file of every email you think is relevant. Do not use the "Save as PDF", but rather print them to PDF. Keep all the emails in the same folder.

Then, use the following function to parse all emails and obtain a RDS file in the same directory. The function will also return you the file in-memory.

```{r eval=FALSE, include=FALSE}
emails <- parsePDFEmails("Some/Folder/Path/Here")
```


### Storing Student Info

This will create (or update) a CSV file, in whichever path you want, to add the students you are working with.

When you create a student, you need to add all of the information, as follows:

```{r eval=FALSE, include=FALSE}
# Use this function to add or edit a student data to a CSV file stored where you choose
storeStudents("Jane", "Shepard", "Honours", "Computer Science", "Normandy SR1", "March/2020", "November/2020", FALSE, "Fight the Reapers", "Dr Somebody", "Dr Another Person", "Path/To/Folder", "fileName.csv")

```

But to update, you can change only some records:

```{r eval=FALSE, include=FALSE}
# Use this function to add or edit a student data to a CSV file stored where you choose
storeStudents("Jane", "Shepard", completed = TRUE, csvFilePath =  "Path/To/Folder", csvFileName = "fileName.csv")

```

In both cases, the function will return the file in-memory, if you want to further explore it.



## Engagement

Contributors: Belinda Fabian and Huong Ly Tong

This section includes suggestions for engagement activities that could be included in academic promotion applications. These examples are indicative only and do not provide a list of expectations. Engagement is interpreted in a broad sense to include discipline, industry, government and community engagement.

*Engagement with Industry*

- Partnerships with organisations: for profit, not-for-profit, volunteering
- Consulting projects -> could list value of projects, reports completed
- Participation in project development programs e.g. CSIRO On Prime
- Patents
- Service on industry boards and/or committees at the local, state or national level

*Engagement with Government*

- Policy development, such as changes resulting from your work
- Advocacy programs e.g. Science Meets Parliament
- Service with government bodies

*Engagement with Public*

- Public presentations - list of locations
- Blogging (own blog or collaborative), with stats available from blog backend e.g. views, visitors, followers.
- Twitter. Such as number of followers from profile, [Twitter analytics](https://analytics.twitter.com)  shows impressions, engagament rate, likes, retweets, replies (only allows viewing of the last 90 days of data).
- Community programs e.g. National Science Week, etc.
- Media appearances e.g. appearances on TV, radio, web.
- Writing for general audience e.g. The Conversation, university news platforms (e.g. The Lighthouse).
- Public works e.g. art installations, consulting on museum exhibit.
- Service on community boards and/or committees at the local, state or national level.

*Engagement with Professional Community*

- Contributions to community support websites e.g. Stack Overflow
- Data science competitions e.g. Kaggle
- Community engagement projects e.g. citizen science
- Community development e.g. meetup groups, RLadies, rOpenSci, hackathons
- Creation of software packages/tools for open use

*Engagement with Schools*

- Curriculum development e.g. STEM at School.
- Interactions with school students e.g. Skype a Scientist (discussing science with students).
- University events e.g. Open Day.

*Contributions to enhancing the employability of graduates*

- Establishing student links with industry/professional societies.
- Participating in professional practice teaching e.g. teamwork, communication, problem solving, grant writing.

*Engagement/leadership within one’s profession or discipline*

- Professional society membership & activity.
- Membership of professional or foundation boards/councils
- Peer review _(It should go into the research section)_. This can include: journal article review, ARC college of experts, grant review panels.

## Leadership

Contributors: Belinda Fabian and Huong Ly Tong

This section includes examples of leadership activities in academic promotion applications.

- University committee (e.g. department, faculty, university-level). List how many events/meetings you have in a year.
- Board membership, and list position, length of service.
- Conference organisation. List your role (e.g. scientific committee, symposium chair), scale of conference (e.g number of attendees, funding, international/local).
- Leading projects and initiatives (e.g. sustainability, diversity inclusion initiatives).
- Event organisation (e.g. writing retreat).
- Training events (e.g. university management course). List the course, completion date.
- Leadership roles in external professional or industry associations
- Mentoring. List how many mentees you have, length of relationship, where they are working now.

