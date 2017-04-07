DROP TABLE test;
-- Create test data
CREATE TABLE test (x SERIAL, y INT);
INSERT INTO test (y) VALUES (64), (48), (32), (16), (50), (40), (30), (20), (10), (60), (70), (80);
SELECT * FROM test;
-- With respect to x-ordering, get y-value of item before and item after where y=50
SELECT * FROM (
	SELECT
		x,
		lag(y,1,0) OVER (ORDER BY x) AS prev,
		y AS this,
		lead(y,1,0) OVER (ORDER BY x) AS next
	FROM test) AS tmp
WHERE this = 50;

