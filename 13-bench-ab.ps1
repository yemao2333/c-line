param(
  [Parameter(Mandatory = $true)][string]$Label,
  [Parameter(Mandatory = $true)][string]$Exe,
  [int]$Seconds = 180,
  # fork  = 旧 Start-GTA6.cmd 的那套开关（A/B 两组必须完全一致）
  # tuned = 在 fork 之上再叠 11-实施记录.md 里的本机开关（C 组）
  [ValidateSet('fork', 'tuned')][string]$Profile = 'fork',
  # 单变量实验用："VICTORY_THIN_THREADS=8;VICTORY_PIPELINE_WORKERS=8"（覆盖上面两档）
  [string]$Extra = '',
  # 项目 B（测量台升级）：>0 时改成「进世界后再采 N 秒」，结果写 bench-v3.csv
  [int]$WorldSeconds = 0
)

# A/B 采帧：同一套环境变量、不同的产物，结果落 data\bench.csv。
#   .\13-bench-ab.ps1 -Label A-baseline -Exe ..\cool_fox\cool_fox-main\target\release\victory-baseline.exe
#   .\13-bench-ab.ps1 -Label B-opt     -Exe ..\cool_fox\cool_fox-main\target\release\victory.exe
#   .\13-bench-ab.ps1 -Label C-tuned   -Exe ..\cool_fox\cool_fox-main\target\release\victory.exe -Profile tuned

$ErrorActionPreference = 'Stop'
$root = 'G:\GTA\cool_fox-优化方案'

# ---- 本 fork 的旧启动器开关（两组共用，逐字照抄旧 Start-GTA6.cmd）----
$env:VICTORY_AMBIENT_AIR = '1.5'
$env:VICTORY_CACHE_DIR = 'G:\GTA\victory-data\coolfox-cache'
$env:VICTORY_DATA_DIR = 'G:\GTA\victory-data\coolfox-data'
$env:VICTORY_TEXTURE_NO_WAIT = '1'
$env:VICTORY_RELAY = '2'
$env:VICTORY_WIDE_BACK = '1'
$env:VICTORY_CARD_REHASH_RUNS = '1'
$env:VICTORY_JOIN_COPIES = '1'
$env:VICTORY_INDIRECT_WINDOW = '1'
$env:VICTORY_RELAY_COPY = '1'
$env:VICTORY_CARD_STEPS = '2'
$env:VICTORY_INDIRECT_BATCH = '2'
$env:VICTORY_MAP_THREADS = '1'
$env:VICTORY_CARD_AWAKE = '1'
$env:VICTORY_SHOW_AFTER = '1'
$env:VICTORY_AMBIENT = '0.8'
$env:VICTORY_THIN = '1'
$env:VICTORY_JOIN_PARTS = '6'
$env:VICTORY_UPLOAD_AHEAD = '1'
$env:VICTORY_LEVELS_ON_DEMAND = '1'
$env:VICTORY_CARD_BUFFERS_MIN_KB = '64'
$env:VICTORY_LOG = 'warn'

if ($Profile -eq 'tuned') {
  $env:VICTORY_TEXTURE_BUDGET_MB = '1024'
  $env:VICTORY_CARD_BUFFERS_MIN_KB = '256'
  $env:VICTORY_SNAPSHOT_POOL = '512'
  $env:VICTORY_PICKED_MB = '16'
  $env:VICTORY_DSTORAGE_STAGING_MB = '128'
  $env:VICTORY_INPLACE_MB = '1024'
  $env:VICTORY_JOIN_PARTS = '4'
  $env:VICTORY_FAST_CORES = '0'
}

if ($Extra) {
  foreach ($pair in ($Extra -split ';')) {
    $kv = $pair -split '=', 2
    if ($kv.Count -eq 2) { Set-Item -Path ("env:" + $kv[0].Trim()) -Value $kv[1].Trim() }
  }
  "extra=$Extra"
}

"label=$Label exe=$Exe profile=$Profile seconds=$Seconds world_seconds=$WorldSeconds"
& (Join-Path $root '10-实验脚本\bench.ps1') -Label $Label -Seconds $Seconds -Exe $Exe -WorldSeconds $WorldSeconds
