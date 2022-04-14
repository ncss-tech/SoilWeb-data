
library(stringi)
library(httr)
library(plyr)
library(rvest)

source('local_functions.R')

## toggles

# use a small, random sample for testing
testingMode <- FALSE

# re-make tables? used when parsing the entire collection
remakeTables <- TRUE

## TODO: this isn't ready, as we don't have the full dataset for filling of missing colors
# emit a DELETE FROM ... to an update.sql file, remove those series which will be updated
updateMode <- FALSE



# load latest SC-database
download.file(url = 'https://github.com/ncss-tech/SoilTaxonomy/raw/master/databases/SC-database.csv.gz', destfile = 'SC-database.csv.gz')
x <- read.csv('SC-database.csv.gz', stringsAsFactors=FALSE)

# keep only those records that are established or tentative
x <- subset(x, subset= series_status != 'inactive')

# optionally  keep only those series updated within last x months
if(updateMode) {
  remakeTables <- FALSE
  x <- x[which(x$objwlupdated > as.POSIXct('2017-06-01 00:00:00')), ]
}

# keep just the series names 
x <- x$soilseriesname

# init list to store results
l <- list()

# list for site-level data
sl <- list()

# init list to store log
parseLog <- list()


# note: we have to explicitly set the file encoding, as there are non-ASCII characters in these files.. not sure why
if(remakeTables) {
  # resest fulltext SQL file
  cat('DROP TABLE osd.osd_fulltext;\n', file='fulltext-data.sql')
  cat('CREATE TABLE osd.osd_fulltext (series citext, fulltext text);\n', file='fulltext-data.sql', append = TRUE)
  cat("set client_encoding to 'latin1 ;\n", file='fulltext-data.sql', append = TRUE)
  
  ## need to adjust fields manually as we edit
  cat('DROP TABLE osd.osd_fulltext2;\n', file='fulltext-section-data.sql')
  cat('CREATE TABLE osd.osd_fulltext2 (
series citext,
brief_narrative text,
taxonomic_class text,
typical_pedon text,
type_location text,
ric text,
competing_series text,
geog_location text,
geog_assoc_soils text,
drainage text,
use_and_veg text,
distribution text,
remarks text,
established text,
additional_data text
    );\n', file='fulltext-section-data.sql', append = TRUE)
  cat("set client_encoding to 'latin1 ;\n", file='fulltext-section-data.sql', append = TRUE)
}

# generate some extra SQL that will delete those series being updated
if(updateMode) {
  sql <- "DELETE FROM osd.osd_colors WHERE series IN "
  sql <- paste0(sql, soilDB::format_SQL_in_statement(x), ' ;')
  cat(sql, file='delete-for-update.sql')
}

# cut down to a smaller number of series for testing
if(testingMode) {
  x <- x[sample(1:length(x), size = 50)]
}

for(i in x) {
  print(i)
  
  # result is a list
  i.lines <- try(getOSD(i), silent = TRUE)
  
  # there are some OSDs that may not exist
  if(class(i.lines) == 'try-error') {
    l[[i]] <- NULL
    parseLog[[i]][['sections']] <- FALSE
    parseLog[[i]][['hz-data']] <- FALSE
  } else {
    
    # register section REGEX
    # this sets / updates a global variable
    setSectionREGEX(i)
    
    ## no logging, this usually works fine
    # get rendered HTML->text and save to file 
    i.fulltext <- ConvertToFullTextRecord(i, i.lines)
    cat(i.fulltext, file = 'fulltext-data.sql', append = TRUE)
    
    # split data into sections for fulltext search, catch errors related to parsing sections
    i.sections <- try(ConvertToFullTextRecord2(i, i.lines))
    if(class(i.sections) != 'try-error') {
      cat(i.sections, file = 'fulltext-section-data.sql', append = TRUE)
      parseLog[[i]][['sections']] <- TRUE
      
    } else {
      parseLog[[i]][['sections']] <- FALSE
    }
      
    
    # append hz data to our list, catch errors related to parsing sections
    hz.data <- try(extractHzData(i.lines), silent = TRUE)
    
    # append site data to our list, catch errors related to parsing sections
    section.data <- try(extractSections(i.lines), silent = TRUE)
    site.data <- try(extractSiteData(section.data), silent = TRUE)
    
    ## TODO: this isn't likely correct
    # NULL results means that there was a parse error
    parseLog[[i]][['hz-data']] <- ! is.null(hz.data)
    
    # try-error means no OSD
    if(class(hz.data) != 'try-error') {
      l[[i]] <- hz.data
    }
    
    # try-error means sections / site data not parsed
    if(class(site.data) != 'try-error') {
      sl[[i]] <- site.data
    }
    
  }
    
}


## TODO, do some basic error-checking on typos in the hue


# convert log to DF
logdata <- ldply(parseLog)

# 97% sections parsed
# prop.table(table(sapply(parseLog, function(i) i[['sections']])))
# prop.table(table(sapply(parseLog, function(i) i[['hz-data']])))

prop.table(table(logdata$sections))
prop.table(table(logdata$`hz-data`))

# save dated log file
write.csv(logdata, file=paste0('logfile-', Sys.Date(), '.csv'), row.names=FALSE)

# ID those series that were not parsed
parse.errors <- logdata$.id[which(! logdata$`hz-data` & logdata$sections)]
cat(parse.errors, file=paste0('problem-OSDs-', Sys.Date(), '.txt'), sep = '\n')


# convert parsed horizon data to DF and save
d <- ldply(l)
d$seriesname <- d$.id
d$.id <- NULL
write.csv(d, file=gzfile('parsed-data.csv.gz'), row.names=FALSE)

# convert parsed site data to DF and save
d <- ldply(sl)
d$seriesname <- d$.id
d$.id <- NULL
write.csv(d, file=gzfile('parsed-site-data.csv.gz'), row.names=FALSE)





