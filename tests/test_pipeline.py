from pathlib import Path

import pytest

from jira_analytics.pipeline import SQL_FILES, build, project_root


@pytest.fixture(scope="module")
def connection():
    con = build()
    yield con
    con.close()


def test_all_quality_checks_pass(connection):
    assert connection.execute("SELECT COUNT(*) FROM audit.data_quality_results WHERE status <> 'PASS'").fetchone()[0] == 0


def test_expected_fact_grains(connection):
    assert connection.execute("SELECT COUNT(*) FROM analytics.fact_invoice").fetchone()[0] == 412
    assert connection.execute("SELECT COUNT(*) FROM analytics.fact_sales").fetchone()[0] == 2240
    assert connection.execute("SELECT COUNT(DISTINCT customer_id) FROM analytics.fact_invoice").fetchone()[0] == 59


def test_revenue_headlines(connection):
    revenue, orders, customers, aov = connection.execute(
        "SELECT ROUND(SUM(total), 2), COUNT(*), COUNT(DISTINCT customer_id), ROUND(SUM(total)/COUNT(*), 2) FROM analytics.fact_invoice"
    ).fetchone()
    assert float(revenue) == 2328.60
    assert (orders, customers, float(aov)) == (412, 59, 5.65)


def test_activity_status_counts(connection):
    result = dict(connection.execute(
        "SELECT activity_status, COUNT(*) FROM analytics.customer_lifecycle GROUP BY activity_status"
    ).fetchall())
    assert result == {"Active": 19, "At risk": 12, "Dormant": 28}


def test_largest_country_and_genre(connection):
    assert connection.execute("SELECT country FROM analytics.country_performance ORDER BY revenue DESC LIMIT 1").fetchone()[0] == "USA"
    genre, revenue = connection.execute("SELECT genre_name, revenue FROM analytics.product_performance ORDER BY revenue DESC LIMIT 1").fetchone()
    assert genre == "Rock"
    assert float(revenue) == 826.65


def test_sql_layers_are_real_sql():
    root = project_root()
    assert [p.name for p in sorted((root / "sql").glob("*.sql"))] == SQL_FILES
    for path in (root / "sql").glob("*.sql"):
        text = path.read_text(encoding="utf-8").lower()
        assert "import duckdb" not in text


def test_powerbi_exports_exist_after_build(connection):
    export_dir = project_root() / "powerbi" / "exports"
    for name in ["monthly_kpis", "customer_lifecycle", "cohort_continuation", "product_performance", "country_performance", "data_quality_results"]:
        path = export_dir / f"{name}.csv"
        assert path.exists() and path.stat().st_size > 20


def test_repository_hygiene():
    root = project_root()
    banned = {".duckdb", ".wal", ".zip"}
    assert not [p for p in root.rglob("*") if p.is_file() and any(p.name.lower().endswith(x) for x in banned)]
    assert (root / "README.md").is_file()
    assert (root / ".gitignore").is_file()
    assert not (root / "README.md.txt").exists()

