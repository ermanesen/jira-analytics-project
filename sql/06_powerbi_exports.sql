COPY analytics.monthly_kpis TO '{{PROJECT_ROOT}}/powerbi/exports/monthly_kpis.csv' (HEADER, DELIMITER ',');
COPY analytics.customer_lifecycle TO '{{PROJECT_ROOT}}/powerbi/exports/customer_lifecycle.csv' (HEADER, DELIMITER ',');
COPY analytics.cohort_continuation TO '{{PROJECT_ROOT}}/powerbi/exports/cohort_continuation.csv' (HEADER, DELIMITER ',');
COPY analytics.product_performance TO '{{PROJECT_ROOT}}/powerbi/exports/product_performance.csv' (HEADER, DELIMITER ',');
COPY analytics.country_performance TO '{{PROJECT_ROOT}}/powerbi/exports/country_performance.csv' (HEADER, DELIMITER ',');
COPY audit.data_quality_results TO '{{PROJECT_ROOT}}/powerbi/exports/data_quality_results.csv' (HEADER, DELIMITER ',');

