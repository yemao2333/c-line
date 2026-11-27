param(
  [Parameter(Mandatory = $true)][string]$Label,
  [Parameter(Mandatory = $true)][string]$Exe,
  [int]$Seconds = 240,
  [string]$Keys = '25:Enter,30:Enter,35:Enter,40:Enter,45:Space',
  [string]$Game = '<ROOT>\<DUMP>\game_scarlett_master.exe',
  [string]$Work = '<ROOT>\cool_fox\cool_fox-main',
  [int]$EnterFloor = 1000,
  # >0: stop that many seconds after the first draws>=EnterFloor sample (smoke uses it)
  [int]$StopAfterEntered = 0
)

$data = '<ROOT>\cool_fox-优化方案\data'
if (-not (Test-Path -LiteralPath $data)) { New-Item -ItemType Directory -Path $data | Out-Null }
$stamp = Get-Date -Format 'MMdd-HHmmss'
$log = Join-Path $data ("auto-{0}-{1}.log" -f $Label, $stamp)
$err = Join-Path $data ("auto-{0}-{1}.err.log" -f $Label, $stamp)

if (-not (Test-Path -LiteralPath $Exe)) { throw "no exe: $Exe" }
if (-not (Test-Path -LiteralPath $Game)) { throw "no title exe: $Game" }

# fork profile env (same set as 13-bench-ab.ps1 -Profile fork), plus the scripted keys
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
$env:VICTORY_LOG = 'warn'
$env:VICTORY_KEYS = $Keys

"label=$Label exe=$Exe seconds=$Seconds floor=$EnterFloor keys=$Keys"
"start=" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

$p = Start-Process -FilePath $Exe `
  -ArgumentList @('run', $Game, '--console', 'series-s', '--execute') `
  -WorkingDirectory $Work `
  -RedirectStandardOutput $log `
  -RedirectStandardError $err `
  -PassThru -WindowStyle Normal
"pid=$($p.Id)"
"stdout=$log"
"stderr=$err"

$samples = @()
$enteredAt = $null
$enteredDraws = $null
$t0 = Get-Date
$i = 0
while ($true) {
  Start-Sleep -Seconds 5
  $i++
  $vp = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
  if (-not $vp) { break }
  $t = [int]((Get-Date) - $t0).TotalSeconds
  $title = $vp.MainWindowTitle
  $draws = $null
  if ($title -match '(\d+)\s*draws') { $draws = [int]$Matches[1] }
  $ms = $null
  if ($title -match '([\d.]+)\s*ms/frame') { $ms = [double]$Matches[1] }
  $samples += [pscustomobject]@{ T = $t; Draws = $draws; Ms = $ms; Title = $title }
  "t={0,3}s draws={1} ms={2} title={3}" -f $t, $(if ($null -ne $draws) { $draws } else { '-' }), $(if ($null -ne $ms) { $ms } else { '-' }), $title
  if ($null -eq $enteredAt -and $null -ne $draws -and $draws -ge $EnterFloor) {
    $enteredAt = $t
    $enteredDraws = $draws
    ">> ENTERED at t=$t s draws=$draws"
  }
  if ($null -ne $enteredAt -and $StopAfterEntered -gt 0 -and ($t - $enteredAt) -ge $StopAfterEntered) { break }
  if ($t -ge $Seconds) { break }
}
"loop_s=$i samples=$($samples.Count)"

# cleanup by image name, up to 20 s
for ($k = 0; $k -lt 10; $k++) {
  $left = Get-Process | Where-Object { $_.ProcessName -match '^victory' }
  if (-not $left) { break }
  $left | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
}
$leftover = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
if ($leftover -ne 0) { "WARN: $leftover victory* still alive" }

$ok = ($null -ne $enteredAt)
"entered=" + $(if ($ok) { 'True' } else { 'False' })
"entered_at_s=" + $(if ($ok) { $enteredAt } else { '' })
"entered_draws=" + $(if ($ok) { $enteredDraws } else { '' })
"samples=$($samples.Count)"
"leftover=$leftover"
"end=" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
if ($ok) { exit 0 } else { exit 1 }
