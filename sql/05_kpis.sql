CREATE OR REPLACE TABLE analytics.monthly_kpis AS
WITH month_spine AS (
    SELECT DISTINCT month_start FROM analytics.dim_date
), customer_first AS (
    SELECT customer_id, DATE_TRUNC('month', MIN(invoice_date))::DATE AS first_month
    FROM analytics.fact_invoice GROUP BY customer_id
), monthly AS (
    SELECT m.month_start,
           COALESCE(SUM(i.total), 0)::DECIMAL(12, 2) AS revenue,
           COUNT(DISTINCT i.invoice_id) AS orders,
           COUNT(DISTINCT i.customer_id) AS active_customers,
           COUNT(DISTINCT CASE WHEN f.first_month < m.month_start THEN i.customer_id END) AS repeat_customers
    FROM month_spine m
    LEFT JOIN analytics.fact_invoice i USING (month_start)
    LEFT JOIN customer_first f USING (customer_id)
    GROUP BY m.month_start
)
SELECT *,
       CASE WHEN orders = 0 THEN NULL ELSE ROUND(revenue / orders, 2) END AS average_order_value,
       CASE WHEN active_customers = 0 THEN NULL ELSE ROUND(100.0 * repeat_customers / active_customers, 1) END AS repeat_buyer_rate_pct,
       SUM(revenue) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)::DECIMAL(12, 2) AS rolling_3m_revenue
FROM monthly ORDER BY month_start;

CREATE OR REPLACE TABLE analytics.cohort_continuation AS
WITH first_purchase AS (
    SELECT customer_id, DATE_TRUNC('month', MIN(invoice_date))::DATE AS cohort_month
    FROM analytics.fact_invoice GROUP BY customer_id
), activity AS (
    SELECT DISTINCT i.customer_id, f.cohort_month, i.month_start AS activity_month,
           DATE_DIFF('month', f.cohort_month, i.month_start) AS months_since_first_purchase
    FROM analytics.fact_invoice i JOIN first_purchase f USING (customer_id)
), cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size FROM first_purchase GROUP BY cohort_month
)
SELECT a.cohort_month, a.months_since_first_purchase, s.cohort_size,
       COUNT(DISTINCT a.customer_id) AS returning_customers,
       ROUND(100.0 * COUNT(DISTINCT a.customer_id) / s.cohort_size, 1) AS continuation_rate_pct
FROM activity a JOIN cohort_sizes s USING (cohort_month)
GROUP BY a.cohort_month, a.months_since_first_purchase, s.cohort_size
ORDER BY a.cohort_month, a.months_since_first_purchase;

CREATE OR REPLACE TABLE analytics.product_performance AS
SELECT p.genre_name, COUNT(DISTINCT s.invoice_id) AS orders,
       SUM(s.quantity) AS units, SUM(s.line_revenue)::DECIMAL(12, 2) AS revenue,
       ROUND(100.0 * SUM(s.line_revenue) / SUM(SUM(s.line_revenue)) OVER (), 1) AS revenue_share_pct
FROM analytics.fact_sales s JOIN analytics.dim_product p USING (track_id)
GROUP BY p.genre_name ORDER BY revenue DESC;

CREATE OR REPLACE TABLE analytics.country_performance AS
SELECT billing_country AS country, COUNT(DISTINCT invoice_id) AS orders,
       COUNT(DISTINCT customer_id) AS active_customers,
       SUM(total)::DECIMAL(12, 2) AS revenue,
       (SUM(total) / COUNT(DISTINCT invoice_id))::DECIMAL(12, 2) AS average_order_value
FROM analytics.fact_invoice GROUP BY billing_country ORDER BY revenue DESC;

