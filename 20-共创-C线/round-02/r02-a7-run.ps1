# ARCHIVED EVIDENCE (r02-a7, 2026-11-26 23:07-23:25)
# 用途：驱动 r02-a7 四组跑分的 runner（ 推目录 + 全 ASCII + BOM 绝对路径），
# 首版因无 BOM 被 PS 5.1 按 ANSI 读而失败，此处保留为证据，不再执行。
# r02-a7 runner (ASCII only; root derived from script location to survive encoding)
$env:Path = "$env:SystemRoot\System32;$env:SystemRoot\System32\WindowsPowerShell\v1.0;$env:Path"
$ps51 = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$root = $PSScriptRoot
$log  = Join-Path $root 'data\r02-a7-console.log'
$ab   = Join-Path $root '13-bench-ab.ps1'
$rel  = '<ROOT>\cool_fox\cool_fox-main\target\release'

function W([string]$s) { Add-Content -LiteralPath $log -Value $s -Encoding UTF8 }

function HashOf([string]$p) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::OpenRead($p)
    $h = $sha.ComputeHash($fs)
    $fs.Close(); $sha.Dispose()
    return ([System.BitConverter]::ToString($h) -replace '-','')
}

W ("=== r02-a7 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
W ("root=" + $root)
W ("SHA256_victory="  + (HashOf (Join-Path $rel 'victory.exe')))
W ("SHA256_baseline=" + (HashOf (Join-Path $rel 'victory-baseline.exe')))

$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$limit = [math]::Round((($c | Where-Object Path -match 'commit limit').CookedValue) / 1GB, 2)
$used  = [math]::Round((($c | Where-Object Path -match 'committed bytes').CookedValue) / 1GB, 2)
$free  = [math]::Round($limit - $used, 2)
W "commit_limit_gb=$limit commit_used_gb=$used commit_free_gb=$free"

if ($limit -lt 44) { W "SKIP_R4: commit_limit_gb=$limit < 44"; exit 0 }

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

$groups = @(
    @{ L = 'R4-A2-baseline';   E = 'victory-baseline.exe'; X = '' },
    @{ L = 'R4-B-reverted';    E = 'victory.exe';          X = '' },
    @{ L = 'R4-B-threads-old'; E = 'victory.exe';          X = 'VICTORY_THIN_THREADS=8;VICTORY_PIPELINE_WORKERS=8;VICTORY_VIEW_THREADS=6;VICTORY_UNDER_THREADS=6' },
    @{ L = 'R4-B-floor2g';     E = 'victory.exe';          X = 'VICTORY_TEXTURE_BUDGET_MB=2048' }
)

foreach ($g in $groups) {
    W ("=== group " + $g.L + " start " + (Get-Date -Format 'HH:mm:ss'))
    $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$ab,
           '-Label',$g.L,'-Exe',(Join-Path $rel $g.E),'-Seconds','200','-Profile','fork')
    if ($g.X) { $a += @('-Extra',$g.X) }
    & $ps51 @a *>> $log
    W ("=== group " + $g.L + " end " + (Get-Date -Format 'HH:mm:ss'))
    Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 5
    W ("post-clean leftover_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count)
}

W "=== bench-v2.csv ==="
$n = 0
Get-Content (Join-Path $root 'data\bench-v2.csv') | ForEach-Object { $n++; W ("{0,2}: {1}" -f $n, $_) }
W ("=== r02-a7 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
