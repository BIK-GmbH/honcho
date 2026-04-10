#!/bin/sh
set -e

echo "Enabling pgvector extension..."
/app/.venv/bin/python -c "
import asyncio
import psycopg
import os
from urllib.parse import urlparse

def get_pg_url():
    uri = os.environ['DB_CONNECTION_URI']
    # psycopg3 sync needs postgresql://, not postgresql+psycopg://
    if uri.startswith('postgresql+psycopg://'):
        uri = 'postgresql://' + uri[len('postgresql+psycopg://'):]
    return uri

conn = psycopg.connect(get_pg_url(), autocommit=True)
with conn.cursor() as cur:
    cur.execute('CREATE EXTENSION IF NOT EXISTS vector')
    print('pgvector extension ready')
conn.close()
"

echo "Running database migrations..."
/app/.venv/bin/python scripts/provision_db.py

echo "Starting API server..."
exec /app/.venv/bin/fastapi run --host 0.0.0.0 src/main.py
