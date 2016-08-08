CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

SET plpgsql.extra_warnings TO 'all';

DO $$
DECLARE
	N INT DEFAULT 10000000;
	e TEXT;
	id_int INT;
	id_uuid UUID;
	id_text TEXT;
BEGIN

RAISE NOTICE 'Creating tables';

CREATE TEMPORARY TABLE big_int(id SERIAL PRIMARY KEY, x INT NULL);
CREATE TEMPORARY TABLE big_uuid(id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), x INT NULL);
CREATE TEMPORARY TABLE big_text(id TEXT PRIMARY KEY DEFAULT digest(random()::text || now()::text || random()::text, 'sha512'), x INT NULL);

RAISE NOTICE '----------------------------------------';

RAISE NOTICE 'Primary key (surrogate serial/uuid / natural text) benchmark';

RAISE NOTICE 'Filling tables with % random items', N;

RAISE NOTICE '----------------------------------------';

RAISE NOTICE 'Populating %', 'big_int';
FOR e IN EXPLAIN ANALYZE
	INSERT INTO big_int (x) SELECT generate_series(1, N) AS x
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE 'Populating %', 'big_uuid';
FOR e IN EXPLAIN ANALYZE
	INSERT INTO big_uuid (x) SELECT generate_series(1, N) AS x
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE 'Populating %', 'big_text';
FOR e IN EXPLAIN ANALYZE
	INSERT INTO big_text (x) SELECT generate_series(1, N) AS x
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE '----------------------------------------';

RAISE NOTICE 'Inserting into %', 'big_int';
FOR e IN EXPLAIN ANALYZE
	INSERT INTO big_int (x) VALUES (NULL)
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE 'Inserting into %', 'big_uuid';
FOR e IN EXPLAIN ANALYZE
	INSERT INTO big_uuid (x) VALUES (NULL)
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE 'Inserting into %', 'big_text';
FOR e IN EXPLAIN ANALYZE
	INSERT INTO big_text (x) VALUES (NULL)
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE '----------------------------------------';

RAISE NOTICE 'Sampling %', 'big_int';
id_int := (SELECT id FROM big_int TABLESAMPLE BERNOULLI (1) LIMIT 1);

RAISE NOTICE 'Sampling %', 'big_uuid';
id_uuid := (SELECT id FROM big_uuid TABLESAMPLE BERNOULLI (1) LIMIT 1);

RAISE NOTICE 'Sampling %', 'big_text';
id_text := (SELECT id FROM big_text TABLESAMPLE BERNOULLI (1) LIMIT 1);

RAISE NOTICE '----------------------------------------';

RAISE NOTICE 'Searching %', 'big_int';
FOR e IN EXPLAIN ANALYZE
	SELECT x FROM big_int WHERE id = id_int
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE 'Searching %', 'big_uuid';
FOR e IN EXPLAIN ANALYZE
	SELECT x FROM big_uuid WHERE id = id_uuid
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE 'Searching %', 'big_text';
FOR e IN EXPLAIN ANALYZE
	SELECT x FROM big_text WHERE id = id_text
LOOP
	RAISE NOTICE ' | %', e;
END LOOP;
RAISE NOTICE '';

RAISE NOTICE '----------------------------------------';

DROP TABLE IF EXISTS big_int, big_uuid, big_text CASCADE;
RAISE NOTICE 'Done';

END;
$$;
