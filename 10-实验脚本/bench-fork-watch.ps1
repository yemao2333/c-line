param(
  [string]$Label = "A",
  [int]$Seconds = 120,
  # 项目 B（测量台升级）：>0 时改成「进世界（draws>=1000）后再采 N 秒」，
  # 全部指标只在这个窗里算；0 = 旧行为（从进程启动起采 $Seconds 秒）。
  [int]$WorldSeconds = 0,
  [string]$Game = "G:\GTA\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe",
  [string]$Exe = "G:\GTA\fork-eval\target\release\victory.exe",
  [string]$Work = "G:\GTA\fork-eval\victory-fork"
)

# 用法：
#   .\bench.ps1 -Label base -Seconds 120                    # 旧口径（从启动计时）
#   .\bench.ps1 -Label r10 -Seconds 420 -WorldSeconds 200   # 项目 B 口径（进世界后 200 s）
#   环境变量在启动前由调用方设置（$env:VICTORY_...），本脚本只负责采样与记账。

$data = "G:\GTA\cool_fox-优化方案\data"
if (-not (Test-Path -LiteralPath $data)) { New-Item -ItemType Directory -Path $data | Out-Null }
$csv = Join-Path $data "bench-fork.csv"
$log = Join-Path $data ("run-{0}-{1}.log" -f $Label, (Get-Date -Format "MMdd-HHmmss"))

if (-not (Test-Path -LiteralPath $Exe)) { throw "找不到 victory.exe：$Exe" }
if (-not (Test-Path -LiteralPath $Game)) { throw "找不到标题可执行文件：$Game" }

$p = Start-Process -FilePath $Exe `
  -ArgumentList @("run", $Game, "--console", "series-s", "--execute") `
  -WorkingDirectory $Work `
  -RedirectStandardOutput $log `
  -RedirectStandardError ($log -replace '\.log$', '.err.log') `
  -PassThru -WindowStyle Normal

$samples = @()
$t0 = Get-Date
# 项目 B：世界窗模式。$cap 只是安全上界（世界加载 + 窗口 + 余量），
# 真正结束由「世界窗采满」触发。
$cap = if ($WorldSeconds -gt 0) { [math]::Ceiling(($Seconds + 300) / 5) } else { [math]::Ceiling($Seconds / 5) }
$worldFrom = $null
for ($i = 1; $i -le $cap; $i++) {
  Start-Sleep -Seconds 5
  # 只改这里：标题会 re-exec/派生，PID 会变；按映像名找当前存活的那个，优先带标题的。
  $vps = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' })
  if (-not $vps) { break }
  $vp = $vps | Where-Object { $_.MainWindowTitle -match 'draws/frame' } | Select-Object -First 1
  if (-not $vp) { $vp = $vps | Sort-Object StartTime -Descending | Select-Object -First 1 }
  $title = $vp.MainWindowTitle
  $fps = $null; $ms = $null; $draws = $null
  if ($title -match '([\d.]+)\s*fps\s+([\d.]+)\s*ms/frame\s+(\d+)\s*draws') {
    $fps = [double]$Matches[1]; $ms = [double]$Matches[2]; $draws = [int]$Matches[3]
  }
  # WMI 的 FreeVirtualMemory 在多进程大提交下读数不可靠，改用性能计数器
  $c = Get-Counter -Counter '\Memory\Committed Bytes','\Memory\Commit Limit','\Memory\Available MBytes' -SampleInterval 1 -MaxSamples 1
  $vals = @{}
  foreach ($s in $c.CounterSamples) {
    if ($s.Path -match 'available mbytes') { $vals['avail'] = $s.CookedValue / 1024 }
    elseif ($s.Path -match 'commit limit')  { $vals['limit'] = $s.CookedValue / 1GB }
    else                                   { $vals['used']  = $s.CookedValue / 1GB }
  }
  $samples += [pscustomobject]@{
    T      = [int]((Get-Date) - $t0).TotalSeconds
    Title  = $title
    Fps    = $fps
    Ms     = $ms
    Draws  = $draws
    PrivGB = [math]::Round($vp.PrivateMemorySize64 / 1GB, 2)
    RssGB  = [math]::Round($vp.WorkingSet64 / 1GB, 2)
    FreeGB = [math]::Round($vals['avail'], 2)
    CommitFreeGB = [math]::Round($vals['limit'] - $vals['used'], 2)
  }
  # 边采边打：round-02 的 S5 里，A 组起跑后 4 分钟没有采样行、看着像空跑，
  # 其实进程在跑（19.8 GB / 4 fps）——采样表原来只在循环结束后一次性打印。
  # 这里每 5 秒吐一行，重定向的 console 就能看出进度。
  "  t={0,4}s fps={1,6} ms={2,8} draws={3,6} priv={4,6} commitfree={5,6}" -f `
    $samples[-1].T, $samples[-1].Fps, $samples[-1].Ms, $samples[-1].Draws, $samples[-1].PrivGB, $samples[-1].CommitFreeGB

  if ($WorldSeconds -gt 0 -and $null -eq $worldFrom -and $null -ne $samples[-1].Draws -and $samples[-1].Draws -ge 1000) {
    $worldFrom = $samples[-1].T
    "  >> 进世界：draws=$($samples[-1].Draws)，世界窗自 t=$worldFrom s 起，采 $WorldSeconds s"
  }
  if ($WorldSeconds -gt 0 -and $null -ne $worldFrom -and ($samples[-1].T - $worldFrom) -ge $WorldSeconds) { break }
}

