# Jira delivery plan

## Epic: CRR-1 — Customer revenue and retention analytics

**Outcome:** Give commercial stakeholders a reproducible view of revenue drivers, repeat purchasing and customer inactivity risk.

### CRR-2 — Establish a governed source snapshot

Acceptance criteria:

- Source, retrieval date, license, row counts and limitations are documented.
- Direct customer identifiers are excluded.
- Primary and foreign key checks return zero failures.

### CRR-3 — Build the DuckDB analytical model

Acceptance criteria:

- Numbered SQL layers run from a clean environment.
- Invoice-line revenue reconciles to every invoice total within $0.01.
- Facts, dimensions and grains are documented.

### CRR-4 — Define lifecycle and cohort metrics

Acceptance criteria:

- Repeat buyer rate and cohort continuation have explicit denominators.
- Inactivity uses a fixed as-of date and documented 90/180-day thresholds.
- The output never labels inactivity as observed churn.

### CRR-5 — Deliver Power BI-ready outputs

Acceptance criteria:

- Six non-empty CSV exports are produced by the pipeline.
- DAX measures, field types and page recommendations are documented.
- Dashboard values agree with validated SQL outputs.

### CRR-6 — Automate quality gates

Acceptance criteria:

- CI runs the full SQL pipeline, tests and notebook from top to bottom.
- Binary databases, WAL files and unrelated archives are rejected.
- A failing data quality check stops the build.

