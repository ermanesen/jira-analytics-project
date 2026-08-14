CREATE OR REPLACE TABLE analytics.fact_invoice AS
SELECT i.invoice_id, i.customer_id, i.invoice_date,
       DATE_TRUNC('month', i.invoice_date)::DATE AS month_start,
       i.billing_country, i.total
FROM raw.invoices i;

CREATE OR REPLACE TABLE analytics.fact_sales AS
SELECT l.invoice_line_id, l.invoice_id, i.customer_id, i.invoice_date,
       DATE_TRUNC('month', i.invoice_date)::DATE AS month_start,
       i.billing_country, l.track_id, l.unit_price, l.quantity,
       (l.unit_price * l.quantity)::DECIMAL(12, 2) AS line_revenue
FROM raw.invoice_lines l
JOIN raw.invoices i USING (invoice_id);

