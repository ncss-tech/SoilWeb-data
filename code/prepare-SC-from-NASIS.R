## 2023-08-17
## D.E. Beaudette
## Export the current SC database from local NASIS DB
##

library(soilDB)

# refresh local NASIS
sc <- get_soilseries_from_NASIS()

nrow(sc)

# remove edit history
sc$soilseriesedithistory <- NULL

write.csv(sc, file = gzfile('files/SC-database.csv.gz'), row.names = FALSE)

