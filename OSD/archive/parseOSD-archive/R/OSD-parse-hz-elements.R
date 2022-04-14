library(soilDB)
library(stringi)
library(purrr)
library(aqp)

source('local_functions.R')

# s.list <- c('musick', 'cecil', 'drummer', 'amador', 'pentz', 'pardee', 'inks', 'capay', 'whiterock', 'reiff')
# x <- fetchOSD(s.list)

x <- fetchOSD('cecil')


x$texture_class <- parse_texture(x$narrative)
x$cf_class <- parse_CF(x$narrative)
x$pH <- parse_pH(x$narrative)
x$pH_class <- parse_pH_class(x$narrative)


plot(x, color='texture_class')
plot(x, color='cf_class')
plot(x, color='pH')
plot(x, color='pH_class')



