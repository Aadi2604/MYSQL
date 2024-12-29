-- Q1. Find the total number of rows in each table of the schema?
-- Number of rows for the table 'movie'
Select count(*) from movie; 
-- Number of rows for the table 'ratings'
Select count(*) from ratings;
-- Number of rows for the table 'genre'
Select count(*) from genre;
-- Number of rows for the table 'names'
Select count(*) from names;
-- Number of rows for the table 'director_mapping'
Select count(*) from director_mapping;
-- Number of rows for the table 'role_mapping'
Select count(*) from role_mapping;

-- Q2. Which columns in the movie table have null values?
SELECT 
      SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS ID_NULL,
      SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_NULL,
      SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_NULL,
      SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_NULL,
      SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_NULL,
      SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_NULL,
      SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_NULL,
      SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_NULL,
      SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_NULL
FROM movie;

-- ROUGH NOTE: The 4 columns: country , worldwide_gross_income,languages,production_company have null values .

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
 -- First Part
 Select * from movie;
   Select year ,count(id) as no_of_movies from movie 
   group by year
  -- Second Part
  SELECT 
    MONTH(date_published) AS month,
    COUNT(*) AS movie_count
FROM 
    movie
WHERE 
    YEAR(date_published) = 2019 
GROUP BY 
    MONTH(date_published)
ORDER BY 
    MONTH(date_published);

-- Checking which month has maximum movies released
-- ORDER BY number_of_movies DESC;

-- Q4. How many movies were produced in the USA or India in the year 2019??
Select count(id) from movie
where (country = "USA" Or country="INDIA") and  year="2019"

-- ROUGH NOTE: Together India and USA has produced 1007 movies

-- Q5. Find the unique list of the genres present in the data set?
Select distinct(genre) from genre

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
Select genre ,COUNT(id) AS MAX_MOVIE from movie as m
Inner join genre as g
on m.id=g.movie_id
group by GENRE 
LIMIT 1;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
SELECT COUNT(*) AS movie_count
FROM (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(genre) = 1
) AS single_genre_movies;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/


-- Q8.What is the average duration of movies in each genre? 
Select genre , avg(duration) as avg_duration from movie m
inner join genre as g
on m.id=g.movie_id
group by genre
order by avg_duration desc

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
with GenreRanking As(
   Select 
     genre, count(movie_id) as movie_count,
     Rank() over(order by count(movie_id) Desc)as Movie_Rank
   from genre
   group by genre
   )
Select genre , movie_count ,Movie_Rank
from GenreRanking
where genre = "Thriller";

/*Thriller movies is in top 3 among all genres in terms of number of movies
 
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
Select max(avg_rating),max(total_votes),max(median_rating) ,min(avg_rating),min(total_votes),min(median_rating)
from ratings 

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
SELECT m.title, r.avg_rating,
       DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM ratings as r
INNER JOIN movie as m
ON r.movie_id = m.id
LIMIT 10;
/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
select median_rating, count(movie_id) as movie_count from ratings
group by median_rating
order by median_rating

/* Movies with a median rating of 7 is highest in number. */

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

WITH prod_company_details AS
(
SELECT production_company,
       COUNT(id) as movie_count,
       avg(avg_rating)
FROM ratings as r
INNER JOIN movie as m
ON r.movie_id = m.id
WHERE avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
)
SELECT production_company,
       movie_count,
       DENSE_RANK() OVER(ORDER BY movie_count DESC) AS prod_company_rank
FROM prod_company_details;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

WITH Movie_in_march AS (
    SELECT 
        g.genre,
        COUNT(m.id) AS movie_count
    FROM movie m
    INNER JOIN 
        genre g
    ON 
        m.id = g.movie_id
    INNER JOIN 
        ratings r
    ON 
        r.movie_id = m.id
	WHERE 
		m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
        AND m.country = 'USA' 
        AND r.total_votes > 1000
    GROUP BY 
        g.genre, 
        m.country
    ORDER BY 
        movie_count DESC
)
SELECT 
    genre,
    movie_count 
FROM 
    Movie_in_march;


	-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
Select title , genre  ,avg_rating from movie m
Inner join genre g
on m.id=g.movie_id
Inner join ratings r
on m.id=r.movie_id
where title like "the%" and avg_rating>8
order by avg_rating desc

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
Select count(id) as movie_count from movie m 
Inner join ratings r 
on m.id=r.movie_id
where m.date_published BETWEEN '2018-04-01' AND '2019-04-01'and median_rating=8

-- Q17. Do German movies get more votes than Italian movies? 
select languages,sum(total_votes)as totalvotes ,count(id)as movie_count from movie m
Inner join ratings r
on m.id=r.movie_id
where languages in ("Italian" ,"German")
group by languages
order by totalvotes desc

 -- Q18. Which columns in the names table have null values??
Select * from names
SELECT 
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_null_count,
    SUM(CASE WHEN height  IS NULL THEN 1 ELSE 0 END) AS height_null_count,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS DOB_null_count,
	SUM(CASE WHEN known_for_movies  IS NULL THEN 1 ELSE 0 END) AS Known_null_count
FROM names;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH top3_genre AS (
    SELECT 
        g.genre, 
        COUNT(g.movie_id) AS movie_count
    FROM 
        genre AS g
    INNER JOIN 
        ratings AS r
    ON 
        g.movie_id = r.movie_id
    WHERE 
        r.avg_rating > 8
    GROUP BY 
        g.genre
    ORDER BY 
        movie_count DESC
    LIMIT 3
),

