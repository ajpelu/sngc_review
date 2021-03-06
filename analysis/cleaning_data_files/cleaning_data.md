Import raw data
---------------

``` r
library("stringr") 
library("dplyr")
```

    ## 
    ## Attaching package: 'dplyr'
    ## 
    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library("tidyr")
library("ggplot2")
```

    ## Warning: package 'ggplot2' was built under R version 3.2.3

``` r
# Read raw files
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

rawdf <- rbind(bioCI, bioP, med, wos1, wos2, zoo)
```

### Create several subsets

First we want to create a table with the authors and the corresponding author.

``` r
d <- rawdf[, c("Authors..Primary", "Author.Address")]
names(d) <- c("authors", "address")

# Option 1. Get a colum with all authors 
all_authors <- as.data.frame(unlist(stringr::str_split(d$authors, pattern = ";")))
names(all_authors)[1] <- 'author'

# Option 2. Dataframe with one auhtor per colum 
# Determine the max number of columns based on ";"
max_columnas <- max(stringr::str_count(d$authors, pattern=";"))

# Create vector with columns name
vec_columnas <- paste0("a", 1:(max_columnas + 1))

all_authors_colum <- tidyr::separate(d, authors, into=vec_columnas, extra="merge", sep=";")
```

    ## Warning: Too few values at 1036 locations: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    ## 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, ...

``` r
#### Create a dataframe with unique authors
all_authors_clean <- all_authors %>% 
  mutate(author = str_replace_all(author, pattern = ",", replacement = " ")) %>%  # Replace "," by " "
  arrange(desc(author)) %>% # Sort 
  filter(!duplicated(author))

# Export unique dataframe authors
write.csv(all_authors_clean, file=paste(di, "/data/output/lista_author_wos.csv", sep=""), row.names = FALSE)
```

``` r
# Matching e-mail address 
# via Gaston Sanchez http://gastonsanchez.com/Handling_and_Processing_Strings_in_R.pdf 

# Create a varible (binari) indicating if there is email adress in the Address Field
d$email_yes <- stringr::str_count(d$address, pattern="@")

# How many records has email address? 
sum(d$email_yes, na.rm = TRUE)
```

    ## [1] 709

``` r
# 

# Define a pattern for email 
# From http://stackoverflow.com/questions/25076575/how-to-extract-expression-matching-an-email-address-in-a-text-file-using-r-or-co 
# See also http://regexper.com/ 
email_pattern <- "([_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,4}))"

email_adress <- stringr::str_extract_all(d$address, email_pattern, simplify = TRUE)

data_allpotential <- cbind(all_authors_colum, email_adress)
# Export data_all_potential
write.csv(data_allpotential, file=paste(di, "/data/output/lista_authors_mails_wos.csv", sep=""), row.names = FALSE)


## Generate a list of unique mails
lista_emails <- stringr::str_extract_all(d$address, email_pattern, simplify = TRUE)

# Create a dataframe with the unique emails
library("reshape2")
melt_emails <- melt(lista_emails, na.rm=TRUE)
lista_emails_unicos <- as.data.frame(unique(melt_emails$value))
names(lista_emails_unicos)[1] <- 'email'

# Export 
write.csv(lista_emails_unicos, file=paste(di, "/data/output/lista_emails_wos.csv", sep=""), row.names = FALSE)
```

### Preliminary Analysis of the Journals

``` r
# Get journal name and year
jo <- rawdf %>% 
  group_by(Periodical.Full) %>% 
  summarise(count=n()) %>%
  arrange(desc(count))

write.table(jo, file=paste(di, "/data/output/sta_cout_by_journal.csv", sep=""), row.names = FALSE)
```

### Papers by year

``` r
art_by_year <- rawdf %>% 
  group_by(Pub.Year) %>% 
  summarise(count=n()) %>%
  mutate(cum=cumsum(count),
         ln_sum=log(cum)) %>%
  arrange(desc(Pub.Year))

ggplot(art_by_year, aes(x=Pub.Year, y=count)) + 
  geom_bar(stat = "identity") + 
  theme_bw() + ylab("n papers") + xlab("Year")
```

![](cleaning_data_files/figure-markdown_github/unnamed-chunk-5-1.png)

``` r
ggplot(art_by_year, aes(x=Pub.Year, y=ln_sum)) + 
  geom_line(stat="identity", col="blue", size=1) +
  geom_point(stat = "identity", col="blue", size=2.5, shape=19) + 
  theme_bw() + ylab("ln (n papers)") + xlab("Year")
```

![](cleaning_data_files/figure-markdown_github/unnamed-chunk-5-2.png)
