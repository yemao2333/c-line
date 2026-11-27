param(
  [string]$Claim = '',      # 认领的 task_id：把该行状态改成 进行中
  [string]$Done  = '',      # 完成回填：把该行状态改成 已回填
  [string]$Note  = '',      # 附注，写进心跳
  [string]$Artifact = ''    # 回填产物路径（配合 -Done）
)

# 工作台对接脚本（双方共用）。只动 工作台.md 的 §1 表格状态行与 §5 心跳，不改其它文件。
# 用法：
#   .\workbench.ps1                     看板：队列 + 心跳尾 + victory 进程数 + 待领取
#   .\workbench.ps1 -Claim r02-h1       认领
#   .\workbench.ps1 -Done r02-h1 -Artifact outbox\r02-h1.md   回填

$root = 'G:\GTA\cool_fox-优化方案\20-共创-C线'
$board = Join-Path $root '工作台.md'
if (-not (Test-Path $board)) { throw "找不到工作台：$board" }
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$procCount = @(Get-Process -Name victory -ErrorAction SilentlyContinue).Count
$stamp = (Get-Date -Format 'MM-dd HH:mm:ss')

function Show-Board {
  $lines = Get-Content $board -Encoding UTF8
  $i = ($lines | Select-String -Pattern '^## 1 ' | Select-Object -First 1).LineNumber
  $j = ($lines | Select-String -Pattern '^## 2 ' | Select-Object -First 1).LineNumber
  if ($i -and $j) { $lines[($i-1)..($j-2)] }
  '--- 心跳（末 5 行）---'
  $lines | Where-Object { $_ -match '^\d{2}-\d{2} \d{2}:\d{2}:\d{2} \|' } | Select-Object -Last 5
  '--- 环境 ---'
  "victory 进程数 = $procCount"
  $pending = @(Get-ChildItem (Join-Path $root 'inbox') -Filter 'task-*.md' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '_superseded' } | Sort-Object Name)
  '--- inbox 任务单（末 6 个，共 N 个）---'
  if ($pending.Count -eq 0) { '(空)' } else { "共 $($pending.Count) 个"; $pending | Select-Object -Last 6 | ForEach-Object { $_.Name } }
}

function Set-RowState([string]$id, [string]$state) {
  $txt = Get-Content $board -Raw -Encoding UTF8
  $pattern = '(\|\s*`' + [regex]::Escape($id) + '`\s*\|[^\n]*?\|\s*)([^|\n]+)(\s*\|)'
  $new = [regex]::Replace($txt, $pattern, { param($m) $m.Groups[1].Value + $state + $m.Groups[3].Value }, 1)
  if ($new -eq $txt) { "WARN: 没找到 $id 的状态行（原样未改）" } else { Set-Content -LiteralPath $board -Value $new -Encoding UTF8; "OK: $id -> $state" }
}

function Add-Heartbeat([string]$what) {
  $line = "$stamp | $who | $what | victory=$procCount"
  Add-Content -LiteralPath $board -Value $line -Encoding UTF8
  "heartbeat: $line"
}

$who = if ($env:WORKBENCH_WHO) { $env:WORKBENCH_WHO } else { $env:USERNAME }

if ($Claim) { Set-RowState $Claim "进行中（$who $stamp）"; Add-Heartbeat "claim $Claim $Note" }
if ($Done)  {
  $state = if ($Artifact) { "已回填（$Artifact）" } else { "已回填" }
  Set-RowState $Done $state
  Add-Heartbeat "done $Done $Note"
}
if (-not $Claim -and -not $Done) { Show-Board }

'--- 下一步 ---'
$claimable = @(Get-Content $board -Encoding UTF8 | Select-String -Pattern '`(r02-[A-Za-z0-9]+|task-\d+)`.*待领取')
if ($claimable.Count) { "可领取：" + (($claimable | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }) -join ' , ') } else { '队列里没有"待领取"的项。' }
if ($procCount -gt 0) { 'WARN: 有 victory 进程在跑，动手前先清到 0。' }
