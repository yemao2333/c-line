$ErrorActionPreference = 'Stop'
$root = '<ROOT>\cool_fox-优化方案'
$data = Join-Path $root 'data'
$diag = '<ROOT>\cool_fox\cool_fox-main\target\diag\victory.exe'
$expect = '710857B58C00BA3E1AB71141DE1C23ED039A156AFEB78B7AC3CFB0115DA7C7D5'
"=== r02-a11 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$sha = (Get-FileHash $diag -Algorithm SHA256).Hash
"SHA256_diag=$sha"
if ($sha -ne $expect) { "SHA_MISMATCH expected=$expect"; exit 2 }

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

$env:VICTORY_AMBIENT_AIR='1.5'; $env:VICTORY_CACHE_DIR='<ROOT>\victory-data\coolfox-cache'; $env:VICTORY_DATA_DIR='<ROOT>\victory-data\coolfox-data'
$env:VICTORY_TEXTURE_NO_WAIT='1'; $env:VICTORY_RELAY='2'; $env:VICTORY_WIDE_BACK='1'; $env:VICTORY_CARD_REHASH_RUNS='1'
$env:VICTORY_JOIN_COPIES='1'; $env:VICTORY_INDIRECT_WINDOW='1'; $env:VICTORY_RELAY_COPY='1'; $env:VICTORY_CARD_STEPS='2'
$env:VICTORY_INDIRECT_BATCH='2'; $env:VICTORY_MAP_THREADS='1'; $env:VICTORY_CARD_AWAKE='1'; $env:VICTORY_SHOW_AFTER='1'
$env:VICTORY_AMBIENT='0.8'; $env:VICTORY_THIN='1'; $env:VICTORY_JOIN_PARTS='6'; $env:VICTORY_UPLOAD_AHEAD='1'
$env:VICTORY_LEVELS_ON_DEMAND='1'; $env:VICTORY_CARD_BUFFERS_MIN_KB='64'
$env:VICTORY_LOG = 'info'
$env:VICTORY_GPU_TIMING = '1'
Remove-Item Env:\VICTORY_TIMELINE -ErrorAction SilentlyContinue
Remove-Item Env:\VICTORY_CAPTURE_FRAMES -ErrorAction SilentlyContinue
Remove-Item Env:\VICTORY_RECORD_FRAMES -ErrorAction SilentlyContinue

$err = Join-Path $data 'r02-a11-gputiming-info.err.log'
$out = Join-Path $data 'r02-a11-gputiming-info.log'
$tfile = Join-Path $data 'r02-a11-titles.txt'
$p = Start-Process -FilePath $diag -ArgumentList @('run','<ROOT>\<DUMP>\game_scarlett_master.exe','--console','series-s','--execute') -WorkingDirectory '<ROOT>\cool_fox\cool_fox-main' -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Normal
"pid=$($p.Id)"

$titles = @()
$goneAt = 0
for ($i = 1; $i -le 42; $i++) {
  Start-Sleep -Seconds 10
  $v = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
  if (-not $v) { $goneAt = $i * 10; "process gone at $($i*10)s"; break }
  $t = $v.MainWindowTitle
  $titles += ("{0}s|{1}" -f ($i*10), $t)
  if ($i % 6 -eq 0) { "  t=$($i*10)s title=$t" }
}
"titles_count=$($titles.Count) gone_at_s=$goneAt"
[System.IO.File]::WriteAllLines($tfile, $titles, (New-Object System.Text.UTF8Encoding($false)))
"=== titles with draws (last 3)"; $titles | Where-Object { $_ -match 'draws' } | Select-Object -Last 3

$left = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' })
"leftover_before_kill=$($left.Count)"
Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2
$left2 = @(Get-Process | Where-Object { $_.ProcessName -match '^victory' })
"leftover_after_kill=$($left2.Count)"
"err_bytes=" + (Get-Item $err).Length
"out_bytes=" + (Get-Item $out).Length

"=== by-what-ran count ==="
"by_what_ran_hits=" + @(Select-String -Path $err -Pattern "the card's time by what ran" -SimpleMatch).Count
"=== by-what-ran last 5 (full lines) ==="
Select-String -Path $err -Pattern "the card's time by what ran" -SimpleMatch | Select-Object -Last 5 | ForEach-Object { "L$($_.LineNumber): " + ([regex]::Replace($_.Line, "\x1b\[[0-9;]*m", '')) }
"=== waits last 3 ==="
Select-String -Path $err -Pattern 'waits for every earlier shader write' -SimpleMatch | Select-Object -Last 3 | ForEach-Object { "L$($_.LineNumber): " + ([regex]::Replace($_.Line, "\x1b\[[0-9;]*m", '')) }
"settles_hits=" + @(Select-String -Path $err -Pattern 'of the waiting for the card in settles' -SimpleMatch).Count
"thin_hits=" + @(Select-String -Path $err -Pattern 'list calls translated by threads of ours per frame' -SimpleMatch).Count
"=== err tail 40 ==="
Get-Content $err -Tail 40 | ForEach-Object { [regex]::Replace($_, "\x1b\[[0-9;]*m", '') }
"=== r02-a11 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')