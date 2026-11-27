$ErrorActionPreference = 'Continue'
# r02-z3-run.ps1 — 按任务单固定顺序六跑（交替抵消漂移），600 s 世界窗
# tight 的四个键取 z2-memtight 运行日志里的 -Extra 原文：
#   VICTORY_MEMORY_CARD_MB=1536;VICTORY_KEEP_SNAPSHOTS_MB=64;VICTORY_INPLACE_MB=512;VICTORY_TEXTURE_BUDGET_MB=768
$root = 'G:\GTA\cool_fox-优化方案'
$scripts = Join-Path $root '10-实验脚本'
$exe = 'G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe'
$sec = 800
$world = 600
$tight = 'VICTORY_MEMORY_CARD_MB=1536;VICTORY_KEEP_SNAPSHOTS_MB=64;VICTORY_INPLACE_MB=512;VICTORY_TEXTURE_BUDGET_MB=768'

$configs = @(
  @{ tag = 'base-1';  extra = '' },
  @{ tag = 'tight-1'; extra = $tight },
  @{ tag = 'tight-2'; extra = $tight },
  @{ tag = 'base-2';  extra = '' },
  @{ tag = 'base-3';  extra = '' },
  @{ tag = 'tight-3'; extra = $tight }
)

"=== r02-z3 run start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"exe_sha256=" + (Get-FileHash $exe -Algorithm SHA256).Hash

foreach ($c in $configs) {
  $label = "z3-$($c.tag)"
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
"=== r02-z3 run done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
