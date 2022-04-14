# -*- coding: utf-8 -*-
import re

# TODO: test this extensively
def split_nat_lang_list(text, tokens):
	# function mapped to items split by tokens above
	def mappend(*args):
	    return sum(map(*args), [])
	
	# split the named series by tokens
	R = [text]  # fragments, to split
	for token in tokens:
	    func = lambda fragment: fragment.strip().split(token)
	    R = mappend(func, R)
	
	# TODO: remove 'and ' from some strings
	# there is usualy an empty-string in the result: remove it
	try:
		list.remove(R, '')
	except ValueError:
		1 # do nothing
		
	return R

# TODO: this will not pickup series that contain a '.' in the name
def parse_associated_series(s):
	# note that there are sometimes odd codes appended to the series names "(T)" ???
	pattern = r'^GEOGRAPHICALLY ASSOCIATED SOILS:\sThese are the ([a-zA-Z, ()]+) soils\.'
	m = re.search(pattern, s)
	
	# if there is a match proceed
	if m:
		# extract the natural language list
		associated = m.group(1)
		
		# neat idea from: http://stackoverflow.com/questions/1059559/python-strings-split-with-multiple-separators
		# tokens used to split words from the natural language list
		tokens = [', ', ' and ']
		associated_parsed = split_nat_lang_list(associated, tokens)
		
		# we need to figure out how to strip codes from the series names...
	else:
		associated_parsed = []
	
	# done
	return associated_parsed

# TODO: this will not pickup series that contain a '.' in the name
def parse_competing_series(s):
	# typical example 
	# s = "COMPETING SERIES:  These are the Crazybird, Dawgbuffer, Epvip, San Joauqin, St. Mary, and Rancheria series."
	
	# get just the line with the competing series
	pattern = r'^COMPETING SERIES:\s?These are (?:the )?([a-zA-Z, ]+) (?:soils|series)\.'
	m = re.search(pattern, s)
	
	# return m.group(1)
	
	# if there is a match proceed
	if m:
		# extract the natural language list
		competing = m.group(1)
		
		# neat idea from: http://stackoverflow.com/questions/1059559/python-strings-split-with-multiple-separators
		# tokens used to split words from the natural language list
		tokens = [', ', ' and ']
		competing_parsed = split_nat_lang_list(competing, tokens)
	else:
		competing_parsed = []
	
	# done
	return competing_parsed



## TODO: figure out how to deal with multiple colors
## TODO: prime (') is not always handled properly
## TODO: caret (^) is not parsed correctly
## TODO: 'Thickness' records are still getting in here...
## TODO: how can we extract this: '3E & Bt'
def parse_hz(s):
  	# extract name and depths---> TODO: need to verify with odd hz names
	pattern = r'^\s*([a-zA-Z0-9\'\/]+)\s?\-\-?\-?\s?([0-9\.]+) to ([0-9\.]+) (in|inches|cm|centimeters)'
	m = re.search(pattern, s)
	
	# test for a match, and extract elements / convert units
	if m:
		name = m.group(1)
		# we store top and bottom as floats just in case fractional inches are given
		top = float(m.group(2))
		bottom = float(m.group(3))
		units = m.group(4)
		
		# convert inches to cm
		if units in ("inches","in"):
			top = int(round(top * 2.54))
			bottom = int(round(bottom * 2.54))
		
		# cast top and bottom to integer for simplicity
		else:
			top = int(round(top))
			bottom = int(round(bottom))
	
	# there are cases where there is no lower depth (i.e. R horizons)
	# search for these
	else:
		pattern = r'^\s*([a-zA-Z0-9]+)\s?\-\-?\-?\s?([0-9\.]+) (in|inches|cm|centimeters)'
		m = re.search(pattern, s)
		
		# if there is a match, set bottom = top
		if m:
			name = m.group(1)
			top = float(m.group(2))
			bottom = top
			units = m.group(3)
			
			if units in ("inches","in"):
				top = int(round(top * 2.54))
				bottom = int(round(bottom * 2.54))
			
			# cast integer for simplicity
			else:
				top = int(round(top))
				bottom = int(round(bottom))
			
		# if not found, then we aren't processing a horizon record
		else:
			return None
	
	# TODO: figure out how to extract this: (N 2.5/)
	# extract dry colors
	pattern = r'\(([0-9]?[\\.]?[0-9][Y|R]+)([ ]+?[0-9])/([0-9])\)'
	m = re.search(pattern, s)
	
	if m:
		hue = m.group(1)
		value = int(m.group(2))
		chroma = int(m.group(3))
	else:
		hue = None
		value = None
		chroma = None
	
	# extract moist colors
	pattern = r'\(([0-9]?[\\.]?[0-9][Y|R]+)([ ]+?[0-9])/([0-9])\) moist'
	m = re.search(pattern, s)
	
	if m:
		hue_moist = m.group(1)
		value_moist = int(m.group(2))
		chroma_moist = int(m.group(3))
	else:
		hue_moist = None
		value_moist = None
		chroma_moist = None
	
	
	return [name, top, bottom, hue, value, chroma, hue_moist, value_moist, chroma_moist]

