library(sf)
library(terra)
library(viridisLite)
library(soilDB)

source('WCS/config.R')

## collect SSA labels for HI, PR
pr.ssa <- SDA_query("SELECT areasymbol, saverest FROM sacatalog WHERE areasymbol LIKE 'PR%';")
hi.ssa <- SDA_query("SELECT areasymbol, saverest FROM sacatalog WHERE areasymbol LIKE 'HI%';")

## save SSA details
write.csv(pr.ssa, file = 'WCS/pr-SSA.csv', row.names = FALSE)
write.csv(hi.ssa, file = 'WCS/hi-SSA.csv', row.names = FALSE)

## download SSURGO archives
# ~ 10 minutes
td <- 'WCS/ssurgo-temp'
unlink(td, force = TRUE)
dir.create(td)
downloadSSURGO(
  areasymbols = c(hi.ssa$areasymbol, pr.ssa$areasymbol), 
  destdir = td, 
  include_template = FALSE, 
  remove_zip = TRUE, 
  overwrite = TRUE
)

## create temp SSURGO composite DB as geopkg
# ~ 700MB
# ~ 5 minutes
createSSURGO('WCS/ssurgo-data.gpkg', exdir = td)

## cleanup
unlink(td, force = TRUE, recursive = TRUE)

## cleanup
rm(list = ls())
gc(reset = TRUE)

