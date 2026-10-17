# ==============================================================================
# Sub2API (Personal Edition) 一键常规启动脚本
# ==============================================================================
# 首次启动：自动就绪 DB/Redis，浏览器打开只需设置管理员邮箱密码即可
# 常规启动：自动就绪环境并启动控制台
# ==============================================================================

$ErrorActionPreference = "Stop"
$RootPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $RootPath

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  Sub2API (Personal Edition) 单人专用版启动中...  " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 快速检测端口连接
function Test-PortConnected($port) {
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect("127.0.0.1", $port, $null, $null)
        $wait = $iar.AsyncWaitHandle.WaitOne(1000)
        if ($wait) {
            $client.EndConnect($iar)
            $client.Close()
            return $true
        }
        $client.Close()
        return $false
    } catch {
        return $false
    }
}

$pgReady = Test-PortConnected 5432
$redisReady = Test-PortConnected 6379

if (-not $pgReady -or -not $redisReady) {
    Write-Host "[1/3] 正在拉起 PostgreSQL 与 Redis 服务..." -ForegroundColor Yellow
    # 动态转换 Windows 绝对路径为 WSL 路径
    $driveLetter = $RootPath.Substring(0, 1).ToLower()
    $subPath = $RootPath.Substring(2).Replace('\', '/')
    $wslScriptPath = "/mnt/host/$driveLetter$subPath/run_services.sh"

    Start-Process wsl -ArgumentList "-u", "root", "sh", "-c", "tr -d '\r' < $wslScriptPath > /tmp/run_services.sh && sh /tmp/run_services.sh" -WindowStyle Hidden
    
    # 循环等待服务就绪
    $retries = 15
    while ($retries -gt 0) {
        Start-Sleep -Seconds 1
        if ((Test-PortConnected 5432) -and (Test-PortConnected 6379)) {
            break
        }
        $retries--
    }
    Write-Host "[1/3] PostgreSQL 与 Redis 启动成功！" -ForegroundColor Green
} else {
    Write-Host "[1/3] PostgreSQL 与 Redis 服务已在运行。" -ForegroundColor Green
}

# 检查后端二进制文件
$ServerExe = Join-Path $RootPath "backend\bin\server.exe"
if (-not (Test-Path $ServerExe)) {
    Write-Host "[2/3] 编译一体化后端二进制（含前端）..." -ForegroundColor Yellow
    Set-Location (Join-Path $RootPath "backend")
    go build -tags embed -trimpath -o bin/server.exe ./cmd/server
    Set-Location $RootPath
}
Write-Host "[2/3] 服务程序已就绪。" -ForegroundColor Green

# 启动服务并在浏览器中打开
Write-Host "[3/3] 启动 Sub2API 服务中..." -ForegroundColor Green
Start-Process "http://localhost:8080"
Set-Location (Join-Path $RootPath "backend")
& .\bin\server.exe
