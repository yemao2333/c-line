param(
  [Parameter(Mandatory = $true)][string]$Label,
  [string]$Exe = '<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe',
  [int]$Seconds = 420,
  [int]$WorldSeconds = 200,
  [int]$MinWorldSamples = 25,
  [int]$PreflightSeconds = 150,
  [string]$Keys = '25:Enter,30:Enter,35:Enter,40:Enter,45:Space',
  [string]$Extra = '',
  [switch]$SkipPreflight
)

# smoke.ps1 — 一页冒烟：先用 auto-enter 判「能不能进世界」，再用 bench.ps1 的采样判据出数。
# 判据一律复用（bench.ps1 的 filter v2 与 world 窗口、auto-enter 的 draws>=1000）；
# 本脚本只做「启动 + 断言」，不复制任何中位数/过滤逻辑。
# 退出码：全绿 0，任一断言失败 1。

$root = '<ROOT>\cool_fox-优化方案'
$scripts = Join-Path $root '10-实验脚本'
$data = Join-Path $root 'data'
$csv3 = Join-Path $data 'bench-v3.csv'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

$failed = @()
"=== smoke label=$Label start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# ---- 0 前置 ----
if (-not (Test-Path -LiteralPath $Exe)) { "ASSERT exe_exists : FAIL ($Exe)"; exit 1 }
"exe_sha256=" + (Get-FileHash $Exe -Algorithm SHA256).Hash
$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$lim = ($c | Where-Object Path -match 'commit limit').CookedValue / 1GB
$used = ($c | Where-Object Path -match 'committed bytes').CookedValue / 1GB
"commit_limit_gb={0:N2} commit_free_gb={1:N2}" -f $lim, ($lim - $used)
if ($lim -lt 44) { $failed += 'commit_limit_gb>=44' }

# ---- 1 预检：能否自动进世界（auto-enter 自己的判定）----
if (-not $SkipPreflight) {
  & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'auto-enter.ps1') `
    -Label "$Label-preflight" -Exe $Exe -Seconds $PreflightSeconds -StopAfterEntered 10 -Keys $Keys
  $pre = $LASTEXITCODE
  "preflight_EXIT=$pre"
  if ($pre -ne 0) { $failed += 'preflight_entered' }
} else {
  "preflight=skipped"
}

# ---- 2 出数：13-bench-ab -> bench.ps1（fork 全套 env 由 13-bench-ab 设，判据全在 bench.ps1）----
$before = if (Test-Path -LiteralPath $csv3) { (Get-Content -LiteralPath $csv3).Count } else { 0 }
$benchExtra = "VICTORY_KEYS=$Keys"
if ($Extra) { $benchExtra = "$benchExtra;$Extra" }
& $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root '13-bench-ab.ps1') `
  -Label $Label -Exe $Exe -Seconds $Seconds -WorldSeconds $WorldSeconds -Profile fork -Extra $benchExtra
$benchExit = $LASTEXITCODE
"bench_EXIT=$benchExit"
if ($benchExit -ne 0) { $failed += 'bench_EXIT=0' }

# ---- 3 断言：读 bench-v3 最后一行（不重算，只读脚本写下的值）----
$after = (Get-Content -LiteralPath $csv3).Count
"v3_lines_before=$before after=$after"
if ($after -le $before) { $failed += 'v3_new_row' } else {
  $last = (Get-Content -LiteralPath $csv3)[-1]
  $f = $last -split ','
  # 列序：time,label,world_seconds,cap_seconds,samples,world_from_s,world_samples,world_filter,
  #       median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log
  $worldSamples = $f[6]
  $medianMs = $f[8]
  $medianDraws = $f[9]
  $leftover = $f[13]
  "row=$last"
  "world_samples=$worldSamples median_ms_world=[$medianMs] median_draws=[$medianDraws] leftover_procs=[$leftover]"
  if ([int]$worldSamples -lt $MinWorldSamples) { $failed += "world_samples>=$MinWorldSamples" }
  if ([string]::IsNullOrWhiteSpace($medianMs)) { $failed += 'median_ms_world_has_value' }
  if ([string]::IsNullOrWhiteSpace($medianDraws)) { $failed += 'median_draws_has_value' }
  if ($leftover -ne '0') { $failed += 'leftover_procs=0' }
}

# ---- 4 收尾 ----
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
$post = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"post_run_leftover=$post"
if ($post -ne 0) { $failed += 'post_run_leftover=0' }

"=== smoke end " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
if ($failed.Count -eq 0) {
  "SMOKE=PASS"
  exit 0
} else {
  "SMOKE=FAIL failed_asserts=" + ($failed -join '|')
  exit 1
}
