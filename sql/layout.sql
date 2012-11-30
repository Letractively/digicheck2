-- Para PgSQL

-- createuser <digick>

-- createdb <digick>

CREATE TABLE cam1 (
       id SERIAL PRIMARY KEY,
       img BYTEA NOT NULL,
       csum CHAR(32) NOT NULL);

ALTER TABLE cam1 ALTER COLUMN img SET STORAGE EXTERNAL;

CREATE TABLE cam2 (
       id SERIAL PRIMARY KEY,
       img BYTEA NOT NULL,
       csum CHAR(32) NOT NULL);

ALTER TABLE cam2 ALTER COLUMN img SET STORAGE EXTERNAL;

CREATE TABLE cam3 (
       id SERIAL PRIMARY KEY,
       img BYTEA NOT NULL,
       csum CHAR(32) NOT NULL);

ALTER TABLE cam3 ALTER COLUMN img SET STORAGE EXTERNAL;

CREATE TABLE record (
       id SERIAL PRIMARY KEY,
       img1 INT NOT NULL REFERENCES cam1 (id),
       img2 INT NOT NULL REFERENCES cam2 (id),
       img3 INT NOT NULL REFERENCES cam3 (id),
       caja INT NOT NULL,
       ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);


-- Querys

-- SELECT id FROM record WHERE ts = $date AND caja = $caja;



