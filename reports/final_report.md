# Customer revenue and retention analytics — final report

## Answer first

The validated sample contains $2,328.60 from 412 invoices and 59 customers. Revenue is concentrated most heavily in the United States ($523.06; 22.5%) and Rock ($826.65; 35.5%). As of 2025-12-31, 12 customers fall in the 91–180 day At-risk band and form the most defensible first re-engagement audience; the 28 customers dormant for more than 180 days should be handled as a separate, lower-propensity segment.

## Evidence

- Coverage: 2021-01-01 through 2025-12-22.
- Average order value: $5.65.
- Activity bands: 19 Active, 12 At risk, 28 Dormant.
- 2025 repeat buyer rate: 100% in each month, reflecting the generated sample's purchasing schedule.
- Every invoice total reconciles to its line items within $0.01.
- Primary-key, required-field and foreign-key checks pass before KPI tables are produced.

## Decision recommendation

Use the At-risk segment for a small re-engagement test, stratified by country and lifetime value. Keep Dormant customers out of the primary test so materially different recency profiles are not mixed. Monitor incremental repeat purchases rather than interpreting the proxy status as confirmed churn.

## Limitations

Chinook is a sample database with fictional customers and generated sales. Findings demonstrate a reliable analytical workflow, not external market truth. There is no cancellation event, subscription state, campaign exposure or margin data. The inactivity windows are assumptions and should be calibrated against real purchase cadence before production use.

