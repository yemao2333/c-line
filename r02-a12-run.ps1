$ErrorActionPreference = 'Continue'
$root = 'G:\GTA\cool_fox-优化方案'
$exe  = 'G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe'
$expect = '58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
"=== r02-a12 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"SHA256=" + (Get-FileHash $exe -Algorithm SHA256).Hash
if ((Get-FileHash $exe -Algorithm SHA256).Hash -ne $expect) { "SHA_MISMATCH expected=$expect"; exit 2 }
$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$lim = ($c | Where-Object Path -match 'commit limit').CookedValue / 1GB
$used = ($c | Where-Object Path -match 'committed bytes').CookedValue / 1GB
"commit_limit_gb={0:N2} commit_free_gb={1:N2}" -f $lim, ($lim - $used)
if ($lim -lt 44) { "SKIP_R6: commit_limit_gb < 44"; exit 3 }

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3
Set-Location $root

$groups = @(
  @{ label = 'R6-control';   extra = $null },
  @{ label = 'R6-sendown0';  extra = 'VICTORY_SEND_OWN=0' },
  @{ label = 'R6-inplace0';  extra = 'VICTORY_COPIES_IN_PLACE=0' },
  @{ label = 'R6-latewait1'; extra = 'VICTORY_LATE_WAIT=1' }
)
foreach ($g in $groups) {
  "=== group $($g.label) extra=$($g.extra) at " + (Get-Date -Format 'HH:mm:ss')
  if ($null -eq $g.extra) {
    & $ps -NoProfile -ExecutionPolicy Bypass -File '.\13-bench-ab.ps1' -Label $g.label -Exe $exe -Seconds 200 -Profile fork
  } else {
    & $ps -NoProfile -ExecutionPolicy Bypass -File '.\13-bench-ab.ps1' -Label $g.label -Exe $exe -Seconds 200 -Profile fork -Extra $g.extra
  }
  "group_exit=$LASTEXITCODE"
  Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep 5
  $left = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' })
  "leftover_after_group=$($left.Count)"
}
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
"=== final_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"=== bench-v2.csv ==="
$n = 0
Get-Content (Join-Path $root 'data\bench-v2.csv') | ForEach-Object { $n++; "{0,2}: {1}" -f $n, $_ }
"=== r02-a12 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')