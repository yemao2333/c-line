$ErrorActionPreference = 'Continue'
# r02-z2-run.ps1 — 第 2/3/4 条的机器侧对照（warm 全量之后跑，600 s 世界窗，每组 2 次）
# 判据一律复用 smoke.ps1 / bench.ps1，本脚本只串跑与记账。
$root = 'G:\GTA\cool_fox-优化方案'
$scripts = Join-Path $root '10-实验脚本'
$exe = 'G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe'
$label0 = 'z2'
$sec = 800
$world = 600

$configs = @(
  @{ tag = 'base-1';     extra = '' },
  @{ tag = 'base-2';     extra = '' },
  @{ tag = 'batchoff-1'; extra = 'VICTORY_INDIRECT_BATCH=0;VICTORY_JOIN_COPIES=0' },
  @{ tag = 'batchoff-2'; extra = 'VICTORY_INDIRECT_BATCH=0;VICTORY_JOIN_COPIES=0' },
  @{ tag = 'memtight-1'; extra = 'VICTORY_MEMORY_CARD_MB=1536;VICTORY_KEEP_SNAPSHOTS_MB=64;VICTORY_INPLACE_MB=512;VICTORY_TEXTURE_BUDGET_MB=768' },
  @{ tag = 'memtight-2'; extra = 'VICTORY_MEMORY_CARD_MB=1536;VICTORY_KEEP_SNAPSHOTS_MB=64;VICTORY_INPLACE_MB=512;VICTORY_TEXTURE_BUDGET_MB=768' }
)

"=== r02-z2 run start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"exe_sha256=" + (Get-FileHash $exe -Algorithm SHA256).Hash

foreach ($c in $configs) {
  $label = "$label0-$($c.tag)"
  "---- $label at " + (Get-Date -Format 'HH:mm:ss')
  $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $scripts 'smoke.ps1'),
            '-Label', $label, '-Exe', $exe, '-Seconds', $sec, '-WorldSeconds', $world)
  if ($c.extra) { $argv += @('-Extra', $c.extra) }
  & (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe') @argv
  "$label EXIT=$LASTEXITCODE"
  Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 8
  "leftover=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
}
"=== r02-z2 run done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
