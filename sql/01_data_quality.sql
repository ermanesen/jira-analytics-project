-- Every check is queryable and makes the pipeline fail if its status is not PASS.
CREATE OR REPLACE TABLE audit.data_quality_results AS
WITH checks AS (
    SELECT 'customers_row_count' AS check_name, COUNT(*)::VARCHAR AS observed_value,
           CASE WHEN COUNT(*) = 59 THEN 'PASS' ELSE 'FAIL' END AS status FROM raw.customers
    UNION ALL SELECT 'invoices_row_count', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 412 THEN 'PASS' ELSE 'FAIL' END FROM raw.invoices
    UNION ALL SELECT 'invoice_lines_row_count', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 2240 THEN 'PASS' ELSE 'FAIL' END FROM raw.invoice_lines
    UNION ALL SELECT 'duplicate_customer_keys', (COUNT(*) - COUNT(DISTINCT customer_id))::VARCHAR,
           CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS' ELSE 'FAIL' END FROM raw.customers
    UNION ALL SELECT 'duplicate_invoice_keys', (COUNT(*) - COUNT(DISTINCT invoice_id))::VARCHAR,
           CASE WHEN COUNT(*) = COUNT(DISTINCT invoice_id) THEN 'PASS' ELSE 'FAIL' END FROM raw.invoices
    UNION ALL SELECT 'duplicate_invoice_line_keys', (COUNT(*) - COUNT(DISTINCT invoice_line_id))::VARCHAR,
           CASE WHEN COUNT(*) = COUNT(DISTINCT invoice_line_id) THEN 'PASS' ELSE 'FAIL' END FROM raw.invoice_lines
    UNION ALL SELECT 'invoice_customer_orphans', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
           FROM raw.invoices i LEFT JOIN raw.customers c USING (customer_id) WHERE c.customer_id IS NULL
    UNION ALL SELECT 'line_invoice_orphans', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
           FROM raw.invoice_lines l LEFT JOIN raw.invoices i USING (invoice_id) WHERE i.invoice_id IS NULL
    UNION ALL SELECT 'line_track_orphans', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
           FROM raw.invoice_lines l LEFT JOIN raw.tracks t USING (track_id) WHERE t.track_id IS NULL
    UNION ALL SELECT 'null_required_fields', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
           FROM raw.invoices WHERE customer_id IS NULL OR invoice_date IS NULL OR total IS NULL
    UNION ALL SELECT 'nonpositive_line_values', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
           FROM raw.invoice_lines WHERE unit_price <= 0 OR quantity <= 0
    UNION ALL SELECT 'invoice_line_reconciliation', COUNT(*)::VARCHAR,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
           FROM (
               SELECT i.invoice_id
               FROM raw.invoices i
               JOIN raw.invoice_lines l USING (invoice_id)
               GROUP BY i.invoice_id, i.total
               HAVING ABS(i.total - SUM(l.unit_price * l.quantity)) > 0.01
           ) mismatches
)
SELECT * FROM checks;

