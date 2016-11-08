Import raw data
---------------

``` r
library("stringr") 
```

    ## Warning: package 'stringr' was built under R version 3.2.5

``` r
library("dplyr")
```

    ## Warning: package 'dplyr' was built under R version 3.2.5

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library("tidyr")
```

    ## Warning: package 'tidyr' was built under R version 3.2.5

``` r
library("ggplot2")
```

    ## Warning: package 'ggplot2' was built under R version 3.2.4

``` r
library("knitr")
```

    ## Warning: package 'knitr' was built under R version 3.2.5

Read raw files
==============

``` r
# Get file names
files <- list.files(path = paste(di, "/data/wos_raw/", sep= ""), pattern= "\\.txt$")

# Loop to read files 
for (j in files){ 
  aux <- read.csv(file=paste(di, "/data/wos_raw/", j, sep= ""),
              header = TRUE,
              sep = '\t')
  name_aux <- str_replace(j, "\\..*", "") 
  
  assign(name_aux, aux)
  }


rawdf <- rbind(bioCI, bioP, med, wos1, wos2, zoo, wos3)
```

Create key: Sort by year (ascending) and by Authors..Primary (alphabetically)
=============================================================================

``` r
rawdf <- rawdf %>% 
  mutate(aut = as.character(Authors..Primary)) %>% # Transform factor to character 
  arrange(Pub.Year, aut) %>% # sort by pubyear and author 
  mutate(key=cumsum(rep(1, n()))) # create key 
```

Summary statistics
------------------

``` r
### Total References
tot_ref <- rawdf %>% count()
tot_ref
```

    ## # A tibble: 1 × 1
    ##       n
    ##   <int>
    ## 1  1038

``` r
### By reference types 
rawdf %>% 
  group_by(Reference.Type) %>% 
  summarise (n = n()) %>%
  mutate(freq = round((n / sum(n))*100, 2))
```

    ## # A tibble: 3 × 3
    ##           Reference.Type     n  freq
    ##                   <fctr> <int> <dbl>
    ## 1        Journal Article  1005 96.82
    ## 2            Book, Whole    28  2.70
    ## 3 Conference Proceedings     5  0.48

``` r
# Journals 
articles_by_journal <- rawdf %>% group_by(Periodical.Full) %>% count() 
```

Read Wos UT
===========

``` r
utdf <- read.csv(file=paste(di, "/data/wos_ut/wos_ut_issn.txt", sep= ""), header = TRUE, sep = '\t')


issn_unique <- utdf %>% group_by(SN) %>% count() %>% filter(SN !="") %>% select(SN, n_papers=n)


cat_journal <- read.csv(file=paste(di, "/data/output/Journals_X_Categories.txt", sep= ""), 
                        header = TRUE, sep = ';')
cat_journal <- cat_journal %>% select(Journal, SN=ISSN, Categoria)


# Join 
# unidos <- cat_journal %>% 
#   left_join(issn_unique, by = "SN")

unidos <- issn_unique %>% 
  right_join(cat_journal, by = "SN") 
```

    ## Warning in right_join_impl(x, y, by$x, by$y, suffix$x, suffix$y): joining
    ## factors with different levels, coercing to character vector

``` r
unidos_n <- unidos %>% filter(!is.na(n_papers)) %>% 
  group_by(Categoria) %>% summarise(sum_paper = sum(n_papers)) %>% 
  mutate(freq = round((sum_paper / sum(sum_paper))*100, 2)) %>% 
  arrange(desc(freq))

