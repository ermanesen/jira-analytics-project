# Data dictionary

## Model grain

| Object | Grain | Primary key |
|---|---|---|
| `dim_customer` | One customer | `customer_id` |
| `dim_product` | One track | `track_id` |
| `dim_date` | One calendar day | `calendar_date` |
| `fact_invoice` | One invoice | `invoice_id` |
| `fact_sales` | One invoice line | `invoice_line_id` |
| `customer_lifecycle` | One customer at 2025-12-31 | `customer_id` |
| `monthly_kpis` | One calendar month | `month_start` |

## Important fields

- `line_revenue`: unit price multiplied by quantity.
- `recency_days`: days from a customer's last invoice to the fixed analysis date.
- `activity_status`: transparent inactivity band, not observed churn.
- `repeat_buyer_rate_pct`: share of monthly buyers first acquired before that month.
- `continuation_rate_pct`: share of an acquisition cohort buying again at month offset *n*.
- `rolling_3m_revenue`: current plus preceding two calendar months.

