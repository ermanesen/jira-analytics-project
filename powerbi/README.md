# Power BI import guide

1. Run the pipeline to refresh `powerbi/exports/`.
2. Import each CSV with **Get data → Text/CSV**.
3. Set dates to Date, IDs/counts to Whole number, revenue to Fixed decimal, and rates to Decimal number.
4. Relate `customer_lifecycle[customer_id]` only to customer-level extensions. The current summary exports are intentionally separate aggregate tables and should not be joined to each other.
5. Add the measures from `measures.dax` and import `theme.json`.
6. Build pages for Executive Overview, Customer Lifecycle, Cohorts, and Product/Market Mix.

Recommended slicers are month, country, genre, activity status and RFM segment. Always label inactivity status as a proxy rather than confirmed churn.

The included `docs/dashboard_preview.svg` documents the intended layout. It is not represented as a native Power BI file because Power BI Desktop was unavailable for validation.

