# r02-z3 回填 · 唯一候选钉死 + 新判据基线

> 执行端本机 Windows。任务单 `inbox\task-20261127-1250-27.md`。六跑严格按 `z3-base-1 → z3-tight-1 → z3-tight-2 → z3-base-2 → z3-base-3 → z3-tight-3` 顺序执行（12:48:16–14:07:54），六次全 `SMOKE=PASS`、`leftover_procs=0`、无早退、无重跑。只报数、不判读；三处代码改动未动（BLOCK）。

## 0 tight 的四个键（-Extra 原文，取自 `z2-memtight` 运行日志）

任务单给的键名为 `VICTORY_CARD_ROOM_FOR_TARGETS_MB` / `VICTORY_CARD_BUFFERS_MIN_KB` / `VICTORY_SNAPSHOT_POOL_MB` / `VICTORY_KEEP_SNAPSHOTS_MB`；按任务单「若 z2 实际用的是别的键名/顺序，以 z2 那次运行日志里 `-Extra` 的原文为准」，本次采用 z2 原文：

```text
VICTORY_KEYS=25:Enter,30:Enter,35:Enter,40:Enter,45:Space;VICTORY_MEMORY_CARD_MB=1536;VICTORY_KEEP_SNAPSHOTS_MB=64;VICTORY_INPLACE_MB=512;VICTORY_TEXTURE_BUDGET_MB=768
```

（出处：`data\r02-z2-run.log` 中 `z2-memtight-1` / `z2-memtight-2` 两行 `extra=`，逐字未改。）

## 1 六行 csv 原文（`data\bench-v3.csv` L23–L28，600 s 窗、`-Seconds 800`）

```text
L23 2026-11-27 13:01:28,z3-base-1,600,800,113,80,101,ms>40&draws>=200,249.2,4262,20.07,2.48,8.65,0,run-z3-base-1-1127-124958.log
L24 2026-11-27 13:14:44,z3-tight-1,600,800,111,69,101,ms>40&draws>=200,246.3,4180,17.63,2.54,11.18,0,run-z3-tight-1-1127-130329.log
L25 2026-11-27 13:28:04,z3-tight-2,600,800,113,80,101,ms>40&draws>=200,243.9,4193,17.66,2.67,11.27,0,run-z3-tight-2-1127-131637.log
L26 2026-11-27 13:41:24,z3-base-2,600,800,113,80,101,ms>40&draws>=200,244.1,4330,20.23,3.17,8.65,0,run-z3-base-2-1127-132957.log
L27 2026-11-27 13:54:35,z3-base-3,600,800,113,80,101,ms>40&draws>=200,252.7,4350,20.49,3.1,8.39,0,run-z3-base-3-1127-134308.log
L28 2026-11-27 14:07:43,z3-tight-3,600,800,111,68,101,ms>40&draws>=200,240.2,4200,18.35,3.09,10.47,0,run-z3-tight-3-1127-135628.log
```

## 2 每 draw µs（`median_ms_world*1000/median_draws`，2 位）

| 组 | rep1 | rep2 | rep3 | 区间 | 均值 |
| --- | --- | --- | --- | --- | --- |
| base | 58.47（249.2/4262） | 56.37（244.1/4330） | 58.09（252.7/4350） | **56.37 – 58.47** | 57.64 |
| tight | 58.92（246.3/4180） | 58.17（243.9/4193） | 57.19（240.2/4200） | **57.19 – 58.92** | 58.09 |

## 3 内存两组

| 组 | max_priv_gb（rep1/2/3） | 区间 | 均值 | min_commit_free_gb（rep1/2/3） | 区间 | 均值 | min_free_gb（rep1/2/3） |
| --- | --- | --- | --- | --- | --- | --- | --- |
| base | 20.07 / 20.23 / 20.49 | 20.07 – 20.49 | 20.26 | 8.65 / 8.65 / 8.39 | 8.39 – 8.65 | 8.56 | 2.48 / 3.17 / 3.1 |
| tight | 17.63 / 17.66 / 18.35 | 17.63 – 18.35 | 17.88 | 11.18 / 11.27 / 10.47 | 10.47 – 11.27 | 10.97 | 2.54 / 2.67 / 3.09 |

