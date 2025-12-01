## 2025-12-01
## D.E. Beaudette
## Export the current SC database from local NASIS DB for use in SoilWeb and beyond
##

library(soilDB)

# refresh local NASIS first
sc <- get_soilseries_from_NASIS()

# 2025-12-01: 26573
nrow(sc)

# remove edit history
sc$soilseriesedithistory <- NULL

write.csv(sc, file = gzfile('files/SC-database.csv.gz'), row.names = FALSE)


## bugs and questions

# # 2025-11-30: there are some AK soil series missing suborder labels
# z <- sc[which(sc$soilseriesstatus == 'established' & is.na(sc$taxsuborder)), ]
# 
# knitr::kable(
#   z[, c('mlraoffice', 'soilseriesname', 'taxorder', 'taxsuborder', 'taxgrtgroup', 'taxsubgrp')],
#   row.names = FALSE
# )
