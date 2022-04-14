# -*- coding: utf-8 -*-

# TODO: modularize parsing tasks

# TODO: 'Thickness' picked up in horizon REGEX
# 		---> temp fix: stop parsing horizon data at '^TYPE LOCATION' line
# 		---> re-wind and continue processing other features

# NOTE: taxonomy is already available in the DB that runs the OSD query page...
# taxonomy: grep -o -E "TAXONOMIC CLASS: .+$" oseds/a*.txt

# TODO: associated soils | competing soils REGEX aren't perfect... why?
# may be able to extract from lynx
# lynx will format the references at the bottom of the page:
# lynx -dump https://soilseries.sc.egov.usda.gov/OSD_Docs/I/INKS.html
#
# disable referenced links:
# lynx -dump -nolist https://soilseries.sc.egov.usda.gov/OSD_Docs/I/INKS.html

# load libraries
import fileinput
import csv
import osd_functions as osd
import os
import re

# output output file for append
f = open("output.csv", "a")
o = csv.writer(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

# iterate over lines of input
for line in fileinput.input():
	
	## this stuff needs to occur after processing horizons
	#~ pattern = r'^COMPETING SERIES:'
	#~ m = re.search(pattern, line)
	#~ if m:
		#~ print 'competing', osd.parse_competing_series(line)
	
	#~ pattern = r'^GEOGRAPHICALLY ASSOCIATED SOILS:'
	#~ m = re.search(pattern, line)
	#~ if m:
		#~ print 'associated', osd.parse_associated_series(line)
	
	
	# only process horizon data until the TYPE LOCATION line
	#~ # cuts down on spurious matches
	pattern = r'TYPE LOCATION'
	m = re.search(pattern, line)
	if m:
		# perform other processing and then finish
		break
	
	
	# attempt to parse horizon data from the current line
	else:
	  r = osd.parse_hz(line)
	  # if something other than None was returned we have some data
	  if r != None:
		  # get the current file name
		  fn = fileinput.filename()
		  # format the file name:
		  fn = os.path.basename(fn)
		  # remove the file extension
		  fn = fn.rsplit('.', 1)[0]
		  # convert '_' -> ' '
		  fn = fn.replace('_', ' ')
		  # add to this row of data, as last element
		  r.append(fn)
		  # save to output file
		  o.writerow(r)

# done
f.close()


