CREATE OR REPLACE TABLE analytics.dim_customer AS
SELECT c.customer_id, c.country, c.support_rep_id, e.role AS support_rep_role
FROM raw.customers c
LEFT JOIN raw.employees e ON c.support_rep_id = e.employee_id;

CREATE OR REPLACE TABLE analytics.dim_product AS
SELECT t.track_id, t.track_name, t.album_id, a.album_title,
       a.artist_id, ar.artist_name, t.genre_id, g.genre_name,
       t.media_type_id, t.milliseconds, t.unit_price
FROM raw.tracks t
LEFT JOIN raw.albums a USING (album_id)
LEFT JOIN raw.artists ar USING (artist_id)
LEFT JOIN raw.genres g USING (genre_id);

CREATE OR REPLACE TABLE analytics.dim_date AS
SELECT calendar_date,
       DATE_TRUNC('month', calendar_date)::DATE AS month_start,
       YEAR(calendar_date) AS calendar_year,
       MONTH(calendar_date) AS month_number,
       STRFTIME(calendar_date, '%Y-%m') AS year_month
FROM generate_series(
    (SELECT MIN(invoice_date) FROM raw.invoices),
    (SELECT MAX(invoice_date) FROM raw.invoices),
    INTERVAL 1 DAY
) AS dates(calendar_date);

