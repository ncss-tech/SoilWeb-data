##
## TODO: is this approach as accurate as 4x OLS models with RCS terms? 
##  ---> likely more accurate
##
 

library(vegan)
library(aqp)
library(farver)
library(lattice)
library(tactile)
library(grid)
library(igraph)
library(sharpshootR)

## from OSDs
d <- read.csv('parsed-data.csv.gz', stringsAsFactors=FALSE)

## build training data

# no missing data
x <- na.omit(d[, c('dry_hue', 'dry_value', 'dry_chroma', 'moist_hue', 'moist_value', 'moist_chroma')])

# split, convert to CIELAB

# not all can be converted: invalid hues
lab.dry <- munsell2rgb(x$dry_hue, x$dry_value, x$dry_chroma, returnLAB = TRUE)
lab.moist <- munsell2rgb(x$moist_hue, x$moist_value, x$moist_chroma, returnLAB = TRUE)

names(lab.dry) <- sprintf("dry.%s", names(lab.dry))
names(lab.moist) <- sprintf("moist.%s", names(lab.moist))

# combine
z <- data.frame(lab.dry, lab.moist, x)
head(z)
summary(z)

# missing CIELAB due to bogus hues
z <- na.omit(z)

# convert to Munsell notation for colorContrast()
z$dry_Munsell <- sprintf('%s %s/%s', z$dry_hue, z$dry_value, z$dry_chroma)
z$moist_Munsell <- sprintf('%s %s/%s', z$moist_hue, z$moist_value, z$moist_chroma)

# ~ 1 minute
cc <- colorContrast(z$dry_Munsell, z$moist_Munsell)

# double-check data are the same shape
stopifnot(nrow(cc) == nrow(z))

# copy dE00 over from contrast class eval
z$dE00.o <- cc$dE00

# used later for color comparisons
moist.vars <- c('moist.L', 'moist.A', 'moist.B')
dry.vars <- c('dry.L', 'dry.A', 'dry.B')

# # compute dE00: dry -- moist
# z$dE00.o <- NA
# for(i in 1:nrow(z)) {
#   z$dE00.o[i] <- compare_colour(from = z[i, moist.vars], to = z[i, dry.vars], from_space = 'lab', to_space = 'lab', white_from = 'd65', white_to = 'd65', method = 'CIE2000')
# }


ragg::agg_png(filename = 'figures/dry-vs-moist-colors-dE00.png', width = 1000, height = 500, scaling = 1.5)

# expected range + likely mistakes
histogram(
  z$dE00.o[z$dE00.o < 35], 
  breaks = 50, 
  par.settings = tactile.theme(), 
  scales = list(x = list(tick.number = 16)), 
  xlab = 'CIE2000 Color Contrast Metric', 
  main = 'Perceptual Differences: Moist \u2194 Dry Soil Colors', 
  sub = 'Official Series Descriptions, ~78k horizons',
  panel = function(...) {
    panel.grid(-1, -1)
    panel.histogram(...)
    
    grid.text('approximately\n1-unit change\nMunsell value', x = unit(7, units = 'native'), y = unit(0.85, 'npc'), hjust = 0.5, gp = gpar(cex = 0.75))
    
    grid.text('approximately\n2-unit change\nMunsell value', x = unit(16.5, units = 'native'), y = unit(0.85, 'npc'), hjust = 0.5, gp = gpar(cex = 0.75))
    
    grid.text('approximately\n3-unit change\nMunsell value', x = unit(28, units = 'native'), y = unit(0.3, 'npc'), hjust = 0.5, gp = gpar(cex = 0.75))
    
    grid.text('truncated at dE00 < 35\nlikely parsing errors', x = unit(36, units = 'native'), y = unit(0.66, 'npc'), hjust = 1, gp = gpar(cex = 0.66))
    
    grid.text('\u2190', x = unit(35, units = 'native'), y = unit(0.55, 'npc'), hjust = 1, gp = gpar(cex = 2))
})

dev.off()



sort(table(cc$dH), decreasing = TRUE)
sort(table(cc$dV), decreasing = TRUE)
sort(table(cc$dC), decreasing = TRUE)

dotplot(sort(table(cc$dH), decreasing = TRUE))
dotplot(sort(table(cc$dV), decreasing = TRUE))
dotplot(sort(table(cc$dC), decreasing = TRUE))

colorContrast('10YR 2/3', '10YR 4/3')

quantile(z$dE00.o)

# what is the expected rate of shift in hue?
prop.table(table(z$moist_hue != z$dry_hue))
boxplot(dE00.o ~ moist_hue != dry_hue, data = z, horizontal = TRUE)


