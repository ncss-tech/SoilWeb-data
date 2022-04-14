-- 2015-06-20: still need to apply these

-- set search_path to osd, public;

-- had to manually fix some stuff in R

-- load fixed data
CREATE TEMP TABLE fixed (
hzname varchar(25),
top_cm integer,
bottom_cm integer,
matric_dry_color_hue varchar(25),
matrix_dry_color_value numeric,
matrix_dry_color_chroma numeric,
matrix_wet_color_hue varchar(25),
matrix_wet_color_value numeric,
matrix_wet_color_chroma numeric,
series varchar(100),
MO_region integer
);

\copy fixed from 'manual-fixes/fixed-2.csv' CSV HEADER

--don't need this column
ALTER TABLE fixed DROP COLUMN mo_region ;

--convert series names to upper case
UPDATE fixed SET series = UPPER(series);

-- delete 'fixed' series from main table
DELETE FROM osd_colors WHERE series IN (SELECT DISTINCT series FROM fixed);

-- copy over fixed records
INSERT INTO osd_colors
SELECT * FROM fixed;

-- investigate those series with hz data but no colors:
-- SELECT series, count(series) from osd.osd_colors where matrix_wet_color_hue is null group by series having count(series) > 3 order by series;

-- remove false-positive matches from RIC section:
-- http://casoilresource.lawr.ucdavis.edu/sde/?series=humeston
-- http://soilmap2-1.lawr.ucdavis.edu/soil_web/soil_profile.php?use_osd=1&database_type=SSURGO&depth_mode=mini&osd_series_override=humeston&cached=0
DELETE FROM osd.osd_colors WHERE hzname = 'Thickness';



