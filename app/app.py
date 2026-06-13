"""BeeBox REST API.

A minimal read-only Flask service that returns seeded rows from MySQL as JSON.
Every response includes the serving container's hostname so that round-robin
load balancing across web-1 / web-2 is directly observable.
"""
import socket
from datetime import date, datetime

from flask import Flask, jsonify

import db

app = Flask(__name__)

HOSTNAME = socket.gethostname()


def _serialize(row):
    """Make a DB row JSON-safe (datetime/date -> ISO 8601 strings)."""
    out = {}
    for key, value in row.items():
        if isinstance(value, (datetime, date)):
            out[key] = value.isoformat()
        else:
            out[key] = value
    return out


@app.get("/api/data")
def get_data():
    """Read-only endpoint: returns all rows from the database in JSON."""
    rows = [_serialize(r) for r in db.fetch_all_data()]
    return jsonify(served_by=HOSTNAME, count=len(rows), data=rows)


@app.get("/health")
def health():
    """Liveness/readiness probe; reports DB reachability and the serving host."""
    try:
        db.ping()
        return jsonify(status="ok", served_by=HOSTNAME, database="up"), 200
    except Exception:  # noqa: BLE001 - report any DB error as unhealthy
        return jsonify(status="degraded", served_by=HOSTNAME, database="down"), 503


@app.get("/")
def index():
    return jsonify(service="beebox-api", served_by=HOSTNAME,
                   endpoints=["/api/data", "/health"])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
