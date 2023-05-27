/* Rounding the Imdb rating to 1 digit */
UPDATE 
  [GameOfThrones].[dbo].[got_imdb] 
SET 
  imdb_rating = ROUND(imdb_rating, 1);

/* What are the top-rated episodes of Game of Thrones according to the IMDb ratings? (Here Top 5) */
WITH temp_table AS (
  SELECT 
    ep.title, 
    ep.season, 
    MAX(imdb.imdb_rating) as 'imdb_rating', 
    DENSE_RANK() OVER (
      ORDER BY 
        MAX(imdb.imdb_rating) DESC
    ) as 'rank' 
  FROM 
    [GameOfThrones].[dbo].[got_episodes] ep 
    JOIN [GameOfThrones].[dbo].[got_imdb] imdb ON ep.original_air_date = imdb.original_air_date 
  GROUP BY 
    ep.title, 
    ep.season
) 
SELECT 
  * 
FROM 
  temp_table 
WHERE 
  rank <= 5;

/* Which episodes received the lowest IMDb rating? */
WITH temp_table AS (
  SELECT 
    ep.title, 
    ep.season, 
    min(imdb.imdb_rating) AS 'imdb_rating', 
    DENSE_RANK() OVER (
      ORDER BY 
        min(imdb.imdb_rating)
    ) AS 'rank' 
  FROM 
    [GameOfThrones].[dbo].[got_episodes] ep 
    JOIN [GameOfThrones].[dbo].[got_imdb] imdb ON ep.original_air_date = imdb.original_air_date 
  GROUP BY 
    ep.title, 
    ep.season
) 
SELECT 
  * 
FROM 
  temp_table 
WHERE 
  rank = 1;

/* What is the average IMDb rating of all episodes? */
SELECT 
  ROUND(
    AVG(imdb_rating), 
    1
  ) AS 'average_rating' 
FROM 
  [GameOfThrones].[dbo].[got_imdb];

/* How does the IMDb rating vary across seasons? */
SELECT 
  season, 
  ROUND(
    AVG(imdb_rating), 
    1
  ) AS 'average_rating' 
FROM 
  [GameOfThrones].[dbo].[got_imdb] 
GROUP BY 
  season;

/* What are the most-watched episodes of Game of Thrones based on the number of viewers? */
WITH temp_table AS(
  SELECT 
    season, 
    title, 
    MAX(us_viewers) AS 'us_viewers', 
    RANK() OVER (
      ORDER BY 
        MAX(us_viewers) DESC
    ) AS 'rank' 
  FROM 
    [GameOfThrones].[dbo].[got_episodes] 
  GROUP BY 
    season, 
    title
) 
SELECT 
  * 
FROM 
  temp_table 
WHERE 
  rank = 1;

/* Which episode had the lowest number of viewers? (use a sub-query for this) */
SELECT 
  season, 
  episode_num_in_season, 
  title, 
  us_viewers 
FROM 
  [GameOfThrones].[dbo].[got_episodes] 
WHERE 
  us_viewers = (
    SELECT 
      MIN(us_viewers) 
    FROM 
      [GameOfThrones].[dbo].[got_episodes]
  );

/* How does the average number of viewers vary across seasons? */
SELECT 
  season, 
  AVG(us_viewers) AS 'average_viewers' 
FROM 
  [GameOfThrones].[dbo].[got_episodes] 
GROUP BY 
  season;

/* Are there any episodes that have a high IMDb rating but a relatively low number of viewers 
or total votes or vice versa? */
SELECT 
  imdb.season, 
  imdb.episode_num, 
  imdb.title, 
  ep.us_viewers, 
  DENSE_RANK() OVER (
    ORDER BY 
      ep.us_viewers DESC
  ) AS 'rank_by_viewers', 
  imdb.imdb_rating, 
  DENSE_RANK() OVER (
    ORDER BY 
      imdb.imdb_rating DESC
  ) AS 'rank_by_rating', 
  imdb.total_votes, 
  DENSE_RANK() OVER (
    ORDER BY 
      imdb.total_votes DESC
  ) AS 'rank_by_votes' 
FROM 
  [GameOfThrones].[dbo].[got_episodes] ep 
  JOIN [GameOfThrones].[dbo].[got_imdb] imdb ON ep.original_air_date = imdb.original_air_date;
