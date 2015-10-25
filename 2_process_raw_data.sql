/*
 * Create function to process the fruits table.
 * Cycles through the tmp_fruit records and returns a string.
 */

CREATE OR REPLACE FUNCTION tmp_process_fruit(varchar) RETURNS VARCHAR AS $$
DECLARE
 		c_tmp_fruit      refcursor;
        r_tmp_fruit      RECORD;
        counter          int;
        accum 			 varchar;
        query 			 varchar;

BEGIN
    counter := 0;
	query := 'select * from tmp_fruit order by name desc';
	accum := '';
	OPEN c_tmp_fruit FOR EXECUTE query;
    FETCH FIRST FROM c_tmp_fruit INTO r_tmp_fruit;

    WHILE FOUND = TRUE LOOP 
        -- If the fruit is what we passed in as a parameter the generated 
        -- string element will look a little different when added to the accumulator 
        IF (r_tmp_fruit.name   = $1) THEN 
            accum := '*_' || r_tmp_fruit.name || '_' || CAST( counter AS text ) || '_' || accum || '*';
        -- Otherwise, the string element just gets added to the accumulator as is
        ELSE
            accum := r_tmp_fruit.name || ' ' || accum ;
        END IF;
        RAISE NOTICE 'Processing Record : %  ', counter;
        counter := counter + 1;
  		FETCH NEXT FROM c_tmp_fruit INTO r_tmp_fruit;
    END LOOP;

    CLOSE c_tmp_fruit;
    RETURN accum;
END;
$$ LANGUAGE PLPGSQL
;

DROP TABLE IF EXISTS tmp_processed
;

/*
 * Create a table called tmp_processed with the result of the 
 * tmp_process_fruit('Orange') function call. We will export this 
 * in a CSV file in another step.
 */
CREATE TABLE tmp_processed AS
SELECT tmp_process_fruit('Orange')
;