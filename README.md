# Data Wrangling

The repo consists of projects involving wrangling data (transformations).
The projects are accross three languages: python, sql and pyspark.

**SQL:**
1. [Netflix dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows):
<ins>Description (from Kaggle)</ins>: Netflix is one of the most popular media and video streaming platforms. 
They have over 8000 movies or tv shows available on their platform, as of mid-2021, they have over 
200M Subscribers globally. This tabular dataset consists of listings of all the movies and tv shows 
available on Netflix, along with details such as - cast, directors, ratings, release year, duration,
etc.
A few questions we try answer while exploring this dataset:
* What's the oldest TV show & Movie on Netflix based on release year
* How many shows on an average (3 month moving average) are added every month to the Netflix catalogue? 
* Number of movies on the catalogues are categorized as comedies, starring Brad Pitt
* What is the average duration of movies accross countries
* Which countries make the shortest films on an average vs which ones make the longest?

Other themes explored as part of the analysis:
* How to resample the date ranges to get a contiguous time period for the data
* How to use Regular Expressions (regex) to answer questions through Text Analysis
* Extracting firs country from columns with multiple country names
* Extracting duration of shows from text based column

Key concepts used in the analysis:
* Datetime functions: DATE_PART(), DATE_TRUNC(), 
* Fixed range moving windows defined based on time intervals
* Text functions: regex, SPLIT_PART(), LIKE, ILIKE
