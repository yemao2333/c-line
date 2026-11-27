# r02-a5 回填（probe = a3 + 台账素材 + S5）

task_id: `r02-a5` ｜ 执行侧：豆包 ｜ 2026-11-26 22:33:02–22:35:41

## 状态

```
脚本自检 16-ledger-probe.ps1 => 脚本自检通过 / BOM=EFBBBF
脚本自检 13-bench-ab.ps1    => 脚本自检通过 / BOM=EFBBBF
脚本自检 10-实验脚本\bench.ps1 => 脚本自检通过 / BOM=EFBBBF
脚本自检 12-页面文件.ps1    => 脚本自检通过 / BOM=EFBBBF
attempt 1: captured 5 / 5 lines
probe_done 22:35:41 leftover=1（清理后 0）
S5 = SKIP_S5（未跑：bench-v2.csv 不存在，且页面文件未扩）
```

## 数字

### E07 账本 5 行原文（attempt 1，`data\ledger-a1-1126-223308.err.log`）

```
L54:   2026-11-26T14:33:10.337106Z  INFO victory_gpu::list::thin: threads that translate lists (VICTORY_THIN_THREADS) threads=6
L63:   2026-11-26T14:33:10.424303Z  INFO victory_gpu::pipeline::make: pipeline workers workers=4
L258:  2026-11-26T14:33:11.093409Z  INFO victory_gpu::shadow: card buffer limits vram_budget_mb=7256 card_buffers_min_kb=64 card_buffers_max_mb=512
L283:  2026-11-26T14:33:11.501916Z  INFO victory_gpu::resource: the card's room kept for the render targets a world makes in its first frame (VICTORY_CARD_ROOM_FOR_TARGETS_MB) most_mb=3072
L8812: 2026-11-26T14:34:05.823024Z  INFO victory_gpu::shadow: the card's most title memory by address (VICTORY_MEMORY_CARD_MB) most_mb=4096 card_mb=6625
```

版本指纹判定（只陈述观测）：

| 项 | 观测 | 期望 |
| --- | --- | --- |
| `threads=` | 6 | 6 |
| `workers=` | 4 | 4 |
| `room most_mb=` | 3072 | 3072 |
| `card most_mb=` | 4096 | 4096 |
| `card_mb=` | 6625 | `*`（动态值） |
| `asked_mb=` | **该行未出现此字段** | 任务单期望 `asked_mb=None` |

> `asked_mb` 这一项：任务单要求 `asked_mb=None`，实测第 4 行原文里没有这个字段（行尾即 `most_mb=3072`）。按禁止事项 1/2，照抄原文并标出差异，不作补写。

### E08 世界内 `available_commit_mib` 最低值

```
L6355: 2026-11-26T14:33:48.693597Z  WARN victory_gpu::residency: host memory pressure: limiting texture prefetch and idle upload storage pid=18060 frame=1112 physical_free_mib=14952 available_commit_mib=3633 buffer_mirror_span_mib=174 texture_staging_mib=17 spare_scratch_mib=126 game_filled_gpu_texture_mib=693
```

全文仅 1 处 `available_commit_mib=`，故 `min = max = 3633`（n=1）。

### 守卫行（本次 probe 启动前）

```
commit_limit_gb=33.84 commit_used_gb=16.81 commit_free_gb=17.03
exe=<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe  bytes=49681038  written=2026-11-26 22:02:32
SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
```

### S5

```
SKIP_S5：`data\bench-v2.csv` 不存在（编排侧声明新增该文件，磁盘上未落）；页面文件亦未扩（Commit Limit 仍 33.84 GB）
```

## 证据路径

| 项 | 路径 |
| --- | --- |
| probe 控制台原文 | `data\r02-a5-probe.log` |
| attempt 1 原始日志（未裁剪，3,596,951 B / 13,730 行） | `data\ledger-a1-1126-223308.err.log` / `.log` |
| 自检用脚本 | `16-ledger-probe.ps1`、`13-bench-ab.ps1`、`10-实验脚本\bench.ps1`、`12-页面文件.ps1` |

## 异常

1. **attempt 1 结束残留 1 个进程**（脚本收尾后 `leftover=1`）；已按映像名清理，清理后计数 0。本条对应 P1-6 的同类现象，落 `leftover_procs` 时应记非 0。
2. `bench-v2.csv` 未落盘，S5 无法执行，E10 无观测值。
3. `asked_mb` 字段未出现在第 4 行原文。
