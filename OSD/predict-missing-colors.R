##
##
##


## TODO:
# * archive old code / content
# * new QC output
# * links to source models / documentation


# >= 2.3.2
library(aqp)

# source data ----
x <- read.csv('parsed-data.csv.gz')
str(x)


# add a flags for estimated colors
x$dry_color_estimated <- FALSE
x$moist_color_estimated <- FALSE


# find missing O horizon colors ----
data("Ohz.colors")

# lookup function for genhz/state combinations
OC <- function(n, s) {
  
  .idx <- which(Ohz.colors$genhz == n & Ohz.colors$state == s)
  .o <- Ohz.colors[.idx, ]
  
  .m <- parseMunsell(.o$L1.munsell, convertColors = FALSE)
  
  .res <- data.frame(
    hz = .o$genhz,
    state = .o$state,
    .m
  )
  
  return(.res)
}



## replace missing values ----


# Oi / dry
(o <- OC('Oi', 'dry'))
idx <- which(grepl('Oi', x$name) & is.na(x$dry_hue))

x$dry_color_estimated[idx] <- TRUE
x$dry_hue[idx] <- o$hue
x$dry_value[idx] <- o$value
x$dry_chroma[idx] <- o$chroma


# Oi / moist
(o <- OC('Oi', 'moist'))
idx <- which(grepl('Oi', x$name) & is.na(x$moist_hue))

x$moist_color_estimated[idx] <- TRUE
x$moist_hue[idx] <- o$hue
x$moist_value[idx] <- o$value
x$moist_chroma[idx] <- o$chroma


# Oe / dry
(o <- OC('Oe', 'dry'))
idx <- which(grepl('Oe', x$name) & is.na(x$dry_hue))

x$dry_color_estimated[idx] <- TRUE
x$dry_hue[idx] <- o$hue
x$dry_value[idx] <- o$value
x$dry_chroma[idx] <- o$chroma


# Oe / moist
(o <- OC('Oe', 'moist'))
idx <- which(grepl('Oe', x$name) & is.na(x$moist_hue))

x$moist_color_estimated[idx] <- TRUE
x$moist_hue[idx] <- o$hue
x$moist_value[idx] <- o$value
x$moist_chroma[idx] <- o$chroma


# Oa / dry
(o <- OC('Oa', 'dry'))
idx <- which(grepl('Oa', x$name) & is.na(x$dry_hue))

x$dry_color_estimated[idx] <- TRUE
x$dry_hue[idx] <- o$hue
x$dry_value[idx] <- o$value
x$dry_chroma[idx] <- o$chroma


# Oa / moist
(o <- OC('Oa', 'moist'))
idx <- which(grepl('Oa', x$name) & is.na(x$moist_hue))

x$moist_color_estimated[idx] <- TRUE
x$moist_hue[idx] <- o$hue
x$moist_value[idx] <- o$value
x$moist_chroma[idx] <- o$chroma


# everything else, dry
(o <- OC('other', 'dry'))
idx <- which(grepl('O', x$name) & is.na(x$dry_hue))

x$dry_color_estimated[idx] <- TRUE
x$dry_hue[idx] <- o$hue
x$dry_value[idx] <- o$value
x$dry_chroma[idx] <- o$chroma


# everything else, moist
(o <- OC('other', 'moist'))
idx <- which(grepl('O', x$name) & is.na(x$moist_hue))

x$moist_color_estimated[idx] <- TRUE
x$moist_hue[idx] <- o$hue
x$moist_value[idx] <- o$value
x$moist_chroma[idx] <- o$chroma


## check filling of O hz colors ----
table(dry_color_estimated = x$dry_color_estimated, Oi = grepl('Oi', x$name))
table(dry_color_estimated = x$dry_color_estimated, Oe = grepl('Oe', x$name))
table(dry_color_estimated = x$dry_color_estimated, Oa = grepl('Oa', x$name))
table(dry_color_estimated = x$dry_color_estimated, O = grepl('O', x$name))

