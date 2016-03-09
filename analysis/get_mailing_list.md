### Create a csv with the potential mail list

We compiled a mail list from several sources:

-   Dossier
-   Sierra Nevada LTER Research community
-   Literature Review Search (WOS)

#### Dossier

A sql query to db `dossier_filiaciones` was done

``` sql
SELECT 
  dicc_autores.email
FROM 
  public.dicc_autores;
```

Save as: `/data/mail_raw/dossier_filiaciones.csv`

#### Sierra Nevada LTER Research community

Several sql queries from db `nodo_lter_sn`

``` sql
SELECT 
  "Investigadores_solicitudes".email
FROM 
  public."Investigadores_solicitudes" 
WHERE 
  "Investigadores_solicitudes".email IS NOT NULL AND
  "Investigadores_solicitudes".email <> '';
```

Save as: `/data/mail_raw/investigadores_solicitudes.csv`

``` sql
SELECT 
  eez.email
FROM 
  public.eez
WHERE 
  eez.email IS NOT NULL AND
  eez.email <> '';
```

Save as: `/data/mail_raw/eez.csv`

#### Literature Review Search (WOS)

Get the data from [`/analysis/cleaning_data.md`](analysis/cleaning_data.md)

Read all data and create output mailist
---------------------------------------

``` r
library("dplyr")
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
# Read data
mail_wos <- read.csv(file=paste(di, "/data/output/lista_emails_wos.csv", sep=""),
                     header=TRUE) 

mail_dos <- read.csv(file=paste(di, "/data/mail_raw/dossier_filiaciones.csv", sep=""), 
                     header=TRUE) 

mail_inv <- read.csv(file=paste(di, "/data/mail_raw/investigadores_solicitudes.csv", sep=""), 
                     header=TRUE) 
    
mail_eez <- read.csv(file=paste(di, "/data/mail_raw/eez.csv", sep=""), 
                     header=TRUE) 

# Join, remove duplicates and sort 
mail <- rbind_all(list(mail_eez,mail_inv,mail_dos,mail_wos)) %>%
  unique() %>%
  arrange(email) 
```

    ## Warning in rbind_all(list(mail_eez, mail_inv, mail_dos, mail_wos)): Unequal
    ## factor levels: coercing to character

``` r
# Export 
write.csv(mail, file=paste(di, "/data/output/potential_mail.csv", sep=""), quote=FALSE, row.names = FALSE)
```
