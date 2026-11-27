# r02-a15 回填 · 修正预热（BOOK 跑 → CloseMainWindow → warm 无 --used → 再跑）

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0205-15.md`。只报数，未判读预热效果。

## A 守卫

| 项 | 值 | 出处 |
| --- | --- | --- |
| SHA256（release） | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` | console L2 |
| 产物 | `target\release\victory.exe`（未用 diag） | console L2 |
| commit_limit_gb / commit_free_gb | 49.84 / 37.90（≥ 44，通过） | console L3 |

## B S1 —— BOOK 跑 200 s 与优雅关闭

| 字段 | 值 | 出处 |
| --- | --- | --- |
| pid | 6584 | console L6 |
| title_before_close | `Americas | VIctory 4 fps 253.0 ms/frame 5204 draws/frame` | console L7 |
| clean_exit | False | console L8 |
| waited_s | 60 | console L8 |
| title_at_giveup | （空串） | console L9 |
| after_close: leftover | 1 | console L11 |
| S1 时刻 | 02:00:42 起跑，02:05:05 结束 | console L5 / L12 |

`clean_exit=False` 的含义按原样：`CloseMainWindow()` 后轮询 60 次（每次 1 s）进程仍在，窗口标题已为空串；随后 `Stop-Process -Force` 收尾，`leftover=1`。

## C 册字节数（原样）

| 时点 | `known-pipelines.bin` 大小 | 出处 |
| --- | --- | --- |
| before | 50326544 | console L4 |
| after_close | 50326544 | console L10 |
| after_warm | 50326544 | console L16 |

## D S2 —— `victory warm --jobs 4`（不带 `--used`，不带 `--again`）

| 字段 | 值 |
| --- | --- |
| warm_EXIT | -1（进程被中断，非自然退出） |
| warm_elapsed | 1215 s |
| 中断点 | 进度行 `14000 of 83581, 1150 s` 之后；执行端按 20 分钟上限 kill，4 个 worker 一并收掉 |
| warm_line（原文） | `83581 pipelines known, 0 made before (efb900b470e1ead1), 0 bad; 83581 to make, 4 processes` |
| known_pipelines_head32 | `33000000884f148a67b0e3ae9f8b708c416551040105eaaf3a4f6c87b0803581` |

`data\r02-a15-warm.log` 全文（408 B）：

```text
83581 pipelines known, 0 made before (efb900b470e1ead1), 0 bad; 83581 to make, 4 processes
1000 of 83581, 157 s
2000 of 83581, 289 s
3000 of 83581, 395 s
4000 of 83581, 467 s
5000 of 83581, 538 s
6000 of 83581, 613 s
7000 of 83581, 682 s
8000 of 83581, 756 s
9000 of 83581, 823 s
10000 of 83581, 891 s
11000 of 83581, 957 s
12000 of 83581, 1026 s
13000 of 83581, 1086 s
14000 of 83581, 1150 s
```

## E S3 —— `R9-after-warm2`（200 s，fork）

`data\bench-v2.csv` L22 原样：

```csv
2026-11-27 02:29:32,R9-after-warm2,200,40,ms>40&draws>=200,32,298.5,3205,20.46,3.06,11.78,0,run-R9-after-warm2-1127-022521.log
```

| 项 | 值 |
| --- | --- |
| samples | 40 |
| world_samples | 32（filter v2：`ms>40&draws>=200`） |
| median_ms_world | 298.5 |
| median_draws | 3205 |
| max_priv_gb / min_free_gb / min_commit_free_gb | 20.46 / 3.06 / 11.78 |
| leftover_procs | 0 |
| S3_exit | 0 |
| final_procs | 0 |
| runlog | `run-R9-after-warm2-1127-022521.log` |

卡顿口径（从 console 40 条采样行复算，世界段 `ms>40 且 draws>=200`）：

```text
R9-after-warm2: world_n=32 gt200=32 gt400=2 max_ms=521.8 max_draws=6557
```

世界段最慢 6 条（t / ms / draws）：

| t | ms | draws |
| --- | --- | --- |
| 63 | 521.8 | 1651 |
| 118 | 448.5 | 1149 |
| 81 | 394.1 | 2972 |
| 130 | 380.4 | 5019 |
| 57 | 364.5 | 2779 |
| 75 | 342.4 | 1617 |

## F 日志清单与已知编码瑕疵

1. `data\r02-a15-console.log`（runner 全过程；S3 的 40 条采样行为 `t=…s fps=… ms=… draws=…`）。末段 `median_ms_world = …` 一行的中文（`（filter v2，…条世界样本，中位 draws=…）`）在内层 PS 5.1 的 GBK 输出被 UTF-8 二次解码后丢失，只剩替换字符；该行数字与字段名完好，权威值以 `data\bench-v2.csv` L22 为准。
2. `data\r02-a15-console.err.log`（空）。
3. `data\r02-a15-book.log`（1035 B）/ `r02-a15-book.err.log`（S1 的 stdout/stderr；err 末 4 行为 `WARN victory_gpu::descriptor::host` / `texback` / `draw` 类告警原文）。
4. `data\r02-a15-warm.log`（408 B）；`data\run-R9-after-warm2-1127-022521.log` + `.err.log`。

## G 未改动项

1. `data\bench-v2.csv` 仅追加 L22；L1–L21 未动；`data\bench.csv` 未动。
2. 缓存目录 `G:\GTA\victory-data\coolfox-cache\pipelines` 既有文件未删改；`known-pipelines.bin` 三次读数均为 50326544。
3. 未改源码 / `Cargo.toml` / `.cargo\config.toml` / `rust-toolchain.toml`；未覆盖 release / baseline；未用 diag；未开 `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES`；未并发两局。
4. runner 脚本 `r02-a15-run.ps1`（UTF-8 带 BOM，`Parser::ParseFile` 0 错）。
