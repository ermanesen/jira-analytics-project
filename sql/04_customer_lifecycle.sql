CREATE OR REPLACE VIEW analytics.customer_order_sequence AS
SELECT invoice_id, customer_id, invoice_date, total,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY invoice_date, invoice_id) AS order_number,
       MIN(invoice_date) OVER (PARTITION BY customer_id) AS first_order_date,
       LAG(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date, invoice_id) AS previous_order_date
FROM analytics.fact_invoice;

CREATE OR REPLACE TABLE analytics.customer_lifecycle AS
WITH customer_metrics AS (
    SELECT customer_id,
           MIN(invoice_date) AS first_order_date,
           MAX(invoice_date) AS last_order_date,
           DATE_DIFF('day', MAX(invoice_date), DATE '2025-12-31') AS recency_days,
           COUNT(*) AS order_count,
           SUM(total)::DECIMAL(12, 2) AS lifetime_revenue,
           AVG(total)::DECIMAL(12, 2) AS average_order_value
    FROM analytics.fact_invoice
    GROUP BY customer_id
), scored AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY recency_days DESC) AS recency_score,
           NTILE(4) OVER (ORDER BY order_count) AS frequency_score,
           NTILE(4) OVER (ORDER BY lifetime_revenue) AS monetary_score
    FROM customer_metrics
)
SELECT s.*, c.country,
       CASE WHEN recency_days <= 90 THEN 'Active'
            WHEN recency_days <= 180 THEN 'At risk'
            ELSE 'Dormant' END AS activity_status,
       CASE WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal'
            WHEN recency_score <= 2 AND (frequency_score >= 3 OR monetary_score >= 3) THEN 'At risk'
            WHEN recency_score = 1 AND frequency_score <= 2 THEN 'Hibernating'
            ELSE 'Needs attention' END AS rfm_segment
FROM scored s
JOIN analytics.dim_customer c USING (customer_id);