# 标题会自行重启/派生子进程，按映像名收尾，最多试 20 秒
# 注意：进程名是映像名去掉扩展名，`-Name victory` 匹配不到 victory-baseline.exe，
# round-02 因此漏收过一次（基线进程在出数后还活了 12 分钟）。一律用 ^victory 正则。
for ($k = 0; $k -lt 10; $k++) {
  $left = Get-Process | Where-Object { $_.ProcessName -match '^victory' }
  if (-not $left) { break }
  $left | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
}
if (Get-Process | Where-Object { $_.ProcessName -match '^victory' }) {
  & "$env:SystemRoot\System32\taskkill.exe" /F /IM victory.exe /T 2>$null | Out-Null
  & "$env:SystemRoot\System32\taskkill.exe" /F /IM victory-baseline.exe /T 2>$null | Out-Null
  Start-Sleep -Seconds 2
}
$leftover = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
if ($leftover -ne 0) { "WARN: $leftover 个 victory* 进程仍未收掉，本轮数字可能被污染" }

# 项目 B：给了 -WorldSeconds 时，全部指标只在这一窗里算（进世界之后）；
# 否则仍用整个采样集（旧口径）。
$scope = if ($WorldSeconds -gt 0 -and $null -ne $worldFrom) { @($samples | Where-Object { $_.T -ge $worldFrom }) } else { $samples }
$all = $scope | Where-Object { $null -ne $_.Ms }
# 世界样本（filter v2）：Ms>40 且 Draws>=200。
# v1 只看 Ms>40，菜单偶发尖峰（47.6 / 58.8 / 67 ms，draws 9-10）会被当成世界帧：
# round-02 的 B 组混进 3 条，csv 中位从 272.8 被拉到 271.9（见 round-02\F-核对结论.md）。
$world = @($all | Where-Object { $_.Ms -gt 40 -and $null -ne $_.Draws -and $_.Draws -ge 200 })
$median = if ($world.Count) { ($world | Sort-Object Ms | Select-Object -Skip ([int]($world.Count / 2)) -First 1).Ms } else { $null }
$medianDraws = if ($world.Count) { ($world | Sort-Object Draws | Select-Object -Skip ([int]($world.Count / 2)) -First 1).Draws } else { $null }
$maxPriv = ($scope | Measure-Object PrivGB -Maximum).Maximum
$minFree = ($scope | Measure-Object FreeGB -Minimum).Minimum
$minCommit = ($scope | Measure-Object CommitFreeGB -Minimum).Minimum

if ($WorldSeconds -gt 0) {
  # 项目 B 口径写 bench-fork.csv（v2 冻结为历史；两种口径的 median 不可混用）。
  $csv3 = Join-Path $data "bench-fork.csv"
  if (-not (Test-Path -LiteralPath $csv3)) {
    "time,label,world_seconds,cap_seconds,samples,world_from_s,world_samples,world_filter,median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log" | Set-Content -LiteralPath $csv3
  }
  Add-Content -LiteralPath $csv3 -Value ("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}" -f `
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Label, $WorldSeconds, $Seconds, $samples.Count, $worldFrom, $world.Count,
    'ms>40&draws>=200', $([math]::Round($median, 1)), $medianDraws, $maxPriv, $minFree, $minCommit, $leftover, (Split-Path $log -Leaf))
} else {
  # filter v2 起写 bench-v2.csv：旧 bench.csv 冻结为历史，两种口径的 median 不可混用。
  $csv2 = Join-Path $data "bench-v2.csv"
  if (-not (Test-Path -LiteralPath $csv2)) {
    "time,label,seconds,samples,world_filter,world_samples,median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log" | Set-Content -LiteralPath $csv2
  }
  Add-Content -LiteralPath $csv2 -Value ("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}" -f `
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Label, $Seconds, $samples.Count, 'ms>40&draws>=200', $world.Count,
    $([math]::Round($median, 1)), $medianDraws, $maxPriv, $minFree, $minCommit, $leftover, (Split-Path $log -Leaf))
}

$samples | Format-Table T, Fps, Ms, Draws, PrivGB, RssGB, FreeGB, CommitFreeGB -AutoSize | Out-String -Width 160
"window = $(if ($WorldSeconds -gt 0) { "world+$WorldSeconds s (from t=$worldFrom s)" } else { 'process start (legacy)' }) ；采样 $($samples.Count) 条，窗内 $($scope.Count) 条"
"median_ms_world = $median （filter v2，$(@($world).Count) 条世界样本，中位 draws=$medianDraws）；max_priv_gb = $maxPriv ；min_free_gb = $minFree ；min_commit_free_gb = $minCommit ；leftover_procs = $leftover"
"详情写入 $(if ($WorldSeconds -gt 0) { 'bench-fork.csv' } else { 'bench-v2.csv' })"

