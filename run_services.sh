#!/bin/sh
set -e

PG_DATA="/mnt/host/wsl/postgresql_data"

mkdir -p "$PG_DATA" /run/postgresql
chown -R postgres:postgres "$PG_DATA" /run/postgresql

# Clean stale pid if postgres is not actually running
if [ -f "$PG_DATA/postmaster.pid" ]; then
    PID=$(head -n 1 "$PG_DATA/postmaster.pid")
    if ! kill -0 "$PID" 2>/dev/null; then
        echo "Removing stale postmaster.pid (PID $PID)"
        rm -f "$PG_DATA/postmaster.pid"
    fi
fi

# Start PostgreSQL in background
su - postgres -c "pg_ctl -D $PG_DATA -l $PG_DATA/logfile status || pg_ctl -D $PG_DATA -l $PG_DATA/logfile start" || true

# Start Redis
pkill redis-server || true
redis-server --bind 0.0.0.0 --port 6379 --protected-mode no --daemonize yes --dir /mnt/host/wsl

echo "ALL SERVICES RUNNING!"
exec tail -f "$PG_DATA/logfile"
