"""Database access layer for the BeeBox REST API.

Credentials are read from the environment (never hardcoded). Connections use a
short retry/backoff loop so the app tolerates MySQL still warming up.
"""
import os
import time

import pymysql
from pymysql.cursors import DictCursor


def _config():
    return {
        "host": os.getenv("DB_HOST", "db"),
        "port": int(os.getenv("DB_PORT", "3306")),
        "user": os.getenv("DB_USER", "beebox"),
        "password": os.getenv("DB_PASSWORD", "beebox_pw"),
        "database": os.getenv("DB_NAME", "beebox"),
        "cursorclass": DictCursor,
        "connect_timeout": 5,
    }


def get_connection(retries=10, backoff=2):
    """Open a MySQL connection, retrying transient startup failures."""
    last_err = None
    for attempt in range(1, retries + 1):
        try:
            return pymysql.connect(**_config())
        except pymysql.err.OperationalError as err:
            last_err = err
            if attempt == retries:
                break
            time.sleep(backoff)
    raise RuntimeError(f"Could not connect to MySQL after {retries} attempts: {last_err}")


def fetch_all_data():
    """Return every row from the seeded table as a list of dicts (read-only)."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, description, created_at FROM items ORDER BY id"
            )
            return cur.fetchall()
    finally:
        conn.close()


def ping():
    """Return True if the database is reachable, else raise."""
    conn = get_connection(retries=1)
    try:
        conn.ping(reconnect=False)
        return True
    finally:
        conn.close()
