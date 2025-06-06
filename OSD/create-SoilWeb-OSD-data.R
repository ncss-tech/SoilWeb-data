library(aqp)
library(soilDB)
library(data.table)
library(progress)
# library(R.utils)

# special functions for OSD data preparation
source('local-functions.R')

# recent SC database from this repo
sc <- read.csv('../files/SC-database.csv.gz')

# only using soil series names
sc <- sc$soilseriesname

## working on the output from SKB->OSD getting / parsing

## TODO: double-check funky names like "O'BRIEN" and chars not [a-z]

## TODO: add entire OSD -> fulltext data

## TODO: narratives in the JSON files have leading white space

# this must point to a recent, working copy of the SKB repo
osd.path <- '../../SoilKnowledgeBase/inst/extdata/OSD'


# OSDs to process, typically all of them
# debugging
# idx <- 1:500
idx <- 1:length(sc)

# lists to hold pieces
hz.data <- list()
site.data <- list()
missing.file <- list()
fulltext.records <- list()
fulltext.all <- list()

# section names we will be extracting for SoilWeb / NASIS
# must match table definitions!
section.names <- c("OVERVIEW", "TAXONOMIC.CLASS", "TYPICAL.PEDON", "TYPE.LOCATION", "RANGE.IN.CHARACTERISTICS", "COMPETING.SERIES", "GEOGRAPHIC.SETTING", "GEOGRAPHICALLY.ASSOCIATED.SOILS", "DRAINAGE.AND.PERMEABILITY", "USE.AND.VEGETATION", "DISTRIBUTION.AND.EXTENT", "REMARKS", "ORIGIN", "ADDITIONAL.DATA")


## TODO: 
# * convert this to furrr / parallel processing

pb <- progress_bar$new(
  format = "  processing [:bar] :percent eta: :eta", 
  total = length(sc[idx])
)

# ~ 6 minutes on GFE
# ~ 4 minutes on 4-1
# iteration over series names
for(i in sc[idx]) {

  pb$tick()
    
  # important notes:
  # * some series in SC may not exist here
  # * these files may contain data.frames of varying structure
  osddf <- get_OSD(i, result = 'json', base_url = osd.path, fix_ocr_errors = TRUE)
  
  # typical pedon section, already broken into pieces
  hz <- osddf[['HORIZONS']][[1]]
  s <- osddf[['SITE']][[1]]
  
  # missing files / generate warnings
  if(is.null(hz)) {
    missing.file[[i]] <- i
    next
  }
  
  ## horizon data
  # file exists, but perhaps nothing was extracted... why?
  if(inherits(hz, 'data.frame')) {
    if(nrow(hz) > 0) {
      # add series name to last column, for compatibility with SoilWeb OSD import
      hz$seriesname <- i
      
      # append
      hz.data[[i]] <- hz
    }
  }
  
  ## site data
  # columns should contain: drainage, drainage_overview, id
  if(inherits(s, 'data.frame')) {
    # remove 'id' column
    s$id <- NULL
    
    ## TODO: consider keeping both
    # if the drainage class is missing from the DRAINAGE section use whatever was found in the overview
    s$drainage <- ifelse(is.na(s$drainage), s$drainage_overview, s$drainage)
    
    # remove drainage overview for now
    s$drainage_overview <- NULL
    
    # add series name
    s$seriesname <- i
    
    # append
    site.data[[i]] <- s
  }
  
  ## attempt narrative chunks
  .narratives <- list()
  for(sn in section.names) {
    .text <- osddf[[sn]]
    
    # remove section title, not present in all sections
    .text <- gsub(pattern = "^[a-zA-Z1-9 ]+\\s?:\\s*", replacement = "", x = .text)
    
    # convert NA -> ''
    
    # pack into a list for later
    .narratives[[sn]] <- .text
  }
  
  ## store the section fulltext INSERT statements
  # with compression: 61 MB
  # without compression: 232 MB
  fulltext.records[[i]] <- memCompress(
    .ConvertToFullTextRecord2(s = i, narrativeList = .narratives),
    type = 'gzip'
  )
  
  ## store entire OSD without section names for OSD-fulltext table
  fulltext.all[[i]] <- memCompress(
    .ConvertToFullTextRecord(s = i, s.lines = .narratives),
    type = 'gzip'
  )
  
}


pb$terminate()





## flatten
# missing files: likely old / retired OSDs
# 2023-02-09: 1686
# 2023-08-18: 1724
# 2023-10-01: 1739
# 2024-04-24: 1730
# 2024-10-17: 1827
# 2025-05-29: 1910
missing.file <- as.vector(do.call('c', missing.file))
length(missing.file)

## horizon data: may not share the same column-ordering
hz <- as.data.frame(rbindlist(hz.data, fill = TRUE))

# re-order
vars <- c("name", "top", "bottom", "dry_hue", "dry_value", "dry_chroma", 
          "moist_hue", "moist_value", "moist_chroma", "texture_class", 
          "cf_class", "pH", "pH_class", "eff_class", "distinctness", "topography", "narrative", 
          "seriesname")

hz <- hz[, vars]

## site data, all items should be conformal
s <- as.data.frame(rbindlist(site.data))


## save hz + site data
write.csv(hz, file = gzfile('parsed-data.csv.gz'), row.names = FALSE)
write.csv(s, file = gzfile('parsed-site-data.csv.gz'), row.names = FALSE)

## re-make section fulltext table + INSERT statements
# 2.3 seconds on 4-1
system.time(
  .makeFullTextSectionsTable(fulltext.records)
)

## remake entire OSD full text table + INSERT statements
# 2.3 seconds on 4-1
system.time(
  .makeFullTextTable(fulltext.all)
)


## TODO: no longer needed when running on 4-1
# gzip
# R.utils::gzip('fulltext-section-data.sql', overwrite = TRUE)
# R.utils::gzip('fulltext-data.sql', overwrite = TRUE)


## TODO: finish eval / comparison of both methods

rm(list = ls(all.names = TRUE))
gc(reset = TRUE)

## fill missing colors
source('predict-missing-colors-OLS.R')


rm(list = ls(all.names = TRUE))
gc(reset = TRUE)

source('predict-missing-colors-procrustes.R')

rm(list = ls(all.names = TRUE))
gc(reset = TRUE)




