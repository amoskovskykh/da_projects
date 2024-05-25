-- preprocessing + joining movies based on year and title (and avoiding duplicated)

DROP TABLE IF EXISTS temp_joined_table;


CREATE OR REPLACE PROCEDURE filter_stage_zone() AS $$
BEGIN

	-- substituting \N with NULL
	UPDATE title_basic
	SET startYear = NULL
	WHERE startYear = '\N';
	
	ALTER TABLE title_basic
	ALTER COLUMN startYear TYPE INT USING NULLIF(startYear, '')::INT;
	
	-- general approach to dropping duplicates in a table
	WITH duplicates AS (
    SELECT title, year
    FROM rotten_tomatoes
    GROUP BY title, year
    HAVING COUNT(*) > 1
	)  
	DELETE FROM rotten_tomatoes
	WHERE (title, year) IN (SELECT title, year FROM duplicates)
		AND (id, title, year) NOT IN (
			SELECT MIN(id), title, year
			FROM rotten_tomatoes
			GROUP BY title, year
		);
	
	-- joing tables from in the stage zone 
    CREATE TEMP TABLE temp_joined_table AS
    SELECT tb.tconst, rt.id, rt.title, tb.startYear AS imdb_year, rt."year" AS rt_year
    FROM title_basic tb 
	INNER JOIN rotten_tomatoes rt ON rt.title = tb.primaryTitle AND rt."year" = tb.startYear
    INNER JOIN title_rating tr ON tb.tconst = tr.tconst;
	
	WITH duplicates_id AS (
    SELECT id
    FROM temp_joined_table
    GROUP BY id
    HAVING COUNT(*) > 1
	)
	DELETE FROM temp_joined_table
	WHERE id IN (SELECT id FROM duplicates_id)
		AND (tconst, id) NOT IN (
			SELECT MIN(tconst), id
			FROM temp_joined_table
			GROUP BY id
		);

    DELETE FROM rotten_tomatoes
    WHERE (id) NOT IN (SELECT id FROM temp_joined_table);
			  
    DELETE FROM title_basic
    WHERE tconst NOT IN (SELECT tconst FROM temp_joined_table);

    DELETE FROM title_rating
    WHERE tconst NOT IN (SELECT tconst FROM temp_joined_table);

END;
$$ LANGUAGE plpgsql;

CALL filter_stage_zone();

-- SELECT * FROM temp_joined_table LIMIT 10;
SELECT imdb_year FROM temp_joined_table ORDER BY imdb_year DESC;

-- removing double quotes
CREATE OR REPLACE PROCEDURE remove_dquotes() AS $$
BEGIN
	UPDATE title_basic
	SET
		primaryTitle = REPLACE(primaryTitle, '"', ''),
		originalTitle = REPLACE(originalTitle, '"', ''),
		genres = REPLACE(genres, '"', '')
	WHERE
		primaryTitle LIKE '%"%' OR
		originalTitle LIKE '%"%' OR 
		genres LIKE '%"%';

	UPDATE rotten_tomatoes
	SET
		title = REPLACE(title, '"', ''),
		rating = REPLACE(rating, '"', ''),
		genre_rt = REPLACE(genre_rt, '"', ''),
		director = REPLACE(director, '"', '')
	WHERE
		title LIKE '%"%' OR
		rating LIKE '%"%' OR 
		genre_rt LIKE '%"%' OR
		director LIKE '%"%';
END;
$$ LANGUAGE plpgsql;

CALL remove_dquotes();

