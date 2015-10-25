/*
 * Create temp table to store our incoming data - from the CSV import 
 */
DROP TABLE IF EXISTS tmp_fruit
;

CREATE TABLE tmp_fruit
(
	name	varchar(10),
	count	int
)
;