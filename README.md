# Data Wrangling

The repo consists of projects involving wrangling data (transformations).
The projects are accross three languages: python, sql and pyspark.

## SQL

**[Netflix Movies and TV Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows)**   

<ins>Description</ins>: This tabular dataset consists of listings of all the movies and tv shows 
available on Netflix, along with details such as - cast, directors, ratings, release year, duration,
etc.

DBMS: PostgreSQL
Notebook env: Jupyter, ipython-sql, SQLAlchemy, pandas    

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

## Python

**[Rain in Australia](https://www.kaggle.com/datasets/jsphyg/weather-dataset-rattle-package)**

<ins>Description</ins>: This dataset contains about 10 years of daily weather observations from many locations across Australia.

python libraries: pandas, numpy, seaborn

Key concepts used in the analysis:
1. Analysis of **Missing** values:
    * Non-contiguous date ranges
    * Missing values from individual attributes
    * Missing values from target
2. **Impuatation** of Missing values:
    * Drop certain attributes/locations data
    * Forward & backward fills (ffill & bfill)
    * Imputation by median value
    * Imputation by 3-day moving average
3. Analyze **outlier** and determine appropriate treatment for handling them
3. Data Visualization: Visualize distributions and Correlations between independent attributes in the dataset



