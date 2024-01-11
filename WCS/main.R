## Prepare mukey and derivative grids for SoilWeb WCS
## D.E. Beaudette
## 2024-01-11

## NOTES:
# * results are saved locally for transfer to SoilWeb servers by me


## get SSURGO data for OCONUS
# result is a local GeoPKG
source('WCS/get-oconus-ssurgo-data.R')

## setup grid system from SSA boundaries
# result is set of tiff masks
source('WCS/setup-oconus-grid-systems.R')

## rasterize SSURGO along grid system
# result is a set of tiffs + RATs, mukeys
source('WCS/rasterize-oconus-ssurgo.R')


## cleanup

# OCONUS SSURGO GeoPKG
unlink('WCS/ssurgo-data.gpkg')

# MASK tiffs
unlink('WCS/pr-mask.tif')
unlink('WCS/hi-mask.tif')
