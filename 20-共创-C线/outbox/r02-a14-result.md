# r02-a14 回填 · 管线册 + 预热（S1 BOOK 跑 → S2 warm → S3 再跑）

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0135-14.md`。只报数，不判读预热效果。

## A 前置守卫

| 项 | 值 | 出处 |
| --- | --- | --- |
| SHA256（release） | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` | `data\r02-a14-console.log` L1–L2 |
| 产物 | `target\release\victory.exe`（未用 diag） | 同 L3 |
| commit_limit_gb | 49.84 / commit_free_gb 38.08 | 同 L3 |
| 门禁 | ≥ 44，通过 | — |

## B 管线册计数与 S2 预热结果

| 字段 | 值 | 出处 |
| --- | --- | --- |
| book_before | 3 | console L4 |
| book_after_run | 5 | console L97 |
| book_after_warm | 5 | console L108 |
| warm_EXIT | 1 | console L99 |
| warm_elapsed | 1 s | console L99（未达 20 分钟，无中断） |
| warm 自述行 | `0 pipelines known, 0 made before (efb900b470e1ead1), 0 bad; 0 to make, 4 processes` | `data\r02-a14-warm.log` 倒数第 2 行 |
| warm 报错 | `Error: <系统找不到指定的路径。> (os error 3)` | 同末行；原文该行经 UTF-8/GBK 双重转码损坏，尖括号内为按 `os error 3` 的 Windows 默认文案还原，未转码原件见 `data\r02-a14-warm.raw.log` |

`r02-a14-warm.log` 末 6 行原文：

```text
2026-11-26T17:51:33.925232Z  INFO victory_gpu::tdr: GPU timeout detection (TdrLevel, TdrDelay, TdrDdiDelay) level=default delay=default ddi_delay=default
2026-11-26T17:51:33.925277Z  INFO victory_gpu::host: host wave lanes min=32 max=32
2026-11-26T17:51:33.961295Z  INFO victory_gpu::host: host D3D12 device ready
2026-11-26T17:51:33.961455Z  INFO victory_gpu::descriptor::host: host view heaps hold 1000000 views; view indices are clamped to the null slot at the end from the first shader on views=1000000 raw_twins=false
0 pipelines known, 0 made before (efb900b470e1ead1), 0 bad; 0 to make, 4 processes
Error: 缁崵绮洪幍鍙ョ瑝閸掔増瀵氱€规氨娈戠捄顖氱窞閵?(os error 3)
```

## C S1 / S3 两行（`data\bench-v2.csv` L20–L21，原样）

```csv
2026-11-27 01:51:30,R8-before-book,200,40,ms>40&draws>=200,32,267.8,4948,20.89,3.8,12.36,0,run-R8-before-book-1127-014722.log
2026-11-27 01:55:44,R8-after-warm,200,40,ms>40&draws>=200,32,256.1,4710,20.82,4.17,12.69,0,run-R8-after-warm-1127-015134.log
```

| 组 | `-Extra` | world_samples | median_ms_world | median_draws | max_priv_gb | min_free_gb | min_commit_free_gb | leftover_procs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R8-before-book（S1） | `VICTORY_PIPELINE_BOOK=1` | 32 | 267.8 | 4948 | 20.89 | 3.8 | 12.36 | 0 |
| R8-after-warm（S3） | （无） | 32 | 256.1 | 4710 | 20.82 | 4.17 | 12.69 | 0 |

## D 卡顿口径（任务单脚本输出原文）

```text
R8-before-book: world_n=32 gt200=32 gt400=1
R8-after-warm: world_n=32 gt200=32 gt400=0
```

附加（同一批采样、同口径 max ms）：`R8-before-book: max_ms=578.8`、`R8-after-warm: max_ms=399.2`。

## E 收尾

| 项 | 值 |
| --- | --- |
| S1_exit / S3_exit | 0 / 0 |
| leftover_after_group | 0（console L200 附近） |
| final_procs | 0 |
| 步骤时刻 | S1 01:47:22 → S2 01:51:33（1 s）→ S3 01:51:34 → done 01:55:57 |

## F 日志与编码

1. `data\r02-a14-console.log`（UTF-8）：80 条采样行（两组各 40）与两段 median 行已按行混合解码复原；未转码原件 `data\r02-a14-console.raw.log`。
2. `data\r02-a14-warm.log`（UTF-8）：未转码原件 `data\r02-a14-warm.raw.log`。
3. 缓存目录 `G:\GTA\victory-data\coolfox-cache` 既有内容未删改；仅 `VICTORY_PIPELINE_BOOK=1` 与 `warm` 自身写入使 pipelines 计数 3 → 5。

## G 未改动项

1. `data\bench-v2.csv` 仅追加 L20–L21；L1–L19 未动；`data\bench.csv` L1–12 未动。
2. 未改源码 / `Cargo.toml` / `.cargo\config.toml` / `rust-toolchain.toml`；未覆盖 release / baseline；未用 diag；未开 `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES`。
3. runner 脚本 `r02-a14-run.ps1`（UTF-8 带 BOM，`Parser::ParseFile` 0 错）。
