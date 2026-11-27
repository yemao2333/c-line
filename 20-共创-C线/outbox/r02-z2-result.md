# r02-z2 回填 · 四条优化项（机器侧落地）

> 执行端本机 Windows。任务来源：用户口头指令（"把这4条做了"），对应 `11-27` 对话中给出的四条：①warm 全量 ②每 draw 成本 ③draws/帧 ④内存参数。②③ 的代码级改造不属执行端（不改源码），故机器侧用**现成批处理开关做对照**给出量化，代码级需求另出交接单 `handoff-20261127-优化四条-交接.md`。全部只报数、不判读。

## ① warm 全量（已完成）

| 项 | 值 |
| --- | --- |
| 命令 | `victory.exe warm --jobs 4`（cwd `cool_fox-main`，env 与 a15 同一组） |
| `warm_EXIT` | 0 |
| 耗时 | 4,238 s（1 h 10 min 38 s） |
| 起始读数 | `known=50,326,544` / `host=148,201,324` / `warm-done=14,888 行`（744,400 B） |
| 本次日志首行 | `83581 pipelines known, 14888 made before (efb900b470e1ead1), 0 bad; 68693 to make, 4 processes` |
| 本次制得 | 68,693 条（末行：`68693 made in 4236 s (24 have no host pipeline, 0 ended their process)`） |
| 单条耗时分布 | median 3.1 ms、p90 529.8 ms、p99 3,099.8 ms、max 19,743 ms、sum 12,517 s |
| 完成后读数 | `warm-done=83,581 行`（4,179,050 B）；`slow-pipelines.txt` 54,111 → 191,121 B；`host-pipelines.bin` 148,201,324（未增，mtime 仍 09:22:09） |
| 缓存总量 | `victory-data` 文件 26,756 → 26,809，字节 1,614,149,512 → 1,619,629,981（+5,480,469） |

日志：`data\r02-z2-warm.log`（`1000 … 68000` 全程进度行 + 末行汇总）。

## ② 每 draw 成本 & ③ draws/帧：批处理开关对照（零代码）

对照对象是运行时默认已开的 `VICTORY_INDIRECT_BATCH=2` 与 `VICTORY_JOIN_COPIES=1`；off 组把二者置 0。口径：warm 全量之后的暖态，600 s 世界窗、每组 2 次。

| csv 行 | label | env 差异 | median_ms_world | median_draws | µs/draw | world_samples |
| --- | --- | --- | --- | --- | --- | --- |
| L17 | `z2-base-1` | 默认 | 258.4 | 4203 | 61.48 | 101 |
| L18 | `z2-base-2` | 默认 | 236.9 | 4150 | 57.08 | 101 |
| L19 | `z2-batchoff-1` | `INDIRECT_BATCH=0`、`JOIN_COPIES=0` | 257.7 | 4300 | 59.93 | 101 |
| L20 | `z2-batchoff-2` | 同上 | 253.3 | 4303 | 58.87 | 101 |
| L21 | `z2-memtight-1` | 默认批处理 + 内存收紧 | 232.5 | 4193 | 55.45 | 101 |
| L22 | `z2-memtight-2` | 同上 | 237.1 | 4170 | 56.86 | 101 |

同组两 rep 之间的差：默认组 258.4 vs 236.9（差 21.5 ms，8.3%）；batchoff 组 257.7 vs 253.3（差 4.4 ms，1.7%）；memtight 组 232.5 vs 237.1（差 4.6 ms，1.9%）。

draws 观测：默认 4,150 / 4,203；batchoff 4,300 / 4,303（+3.4% / +2.5%）；memtight 4,170 / 4,193。**关闭批处理后 draws 未下降、帧时未上升**；两组实测的 4,150–4,303 区间内，µs/draw 与帧时同向变动（帧时 232.5–258.4 对应 55.45–61.48 µs）。

## ④ 内存参数收紧（零代码，env 四键）

