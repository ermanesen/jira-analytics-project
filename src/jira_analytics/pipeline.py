"""Build the DuckDB analytical model and Power BI-ready exports."""

from __future__ import annotations

import argparse
import logging
from pathlib import Path

import duckdb

LOGGER = logging.getLogger(__name__)
SQL_FILES = [
    "00_create_raw_tables.sql",
    "01_data_quality.sql",
    "02_dimensions.sql",
    "03_facts.sql",
    "04_customer_lifecycle.sql",
    "05_kpis.sql",
    "06_powerbi_exports.sql",
]


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def build(database: str = ":memory:", root: Path | None = None) -> duckdb.DuckDBPyConnection:
    """Run every numbered SQL layer in a fresh or supplied DuckDB database."""
    root = (root or project_root()).resolve()
    (root / "powerbi" / "exports").mkdir(parents=True, exist_ok=True)
    connection = duckdb.connect(database)
    connection.execute(f"SET home_directory='{root.as_posix()}'")

    for name in SQL_FILES:
        sql_path = root / "sql" / name
        LOGGER.info("Running %s", name)
        sql = sql_path.read_text(encoding="utf-8").replace("{{PROJECT_ROOT}}", root.as_posix())
        connection.execute(sql)

    failures = connection.execute(
        "SELECT check_name, observed_value FROM audit.data_quality_results WHERE status <> 'PASS'"
    ).fetchall()
    if failures:
        raise RuntimeError(f"Data quality checks failed: {failures}")
    return connection


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", default=":memory:", help="DuckDB path; defaults to an in-memory build")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO if args.verbose else logging.WARNING, format="%(levelname)s %(message)s")
    connection = build(args.database)
    summary = connection.execute(
        "SELECT ROUND(SUM(total), 2), COUNT(*), COUNT(DISTINCT customer_id) FROM analytics.fact_invoice"
    ).fetchone()
    print(f"Pipeline complete: revenue={summary[0]:.2f}, orders={summary[1]}, customers={summary[2]}")
    connection.close()


if __name__ == "__main__":
    main()

