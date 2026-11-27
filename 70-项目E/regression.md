# 项目 E · 回归自测一页（每次改动后照这个跑）

## 一条命令

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File <ROOT>\cool_fox-优化方案\10-实验脚本\smoke.ps1 -Label smoke-01
```

默认：`-Exe target\release\victory.exe`、`-Seconds 420`、`-WorldSeconds 200`、`-MinWorldSamples 25`，先跑 `auto-enter.ps1` 预检（默认 150 s，进世界后 10 s 收），再跑 `13-bench-ab.ps1 -Profile fork -WorldSeconds 200`（内部即 `bench.ps1`，判据全在 `bench.ps1`，smoke 不复制任何过滤/中位逻辑）。

退出码：`SMOKE=PASS` → 0；任一断言失败 → 1，并在 `SMOKE=FAIL failed_asserts=…` 里列出失败项。

## 可传参数（e2 起）

| 参数 | 默认 | 作用 |
| --- | --- | --- |
| `-Keys` | `25:Enter,30:Enter,35:Enter,40:Enter,45:Space` | 注入 `VICTORY_KEYS`；**预检段与 bench 段都要有**，缺了 bench 段会整段停在菜单（`draws=8`、`world_from_s` 空、`world_samples=0`） |
| `-Extra` | 空 | 追加给 `13-bench-ab.ps1` 的环境变量，分号分隔，如 `"VICTORY_SETTLE_ROOM=1"`；实际注入串会在 console 里以 `extra=…` 原样打印 |
| `-SkipPreflight` | 关 | 跳过 `auto-enter` 预检（只在确认能自己进世界时用） |

## 看哪 4 个数

`smoke.ps1` 从 `data\bench-v3.csv` 最后一行读，不重算：

| # | 字段 | 通过线 |
| --- | --- | --- |
| 1 | `world_samples` | ≥ 25 |
| 2 | `median_ms_world` | 有值；且不超过基线 **+10%** |
| 3 | `median_draws` | 有值 |
| 4 | `leftover_procs` | = 0（另有 `post_run_leftover=0`） |

## 什么算回归

**`median_ms_world` 超过基线 10%** 即记回归；其余三项是硬门禁（任一项不满足直接判红）。

基线取值（同一个口径、同 200 s 世界窗、同 fork 环境）：

| 基线来源 | label | median_ms_world | median_draws | world_samples | 位置 |
| --- | --- | --- | --- | --- | --- |
| 项目 B 新口径控制组 | `R10-control` | 250.2 | 4030 | 35 | `data\bench-v3.csv` L2 |
| 旧口径最近一条控制组 | `R6-control` | 268 | 4679 | 30 | `data\bench-v2.csv` L12 |
| round-02 最终一条 | `R9-after-warm2` | 298.5 | 3205 | 32 | `data\bench-v2.csv` L22 |

回归线（+10%，按 `R10-control` 250.2 计）：`median_ms_world ≤ 275.2` 为不回归；> 275.2 记回归。换基线时把这条重算，别改算法。

## 跑之前的三条硬约束

1. `commit_limit_gb ≥ 44`（页面文件 C: 2048 + G: 16384/32768）；smoke 会自己打印，低于 44 直接判红。
2. 不许并发两局；跑前 `^victory` 残留必须为 0（smoke 会清并在结尾复核 `post_run_leftover`）。
3. 不许开 `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES`；不许用 diag 产物当性能对照。

## 出问题先看哪

| 现象 | 先看 |
| --- | --- |
| `preflight_entered` 失败 | `data\e2-*` 或 `data\auto-*-<stamp>.log` 的标题序列；`VICTORY_KEYS` 是否在 120 s 内按下（键表见 `gameinput.rs:1254`） |
| `world_samples` 不足 | `data\run-<label>-*.log`；窗口是否在 200 s 内被进程退出打断 |
| 中位数空/0 | 该组是否整段停在菜单（`draws` 一直 < 200） |
| `leftover_procs≠0` | `Get-Process ^victory`；`victory-baseline.exe` 也会被算进来 |