收紧组 env：`VICTORY_MEMORY_CARD_MB=1536`、`VICTORY_KEEP_SNAPSHOTS_MB=64`、`VICTORY_INPLACE_MB=512`、`VICTORY_TEXTURE_BUDGET_MB=768`（对应默认由 `Start-GTA6.cmd` 注释给出的 2048 / 128 / 1024 / 1024）。

| csv 行 | label | max_priv_gb | min_free_gb | min_commit_free_gb | median_ms_world | median_draws |
| --- | --- | --- | --- | --- | --- | --- |
| L17 | `z2-base-1` | 20.45 | 2.06 | 9.95 | 258.4 | 4203 |
| L18 | `z2-base-2` | 20.31 | 1.78 | 10.02 | 236.9 | 4150 |
| L19 | `z2-batchoff-1` | 20.3 | 2.25 | 9.79 | 257.7 | 4300 |
| L20 | `z2-batchoff-2` | 20.59 | 2.75 | 9.53 | 253.3 | 4303 |
| L21 | `z2-memtight-1` | **18.19** | 3.24 | 12.05 | 232.5 | 4193 |
| L22 | `z2-memtight-2` | **18.28** | 3.06 | 11.73 | 237.1 | 4170 |

默认组四行 `max_priv_gb` 20.30–20.59；收紧组两行 18.19 / 18.28（差 −2.11 / −2.03 GB）。`min_commit_free_gb` 默认组 9.53–10.02，收紧组 11.73 / 12.05（差 +1.71 / +2.10 GB）。`min_free_gb` 默认组 1.78–2.75，收紧组 3.06 / 3.24。

## 台账写入

| 台账 | 变化 |
| --- | --- |
| `data\bench-v3.csv` | 16 → 22 行（追加 L17–L22，`world_seconds=600`、`cap_seconds=800`；200 s 旧行未动） |
| `data\bench-v2.csv` | 22 行未动 |
| `data\bench.csv` | 12 行未动（冻结） |
| `80-最终交付.md` | 追加 `### 7.6 z2 · 四条优化项机器侧读数`（只抄表，不含结论） |
| 日志 | `data\r02-z2-warm.log`、`data\r02-z2-run.log`、`data\run-z2-*.log` 6 份、`data\auto-z2-*-preflight-*.log` 6 份 |

## 四条各自的状态

| 条 | 机器侧状态 | 交付位置 |
| --- | --- | --- |
| ① warm 全量 | **已跑完**（83,581 / 83,581，`warm_EXIT=0`） | 本文件 §① |
| ② 每 draw 成本 | **已量化对照**（批处理 off/on 六行，55.45–61.48 µs）；代码级合并需求交代码侧 | 本文件 §②③ + `handoff-20261127-优化四条-交接.md` §1 |
| ③ draws/帧 | **已量化对照**（draws 4,150–4,303，关批处理未下降）；代码级合并需求交代码侧 | 同上 §2 |
| ④ 内存参数 | **已量化对照**（`max_priv_gb` 20.30–20.59 → 18.19 / 18.28） | 本文件 §④ |

## 红线核对

| 项 | 结果 |
| --- | --- |
| 改源码 / 编译 | **均未**；`host.rs` mtime 仍 05:08:31 |
| 改脚本 / 改判据 | 未改 `smoke.ps1`、`bench.ps1`、`auto-enter.ps1`；新增 `r02-z2-run.ps1` 只串跑 |
| 覆盖 exe | 未覆盖：`victory.exe` `4230CCF9…`、`victory-pre-e3.exe` `58E60D62…`、`victory-baseline.exe` `9627DF10…` |
| `policy.rs` / `rust-toolchain.toml` / `victory-shader` | 未触碰 |
| 进程 | 六组收尾 `leftover=0`、最终 `procs=0` |
| 并发 | 全程单局串跑，未并发 |
| `victory-data` | 仅 warm 与六次运行自身写入（§① 有前后读数），本端未删改 |
| 判读 | 未写"快/慢/有效/无效"结论 |
