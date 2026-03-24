
# old method: predict-missing-colors-OLS.R
x <- read.csv('old-parsed-data-est-colors.csv.gz')

# new method: predict-missing-colors.R
y <- read.csv('parsed-data-est-colors.csv.gz')

str(x)
str(y)


nrow(x) == nrow(y)


table(x$dry_color_estimated)
table(y$dry_color_estimated)

table(x$moist_color_estimated)
table(y$moist_color_estimated)


table(is.na(x$dry_hue))
table(is.na(y$dry_hue))

table(is.na(x$moist_hue))
table(is.na(y$moist_hue))


prop.table(table(x$dry_hue == y$dry_hue))
prop.table(table(x$dry_value == y$dry_value))

prop.table(table(x$moist_hue == y$moist_hue))
prop.table(table(x$moist_value == y$moist_value))

table(x$moist_value)
table(y$moist_value)


table(old = x$moist_hue, new = y$moist_hue)
table(old = x$moist_value, new = y$moist_value)
table(old = x$moist_chroma, new = y$moist_chroma)


x[x$seriesname == 'CECIL', 1:9, ]
y[y$seriesname == 'CECIL', 1:9, ]

x[x$seriesname == 'DRUMMER', 1:9, ]
y[y$seriesname == 'DRUMMER', 1:9, ]


