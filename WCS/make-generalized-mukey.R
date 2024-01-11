## Approximate gNATSGO mukey grid with a 300m modal filter. 
## This is not aggregation, only for rapid preview of thematic maps and testing.
## 
## D.E Beaudette
## 2024-01-11

library(soilDB)
library(terra)

# local files
.path <- 'e:/gis_data/mukey-grids'

# current FY mukey grid, 30m res
x <- rast(file.path(.path, 'gNATSGO-mukey.tif'))

## 300m approximated gNATSGO grid
# ~ 15 minutes
system.time(
  a <- aggregate(
    x, 
    fact = 10, 
    fun = 'modal', 
    filename = file.path(.path, 'gNATSGO-mukey-ML-300m.tif'), 
    overwrite = TRUE
  )
)


## sanity check: STATSGO mukey in aggregate version?
s <- SDA_query("SELECT mukey FROM legend INNER JOIN mapunit ON legend.lkey = mapunit.lkey WHERE areasymbol = 'US';")
# 9562
nrow(s)


# integer grid -> grid + RAT
a <- as.factor(a)

# extract rat
rat <- cats(a)[[1]]

## hmmm: 1273 STATSGO mukey remain...why?
length(which(s$mukey %in% rat$ID))