table(moist_color_estimated = x$moist_color_estimated, Oi = grepl('Oi', x$name))
table(moist_color_estimated = x$moist_color_estimated, Oe = grepl('Oe', x$name))
table(moist_color_estimated = x$moist_color_estimated, Oa = grepl('Oa', x$name))
table(moist_color_estimated = x$moist_color_estimated, O = grepl('O', x$name))

# OK



# basic QC on colors -> save to QC folder ----

# safe formatting of Munsell notation (aqp >= 2.3.2)
x.m <- formatMunsell(x$moist_hue, x$moist_value, x$moist_chroma)
x.d <- formatMunsell(x$dry_hue, x$dry_value, x$dry_chroma)


options(scipen = 10)

# 2026-03-19: 99.99% of non-NA colors passing
v <- validateMunsell(na.omit(x.m))
prop.table(table(v))

# 100% non-NA colors passing
v <- validateMunsell(na.omit(x.d))
prop.table(table(v))


## TODO: think about these colors
#
# 10YR 1/1 10YR 1/2 10YR 1/3 2.5Y 1/1 
# 6        2        1        1 
table(na.omit(x.m)[which(!na.omit(v))])


# 2026-03-19: 91% of all moist colors passing 
v <- validateMunsell(x.m)
prop.table(table(v))

# 67% of all dry colors passing 
v <- validateMunsell(x.d)
prop.table(table(v))


# identify missing moist | dry colors ----

# moist: 11940
length(m.na.idx <- which(is.na(x.m)))

# dry: 47036
length(d.na.idx <- which(is.na(x.d)))

# identify missing colors with paired moist|dry colors available

# moist: 4516
length(m.to.est.idx <- which(is.na(x.m) & !is.na(x.d)))

# dry: 39612
length(d.to.est.idx <- which(is.na(x.d) & !is.na(x.m)))



# replace missing mineral soil colors ----

# split into hue, value, chroma for estimation
x.m.m <- parseMunsell(x.m, convertColors = FALSE)
x.d.d <- parseMunsell(x.d, convertColors = FALSE)

# NOTE: result from estimateSoilColor() is a data.frame


## estimate moist from dry colors ----

# estimate moist from dry
.e <- estimateSoilColor(
  hue = x.d.d$hue[m.to.est.idx], 
  value = x.d.d$value[m.to.est.idx], 
  chroma = x.d.d$chroma[m.to.est.idx], method = 'ols', 
  sourceMoistureState = 'dry', 
  returnMunsell = TRUE
)

# update moist colors in original data
x$moist_hue[m.to.est.idx] <- .e$hue
x$moist_value[m.to.est.idx] <- .e$value
x$moist_chroma[m.to.est.idx] <- .e$chroma

# mark these colors as estimated in original data
x$moist_color_estimated[m.to.est.idx] <- TRUE

# FALSE   TRUE 
# 136132   7396
table(is.na(x$moist_hue))


## estimate dry from moist colors ----
# GFE: ~ 6 seconds

# estimate dry from moist
system.time(
  .e <- estimateSoilColor(
    hue = x.m.m$hue[d.to.est.idx], 
    value = x.m.m$value[d.to.est.idx], 
    chroma = x.m.m$chroma[d.to.est.idx], method = 'ols', 
    sourceMoistureState = 'moist', 
    returnMunsell = TRUE
  )  
)

# update dry colors in original data
x$dry_hue[d.to.est.idx] <- .e$hue
x$dry_value[d.to.est.idx] <- .e$value
x$dry_chroma[d.to.est.idx] <- .e$chroma

# mark these colors as estimated in original data
x$dry_color_estimated[d.to.est.idx] <- TRUE


# FALSE   TRUE 
# 136123   7405
table(is.na(x$dry_hue))


# final cleanup

# convert logical -> character for portability
x$dry_color_estimated <- as.character(x$dry_color_estimated)
x$moist_color_estimated <- as.character(x$moist_color_estimated)


# save results ----
write.csv(x, file = gzfile('parsed-data-est-colors.csv.gz'), row.names = FALSE)


# clean up ----
rm(list = ls(all.names = TRUE))
gc(reset = TRUE)



