$ErrorActionPreference = 'Continue'
$root = '<ROOT>\cool_fox-优化方案'
$exe  = '<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe'
$expect = '58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$data = Join-Path $root 'data'
$gbk = [System.Text.Encoding]::GetEncoding(936)
$u8  = New-Object System.Text.UTF8Encoding($true)

"=== r02-b1 (attempt 2) start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$sha = (Get-FileHash $exe -Algorithm SHA256).Hash
"SHA256=$sha"
if ($sha -ne $expect) { "SHA_MISMATCH expected=$expect"; exit 2 }
$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$lim = ($c | Where-Object Path -match 'commit limit').CookedValue / 1GB
$used = ($c | Where-Object Path -match 'committed bytes').CookedValue / 1GB
"commit_limit_gb={0:N2} commit_free_gb={1:N2}" -f $lim, ($lim - $used)
if ($lim -lt 44) { "SKIP_R10: commit_limit_gb < 44"; exit 3 }
"v2_lines_before=" + (Get-Content (Join-Path $data 'bench-v2.csv')).Count
"v2_sha_before=" + (Get-FileHash (Join-Path $data 'bench-v2.csv') -Algorithm SHA256).Hash
"v1_lines_before=" + (Get-Content (Join-Path $data 'bench.csv')).Count
"v1_sha_before=" + (Get-FileHash (Join-Path $data 'bench.csv') -Algorithm SHA256).Hash

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

function RunGroup($label, $extra) {
  $safe = $label.ToLower()
  $raw = Join-Path $data "r10-$safe-console.raw.log"
  $cln = Join-Path $data "r10-$safe-console.log"
  $gerr = Join-Path $data "r10-$safe-console.err.log"
  "=== $label start " + (Get-Date -Format 'HH:mm:ss')
  $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $root '13-bench-ab.ps1'),
         '-Label',$label,'-Exe',$exe,'-Seconds','420','-WorldSeconds','200','-Profile','fork')
  if ($extra) { $a += @('-Extra', $extra) }
  $gp = Start-Process -FilePath $ps -ArgumentList $a -WorkingDirectory $root -RedirectStandardOutput $raw -RedirectStandardError $gerr -PassThru -WindowStyle Hidden
  $waited = 0
  while (-not $gp.HasExited -and $waited -lt 800) { Start-Sleep -Seconds 5; $waited += 5 }
  "group_EXIT=$($gp.ExitCode) waited_s=$waited"
  if (-not $gp.HasExited) { "group_STILL_RUNNING after ${waited}s" }
  $txt = $gbk.GetString([System.IO.File]::ReadAllBytes($raw))
  [System.IO.File]::WriteAllText($cln, $txt, $u8)
  $l1 = ($txt -split "`r?`n" | Where-Object { $_ -match '进世界' } | Select-Object -First 1)
  $l2 = ($txt -split "`r?`n" | Where-Object { $_ -match 'window = world' } | Select-Object -First 1)
  "world_line=" + $(if ($l1) { $l1.Trim() } else { 'NO_MATCH' })
  "window_line=" + $(if ($l2) { $l2.Trim() } else { 'NO_MATCH' })
  "group_console=$cln"
  Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep 5
  "leftover_after_$label =" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
}

RunGroup 'R10-control' ''
RunGroup 'R10-sendown0' 'VICTORY_SEND_OWN=0'

"=== bench-v3.csv 全文 ==="
$v3 = Join-Path $data 'bench-v3.csv'
if (Test-Path $v3) { $n = 0; foreach ($ln in (Get-Content $v3)) { $n++; "{0,2}: {1}" -f $n, $ln } } else { 'V3_MISSING' }
"=== bench-v2.csv 行数 / sha ==="
(Get-Content (Join-Path $data 'bench-v2.csv')).Count
"v2_sha_after=" + (Get-FileHash (Join-Path $data 'bench-v2.csv') -Algorithm SHA256).Hash
"=== bench.csv 行数 / sha ==="
(Get-Content (Join-Path $data 'bench.csv')).Count
"v1_sha_after=" + (Get-FileHash (Join-Path $data 'bench.csv') -Algorithm SHA256).Hash
"=== final_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"=== r02-b1 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
