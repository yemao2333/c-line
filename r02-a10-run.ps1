# r02-a10 runner: S1 diag build, then S2 info+GPU_TIMING probe (150 s, one retry if early death)
# ASCII only; root from $PSScriptRoot; save with UTF-8 BOM.
$env:CARGO_HOME  = '<RUST>\cargo'
$env:RUSTUP_HOME = '<RUST>\rustup'
$env:PATH = '<RUST>\cargo\bin;<TOOLCHAIN>\w64devkit\w64devkit\bin;C:\Windows\System32;' + $env:PATH
$env:RUSTFLAGS = '-C target-cpu=native'

$root   = $PSScriptRoot
$data   = Join-Path $root 'data'
$log    = Join-Path $data 'r02-a10-console.log'
$repo   = '<ROOT>\cool_fox\cool_fox-main'
$release= Join-Path $repo 'target\release\victory.exe'
$diag   = Join-Path $repo 'target\diag\victory.exe'

function W([string]$s) { Add-Content -LiteralPath $log -Value $s -Encoding UTF8 }
function HashOf([string]$p) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::OpenRead($p); $h = $sha.ComputeHash($fs)
    $fs.Close(); $sha.Dispose()
    return ([System.BitConverter]::ToString($h) -replace '-','')
}

W ("=== r02-a10 start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
W ("release_sha256_before=" + (HashOf $release))

# ---------- S1 build ----------
$buildLog = Join-Path $data 'build-diag.log'
$t0 = Get-Date
Push-Location $repo
& '<RUST>\cargo\bin\cargo.exe' build --profile diag -p victory --features diagnostics --locked 2>&1 | Out-File -LiteralPath $buildLog -Encoding utf8
$code = $LASTEXITCODE
Pop-Location
W ("EXIT=$code elapsed=$([int]((Get-Date)-$t0).TotalSeconds)s")
W ("errors=" + @(Select-String -Path $buildLog -Pattern '^error' | Select-Object -First 5).Count)
if (Test-Path -LiteralPath $diag) {
    $d = Get-Item -LiteralPath $diag
    W ("diag_bytes=" + $d.Length + " written=" + $d.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
    W ("diag_sha256=" + (HashOf $diag))
} else { W "diag_exe=NOT_FOUND" }
W ("release_sha256_after=" + (HashOf $release))
if ($code -ne 0 -or -not (Test-Path -LiteralPath $diag)) { W "S1_FAILED: stop"; exit 1 }

# ---------- S2 probe ----------
function SetFork() {
    $env:VICTORY_AMBIENT_AIR='1.5'; $env:VICTORY_CACHE_DIR='<ROOT>\victory-data\coolfox-cache'
    $env:VICTORY_DATA_DIR='<ROOT>\victory-data\coolfox-data'
    $env:VICTORY_TEXTURE_NO_WAIT='1'; $env:VICTORY_RELAY='2'; $env:VICTORY_WIDE_BACK='1'
    $env:VICTORY_CARD_REHASH_RUNS='1'; $env:VICTORY_JOIN_COPIES='1'; $env:VICTORY_INDIRECT_WINDOW='1'
    $env:VICTORY_RELAY_COPY='1'; $env:VICTORY_CARD_STEPS='2'; $env:VICTORY_INDIRECT_BATCH='2'
    $env:VICTORY_MAP_THREADS='1'; $env:VICTORY_CARD_AWAKE='1'; $env:VICTORY_SHOW_AFTER='1'
    $env:VICTORY_AMBIENT='0.8'; $env:VICTORY_THIN='1'; $env:VICTORY_JOIN_PARTS='6'
    $env:VICTORY_UPLOAD_AHEAD='1'; $env:VICTORY_LEVELS_ON_DEMAND='1'; $env:VICTORY_CARD_BUFFERS_MIN_KB='64'
    $env:VICTORY_GPU_TIMING='1'
    Remove-Item Env:\VICTORY_TIMELINE -ErrorAction SilentlyContinue
    Remove-Item Env:\VICTORY_CAPTURE_FRAMES -ErrorAction SilentlyContinue
    Remove-Item Env:\VICTORY_RECORD_FRAMES -ErrorAction SilentlyContinue
}

function RunOne([string]$tag, [int]$seconds) {
    $err = Join-Path $data ("r02-a10-gputiming" + $tag + ".err.log")
    $out = Join-Path $data ("r02-a10-gputiming" + $tag + ".log")
    foreach ($f in @($err,$out)) { if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force } }
    Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 3
    $p = Start-Process -FilePath $diag -ArgumentList @('run','<ROOT>\<DUMP>\game_scarlett_master.exe','--console','series-s','--execute') -WorkingDirectory $repo -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Normal
    W ("pid=" + $p.Id)
    $start = Get-Date
    for ($i = 0; $i -lt [int]($seconds / 5); $i++) {
        Start-Sleep -Seconds 5
        if (-not (Get-Process -Id $p.Id -ErrorAction SilentlyContinue)) { break }
    }
    $lived = [int]((Get-Date) - $start).TotalSeconds
    Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    W ("lived_s=$lived leftover_procs=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count)
    W ("err_bytes=" + (Get-Item -LiteralPath $err -ErrorAction SilentlyContinue).Length)
    return [pscustomobject]@{ Err=$err; Lived=$lived }
}

SetFork
$env:VICTORY_LOG = 'info'
$r1 = RunOne '-info' 150
if ($r1.Lived -lt 30) {
    W "EARLY_DEATH_1: lived=$($r1.Lived)s < 30 -> retry with only VICTORY_GPU_TIMING"
    Remove-Item Env:\VICTORY_LOG -ErrorAction SilentlyContinue
    $r2 = RunOne '-retry' 150
    $errFinal = $r2.Err
    W ("retry_lived_s=" + $r2.Lived)
} else {
    $errFinal = $r1.Err
}

W "=== key lines (last 3 matching by what ran | commands | of the waiting for the card in settles) ==="
$hits = Select-String -Path $errFinal -Pattern 'by what ran|commands|of the waiting for the card in settles'
$last = $hits | Select-Object -Last 3
W ("hits_total=" + @($hits).Count)
$esc = [char]27
$ansi = '[' + $esc + '][[][0-9;]*m'
foreach ($h in $last) { W ("L" + $h.LineNumber + ": " + ($h.Line -replace $ansi, '')) }
W ("err_file=" + $errFinal)
W ("=== r02-a10 done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