kable(unidos_n)
```

| Categoria                                        |  sum\_paper|   freq|
|:-------------------------------------------------|-----------:|------:|
| ECOLOGY                                          |         100|  10.76|
| PLANT SCIENCES                                   |          79|   8.50|
| GEOSCIENCES, MULTIDISCIPLINARY                   |          70|   7.53|
| ENVIRONMENTAL SCIENCES                           |          58|   6.24|
| ENTOMOLOGY                                       |          54|   5.81|
| MARINE & FRESHWATER BIOLOGY                      |          54|   5.81|
| ZOOLOGY                                          |          53|   5.71|
| GEOGRAPHY, PHYSICAL                              |          50|   5.38|
| GEOCHEMISTRY & GEOPHYSICS                        |          42|   4.52|
| LIMNOLOGY                                        |          27|   2.91|
| FORESTRY                                         |          23|   2.48|
| EVOLUTIONARY BIOLOGY                             |          21|   2.26|
| SOIL SCIENCE                                     |          20|   2.15|
| BIODIVERSITY CONSERVATION                        |          18|   1.94|
| OCEANOGRAPHY                                     |          17|   1.83|
| PARASITOLOGY                                     |          17|   1.83|
| BIOCHEMISTRY & MOLECULAR BIOLOGY                 |          15|   1.61|
| GENETICS & HEREDITY                              |          14|   1.51|
| ORNITHOLOGY                                      |          13|   1.40|
| METEOROLOGY & ATMOSPHERIC SCIENCES               |          12|   1.29|
| MINERALOGY                                       |          12|   1.29|
| VETERINARY SCIENCES                              |          12|   1.29|
| WATER RESOURCES                                  |          12|   1.29|
| GEOLOGY                                          |          10|   1.08|
| ASTRONOMY & ASTROPHYSICS                         |           8|   0.86|
| BIOTECHNOLOGY & APPLIED MICROBIOLOGY             |           8|   0.86|
| REMOTE SENSING                                   |           8|   0.86|
| BIOLOGY                                          |           7|   0.75|
| MICROBIOLOGY                                     |           7|   0.75|
| AGRONOMY                                         |           6|   0.65|
| ENGINEERING, ENVIRONMENTAL                       |           6|   0.65|
| BEHAVIORAL SCIENCES                              |           5|   0.54|
| MULTIDISCIPLINARY SCIENCES                       |           5|   0.54|
| PHYSIOLOGY                                       |           5|   0.54|
| BIOPHYSICS                                       |           4|   0.43|
| MYCOLOGY                                         |           4|   0.43|
| CHEMISTRY, ANALYTICAL                            |           3|   0.32|
| CHEMISTRY, APPLIED                               |           3|   0.32|
| ENGINEERING, GEOLOGICAL                          |           3|   0.32|
| FISHERIES                                        |           3|   0.32|
| IMAGING SCIENCE & PHOTOGRAPHIC TECHNOLOGY        |           3|   0.32|
| PALEONTOLOGY                                     |           3|   0.32|
| AGRICULTURAL ENGINEERING                         |           2|   0.22|
| AGRICULTURE DAIRY & ANIMAL SCIENCE               |           2|   0.22|
| BIOCHEMICAL RESEARCH METHODS                     |           2|   0.22|
| COMPUTER SCIENCE, INTERDISCIPLINARY APPLICATIONS |           2|   0.22|
| ENERGY & FUELS                                   |           2|   0.22|
| ENGINEERING, CIVIL                               |           2|   0.22|
| ENGINEERING, ELECTRICAL & ELECTRONIC             |           2|   0.22|
| HORTICULTURE                                     |           2|   0.22|
| MEDICINE, GENERAL & INTERNAL                     |           2|   0.22|
| PHYSICS, MULTIDISCIPLINARY                       |           2|   0.22|
| SPORT SCIENCES                                   |           2|   0.22|
| FOOD SCIENCE & TECHNOLOGY                        |           1|   0.11|
| HEMATOLOGY                                       |           1|   0.11|
| INFECTIOUS DISEASES                              |           1|   0.11|
| INSTRUMENTS & INSTRUMENTATION                    |           1|   0.11|
| MECHANICS                                        |           1|   0.11|
| MEDICINE, RESEARCH & EXPERIMENTAL                |           1|   0.11|
| MINING & MINERAL PROCESSING                      |           1|   0.11|
| PHYSICS, APPLIED                                 |           1|   0.11|
| PHYSICS, NUCLEAR                                 |           1|   0.11|
| PUBLIC, ENVIRONMENTAL & OCCUPATIONAL HEALTH      |           1|   0.11|
| TELECOMMUNICATIONS                               |           1|   0.11|
| THERMODYNAMICS                                   |           1|   0.11|
| TOXICOLOGY                                       |           1|   0.11|
