$ErrorActionPreference = 'Continue'
$root = 'G:\GTA\cool_fox-优化方案'
$exe  = 'G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe'
$expect = '58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$cache = 'G:\GTA\victory-data\coolfox-cache\pipelines'
$bookbin = Join-Path $cache 'known-pipelines.bin'
$data = Join-Path $root 'data'

"=== r02-a15 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$sha = (Get-FileHash $exe -Algorithm SHA256).Hash
"SHA256=$sha"
if ($sha -ne $expect) { "SHA_MISMATCH expected=$expect"; exit 2 }
$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$lim = ($c | Where-Object Path -match 'commit limit').CookedValue / 1GB
$used = ($c | Where-Object Path -match 'committed bytes').CookedValue / 1GB
"commit_limit_gb={0:N2} commit_free_gb={1:N2}" -f $lim, ($lim - $used)
if ($lim -lt 44) { "SKIP_R9: commit_limit_gb < 44"; exit 3 }

"before: known_pipelines_bytes=" + $(if (Test-Path -LiteralPath $bookbin) { (Get-Item -LiteralPath $bookbin).Length } else { 'MISSING' })

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3
Set-Location 'G:\GTA\cool_fox\cool_fox-main'

$env:VICTORY_AMBIENT_AIR='1.5'; $env:VICTORY_CACHE_DIR='G:\GTA\victory-data\coolfox-cache'; $env:VICTORY_DATA_DIR='G:\GTA\victory-data\coolfox-data'
$env:VICTORY_TEXTURE_NO_WAIT='1'; $env:VICTORY_RELAY='2'; $env:VICTORY_WIDE_BACK='1'; $env:VICTORY_CARD_REHASH_RUNS='1'
$env:VICTORY_JOIN_COPIES='1'; $env:VICTORY_INDIRECT_WINDOW='1'; $env:VICTORY_RELAY_COPY='1'; $env:VICTORY_CARD_STEPS='2'
$env:VICTORY_INDIRECT_BATCH='2'; $env:VICTORY_MAP_THREADS='1'; $env:VICTORY_CARD_AWAKE='1'; $env:VICTORY_SHOW_AFTER='1'
$env:VICTORY_AMBIENT='0.8'; $env:VICTORY_THIN='1'; $env:VICTORY_JOIN_PARTS='6'; $env:VICTORY_UPLOAD_AHEAD='1'
$env:VICTORY_LEVELS_ON_DEMAND='1'; $env:VICTORY_CARD_BUFFERS_MIN_KB='64'
$env:VICTORY_LOG = 'warn'
$env:VICTORY_PIPELINE_BOOK = '1'

"=== S1 book run at " + (Get-Date -Format 'HH:mm:ss')
$out = Join-Path $data 'r02-a15-book.log'
$err = Join-Path $data 'r02-a15-book.err.log'
$p = Start-Process -FilePath $exe -ArgumentList @('run','G:\GTA\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe','--console','series-s','--execute') `
  -WorkingDirectory 'G:\GTA\cool_fox\cool_fox-main' -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Normal
"pid=$($p.Id)"
Start-Sleep -Seconds 200
$v = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
"title_before_close=" + $(if ($v) { $v.MainWindowTitle } else { 'gone' })

$clean = $false
$i = 0
if ($v) { $null = $v.CloseMainWindow() }
for ($i = 0; $i -lt 60; $i++) {
  Start-Sleep -Seconds 1
  if (-not (Get-Process -Id $p.Id -ErrorAction SilentlyContinue)) { $clean = $true; break }
}
"clean_exit=$clean waited_s=$i"
$still = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
if ($still) { "title_at_giveup=" + $still.MainWindowTitle }
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2
"after_close: known_pipelines_bytes=" + $(if (Test-Path -LiteralPath $bookbin) { (Get-Item -LiteralPath $bookbin).Length } else { 'MISSING' })
"after_close: leftover=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count

"=== S2 warm (no --used) at " + (Get-Date -Format 'HH:mm:ss')
Set-Location 'G:\GTA\cool_fox\cool_fox-main'
$t0 = Get-Date
& $exe warm --jobs 4 *> (Join-Path $data 'r02-a15-warm.log')
$warmElapsed = [int]((Get-Date) - $t0).TotalSeconds
"warm_EXIT=$LASTEXITCODE warm_elapsed=${warmElapsed}s"
"=== warm tail 8 ==="
Get-Content (Join-Path $data 'r02-a15-warm.log') -Tail 8 | Out-String -Width 200
$wl = Select-String -Path (Join-Path $data 'r02-a15-warm.log') -Pattern 'pipelines known' | Select-Object -First 1
"warm_line=" + $(if ($wl) { $wl.Line } else { 'NO_MATCH' })
"after_warm: known_pipelines_bytes=" + $(if (Test-Path -LiteralPath $bookbin) { (Get-Item -LiteralPath $bookbin).Length } else { 'MISSING' })
$hdrHex = 'NO_FILE'
if (Test-Path -LiteralPath $bookbin) {
  $bytes = [System.IO.File]::ReadAllBytes($bookbin)
  $head = if ($bytes.Length -ge 32) { $bytes[0..31] } else { $bytes }
  $hdrHex = ($head | ForEach-Object { '{0:x2}' -f $_ }) -join ''
}
"known_pipelines_head32=$hdrHex"

"=== S3 R9-after-warm2 at " + (Get-Date -Format 'HH:mm:ss')
Remove-Item Env:\VICTORY_PIPELINE_BOOK -ErrorAction SilentlyContinue
Set-Location $root
& $ps -NoProfile -ExecutionPolicy Bypass -File '.\13-bench-ab.ps1' -Label 'R9-after-warm2' -Exe $exe -Seconds 200 -Profile fork
"S3_exit=$LASTEXITCODE"
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 5
"leftover_after_group=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
"final_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count

"=== S3 stall count from run log ==="
$rl = Get-ChildItem (Join-Path $data 'run-R9-after-warm2-*.log') | Where-Object { $_.Name -notmatch '\.err\.log$' } | Sort-Object LastWriteTime | Select-Object -Last 1
"runlog=" + $rl.Name
$msv = @()
foreach ($ln in (Get-Content -LiteralPath $rl.FullName)) {
  if ($ln -match 't=\s*\d+s fps=.*?ms=\s*([0-9.]+)\s+draws=\s*(\d+)') {
    if ($Matches[1] -ne '' -and $Matches[1] -ne $null) { $msv += [double]$Matches[1] }
  }
}
"R9-after-warm2: samples={0} world_n={1} gt200={2} gt400={3} max_ms={4}" -f $msv.Count, $msv.Count, @($msv | Where-Object { $_ -gt 200 }).Count, @($msv | Where-Object { $_ -gt 400 }).Count, ($msv | Measure-Object -Maximum).Maximum

"=== bench-v2.csv from L19 ==="
$n = 0
Get-Content (Join-Path $data 'bench-v2.csv') | ForEach-Object { $n++; if ($n -ge 19) { "{0,2}: {1}" -f $n, $_ } }
"=== r02-a15 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