draws（median）：base 4262 / 4330 / 4350；tight 4180 / 4193 / 4200。`world_samples` 六行均 101，`world_from_s` 80 / 69 / 80 / 80 / 80 / 68。

## 4 两问（只给数字与重叠判定）

**问 1：两组 µs/draw 区间是否零重叠？**

```text
base  [56.37, 58.47]      tight [57.19, 58.92]
⇒ 有重叠（重叠段 57.19 – 58.47）
两点估计差：58.09 − 57.64 = +0.45 µs，即 +0.78%
```

**问 2：两组峰值私有与 `min_commit_free` 的区间是否零重叠？**

```text
max_priv_gb        base [20.07, 20.49]   tight [17.63, 18.35]  ⇒ 零重叠（间隙 1.72 GB）
min_commit_free_gb base [ 8.39,  8.65]   tight [10.47, 11.27]  ⇒ 零重叠（间隙 1.82 GB）
min_free_gb        base [ 2.48,  3.17]   tight [ 2.54,  3.09]  ⇒ 有重叠
```

按任务单新判据的两条（① µs/draw 区间零重叠 ② 两点估计差 ≥8%）逐条对照的事实：①**不满足**（有重叠）；②**不满足**（+0.78% < 8%）；内存两项①**满足**（零重叠，差 2.38 GB / 2.41 GB 均值口径），但内存不在新判据的判定对象内（判据只写 µs/draw）。

## 5 与 z2 同组读数并列（同口径、均 600 s 窗）

| 组 | z2 两行 µs | z3 三行 µs | z2 两行 max_priv | z3 三行 max_priv | z2 两行 min_commit |
| --- | --- | --- | --- | --- | --- |
| base（z2 为 `z2-base-1/2`） | 61.48 / 57.08 | 58.47 / 56.37 / 58.09 | 20.45 / 20.31 | 20.07 / 20.23 / 20.49 | 9.95 / 10.02 |
| tight（z2 为 `z2-memtight-1/2`） | 55.45 / 56.86 | 58.92 / 58.17 / 57.19 | 18.19 / 18.28 | 17.63 / 17.66 / 18.35 | 12.05 / 11.73 |

## 6 红线核对

| 项 | 结果 |
| --- | --- |
| 三处代码改动（barrier 合并 / descriptor 折叠 / draw 合并） | **未动**（BLOCK 生效） |
| 改源码 / 编译 | 未做；`host.rs` mtime 仍 `2026-11-27 05:08:31` |
| 改判据 / 改脚本 | 未改 `smoke.ps1` / `bench.ps1` / `auto-enter.ps1`；新增 `r02-z3-run.ps1` 只串跑 |
| 台账 | `bench-v3.csv` 22 → 28 行（仅追加 L23–L28）；`bench-v2.csv` 22 行、`bench.csv` 12 行未动 |
| exe | `victory.exe` `4230CCF9…`、`victory-pre-e3.exe` `58E60D62…`、`victory-baseline.exe` `9627DF10…` 均未覆盖 |
| `victory-data` 缓存 | 本端未执行写/删命令（六次运行自身写 `host-pipelines.bin` 等属被测进程行为） |
| 早退 / 重跑 | 无（6/6 `SMOKE=PASS`，`leftover_procs=0`，`procs=0`） |
| 并发 | 全程单局串跑 |
| 结论 | 未写"有效/无效" |

## 7 日志

`data\r02-z3-run.log`（六跑全程，1,276+ 行）、`data\run-z3-base-1|tight-1|tight-2|base-2|base-3|tight-3-1127-*.log`（逐 5 s 采样）、`data\auto-z3-*-preflight-*.log`（预检）。
