/*Dataset: https://www.kaggle.com/datasets/shivamb/netflix-shows
kaggle API command: kaggle datasets download -d shivamb/netflix-shows
*/

-- SELECT * FROM netflix
-- ;

SELECT country, COUNT(show_id) FROM netflix --max content from US followed by India and UK. Data also has a lot of nulls for this column 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

/* Output:
"country"	"count"
"United States"	2818
"India"	972
	831
"United Kingdom"	419
"Japan"	245
"South Korea"	199
"Canada"	181
"Spain"	145
"France"	124
"Mexico"	110
*/




--Number of shows added to Netflix every month
SELECT DATE_PART('YEAR', date_added), DATE_PART('MONTH', date_added), COUNT(show_id)
FROM netflix
GROUP BY 1, 2
ORDER BY 1 DESC, 2 DESC
;

/* Output:
"date_part"	"date_part-2"	"count"
2021	9	183
2021	8	178
2021	7	257
2021	6	207
2021	5	132
2021	4	188
2021	3	112
*/




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
;
/* Output:
"release_year"	"show_id"	"type"	"title"
1925	"s4251"	"TV Show"	"Pioneers: First Women Filmmakers*"
1942	"s7791"	"Movie"	"Prelude to War"
*/




--Three month moving average of number of shows, by country
SELECT cnt.*
, ROUND(SUM(cnt.num_shows) OVER(PARTITION BY cnt.country ORDER BY cnt.mnth RANGE BETWEEN INTERVAL '2 months' PRECEDING AND CURRENT ROW)/3.0, 2) AS avg_3m_cnt
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

/* Output:
"country"	"mnth"	"num_shows"	"avg_3m_cnt"
"United States"	"2008-01-01 00:00:00-05"	1	0.33
"United States"	"2008-02-01 00:00:00-05"	1	0.67
"United States"	"2009-11-01 00:00:00-04"	1	0.33
"United States"	"2010-11-01 00:00:00-04"	1	0.33
"United States"	"2011-10-01 00:00:00-04"	11	3.67
"United States"	"2012-02-01 00:00:00-05"	1	0.33
*/








-- Create a data set with contiguous date range using generate_series and compute the 3 month moving average of number of shows added each month
WITH 
full_set AS 
	(
		SELECT countries.*, dates.* 
		FROM 
		generate_series
		(
			DATE_TRUNC('MONTH', (SELECT MIN(date_added) FROM netflix)::timestamp)
			, DATE_TRUNC('MONTH', (SELECT MAX(date_added) FROM netflix)::timestamp)
			, INTERVAL '1 month'
		) dates  --generates a continuous series of dates from earliest date to latest available date in the data set
		LEFT JOIN (SELECT DISTINCT country FROM netflix) countries -- gives aet of all countries present in the dataset
		ON 1=1 -- performs a cross join on the above two tables
	) -- table consists of a contiguous range of dates for each country, to overcome problems concerning discontinuous time series data


SELECT f.country, f.dates AS month_added, COALESCE(n.num_shows,0) AS num_shows --zeroes imputed for nulls
-- gives 3 month moving average of number of shows added in a month with nulls where data is unavailable
, AVG(COALESCE(n.num_shows,0)) OVER(PARTITION BY f.country ORDER BY f.dates 
									RANGE BETWEEN INTERVAL '2 months' PRECEDING -- given that the date ranges are contiguoous we can use ROWS between instead of using a time interval
									AND CURRENT ROW) AS mvg_3m_avg_w_zeroes 
-- gives 3 month moving average of number of shows added in a month with zeroes imputed for nulls
, AVG(n.num_shows) OVER(PARTITION BY f.country ORDER BY f.dates 
						RANGE BETWEEN INTERVAL '2 months' PRECEDING 
						AND CURRENT ROW) AS mvg_3m_avg_w_nulls 
FROM full_set f
LEFT JOIN (
			SELECT country, DATE_TRUNC('MONTH', date_added) AS mnth
			, COUNT(show_id) as num_shows
			FROM netflix
			GROUP BY 1, 2		  
		  ) n --dataset aggregated by month
	ON f.country = n.country AND f.dates = n.mnth
WHERE 1=1
AND f.country = 'United States'
ORDER BY 1, 2 
;

/* Output:
"country"	"month_added"	"num_shows"	"mvg_3m_avg_w_zeroes"	"mvg_3m_avg_w_nulls"
"United States"	"2008-01-01 00:00:00"	1	1.00000000000000000000	1.00000000000000000000
"United States"	"2008-02-01 00:00:00"	1	1.00000000000000000000	1.00000000000000000000
"United States"	"2008-03-01 00:00:00"	0	0.66666666666666666667	1.00000000000000000000
"United States"	"2008-04-01 00:00:00"	0	0.33333333333333333333	1.00000000000000000000
"United States"	"2008-05-01 00:00:00"	0	0.00000000000000000000	
*/


/*----------------------------------------------------------------------------------------------------------------------------------------*/




--Analytics with text data

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

/* Output:
"show_id"	"type"	"title"	"director"	"cast"	"country"	"date_added"	"release_year"
"s5474"	"Movie"	"War Machine"	"David Michôd"	"Brad Pitt, Topher Grace, Emory Cohen, John Magaro, Scoot McNairy, Anthony Michael Hall, Will Poulter"	"United States"	"2017-05-26"	2017
"s7639"	"Movie"	"Ocean's Thirteen"	"Steven Soderbergh"	"George Clooney, Brad Pitt, Matt Damon, Andy Garcia, Don Cheadle, Bernie Mac, Ellen Barkin, Al Pacino, Casey Affleck, Scott Caan"	"United States"	"2019-10-01"	2007
"s7640"	"Movie"	"Ocean's Twelve"	"Steven Soderbergh"	"George Clooney, Brad Pitt, Matt Damon, Catherine Zeta-Jones, Andy Garcia, Don Cheadle, Bernie Mac, Julia Roberts, Casey Affleck, Scott Caan"	"United States"	"2019-10-01"	2004
*/




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

/* Output:
"country_cleaned"	"type"	"duration_units"	"count"	"avg_duration_num"
"Argentina"	"Movie"	"Mins"	56	89.61
"Argentina"	"TV Show"	"Seasons"	20	1.35
"Australia"	"Movie"	"Mins"	61	93.39
"Australia"	"TV Show"	"Seasons"	56	1.96
"Austria"	"Movie"	"Mins"	8	99.00
"Austria"	"TV Show"	"Seasons"	1	1.00
"Bangladesh"	"Movie"	"Mins"	3	111.67
"Belarus"	"TV Show"	"Seasons"	1	2.00
*/




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

/* Output: 
"country_cleaned"	"avg_duration_mins"	"avg_num_seasons"
"Croatia"	157.00	2.00
"West Germany"	150.00	
"Soviet Union"	147.00	
"Cameroon"	143.00	
"India"	126.54	1.17
"Iran"	123.00	
"Pakistan"	121.89	1.00
*/

