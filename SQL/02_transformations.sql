CREATE OR REPLACE VIEW customer_segments AS
SELECT *,
    CASE
        WHEN length_of_membership < 1 THEN '0-1'
        WHEN length_of_membership < 2 THEN '1-2'
        WHEN length_of_membership < 3 THEN '2-3'
        WHEN length_of_membership < 4 THEN '3-4'
        ELSE '4+'
    END AS membership_segment
FROM customers;
