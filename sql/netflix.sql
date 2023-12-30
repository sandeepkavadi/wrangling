SELECT * FROM netflix
;

SELECT country, COUNT(show_id) FROM netflix --max content from US followed by India and UK. Data also has a lot of nulls for this column 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

--Number of shows added to Netflix every month
SELECT DATE_PART('YEAR', date_added), DATE_PART('MONTH', date_added), COUNT(show_id)
FROM netflix
GROUP BY 1, 2
ORDER BY 1 DESC, 2 DESC
;

-- Oldest TV show & movie by release year
(
	SELECT release_year, show_id, type, title
	FROM netflix
	WHERE 1=1
	AND type = 'TV Show'
	AND release_year=(SELECT MIN(release_year) FROM netflix WHERE type='TV Show')
	ORDER BY 1
	LIMIT 1
)
UNION
(
	SELECT release_year, show_id, type, title
	FROM netflix
	WHERE 1=1
	AND type = 'Movie'
	AND release_year=(SELECT MIN(release_year) FROM netflix WHERE type='Movie')
	ORDER BY 1
	LIMIT 1
)

--Three month moving average of number of shows, by country
SELECT cnt.*
, SUM(cnt.num_shows) OVER(PARTITION BY cnt.country ORDER BY cnt.mnth RANGE BETWEEN INTERVAL '2 months' PRECEDING AND CURRENT ROW)/3.0 AS avg_3m_cnt
FROM (
		SELECT country, DATE_TRUNC('MONTH', date_added) AS mnth, COUNT(show_id) AS num_shows
		FROM netflix
		GROUP BY 1, 2
		ORDER BY 1, 2 DESC
	) cnt
WHERE 1=1
AND cnt.country = 'United States'
ORDER BY 2
;

-- Create a data set with contiguous date range using generate_series and compute the 3 month moving average of number of shows added each month
WITH 
full_set AS 
	(
		SELECT countries.*, dates.* 
		FROM 
		generate_series
		(
			(SELECT MIN(date_added) FROM netflix)::timestamp
			, (SELECT MAX(date_added) FROM netflix)::timestamp
			, INTERVAL '1 month'
		) dates  --generates a continuous series of dates from earliest date to latest available date in the data set
		LEFT JOIN (SELECT DISTINCT country FROM netflix) countries -- gives aet of all countries present in the dataset
		ON 1=1 -- performs a cross join on the above two tables
	) -- table consists of a contiguous range of dates for each country, to overcome problems concerning discontinuous time series data


SELECT f.country, f.dates AS month_added, COALESCE(n.num_shows,0) AS num_shows --zeroes imputed for nulls
, AVG(COALESCE(n.num_shows,0)) OVER(PARTITION BY f.country ORDER BY f.dates 
									RANGE BETWEEN INTERVAL '2 months' PRECEDING 
									AND CURRENT ROW) AS mvg_3m_avg_w_zeroes -- gives 3 month moving average of number of shows added in a month with nulls where data is unavailable
, AVG(n.num_shows) OVER(PARTITION BY f.country ORDER BY f.dates 
						RANGE BETWEEN INTERVAL '2 months' PRECEDING 
						AND CURRENT ROW) AS mvg_3m_avg_w_nulls -- gives 3 month moving average of number of shows added in a month with zeroes imputed for nulls
FROM full_set f
LEFT JOIN (
			SELECT country, DATE_TRUNC('MONTH', date_added) AS mnth
			, COUNT(show_id) as num_shows
			FROM netflix
			GROUP BY 1, 2		  
		  ) n 
	ON f.country = n.country AND f.dates = n.mnth
WHERE 1=1
AND f.country = 'United States'
ORDER BY 1, 2 
;


--Analytics with text data


SELECT * FROM netflix
;

--Number of movies with Brad Pitt in the cast listed as Comedies, grouped by release year
SELECT * --release_year, COUNT(show_id)
FROM netflix
WHERE 1=1
AND "cast" ~* 'brad pitt'
--AND "cast" ilike '%brad pitt%'
AND listed_in ilike '%comedies%'
AND type= 'Movie'
GROUP BY 1
;

-- Splitting the duration column into appropriate units of time for TV Shows and Movies
SELECT CASE 
			WHEN SPLIT_PART(country, ', ', 1) = '' THEN SPLIT_PART(country, ', ', 2)
			ELSE SPLIT_PART(country, ', ', 1) END AS country_cleaned
, type
, CASE 
	WHEN SPLIT_PART(duration, ' ', 2) ilike '%min%' THEN 'Mins'
	WHEN SPLIT_PART(duration, ' ', 2) ilike '%season%' THEN 'Seasons' 
	END AS duration_units 
, COUNT(show_id)
, ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS INT)), 2) AS avg_duration_num
FROM netflix
WHERE 1=1
AND duration IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY 1, 4 DESC
;

--Pivoting out the duration by type and grouping by country.  
--List of countries with longest average duration of movies in descending order
SELECT SPLIT_PART(
		CASE 
			WHEN SPLIT_PART(country, ', ', 1) = '' THEN SPLIT_PART(country, ', ', 2)
			ELSE SPLIT_PART(country, ', ', 1) 
		END
	, ',', 1) AS country_cleaned
, ROUND(AVG(CASE WHEN type = 'Movie' THEN CAST(SPLIT_PART(duration, ' ', 1) AS INT) END), 2) AS avg_duration_mins 
, ROUND(AVG(CASE WHEN type = 'TV Show' THEN CAST(SPLIT_PART(duration, ' ', 1) AS INT) END), 2) AS avg_num_seasons
FROM netflix
WHERE 1=1
AND duration IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
;



