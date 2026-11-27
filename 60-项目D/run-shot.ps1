param(
  # 这次运行的标签，只用于回显与文件名
  [string]$Tag = 'shot',
  # 单变量覆盖，分号分隔："VICTORY_AMBIENT=1.5;VICTORY_AMBIENT_AIR=3.0"
  [string]$Extra = '',
  # 跑多久就收；截图由用户在这段时间内自己按（同一存档、同一位置）
  [int]$Seconds = 240
)

# 项目 D：画质对照。作用 = 用给定 env 起一局、每 5 秒回显窗口标题，
# 用户在同一存档同一位置截图，然后按 Tag 把图存下来对比。
#
# 用法：
#   powershell -NoProfile -ExecutionPolicy Bypass -File "G:\GTA\cool_fox-优化方案\60-项目D\run-shot.ps1" -Tag base
#   ... -Tag amb15 -Extra "VICTORY_AMBIENT=1.5"
#   ... -Tag amb15air3 -Extra "VICTORY_AMBIENT=1.5;VICTORY_AMBIENT_AIR=3.0;VICTORY_AMBIENT_SHADE=0"

$ErrorActionPreference = 'Continue'
$exe = 'G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe'
$data = 'G:\GTA\cool_fox-优化方案\data'

# 与 Start-GTA6.cmd 同一套 fork 开关（基线）
$env:VICTORY_AMBIENT_AIR='1.5'; $env:VICTORY_CACHE_DIR='G:\GTA\victory-data\coolfox-cache'; $env:VICTORY_DATA_DIR='G:\GTA\victory-data\coolfox-data'
$env:VICTORY_TEXTURE_NO_WAIT='1'; $env:VICTORY_RELAY='2'; $env:VICTORY_WIDE_BACK='1'; $env:VICTORY_CARD_REHASH_RUNS='1'
$env:VICTORY_JOIN_COPIES='1'; $env:VICTORY_INDIRECT_WINDOW='1'; $env:VICTORY_RELAY_COPY='1'; $env:VICTORY_CARD_STEPS='2'
$env:VICTORY_INDIRECT_BATCH='2'; $env:VICTORY_MAP_THREADS='1'; $env:VICTORY_CARD_AWAKE='1'; $env:VICTORY_SHOW_AFTER='1'
$env:VICTORY_AMBIENT='0.8'; $env:VICTORY_THIN='1'; $env:VICTORY_JOIN_PARTS='6'; $env:VICTORY_UPLOAD_AHEAD='1'
$env:VICTORY_LEVELS_ON_DEMAND='1'; $env:VICTORY_CARD_BUFFERS_MIN_KB='64'
$env:VICTORY_LOG = 'warn'
Remove-Item Env:\VICTORY_GPU_TIMING -ErrorAction SilentlyContinue
Remove-Item Env:\VICTORY_TIMELINE -ErrorAction SilentlyContinue
Remove-Item Env:\VICTORY_PIPELINE_BOOK -ErrorAction SilentlyContinue

$applied = @()
if ($Extra) {
  foreach ($pair in $Extra.Split(';')) {
    $p = $pair.Trim(); if (-not $p) { continue }
    $kv = $p.Split('=', 2); if ($kv.Count -ne 2) { "SKIP bad pair: $p"; continue }
    Set-Item -Path ("Env:" + $kv[0].Trim()) -Value $kv[1].Trim()
    $applied += ("{0}={1}" -f $kv[0].Trim(), $kv[1].Trim())
  }
}
"tag=$Tag"
"extra_applied=" + ($(if ($applied.Count) { $applied -join ';' } else { '(none)' }))
"AMBIENT=$($env:VICTORY_AMBIENT) AMBIENT_AIR=$($env:VICTORY_AMBIENT_AIR) AMBIENT_SHADE=$($env:VICTORY_AMBIENT_SHADE)"
"SHA256_release=" + (Get-FileHash $exe -Algorithm SHA256).Hash

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3
$log = Join-Path $data ("r12-" + $Tag + ".log")
$err = Join-Path $data ("r12-" + $Tag + ".err.log")
$p = Start-Process -FilePath $exe `
  -ArgumentList @('run','G:\GTA\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe','--console','series-s','--execute') `
  -WorkingDirectory 'G:\GTA\cool_fox\cool_fox-main' -RedirectStandardOutput $log -RedirectStandardError $err -PassThru -WindowStyle Normal
"pid=$($p.Id)  started=$(Get-Date -Format HH:mm:ss)"
"NOW: load your save, stand still at the same spot, and take a screenshot."

$t0 = Get-Date
for ($i = 1; $i -le [math]::Ceiling($Seconds / 5); $i++) {
  Start-Sleep -Seconds 5
  $v = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
  if (-not $v) { "process gone at $([int]((Get-Date)-$t0).TotalSeconds)s"; break }
  if ($i % 3 -eq 0) { "  t={0,4}s title={1}" -f [int]((Get-Date)-$t0).TotalSeconds, $v.MainWindowTitle }
}

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2
"leftover=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"err_bytes=" + (Get-Item $err -ErrorAction SilentlyContinue).Length
"save your screenshot as: G:\GTA\cool_fox-优化方案\data\shot-$Tag.png"
