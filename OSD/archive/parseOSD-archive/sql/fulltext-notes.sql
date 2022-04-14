
 
 
 
 -- chain multiple full text searches and rankings
 -- not very fast
SELECT series, sum(rank) as score
FROM (
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', typical_pedon), to_tsquery('english', 'Bt')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', typical_pedon) @@ to_tsquery('english', 'Bt')
	ORDER BY rank DESC
	LIMIT 20
	) as a
UNION ALL
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', ric), to_tsquery('english', 'Bt')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', ric) @@ to_tsquery('english', 'Bt')
	ORDER BY rank DESC
	LIMIT 20
	) as a
UNION ALL
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', competing_series), to_tsquery('english', 'argillic')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', competing_series) @@ to_tsquery('english', 'argillic')
	ORDER BY rank DESC
	LIMIT 20
	) as a
UNION ALL
SELECT * 
FROM (
	SELECT ts_rank(to_tsvector('english', geog_location), to_tsquery('english', 'hills')) AS rank, 
	series
	FROM osd.osd_fulltext2
	WHERE to_tsvector('english', geog_location) @@ to_tsquery('english', 'hills')
	ORDER BY rank DESC
	LIMIT 20
	) as a
) as b
GROUP BY series
ORDER BY score DESC;





SELECT series
FROM osd_fulltext2 
WHERE to_tsvector('english', geog_assoc_soils) @@ to_tsquery('english', 'amador');

 
 
SELECT series, ts_rank(to_tsvector('english', geog_assoc_soils), to_tsquery('english', 'amador'), 32) AS rank
FROM osd_fulltext2
WHERE to_tsvector('english', geog_assoc_soils) @@ to_tsquery('english', 'amador')
ORDER BY rank DESC
LIMIT 10;

 
 
 
 -- note that the 2 argument version of to_tsXXX is used
SELECT series 
FROM osd_fulltext 
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyolite & amador');

SELECT series 
FROM osd.osd_fulltext 
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyolite & amador'::tsvector);

-- basic ranking
SELECT series, ts_rank_cd(to_tsvector('english', fulltext), to_tsquery('english', 'thermic & rhyo:* & amador')) AS rank
FROM osd_fulltext
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyo:* & amador')
ORDER BY rank DESC
LIMIT 10;

-- normalized ranking
SELECT series, ts_rank_cd(to_tsvector('english', fulltext), to_tsquery('english', 'thermic & rhyo:* & tuff:* & xer:*'), 32) AS rank
FROM osd_fulltext
WHERE to_tsvector('english', fulltext) @@ to_tsquery('english', 'thermic & rhyo:* & tuff:* & xer:*')
ORDER BY rank DESC
LIMIT 10;

