import duckdb

con = duckdb.connect("analytics.duckdb")  

con.execute("""
CREATE TABLE customers AS
SELECT *
FROM read_csv_auto('../data/data.csv');
""")

con.execute("SELECT COUNT(*) FROM customers").fetchall()