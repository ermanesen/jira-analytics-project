SELECT AVG(yearly_amount_spent) AS avg_spending
FROM customers;

SELECT
    membership_segment,
    AVG(yearly_amount_spent) AS avg_spending
FROM customer_segments
GROUP BY membership_segment
ORDER BY membership_segment;

SELECT
    AVG(time_on_app) AS avg_time_app,
    AVG(time_on_website) AS avg_time_web,
    AVG(yearly_amount_spent) AS avg_spending
FROM customers;