top3_director AS (
    SELECT 
        n.name AS director_name,
        COUNT(g.movie_id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_row_rank
    FROM 
        names AS n
	INNER JOIN 
        director_mapping AS dm 
    ON 
        n.id = dm.name_id 
    INNER JOIN 
        genre AS g 
    ON 
        dm.movie_id = g.movie_id 
    INNER JOIN 
        ratings AS r 
    ON 
        r.movie_id = g.movie_id
    INNER JOIN 
        top3_genre AS t
    ON 
        g.genre = t.genre
   WHERE 
        r.avg_rating > 8
    GROUP BY 
        n.name
)
SELECT 
    director_name, 
    movie_count
FROM 
    top3_director
WHERE 
    director_row_rank <= 3;

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. */

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
SELECT name as actor_name,COUNT(r.movie_id) as movie_count
FROM names as n
INNER JOIN role_mapping as rm
ON n.id = rm.name_id
INNER JOIN ratings as r
ON rm.movie_id = r.movie_id
WHERE median_rating >=8 AND rm.category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
Select m.production_company,sum(r.total_votes) as total_votes,
Rank() over(order by sum(r.total_votes) desc)as prod_com_rank from movie m
Inner join ratings r
on m.id=r.movie_id
group by m.production_company
limit 3

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.
Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 

with actor_rating_details as
(
Select name as actor_name,sum(total_votes)as total_votes,count(r.movie_id)as movie_count,
        round(sum(avg_rating*total_votes)/sum(total_votes),2)as avg_rating
from names as n
Inner join role_mapping as rm
on n.id=rm.name_id
Inner join  ratings as r
on rm.movie_id=r.movie_id
Inner join movie as m
on m.id=r.movie_id
where country="INDIA" and category="actor"
group by actor_name
having movie_count>=5
)
Select * ,
         Rank() over (order by avg_rating DESC) as actor_rank
from  actor_rating_details
limit 1

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 

with actress_rating_details as
(
Select name as actress_name,sum(total_votes)as total_votes,count(r.movie_id)as movie_count,
        round(sum(avg_rating*total_votes)/sum(total_votes),2)as avg_rating
from names as n
Inner join role_mapping as rm
on n.id=rm.name_id
Inner join  ratings as r
on rm.movie_id=r.movie_id
Inner join movie as m
on m.id=r.movie_id
where country="INDIA" and category="actress"and languages="Hindi"
group by actress_name
having movie_count>=3
)
Select * ,
         Rank() over (order by avg_rating DESC) as actor_rank
from  actress_rating_details
limit 1

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	 Note: Sort the output by average ratings (desc).*/
     
Select title,avg_rating,
Case when avg_rating>8 Then "SUPERHIT"
	 when avg_rating Between 7 and 8 Then "Hit Movies"
     when avg_rating between 5 and 7 then "One-time-watch"
     Else "flop"
     End as rating_category
from movie as m
Inner join genre g
on m.id=g.movie_id
Inner join ratings r 
on g.movie_id=r.movie_id
where genre="Thriller"
order by avg_rating desc 

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.)

Select genre ,AVG(duration) AS avg_duration,SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration from movie m
Inner join genre g 
on m.id=g.movie_id
group by genre
order by genre 

-- Round is good to have and not a must have; Same thing applies to sorting

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

WITH TOP3GENRE AS 
(
    Select g.genre ,COUNT(m.id) AS MOVIE_COUNT FROM Movie m 
    Inner join genre g 
    on m.id=g.movie_id
    group by g.genre
    order by movie_count Desc
),
Top_5 as(
      Select genre , year, title as movie_name, worlwide_gross_income,
      Dense_Rank() over(partition by year order by worlwide_gross_income desc)as movie_rank from movie m
      Inner join genre g 
	  on m.id=g.movie_id
      where genre in (Select genre from TOP3GENRE)
)
Select  * from top_5 
where movie_rank <5 ;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
Select m.production_company, count(m.ID)as movie_count,
rank() over(order by count(m.id) Desc ) as prod_com_rank from movie m
Inner join  ratings r
on m.id=r.movie_id
where median_rating>=8 and production_company is not null and POSITION(',' IN languages)>0
group by m.production_company
limit 2

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.

select name, sum(total_votes), count(m.id), avg(avg_rating) as actress_avg_rating, rank() over(order by avg(avg_rating) desc ) as actress_rank
from names n 
INNER JOIN role_mapping rm on n.id = rm.name_id
INNER JOIN movie m on m.id = rm.movie_id
INNER JOIN genre g on g.movie_id = m.id
INNER JOIN ratings r on r.movie_id = m.id
where category = 'actress' and avg_rating > 8 and genre = 'Drama'
group by name
limit 3

/* Q29. Get the following details for top 9 directors (based on number of movies)*/

WITH movie_date_info AS
(
SELECT d.name_id, name, d.movie_id,
	   m.date_published, 
       LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published) AS next_movie_date
FROM director_mapping d
	 JOIN names AS n 
     ON d.name_id=n.id 
	 JOIN movie AS m 
     ON d.movie_id=m.id
),

date_difference AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM movie_date_info
 ),

 avg_inter_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_inter_movie_days
	 FROM date_difference
	 GROUP BY name_id
 ),

 director_details AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_inter_movie_days) AS inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration
		 -- DENSE_RANK() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_inter_days AS a 
         ON a.name_id=d.name_id

	 GROUP BY director_id
     ORDER BY COUNT(d.movie_id) DESC
 )
 SELECT director_id,
        director_name,
        number_of_movies,
        inter_movie_days,
        avg_rating,
        total_votes,
        min_rating,
        max_rating,
        total_duration	
 FROM director_details
 LIMIT 9;
 

 


      