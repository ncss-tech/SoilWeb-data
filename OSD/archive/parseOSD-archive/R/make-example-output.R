library(stringi)
library(httr)
library(rvest)
library(plyr)
library(aqp)
library(soilDB)

source('local_functions.R')

# save a single example to file
makeExample <- function(x) {
  f <- sprintf("examples/osd-chunks/%s.txt", x)
  res <- jsonlite::toJSON(testIt(x), pretty = TRUE)
  
  sink(file = f)
  print(res)
  sink()
}


s <- c('tappan', 'kinross', 'geneva', 'pardee', 'sites', 'bordengulch', 'amador', 'toomes', 'cecil', 'leon', 'pierre', 'dylan', 'tristan')

for(i in s) {
  makeExample(i)
}

osd <- fetchOSD(s, extended = TRUE)

for(i in names(osd)[-1]) {
  f <- sprintf("examples/%s.csv", i)
  write.csv(osd[[i]], file=f, row.names = FALSE)
}

# siblings
# hmmm. error when series has a space in the name
sib <- ldply(s, function(i) siblings(i)$sib)
write.csv(sib, file='examples/siblings.csv', row.names = FALSE)


