
-- 
-- QA/QC
-- 

-- 
-- * most are due to errors in the OSD format: check there first
-- 
-- 

set search_path TO osd, public;

-- 1. missing horizons:
CREATE TEMP TABLE missing_hz_check AS 
SELECT series, array_accum(top) as t, array_accum(bottom) as b, count(top) as n
FROM 
(
SELECT series, top, bottom
FROM osd_colors
ORDER BY series, top ASC
) as a
GROUP BY series;

-- get problem OSDs...
CREATE TEMP TABLE problems AS
SELECT series, t AS top, b as BOTTOM, t[n], b[n-1], n from missing_hz_check where t[n] != b[n-1] ;

CREATE TEMP TABLE problems_by_mo AS
SELECT mlraoffice, seriesname 
FROM taxa 
WHERE seriesname IN (SELECT series from problems) ORDER BY mlraoffice;

\copy problems TO 'problem-osds.csv' CSV HEADER
\copy problems_by_mo TO 'problems-by-mo.csv' CSV HEADER
