# install tm - uncomment if you haven't already installed
#install.packages("tm")

# use tm
library(tm)

# read in the emails. Col 1 is emailer, Col 2 is the text of the email as a "document"
emails = read.csv("../allTopEmailers.csv",sep='|')

# turn the documents into a corpus, as in lecture 4
corpus = VCorpus(VectorSource(emails$txt))

# inspect VCorpus
inspect(corpus)

# define function discussed in ppt
removeNumPunct = function(x) gsub("[^[:alpha:][:space:]]*", "", x)

# remove stopwords in an intermediate corpus
myStopwords <- c(stopwords('english'))
intermed = tm_map(corpus,removeWords,myStopwords)

# apply it to each document using tm_map
cleanCorpus = tm_map(intermed,content_transformer(removeNumPunct))

# get the TDMatrix
termDocMat = TermDocumentMatrix(cleanCorpus)