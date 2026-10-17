#!/usr/bin/env bash
# ==============================================================================
# Sub2API (Personal Edition) Linux / macOS 启动脚本
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================="
echo "  Sub2API (Personal Edition) 单人专用版启动中...  "
echo "================================================="

# 1. 检查 PostgreSQL 与 Redis
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl start postgresql 2>/dev/null || true
    sudo systemctl start redis 2>/dev/null || sudo systemctl start redis-server 2>/dev/null || true
fi

# 2. 检查后端二进制
if [ ! -f "backend/bin/server" ]; then
    echo "[1/2] 编译后端一体化二进制..."
    (cd backend && go build -tags embed -trimpath -o bin/server ./cmd/server)
fi

# 3. 运行服务
echo "[2/2] 正在启动服务 (http://localhost:8080)..."
cd backend
exec ./bin/server
