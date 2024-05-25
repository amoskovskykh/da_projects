
-- Insert data into genre
CREATE OR REPLACE PROCEDURE add_genres() AS $$
BEGIN
	INSERT INTO genre(name)
	SELECT 
		DISTINCT unnest(string_to_array(genres, ',')) AS genre
	FROM title_basic;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
CALL add_genres();
-- SELECT * FROM genre;
-- ROLLBACK;


-- Insert data into director 
CREATE OR REPLACE PROCEDURE add_director() AS $$
BEGIN

	INSERT INTO director(name)
	SELECT 
		DISTINCT unnest(string_to_array(director, ',')) AS director
	FROM rotten_tomatoes;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
CALL add_director();
-- SELECT * FROM director;


-- Inset data into movie
CREATE OR REPLACE PROCEDURE add_movie() AS $$
BEGIN
	WITH movie_raw AS (
	SELECT *
    FROM title_basic tb 
    INNER JOIN rotten_tomatoes rt ON rt.title = tb.primaryTitle AND rt."year" = tb.startYear
	)
	INSERT INTO movie(id, original_title, primary_title, type, year, duration, original_language, is_adult, mpa_rating, box_office)
	SELECT
		id, 
		originalTitle, 
		primaryTitle, 
		titleType, 
		startYear,
		CASE
			WHEN runtimeMinutes = '\N' THEN NULL
			ELSE runtimeMinutes::INT
		END AS duration,
		original_language, 
		isAdult, 
		-- leave mpa_rating abbreviation without description
		CASE
			WHEN rating IS NULL THEN NULL
			ELSE regexp_replace(rating, ' \([^)]{1,}\)', '', 'g')
		END AS mpa_rating,
		CASE
			WHEN box_office ~ E'^[$][0-9]+\.[0-9]+[MK]$' THEN
				CASE
					WHEN box_office ~ E'M$' THEN
						(substring(box_office, 2, length(box_office) - 2)::NUMERIC) * 1000000::BIGINT
					WHEN box_office ~ E'K$' THEN
						(substring(box_office, 2, length(box_office) - 2)::NUMERIC) * 1000::BIGINT
				END
			ELSE
				NULL
		END as box_office
		
	FROM movie_raw;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
CALL add_movie();
-- SELECT * FROM movie
-- ORDER BY id ASC;


-- Insert into movie_genre
CREATE OR REPLACE PROCEDURE add_movie_genre() AS $$
BEGIN
	CREATE TEMP TABLE basic_rotten_join AS
	SELECT DISTINCT tb.genres, rt.id
	FROM title_basic tb 
	INNER JOIN rotten_tomatoes rt ON rt.title = tb.primaryTitle AND rt."year" = tb.startYear;

	INSERT INTO movie_genre(genre_id, movie_id)
	SELECT
		genre.id AS genre_id,
		movie_un.id AS movie_id
	FROM
		(SELECT id, unnest(string_to_array(genres, ',')) AS genre_name FROM basic_rotten_join) AS movie_un
	JOIN genre 
		ON genre.name = movie_un.genre_name;
	DROP TABLE basic_rotten_join;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
CALL add_movie_genre();
-- SELECT * FROM movie_genre
-- ORDER BY id ASC;


-- Insert into movie_director
CREATE OR REPLACE PROCEDURE add_movie_director() AS $$
BEGIN
    INSERT INTO movie_director(director_id, movie_id)
    SELECT 
        director.id AS director_id,
        movie.id AS movie_id
    FROM
        (SELECT id, unnest(string_to_array(director, ',')) AS director_name FROM rotten_tomatoes) AS movie
    JOIN director
        ON movie.director_name = director.name
    ON CONFLICT ON CONSTRAINT movie_director_pkey DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
CALL add_movie_director();
-- SELECT * FROM movie_director;
-- ROLLBACK;


-- Insert data into imdb_rating
CREATE OR REPLACE PROCEDURE add_imdb_rating() AS $$
BEGIN

	WITH imdb_rating_raw AS (
	SELECT DISTINCT rt.id, tr.averageRating, tr.numVotes
    FROM title_basic tb 
    INNER JOIN title_rating tr ON tb.tconst = tr.tconst
    INNER JOIN rotten_tomatoes rt ON rt.title = tb.primaryTitle AND rt."year" = tb.startYear
	)
	INSERT INTO imdb_rating(movie_id, avg_rating, num_votes)
	SELECT 
		imdb_rating_raw.id, 
		(averageRating * 10)::INT, 
		numVotes
	FROM imdb_rating_raw;

END;
$$ LANGUAGE plpgsql;

CALL add_imdb_rating();
-- SELECT * FROM imdb_rating


-- Insert data into rotten_tom_rating
CREATE OR REPLACE PROCEDURE add_rotten_tom_rating() AS $$
BEGIN

	INSERT INTO rotten_tom_rating(movie_id, critic_score, people_score, total_reviews)
	SELECT 
		id, 
		critic_score, 
		people_score,
		total_reviews
	FROM 
		rotten_tomatoes;
END;
$$ LANGUAGE plpgsql;

CALL add_rotten_tom_rating();

-- SELECT * FROM genre;
-- SELECT * FROM director;
-- SELECT * FROM movie;
-- SELECT * FROM movie_genre;
-- SELECT * FROM movie_director;
-- SELECT * FROM imdb_rating;
-- SELECT * FROM rotten_tom_rating;