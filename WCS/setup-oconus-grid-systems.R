library(soilDB)
library(terra)
library(sf)

# CRS definitions
source('WCS/config.R')


## define SSA boundaries (EPSG:4326)
hi.b <- vect('WCS/ssurgo-data.gpkg', query = "SELECT * FROM sapolygon WHERE areasymbol LIKE 'HI%'")
pr.b <- vect('WCS/ssurgo-data.gpkg', query = "SELECT * FROM sapolygon WHERE areasymbol LIKE 'PR%'")

## transform to local, projected CRS
hi.b <- project(hi.b, crs.hi)
pr.b <- project(pr.b, crs.pr)

## establish local grid, 90m for testing, 30m final
# round to integer extent
hi.g <- rast(round(ext(hi.b)), res = 30)
pr.g <- rast(round(ext(pr.b)), res = 30)

crs(hi.g) <- crs.hi
crs(pr.g) <- crs.pr

## establish masks
hi.m <- rasterize(hi.b, hi.g, value = 1)
pr.m <- rasterize(pr.b, pr.g, value = 1)

## check: ok
# plot(hi.m, axes = FALSE, legend = FALSE, box = TRUE)
# plot(pr.m, axes = FALSE, legend = FALSE, box = TRUE)

## save grids
writeRaster(hi.m, filename = 'WCS/hi-mask.tif', overwrite = TRUE)
writeRaster(pr.m, filename = 'WCS/pr-mask.tif', overwrite = TRUE)


## cleanup
rm(list = ls())
gc(reset = TRUE)



