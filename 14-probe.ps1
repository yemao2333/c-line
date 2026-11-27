param(
  [Parameter(Mandatory = $true)][string]$Label,
  [string]$Exe = '<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe',
  [int]$Seconds = 200,
  # 额外/覆盖的开关："VICTORY_THIN_THREADS=8;VICTORY_WINDOW_KB=4096"
  [string]$Extra = '',
  [string]$LogLevel = 'warn'
)

# 机制探查：只跑一局、采帧、落日志，用来二分定位。
$ErrorActionPreference = 'Stop'
$data = '<ROOT>\cool_fox-优化方案\data'
$game = '<ROOT>\<DUMP>\game_scarlett_master.exe'
$work = '<ROOT>\cool_fox\cool_fox-main'

$env:VICTORY_AMBIENT_AIR = '1.5'
$env:VICTORY_CACHE_DIR = '<ROOT>\victory-data\coolfox-cache'
$env:VICTORY_DATA_DIR = '<ROOT>\victory-data\coolfox-data'
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
$env:VICTORY_LOG = $LogLevel

if ($Extra) {
  foreach ($pair in ($Extra -split ';')) {
    $kv = $pair -split '=', 2
    if ($kv.Count -eq 2) { Set-Item -Path ("env:" + $kv[0].Trim()) -Value $kv[1].Trim() }
  }
}

$stamp = Get-Date -Format 'MMdd-HHmmss'
$log = Join-Path $data ("probe-{0}-{1}.log" -f $Label, $stamp)
$err = [System.IO.Path]::ChangeExtension($log, '.err.log')

$p = Start-Process -FilePath $Exe -ArgumentList @('run', $game, '--console', 'series-s', '--execute') `
  -WorkingDirectory $work -RedirectStandardOutput $log -RedirectStandardError $err -PassThru -WindowStyle Normal

$rows = @()
$t0 = Get-Date
for ($i = 0; $i -lt [math]::Ceiling($Seconds / 5); $i++) {
  Start-Sleep -Seconds 5
  $vp = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
  if (-not $vp) { break }
  $title = $vp.MainWindowTitle
  $ms = $null; $draws = $null
  if ($title -match '([\d.]+)\s*fps\s+([\d.]+)\s*ms/frame\s+(\d+)\s*draws') { $ms = [double]$Matches[2]; $draws = [int]$Matches[3] }
  $rows += [pscustomobject]@{ T = [int]((Get-Date) - $t0).TotalSeconds; Ms = $ms; Draws = $draws; PrivGB = [math]::Round($vp.PrivateMemorySize64 / 1GB, 2) }
}
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
try { & "$env:SystemRoot\System32\taskkill.exe" /F /IM (Split-Path $Exe -Leaf) /T 2>$null | Out-Null } catch { }

$world = @($rows | Where-Object { $null -ne $_.Ms -and $_.Ms -gt 45 })
$worldMed = if ($world.Count) { ($world | Sort-Object Ms | Select-Object -Skip ([int]($world.Count / 2)) -First 1).Ms } else { $null }
$maxDraws = if ($rows.Count) { ($rows | Measure-Object Draws -Maximum).Maximum } else { $null }
"{0}: seconds={1} samples={2} world_samples={3} world_median_ms={4} max_draws={5} max_priv={6} world_log={7}" -f `
  $Label, $Seconds, $rows.Count, $world.Count, $worldMed, $maxDraws, (($rows | Measure-Object PrivGB -Maximum).Maximum), (Split-Path $log -Leaf)
$rows | Format-Table -AutoSize | Out-String -Width 120
