"""Refresh the privacy-minimised CSV snapshot from the official Chinook JSON."""

from __future__ import annotations

import csv
import logging
from pathlib import Path

import requests

SOURCE_URL = "https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/ChinookData.json"
ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "data" / "processed"

TABLES = {
    "customers.csv": ("Customer", {"CustomerId": "customer_id", "Country": "country", "SupportRepId": "support_rep_id"}),
    "employees.csv": ("Employee", {"EmployeeId": "employee_id", "Title": "employee_role", "ReportsTo": "manager_id"}),
    "artists.csv": ("Artist", {"ArtistId": "artist_id", "Name": "artist_name"}),
    "albums.csv": ("Album", {"AlbumId": "album_id", "Title": "album_title", "ArtistId": "artist_id"}),
    "genres.csv": ("Genre", {"GenreId": "genre_id", "Name": "genre_name"}),
    "tracks.csv": ("Track", {"TrackId": "track_id", "Name": "track_name", "AlbumId": "album_id", "MediaTypeId": "media_type_id", "GenreId": "genre_id", "Milliseconds": "milliseconds", "Bytes": "bytes", "UnitPrice": "unit_price"}),
    "invoices.csv": ("Invoice", {"InvoiceId": "invoice_id", "CustomerId": "customer_id", "InvoiceDate": "invoice_date", "BillingCountry": "billing_country", "Total": "total"}),
    "invoice_lines.csv": ("InvoiceLine", {"InvoiceLineId": "invoice_line_id", "InvoiceId": "invoice_id", "TrackId": "track_id", "UnitPrice": "unit_price", "Quantity": "quantity"}),
}


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    try:
        response = requests.get(SOURCE_URL, timeout=60)
        response.raise_for_status()
        payload = response.json()
    except requests.RequestException as exc:
        raise SystemExit(f"Source download failed: {exc}") from exc

    OUTPUT.mkdir(parents=True, exist_ok=True)
    for filename, (source_table, mapping) in TABLES.items():
        rows = payload[source_table]
        with (OUTPUT / filename).open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=mapping.values())
            writer.writeheader()
            writer.writerows({target: row.get(source) for source, target in mapping.items()} for row in rows)
        logging.info("Wrote %s rows to %s", len(rows), filename)


if __name__ == "__main__":
    main()
