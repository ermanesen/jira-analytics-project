-- Load the privacy-minimised relational snapshot. This file is SQL only.
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE TABLE raw.customers AS
SELECT customer_id::INTEGER AS customer_id,
       country::VARCHAR AS country,
       support_rep_id::INTEGER AS support_rep_id
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/customers.csv', header = true);

CREATE OR REPLACE TABLE raw.employees AS
SELECT employee_id::INTEGER AS employee_id,
       employee_role::VARCHAR AS role,
       manager_id::INTEGER AS manager_id
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/employees.csv', header = true);

CREATE OR REPLACE TABLE raw.artists AS
SELECT artist_id::INTEGER AS artist_id, artist_name::VARCHAR AS artist_name
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/artists.csv', header = true);

CREATE OR REPLACE TABLE raw.albums AS
SELECT album_id::INTEGER AS album_id,
       album_title::VARCHAR AS album_title,
       artist_id::INTEGER AS artist_id
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/albums.csv', header = true);

CREATE OR REPLACE TABLE raw.genres AS
SELECT genre_id::INTEGER AS genre_id, genre_name::VARCHAR AS genre_name
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/genres.csv', header = true);

CREATE OR REPLACE TABLE raw.tracks AS
SELECT track_id::INTEGER AS track_id,
       track_name::VARCHAR AS track_name,
       album_id::INTEGER AS album_id,
       media_type_id::INTEGER AS media_type_id,
       genre_id::INTEGER AS genre_id,
       milliseconds::INTEGER AS milliseconds,
       bytes::BIGINT AS bytes,
       unit_price::DECIMAL(10, 2) AS unit_price
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/tracks.csv', header = true);

CREATE OR REPLACE TABLE raw.invoices AS
SELECT invoice_id::INTEGER AS invoice_id,
       customer_id::INTEGER AS customer_id,
       invoice_date::DATE AS invoice_date,
       billing_country::VARCHAR AS billing_country,
       total::DECIMAL(10, 2) AS total
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/invoices.csv', header = true);

CREATE OR REPLACE TABLE raw.invoice_lines AS
SELECT invoice_line_id::INTEGER AS invoice_line_id,
       invoice_id::INTEGER AS invoice_id,
       track_id::INTEGER AS track_id,
       unit_price::DECIMAL(10, 2) AS unit_price,
       quantity::INTEGER AS quantity
FROM read_csv_auto('{{PROJECT_ROOT}}/data/processed/invoice_lines.csv', header = true);