# quick viz
z$dry.col <- munsell2rgb(z$dry_hue, z$dry_value, z$dry_chroma)
z$moist.col <- munsell2rgb(z$moist_hue, z$moist_value, z$moist_chroma)


## subset: pair-wise distances are expensive
z.sub <- z[sample(1:nrow(z), size = 500), ]

# stack
g <- list(
  data.frame(
    state = 'dry',
    z.sub[, c(dry.vars, 'dry.col')]
  ),
  data.frame(
    state = 'moist',
    z.sub[, c(moist.vars, 'moist.col')]
  )
)

names(g[[1]]) <- c('state', 'L', 'A', 'B', 'color')
names(g[[2]]) <- c('state', 'L', 'A', 'B', 'color')

g <- do.call('rbind', g)
g$state <- factor(g$state)

head(g)

## this is expensive: ~ 2 minutes for 5k records
# distances are based on CIE2000 color comparison
# note: single argument -> all pair-wise distances
# output is transposed relative to `dist` object
d <- farver::compare_colour(g[, c('L', 'A', 'B')], from_space='lab', to_space = 'lab', method='CIE2000')
d <- as.dist(t(d))

# classic multidimensional scaling (PCoA)
# relatively fast
# this is fairly robust to 0 distances
# use list. = TRUE to get GOF
mds <- cmdscale(d)

# # too expensive, but possibly more flexible
# # there are a lot of 0-distances
# mds <- metaMDS(d, autotransform = FALSE)
# mds <- mds$points


# split dry/moist for plotting
mds.state <- split(data.frame(mds), g$state)

# simple plot, no indication of density
par(mar=c(1,1,3,1), bg = 'black', fg = 'white')
plot(mds[, 1:2], type = 'n', axes = FALSE)
# grid(nx = 10, ny = 10, col = par('fg'))
points(mds[, 1:2], col = scales::alpha(g$color, 0.5), cex = 5, pch = c(15, 16)[as.numeric(g$state)])

arrows(x0 = mds.state$dry$X1, y0 = mds.state$dry$X2, x1 = mds.state$moist$X1, y1 = mds.state$moist$X2, length = 0.1, col = scales::alpha('green', 0.125))

legend('top', legend = c('dry', 'moist'), pch = 0:1, pt.cex = 3, horiz = TRUE, bty = 'n', cex = 1)

box()





##
##
##

ig <- graph_from_data_frame(z.sub[, c('dry_Munsell', 'moist_Munsell', 'dE00.o')], directed = TRUE)

V(ig)$color <- parseMunsell(V(ig)$name)
V(ig)$size <- sqrt(degree(ig)) * 3
E(ig)$weight <- 1/E(ig)$dE00.o

par(mar = c(0, 0, 0, 0), bg = 'black', fg = 'white')

plot(ig, edge.arrow.size = 0.5, vertex.label.cex = 0.75, vertex.label.family = "sans", vertex.label.color = invertLabelColor(V(ig)$color), layout = layout_with_graphopt)

set.seed(101010)
plot(ig, edge.arrow.size = 0.33, layout = layout_with_fr(ig, weights = 1/E(ig)$dE00.o), vertex.label = NA, edge.color = scales::alpha('white', 0.5))


ig <- graph_from_data_frame(z.sub[, c('dry_Munsell', 'moist_Munsell', 'dE00.o')], directed = FALSE)

V(ig)$color <- parseMunsell(V(ig)$name)
V(ig)$size <- sqrt(degree(ig)) * 3
E(ig)$weight <- 1/E(ig)$dE00.o

par(mar = c(0, 0, 0, 0), bg = 'black', fg = 'white')

plot(ig, edge.arrow.size = 0.33, layout = layout_on_grid, vertex.label = NA, edge.color = scales::alpha('white', 0.125))

plot(ig, edge.arrow.size = 0.33, layout = layout_on_sphere, edge.color = scales::alpha('white', 0.125), vertex.label = NA)

ragg::agg_png(filename = 'figures/dry-vs-moist-colors-graph-grid.png', width = 2000, height = 2000, scaling = 3)

par(mar = c(0, 0, 0, 0), bg = 'black', fg = 'white')

plot(ig, edge.arrow.size = 0.33, layout = layout_on_grid, edge.color = scales::alpha('white', 0.125), vertex.label.cex = 0.5, vertex.label.family = "sans", vertex.label.color = invertLabelColor(V(ig)$color), vertex.label.dist = 0.5, vertex.label.degree = pi/2)

dev.off()


## fit rotation, translation, scale
# dry -> moist
# likely mistakes removed
keep.idx <- which(z$dE00.o < 30)

