#!/bin/sh
set -e

# ==============================================================================
# Sub2API (Personal Edition) 后台依赖服务管理脚本 (PostgreSQL + Redis)
# 运行于 WSL 运行时环境中，无需在物理磁盘占用空间
# ==============================================================================

PG_DATA="/mnt/host/wsl/postgresql_data"

mkdir -p "$PG_DATA" /run/postgresql
chown -R postgres:postgres "$PG_DATA" /run/postgresql
chmod 0700 "$PG_DATA"

# 清理可能残留的失效 postmaster.pid
if [ -f "$PG_DATA/postmaster.pid" ]; then
    PID=$(head -n 1 "$PG_DATA/postmaster.pid")
    if ! kill -0 "$PID" 2>/dev/null; then
        echo "Removing stale postmaster.pid (PID $PID)"
        rm -f "$PG_DATA/postmaster.pid"
    fi
fi

# 初始化并启动 PostgreSQL
if [ ! -f "$PG_DATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL in $PG_DATA..."
    su - postgres -c "initdb -D $PG_DATA -E UTF8"
fi

echo "Starting PostgreSQL..."
su - postgres -c "pg_ctl -D $PG_DATA -l $PG_DATA/logfile status || pg_ctl -D $PG_DATA -l $PG_DATA/logfile start" || true
sleep 1

# 确保数据库角色与库就绪
su - postgres -c "psql -c \"CREATE ROLE sub2api WITH LOGIN PASSWORD 'sub2api_password' SUPERUSER;\"" 2>/dev/null || true
su - postgres -c "psql -c \"CREATE DATABASE sub2api OWNER sub2api;\"" 2>/dev/null || true

# 启动 Redis 服务
echo "Starting Redis..."
pkill redis-server 2>/dev/null || true
redis-server --bind 0.0.0.0 --port 6379 --protected-mode no --daemonize yes --dir /mnt/host/wsl

echo "ALL SERVICES RUNNING!"
exec tail -f "$PG_DATA/logfile"
