$ErrorActionPreference = 'Continue'
# r02-z4-run.ps1 — 三（barrier 作用域）用现成诊断位做实测：VICTORY_BARRIER_TEST=groups 3 rep
$root='G:\GTA\cool_fox-优化方案'; $scripts=Join-Path $root '10-实验脚本'
$exe='G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe'
"=== r02-z4 run start " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"exe_sha256=" + (Get-FileHash $exe -Algorithm SHA256).Hash
foreach ($t in 'grp-1','grp-2','grp-3') {
  $label = "z4-$t"
  "---- $label at " + (Get-Date -Format 'HH:mm:ss')
  & (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe') -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'smoke.ps1') -Label $label -Exe $exe -Seconds 800 -WorldSeconds 600 -Extra 'VICTORY_BARRIER_TEST=groups'
  "$label EXIT=$LASTEXITCODE"
  Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 8
  "leftover=" + @(Get-Process | Where-Object { $_.ProcessName -match '^victory' }).Count
}
"=== r02-z4 run done " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')