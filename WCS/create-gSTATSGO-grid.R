
# 2025-04-25
# superceded by code in e:/gis_data/mukey-grids/
stop()


## Create (experimental) STATSGO2 mukey grid (300m) for SoilWeb WCS
## D.E Beaudette
## 2024-01-11

## TODO: consider a 150m grid, 300m is kind of chunky


library(terra)

.path <- 'e:/gis_data/mukey-grids'

# gNATSGO 300m mukey grid, used as template
x <- rast(file.path(.path, 'gNATSGO-mukey-ML-300m.tif'))

# latest STATSGO
s <- vect('e:/gis_data/STATSGO2/wss_gsmsoil_US_[2016-10-13]/spatial/gsmsoilmu_a_us.shp')

# transform to same CRS as gNATSGO
# AK, HI, PR not happy...
# we are only keeping CONUS anyway
s <- project(s, crs(x))

# store mukey as integer
options(scipen = 10000)
s$mukey.numeric <- as.numeric(s$MUKEY)

# rasterize to 300m grid
# ~ 30 seconds
system.time(
  g <- rasterize(
    s, x, 
    field = 'mukey.numeric'
  )
)


# save as UInt32
# NODATA encoded as 0
# will build overviews later
writeRaster(
  g, filename = file.path(.path, 'gSTATSGO-mukey.tif'), 
  overwrite = TRUE,
  datatype = 'INT4U', 
  NAflag = 0
)


## check: ok
# should be UInt32
# NODATA 0
i <- sf::gdal_utils(util = 'info', source = file.path(.path, 'gSTATSGO-mukey.tif'))


# sf::gdal_utils(util = 'info', source = 'e:/gis_data/mukey-grids/gNATSGO-mukey.tif')


