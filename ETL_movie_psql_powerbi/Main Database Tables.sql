CREATE TABLE director (
	"id" SERIAL PRIMARY KEY,	
	name VARCHAR(60)
);

CREATE TABLE genre (
	"id" SERIAL PRIMARY KEY,	
	name VARCHAR(60)
);

CREATE TABLE movie (
	"id" SERIAL PRIMARY KEY,
	original_title TEXT,
	primary_title TEXT,
	"type" VARCHAR(70),
	"year" INT,
	duration INT,
	original_language VARCHAR(50),
	is_adult BOOL,
	mpa_rating VARCHAR(50),
	box_office BIGINT
);

CREATE TABLE imdb_rating (
	"id" SERIAL PRIMARY KEY,
	movie_id INT REFERENCES movie("id"),
	avg_rating INT,
	num_votes INT
);

CREATE TABLE rotten_tom_rating (
	"id" SERIAL PRIMARY KEY,
	movie_id INT REFERENCES movie("id"),
	critic_score INT,
	people_score INT,
	total_reviews INT
);

CREATE TABLE movie_director (
	"id" SERIAL PRIMARY KEY,
	director_id INT REFERENCES director("id"),
	movie_id INT REFERENCES movie("id")
);

CREATE TABLE movie_genre (
	"id" SERIAL PRIMARY KEY,
	genre_id INT REFERENCES genre("id"),
	movie_id INT REFERENCES movie("id")
);


-- DROP TABLE IF EXISTS movie_director;
-- DROP TABLE IF EXISTS movie_genre;
-- DROP TABLE IF EXISTS imdb_rating;
-- DROP TABLE IF EXISTS rotten_tom_rating;
-- DROP TABLE IF EXISTS movie;
-- DROP TABLE IF EXISTS director;
-- DROP TABLE IF EXISTS genre;