d2m <- procrustes(X = z[keep.idx, moist.vars], Y = z[keep.idx, dry.vars], scale = TRUE)
m2d <- procrustes(X = z[keep.idx, dry.vars], Y = z[keep.idx, moist.vars], scale = TRUE)

## save
save(d2m, m2d, file = 'models/procrustes-models.rda')


## TODO: move this to aqp misc/ code
# 
# dput(d2m$scale)
# dput(d2m$rotation)
# dput(d2m$translation)
# 
# dput(m2d$scale)
# dput(m2d$rotation)
# dput(m2d$translation)
# 


# eval
summary(d2m)
summary(m2d)

## eval residuals
r <- residuals(d2m)
hist(r, las = 1)
quantile(r)

# probably mistakes or bad parsing
head(z[r > 30, ])

# investigate resid ~ L,A,B | hue,value,chroma


## predictions
p.d2m <- predict(d2m, z[, dry.vars])
p.m2d <- predict(m2d, z[, moist.vars])

head(z)
head(p.d2m)
head(p.m2d)


## manual predictions
Y <- as.matrix(z[, dry.vars])
Y <- d2m$scale * Y %*% d2m$rotation
Y <- sweep(Y, MARGIN = 2, STATS = d2m$translation, FUN = "+")

# same? YES
all.equal(Y, p.d2m)


## evaluate predictions

## TODO: generalize to moist + dry


z$dE00.moist <- NA
z$dE00.dry <- NA

for(i in 1:nrow(z)) {
  z$dE00.moist[i] <- compare_colour(from = z[i, moist.vars], to = rbind(p.d2m[i, ]), from_space = 'lab', to_space = 'lab', white_from = 'd65', white_to = 'd65', method = 'CIE2000')
  
  z$dE00.dry[i] <- compare_colour(from = z[i, dry.vars], to = rbind(p.m2d[i, ]), from_space = 'lab', to_space = 'lab', white_from = 'd65', white_to = 'd65', method = 'CIE2000')
  }


quantile(z$dE00.moist / z$dE00.o)
boxplot(list(source = z$dE00.o[keep.idx], estimate = z$dE00.moist[keep.idx]), horizontal = TRUE, xlab = 'dE00')

p1 <- histogram(
  z$dE00.moist[z$dE00.moist < 30], 
  breaks = 50, 
  xlim = c(-1, 31),
  par.settings = tactile.theme(), 
  scales = list(x = list(tick.number = 16)), 
  xlab = 'CIE2000 Color Contrast Metric', 
  main = 'Actual vs. Predicted Moist Colors', 
  panel = function(...) {
    panel.grid(-1, -1)
    panel.histogram(...)
  })


p2 <- histogram(
  z$dE00.dry[z$dE00.dry < 30], 
  breaks = 50, 
  xlim = c(-1, 31),
  par.settings = tactile.theme(), 
  scales = list(x = list(tick.number = 16)), 
  xlab = 'CIE2000 Color Contrast Metric', 
  main = 'Actual vs. Predicted Dry Colors', 
  panel = function(...) {
    panel.grid(-1, -1)
    panel.histogram(...)
  })



print(p1, more = TRUE, split = c(1, 1, 1, 2))
print(p2, more = FALSE, split = c(1, 2, 1, 2))



# chip accuracy
z$m.dry.o <- sprintf("%s %s/%s", z$dry_hue, z$dry_value, z$dry_chroma)
z$m.moist.o <- sprintf("%s %s/%s", z$moist_hue, z$moist_value, z$moist_chroma)


# m <- rgb2munsell(convert_colour(p.d2m, from = 'lab', to = 'rgb', white_from = 'd65', white_to = 'd65') / 255)
# 
# m$m <- sprintf("%s %s/%s", m$hue, m$value, m$chroma)
# 
# table(z$m.moist.o, m$m)


## eval a couple examples
idx <- sample(1:nrow(z), size = 10, replace = FALSE)
rgb2munsell(convert_colour(p.d2m[idx, ], from = 'lab', to = 'rgb', white_from = 'd65', white_to = 'd65') / 255)

z[idx, ]


p.m <- rgb2munsell(convert_colour(p.d2m[idx, ], from = 'lab', to = 'rgb', white_from = 'd65', white_to = 'd65') / 255)

# ~ 1000 random samples: 88% correct
prop.table(table(p.m$hue == z$moist_hue[idx]))


m1 <- sprintf("%s %s/%s", z$moist_hue[idx], z$moist_value[idx], z$moist_chroma[idx])
m2 <- sprintf("%s %s/%s", p.m$hue, p.m$value, p.m$chroma)

colorContrastPlot(m1, m2, labels = c('source', 'estimate'), col.cex = 0.75)



