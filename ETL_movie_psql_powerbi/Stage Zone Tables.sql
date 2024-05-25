-- make sure DB encoding is right

CREATE TABLE title_rating (
	tconst VARCHAR(50) PRIMARY KEY,
	averageRating FLOAT,
	numVotes INT
);

-- executed in psql cli
\copy title_rating FROM 'C:\Users\user\DA_journey\etl_movie_psql\data\title_rating.csv' WITH (FORMAT csv, HEADER true)


CREATE TABLE title_basic (
	tconst VARCHAR(50) PRIMARY KEY,
	titleType VARCHAR(50),
	primaryTitle VARCHAR(250),
	originalTitle VARCHAR(250),
	isAdult BOOL,
	startYear VARCHAR(50),
	endYear VARCHAR(50),
	runtimeMinutes VARCHAR(50),
	genres VARCHAR(200)
);


\copy title_basic FROM 'C:\Users\user\DA_journey\etl_movie_psql\data\title_basic_utf.csv' WITH (FORMAT csv, HEADER true)

	CREATE TABLE rotten_tomatoes (
	"id" INT PRIMARY KEY,
	title VARCHAR(250),
	"year" INT,
	critic_score INT,
	people_score INT,
	total_reviews INT,
	rating TEXT,
	genre_rt VARCHAR(200),
	original_language VARCHAR(100),
	director VARCHAR(250),
	box_office VARCHAR(50)
);


\copy rotten_tomatoes FROM 'C:\Users\user\DA_journey\etl_movie_psql\data\rotten_tomatoes.csv' WITH (FORMAT csv, HEADER true)

-- drop table title_rating;
-- drop table title_basic;
-- drop table rotten_tomatoes;

-- SELECT * 
-- -- FROM title_rating
-- -- FROM title_basic
-- FROM rotten_tomatoes
-- ORDER BY box_office ASC

-- SHOW server_encoding;