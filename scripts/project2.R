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