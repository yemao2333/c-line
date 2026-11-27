param(
  [string]$Exe = '<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe',
  [string]$Game = '<ROOT>\<DUMP>\game_scarlett_master.exe',
  [string]$Work = '<ROOT>\cool_fox\cool_fox-main',
  [int]$Seconds = 150,
  [int]$Attempts = 3
)

# 16-ledger-probe.ps1 —— info 级抓卡内账本 5 行，带 OOM 重试。
# 为什么带重试：这台机提交额度只剩 0.03–1.0 GB，info 级运行有 3–5 秒就被
# 0x8007000E 打死的概率（round-01 三次跑挂了两次）。死一次不算失败，重来。
#
# 用法：
#   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\16-ledger-probe.ps1
#   .\16-ledger-probe.ps1 -Attempts 5 -Seconds 180

$ErrorActionPreference = 'Continue'
$data = '<ROOT>\cool_fox-优化方案\data'

# ---- 本 fork 的旧开关集（与 13-bench-ab.ps1 -Profile fork 一致）----
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
$env:VICTORY_LOG = 'info'

$patterns = @(
  "threads that translate lists",
  "pipeline workers",
  "card buffer limits",
  "the card's room kept",
  "the card's most title memory"
)

# 提交额度：扩完页面文件应 >= 40 GB；没扩也要报出来，便于判读
$c = (Get-Counter '\Memory\Commit Limit', '\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$limit = [math]::Round((($c | Where-Object Path -match 'commit limit').CookedValue) / 1GB, 2)
$used = [math]::Round((($c | Where-Object Path -match 'committed bytes').CookedValue) / 1GB, 2)
"commit_limit_gb=$limit commit_used_gb=$used commit_free_gb=$([math]::Round($limit - $used, 2))"
$exeItem = Get-Item $Exe
$exeBytes = $exeItem.Length
$exeWritten = $exeItem.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
"exe=$Exe  bytes=$exeBytes  written=$exeWritten"

# 按映像名收尾：进程名是映像名去扩展名（victory / victory-baseline），一律 ^victory 正则；
# 20 GB 的进程停得慢，给到 20 秒；收尾后返回残留数（r02-a5 观测到 leftover=1，即此处的 2 秒太短）。
function Stop-Game {
  for ($k = 0; $k -lt 10; $k++) {
    $left = Get-Process | Where-Object { $_.ProcessName -match '^victory' }
    if (-not $left) { break }
    $left | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
  }
  if (Get-Process | Where-Object { $_.ProcessName -match '^victory' }) {
    try { & "$env:SystemRoot\System32\taskkill.exe" /F /IM victory.exe /T 2>$null | Out-Null } catch { }
    try { & "$env:SystemRoot\System32\taskkill.exe" /F /IM victory-baseline.exe /T 2>$null | Out-Null } catch { }
    Start-Sleep -Seconds 2
  }
  $leftover = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
  if ($leftover -ne 0) { Write-Warning "收尾后仍有 $leftover 个 victory* 进程" }
  $leftover
}

$found = @{}
for ($a = 1; $a -le $Attempts; $a++) {
  Stop-Game
  $stamp = Get-Date -Format 'MMdd-HHmmss'
  $err = Join-Path $data ("ledger-a{0}-{1}.err.log" -f $a, $stamp)
  $out = Join-Path $data ("ledger-a{0}-{1}.log" -f $a, $stamp)
  "--- attempt $a : $err ---"
  $t0 = Get-Date
  $p = Start-Process -FilePath $Exe `
    -ArgumentList @('run', $Game, '--console', 'series-s', '--execute') `
    -WorkingDirectory $Work -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Normal

  # 采样到时间到，或者进程提前死掉（OOM）就进下一轮
  for ($i = 0; $i -lt [math]::Ceiling($Seconds / 5); $i++) {
    Start-Sleep -Seconds 5
    if (-not (Get-Process -Id $p.Id -ErrorAction SilentlyContinue)) {
      $gone = [int](((Get-Date) - $t0).TotalSeconds)
      "attempt $a : process gone after $gone s"
      break
    }
  }

  $lo = Stop-Game
  foreach ($pat in $patterns) {
    if (-not $found.ContainsKey($pat)) {
      $hit = Select-String -Path $err -Pattern $pat -SimpleMatch -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($hit) { $found[$pat] = $hit.Line }
    }
  }
  "attempt ${a}: captured $($found.Count) / $($patterns.Count) lines ；leftover=$lo"
  if ($found.Count -ge $patterns.Count) { break }
  Start-Sleep -Seconds 10
}

"=== 账本 ==="
foreach ($pat in $patterns) {
  if ($found.ContainsKey($pat)) { $found[$pat] } else { "MISSING: $pat" }
}
"=== 结束 ==="
