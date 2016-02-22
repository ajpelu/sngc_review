getwd()


# Read table 
q1 <- read.csv(file="/Users/ajpelu/Dropbox/Review_Sierra_Nevada/Data/Search_19_02_16_1_A_500_Campos_limitados.txt",
              header = TRUE,
              sep = '\t')

str(q1)


# ver esto http://stackoverflow.com/questions/24771165/r-project-no-applicable-method-for-meta-applied-to-an-object-of-class-charact 

library(dplyr)

mydf <- q1 %>% select(AU, AB)

## text mining 
# install.packages('tm')
library("tm")

a <- Corpus(VectorSource(mydf$AB))
a <- tm_map(a, content_transformer(tolower))


a <- tm_map(a, removePunctuation) 
a <- tm_map(a, removeNumbers)
a <- tm_map(a, removeWords, stopwords("english"))
a <- tm_map(a, removeWords, stopwords("english")) # this list needs to be edited and this function repeated a few times to remove high frequency context specific words with no semantic value 
require(rJava) # needed for stemming function 
require(SnowballC)

a <- tm_map(a, stemDocument, language = "english") # converts terms to tokens
a.tdm <- DocumentTermMatrix(a, control = list(minWordLength = 3)) 


findFreqTerms(a.tdm, lowfreq=30)


# create a term document matrix, keepiing only tokens longer than three characters, since shorter tokens are very hard to interpret
inspect(a.tdm[1:10,1:10]) # have a quick look at the term document matrix
findFreqTerms(a.tdm, lowfreq=30) # have a look at common words, in this case, those that appear at least 30 times, good to get high freq words and add to stopword list and re-make the dtm, in this case add aaa, panel, session
findAssocs(a.tdm, 'scienc', 0.3) # find associated words and strength of the common words. I repeated this function for the ten most frequent words.

