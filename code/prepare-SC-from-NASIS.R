## 2021-09-10
## D.E. Beaudette
## Export the current SC database from local NASIS DB
##

library(soilDB)

sc <- get_soilseries_from_NASIS()

write.csv(sc, file = gzfile('../files/SC-database.csv.gz'), row.names = FALSE)







