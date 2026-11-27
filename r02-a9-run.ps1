# r02-a9 runner: four serial groups (R5-control / wideback0 / cardsteps0 / relaycopy0)
# ASCII only; root derived from script location; must be saved with UTF-8 BOM.
$env:Path = "$env:SystemRoot\System32;$env:SystemRoot\System32\WindowsPowerShell\v1.0;$env:Path"
$ps51 = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$root = $PSScriptRoot
$log  = Join-Path $root 'data\r02-a9-console.log'
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

W ("=== r02-a9 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
W ("root=" + $root)
W ("SHA256_victory=" + (HashOf (Join-Path $rel 'victory.exe')))

$c = (Get-Counter '\Memory\Commit Limit','\Memory\Committed Bytes' -SampleInterval 1 -MaxSamples 1).CounterSamples
$limit = [math]::Round((($c | Where-Object Path -match 'commit limit').CookedValue) / 1GB, 2)
$used  = [math]::Round((($c | Where-Object Path -match 'committed bytes').CookedValue) / 1GB, 2)
$free  = [math]::Round($limit - $used, 2)
W "commit_limit_gb=$limit commit_used_gb=$used commit_free_gb=$free"
if ($limit -lt 44) { W "SKIP_A9: commit_limit_gb=$limit < 44"; exit 0 }

Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

$groups = @(
    @{ L = 'R5-control';    X = '' },
    @{ L = 'R5-wideback0';  X = 'VICTORY_WIDE_BACK=0' },
    @{ L = 'R5-cardsteps0'; X = 'VICTORY_CARD_STEPS=0' },
    @{ L = 'R5-relaycopy0'; X = 'VICTORY_RELAY_COPY=0' }
)

foreach ($g in $groups) {
    W ("=== group " + $g.L + " start " + (Get-Date -Format 'HH:mm:ss'))
    $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$ab,
           '-Label',$g.L,'-Exe',(Join-Path $rel 'victory.exe'),'-Seconds','200','-Profile','fork')
    if ($g.X) { $a += @('-Extra',$g.X) }
    & $ps51 @a 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
    W ("=== group " + $g.L + " end " + (Get-Date -Format 'HH:mm:ss'))
    Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 5
    W ("post-clean leftover_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count)
}

W "=== bench-v2.csv ==="
$n = 0
Get-Content (Join-Path $root 'data\bench-v2.csv') | ForEach-Object { $n++; W ("{0,2}: {1}" -f $n, $_) }
W ("=== r02-a9 groups done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
