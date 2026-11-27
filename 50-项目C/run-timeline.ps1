param(
  [int]$RunSeconds = 420,
  # 时间线抓帧时刻（秒，可多段，用 + 连接）；两段是为了避开「没进世界」的风险
  [string]$At = '200+320',
  [int]$Frames = 3,
  [string]$Out = '<ROOT>\cool_fox-优化方案\data\timeline.json'
)

# 项目 C：抓 3 帧时间线（Chrome trace + 文本摘要），用来回答
# 「准备 150 ms」与「等卡 227 ms」能不能重叠。
#
# 用法（要点：跑起来后 **90 秒内手动点进世界**，之后就别动鼠标）：
#   powershell -NoProfile -ExecutionPolicy Bypass -File "<ROOT>\cool_fox-优化方案\50-项目C\run-timeline.ps1"
#
# 为什么需要 diag 产物：时间线在 `#[cfg(feature="diagnostics")]` 后面，
# release 产物里没有这套 hooks。

$ErrorActionPreference = 'Continue'
$diag = '<ROOT>\cool_fox\cool_fox-main\target\diag\victory.exe'
$data = '<ROOT>\cool_fox-优化方案\data'

if (-not (Test-Path $diag)) { throw "找不到 diag 产物：$diag（先用 cargo build --profile diag -p victory --features diagnostics 构建）" }
"SHA256_diag=" + (Get-FileHash $diag -Algorithm SHA256).Hash

# 与全部跑分同一套 fork 开关
$env:VICTORY_AMBIENT_AIR='1.5'; $env:VICTORY_CACHE_DIR='<ROOT>\victory-data\coolfox-cache'; $env:VICTORY_DATA_DIR='<ROOT>\victory-data\coolfox-data'
$env:VICTORY_TEXTURE_NO_WAIT='1'; $env:VICTORY_RELAY='2'; $env:VICTORY_WIDE_BACK='1'; $env:VICTORY_CARD_REHASH_RUNS='1'
$env:VICTORY_JOIN_COPIES='1'; $env:VICTORY_INDIRECT_WINDOW='1'; $env:VICTORY_RELAY_COPY='1'; $env:VICTORY_CARD_STEPS='2'
$env:VICTORY_INDIRECT_BATCH='2'; $env:VICTORY_MAP_THREADS='1'; $env:VICTORY_CARD_AWAKE='1'; $env:VICTORY_SHOW_AFTER='1'
$env:VICTORY_AMBIENT='0.8'; $env:VICTORY_THIN='1'; $env:VICTORY_JOIN_PARTS='6'; $env:VICTORY_UPLOAD_AHEAD='1'
$env:VICTORY_LEVELS_ON_DEMAND='1'; $env:VICTORY_CARD_BUFFERS_MIN_KB='64'
$env:VICTORY_LOG = 'info'
Remove-Item Env:\VICTORY_GPU_TIMING -ErrorAction SilentlyContinue

# 时间线：<起>+<起>,<帧数>,<文件>
$env:VICTORY_TIMELINE = "$At,$Frames,$Out"
"VICTORY_TIMELINE=$($env:VICTORY_TIMELINE)"

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

$log = Join-Path $data 'r11-timeline.log'
$err = Join-Path $data 'r11-timeline.err.log'
$p = Start-Process -FilePath $diag `
  -ArgumentList @('run','<ROOT>\<DUMP>\game_scarlett_master.exe','--console','series-s','--execute') `
  -WorkingDirectory '<ROOT>\cool_fox\cool_fox-main' -RedirectStandardOutput $log -RedirectStandardError $err -PassThru -WindowStyle Normal
"pid=$($p.Id)  起跑时刻=$(Get-Date -Format HH:mm:ss)"

$t0 = Get-Date
$worldAt = $null
for ($i = 1; $i -le [math]::Ceiling($RunSeconds / 5); $i++) {
  Start-Sleep -Seconds 5
  $v = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
  if (-not $v) { "process gone at $([int]((Get-Date)-$t0).TotalSeconds)s"; break }
  $title = $v.MainWindowTitle
  $draws = $null
  if ($title -match '(\d+)\s*draws') { $draws = [int]$Matches[1] }
  if ($null -eq $worldAt -and $null -ne $draws -and $draws -ge 1000) {
    $worldAt = [int]((Get-Date) - $t0).TotalSeconds
    "  >> 进世界：t=$worldAt s，draws=$draws"
  }
  if ($i % 6 -eq 0) { "  t={0,4}s title={1}" -f [int]((Get-Date)-$t0).TotalSeconds, $title }
}

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2
"leftover=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"world_at_s=" + $(if ($null -ne $worldAt) { $worldAt } else { 'NOT_REACHED' })
"err_bytes=" + (Get-Item $err -ErrorAction SilentlyContinue).Length

"=== 产物 ==="
Get-ChildItem (Split-Path $Out -Parent) -Filter ((Split-Path $Out -Leaf) -replace '\.json$','*') -ErrorAction SilentlyContinue |
  Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

"=== 文本摘要头 40 行（若有）==="
$txt = [System.IO.Path]::ChangeExtension($Out, '.txt')
if (Test-Path $txt) { Get-Content $txt -TotalCount 40 } else { "MISSING: $txt" }

"=== 日志里的帧汇总行（末 3 条）==="
Select-String -Path $err -Pattern "the card's clock per frame|the waiting for the card in settles" -SimpleMatch -ErrorAction SilentlyContinue |
  Select-Object -Last 3 | ForEach-Object { ($_.Line -replace '\x1b\[[0-9;]*m','') }
