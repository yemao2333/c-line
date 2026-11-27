# r02-e3 B 段：SETTLE_ROOM 复验四连跑（off → on → on → off）
# 顺序固定，机械抵消漂移；不改任何判据，全部交给 smoke.ps1。
$ErrorActionPreference = 'Continue'
$root = '<ROOT>\cool_fox-优化方案'
$smoke = Join-Path $root '10-实验脚本\smoke.ps1'
$log = Join-Path $root 'data\e3-B-console.log'
function Say($t) { $t | Out-File -FilePath $log -Append -Encoding utf8 }
"=== e3-B start $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File -FilePath $log -Encoding utf8
$runs = @(
  @{ Label = 'sr-off-1'; Extra = '' },
  @{ Label = 'sr-on-1';  Extra = 'VICTORY_SETTLE_ROOM=1' },
  @{ Label = 'sr-on-2';  Extra = 'VICTORY_SETTLE_ROOM=1' },
  @{ Label = 'sr-off-2'; Extra = '' }
)
foreach ($r in $runs) {
  Say ""
  Say "--- label=$($r.Label) extra=[$($r.Extra)] at $(Get-Date -Format 'HH:mm:ss') ---"
  $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $smoke, '-Label', $r.Label)
  if ($r.Extra) { $argv += @('-Extra', $r.Extra) }
  $p = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $argv -PassThru -WindowStyle Hidden `
    -RedirectStandardOutput (Join-Path $root "data\e3-$($r.Label)-out.log") `
    -RedirectStandardError (Join-Path $root "data\e3-$($r.Label)-err.log")
  $p.WaitForExit()
  Say "rc[$($r.Label)]=$($p.ExitCode)"
  Get-Content (Join-Path $root "data\e3-$($r.Label)-out.log") -Tail 6 | ForEach-Object { Say $_ }
  Start-Sleep -Seconds 5
}
Say ""
Say "=== e3-B end $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="
