##
##
##

library(soilDB)
library(terra)
library(sf)

source('WCS/config.R')

## get grid masks
hi.m <- rast('WCS/hi-mask.tif')
pr.m <- rast('WCS/pr-mask.tif')

## extract composite pieces
# mu polygons (EPSG:4326)
hi.mu <- vect('WCS/ssurgo-data.gpkg', query = "SELECT * FROM mupolygon WHERE areasymbol LIKE 'HI%'")
pr.mu <- vect('WCS/ssurgo-data.gpkg', query = "SELECT * FROM mupolygon WHERE areasymbol LIKE 'PR%'")


## transform to local CRS
hi.mu <- project(hi.mu, crs(hi.m))
pr.mu <- project(pr.mu, crs(pr.m))


## convert mukey character -> numeric
hi.mu$mukey_int <- as.numeric(hi.mu$MUKEY)
pr.mu$mukey_int <- as.numeric(pr.mu$MUKEY)


## rasterize
# cell values are integer representation of mukey
hi.r <- rasterize(hi.mu, hi.m, field = 'mukey_int')
pr.r <- rasterize(pr.mu, pr.m, field = 'mukey_int')


## check: ok
# plot(pr.r, axes = FALSE, legend = FALSE, box = TRUE, col = hcl.colors(100))
# plot(hi.r, axes = FALSE, legend = FALSE, box = TRUE, col = hcl.colors(100))


## save locally
writeRaster(pr.r, filename = 'e:/gis_data/mukey-grids/pr-mukey-grid.tif', overwrite = TRUE, datatype = 'INT4U')
writeRaster(hi.r, filename = 'e:/gis_data/mukey-grids/hi-mukey-grid.tif', overwrite = TRUE, datatype = 'INT4U')


## check data types, nodata, etc.
# nodata: 4294967295
# OK
gdal_utils(util = 'info', source = 'e:/gis_data/mukey-grids/pr-mukey-grid.tif')
gdal_utils(util = 'info', source = 'e:/gis_data/mukey-grids/hi-mukey-grid.tif')

## cleanup
rm(list = ls())
gc(reset = TRUE)



