"""
DB Health Check Script
Runs a quick connectivity + query test on SQLite (or modify for MySQL/Postgres).
"""

import sqlite3
import sys

try:
    conn = sqlite3.connect("sample.db")
    cursor = conn.cursor()
    cursor.execute("SELECT datetime('now');")
    print("DB Connection OK:", cursor.fetchone())
except Exception as e:
    print("DB Connection FAILED:", e)
    sys.exit(1)
finally:
    conn.close()
