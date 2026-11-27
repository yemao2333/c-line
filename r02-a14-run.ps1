$ErrorActionPreference = 'Continue'
$root = '<ROOT>\cool_fox-优化方案'
$exe  = '<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe'
$expect = '58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$cache = '<ROOT>\victory-data\coolfox-cache'
"=== r02-a14 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$sha = (Get-FileHash $exe -Algorithm SHA256).Hash
"SHA256=$sha"
if ($sha -ne $expect) { "SHA_MISMATCH expected=$expect"; exit 2 }
$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$lim = ($c | Where-Object Path -match 'commit limit').CookedValue / 1GB
$used = ($c | Where-Object Path -match 'committed bytes').CookedValue / 1GB
"commit_limit_gb={0:N2} commit_free_gb={1:N2}" -f $lim, ($lim - $used)
if ($lim -lt 44) { "SKIP_R8: commit_limit_gb < 44"; exit 3 }

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3
Set-Location $root

"book_before=" + @(Get-ChildItem (Join-Path $cache 'pipelines') -Recurse -File -ErrorAction SilentlyContinue).Count

"=== S1 R8-before-book at " + (Get-Date -Format 'HH:mm:ss')
& $ps -NoProfile -ExecutionPolicy Bypass -File '.\13-bench-ab.ps1' -Label 'R8-before-book' -Exe $exe -Seconds 200 -Profile fork -Extra 'VICTORY_PIPELINE_BOOK=1'
"S1_exit=$LASTEXITCODE"
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3
"book_after_run=" + @(Get-ChildItem (Join-Path $cache 'pipelines') -Recurse -File -ErrorAction SilentlyContinue).Count

"=== S2 warm at " + (Get-Date -Format 'HH:mm:ss')
$t0 = Get-Date
& $exe warm --used --jobs 4 *> (Join-Path $root 'data\r02-a14-warm.log')
$warmElapsed = [int]((Get-Date) - $t0).TotalSeconds
"warm_EXIT=$LASTEXITCODE warm_elapsed=${warmElapsed}s"
"=== warm tail 6 ==="
Get-Content (Join-Path $root 'data\r02-a14-warm.log') -Tail 6 | Out-String -Width 200
"book_after_warm=" + @(Get-ChildItem (Join-Path $cache 'pipelines') -Recurse -File -ErrorAction SilentlyContinue).Count

"=== S3 R8-after-warm at " + (Get-Date -Format 'HH:mm:ss')
& $ps -NoProfile -ExecutionPolicy Bypass -File '.\13-bench-ab.ps1' -Label 'R8-after-warm' -Exe $exe -Seconds 200 -Profile fork
"S3_exit=$LASTEXITCODE"
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 5
"leftover_after_group=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"=== final_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"=== bench-v2.csv ==="
$n = 0
Get-Content (Join-Path $root 'data\bench-v2.csv') | ForEach-Object { $n++; "{0,2}: {1}" -f $n, $_ }
"=== r02-a14 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')