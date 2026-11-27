# r02-a11 回填 · 世界内 GPU 时间按 pipeline 归因（420 s，diag 产物）

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0058-11.md`。只回填数字与整行原文，不判读、不解释 pipeline 哈希。

## A 任务单核对

| 项 | 要求 | 实际 |
| --- | --- | --- |
| 产物 | 同一份 `target\diag\victory.exe`，SHA `710857B5…15DA7C7D5` | `SHA256_diag=710857B58C00BA3E1AB71141DE1C23ED039A156AFEB78B7AC3CFB0115DA7C7D5`，一致 |
| 环境 | 任务单 20 个 fork 变量 + `VICTORY_LOG=info` + `VICTORY_GPU_TIMING=1`，`VICTORY_TIMELINE` 已移除 | 逐条照单设置，见本节末清单 |
| 时长 | 420 s，每 10 s 记一次标题 | `titles_count=42`，`gone_at_s=0`（未早退） |
| 禁项 | 不开 `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES` | 两项先 `Remove-Item Env:` 再启动 |
| sleep 循环 | 不得缩短 | 固定 `Start-Sleep -Seconds 10` × 42 |
| 收尾 | `^victory` 正则 + 计数 | 见 §B 的 `leftover_*` 三项 |

## B 运行数字

| 字段 | 值 | 出处 |
| --- | --- | --- |
| pid | 11884 | `data\r02-a11-console.log`（`pid=11884`） |
| start / done | 2026-11-27 00:55:32 / 01:02:44 | 同文件首末行 |
| titles_count | 42 | 同文件 |
| gone_at_s | 0 | 同文件 |
| err_bytes | 6574020 | 同文件（`err_bytes=6574020`） |
| out_bytes | 1035 | 同文件 |
| leftover_before_kill | 1 | 同文件 |
| leftover_after_kill | 1（kill 后 2 s 计数） | 同文件 |
| leftover 复核（本次查询时） | 0 | `Get-Process -Name ^victory` |
| by_what_ran_hits | 809 | 对 `.err.log` 计 `the card's time by what ran` |
| ms a frame ≥ 100 的条数 | 13 | 同一批 809 条按数值筛 |
| ms a frame 最大值 | 454.1（L21233） | 同上 |
| settles_hits | 0 | `of the waiting for the card in settles` 字面计数 |
| thin_hits | 0 | `list calls translated by threads of ours per frame` 字面计数 |

环境变量（照任务单设置，子进程继承）：`VICTORY_AMBIENT_AIR=1.5`、`VICTORY_CACHE_DIR=G:\GTA\victory-data\coolfox-cache`、`VICTORY_DATA_DIR=G:\GTA\victory-data\coolfox-data`、`VICTORY_TEXTURE_NO_WAIT=1`、`VICTORY_RELAY=2`、`VICTORY_WIDE_BACK=1`、`VICTORY_CARD_REHASH_RUNS=1`、`VICTORY_JOIN_COPIES=1`、`VICTORY_INDIRECT_WINDOW=1`、`VICTORY_RELAY_COPY=1`、`VICTORY_CARD_STEPS=2`、`VICTORY_INDIRECT_BATCH=2`、`VICTORY_MAP_THREADS=1`、`VICTORY_CARD_AWAKE=1`、`VICTORY_SHOW_AFTER=1`、`VICTORY_AMBIENT=0.8`、`VICTORY_THIN=1`、`VICTORY_JOIN_PARTS=6`、`VICTORY_UPLOAD_AHEAD=1`、`VICTORY_LEVELS_ON_DEMAND=1`、`VICTORY_CARD_BUFFERS_MIN_KB=64`、`VICTORY_LOG=info`、`VICTORY_GPU_TIMING=1`。

## C 窗口标题（每 10 s 采样，末 3 条）

```text
400s|Americas | VIctory 3 fps 397.2 ms/frame 5457 draws/frame
410s|Americas | VIctory 2 fps 555.4 ms/frame 5410 draws/frame
420s|Americas | VIctory 3 fps 389.2 ms/frame 3238 draws/frame
```

进世界依据：42 条采样中带 `draws/frame` 的 42 条，其中 > 1000 的 36 条；draws 最小 4、最大 6886。

## D `by what ran` 整行原文

### D-1 末 5 条（按日志顺序，来自最后一次报告块）

```text
L21724: 2026-11-26T17:02:35.333832Z  INFO victory_gpu::copystat:   the card's time by what ran: 10.6 ms a frame in 0.1 submissions a frame: 14 lists, pipelines {"[compute 03c01507703d7449]", "[compute 04be1ad677ff1627]", "[compute 05e074ad67e0d6d6]", "[compute 0fc1b11eb36efdb2]", "[compute 119ee96f602f1668]", "[compute 11bbed94ee7a3243]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 291822a279c07067]", "[compute 2b17036bf3a1d615]", "[compute 2bfdc19dc1f25b3a]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 488b12f581b37bfc]", "[compute 4996d173208d83eb]", "[compute 4edee813f
L21725: 2026-11-26T17:02:35.333917Z  INFO victory_gpu::copystat:   the card's time by what ran: 10.6 ms a frame in 0.1 submissions a frame: 16 lists, pipelines {"[compute 03c01507703d7449]", "[compute 052a2316a03b9ba1]", "[compute 0560ac646b358460]", "[compute 05e074ad67e0d6d6]", "[compute 119ee96f602f1668]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 497f59fd986aaebb]", "[compute 51e19585b4753814]", "[compute 528278df1274cb33]", "[compute 55c46e739fa0796a]", "[compute 5e436c09d90ed218]", "[compute 647443e8b7b68415]", "[compute 6a6c7b7fd
L21726: 2026-11-26T17:02:35.334004Z  INFO victory_gpu::copystat:   the card's time by what ran: 10.5 ms a frame in 0.1 submissions a frame: 7 lists, pipelines {"[compute 03c01507703d7449]", "[compute 17af85f170e66f30]", "[compute 32aa8384586e0f12]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 528278df1274cb33]", "[compute 55c46e739fa0796a]", "[compute 6a6c7b7fde59134f]", "[compute 80a0178d3a9d8d12]", "[compute 85dea520c893a3d9]", "[compute 8b437ab61d8008fe]", "[compute 8cbd7f5b9ce7530c]", "[compute 8e614708143ef917]", "[compute 8fb5e4aa9c542c3f]", "[compute 92c12c7a7d607a9a]", "[compute ba578b59c8c28a57]", "[compute c99e30956be0deaf]", "[compute f46117391dd81461]", "[compute f5ab5dcf95536794]", "[compute f7fc6c9844
L21727: 2026-11-26T17:02:35.334087Z  INFO victory_gpu::copystat:   the card's time by what ran: 10.4 ms a frame in 0.1 submissions a frame: 18 lists, pipelines {"[compute 03c01507703d7449]", "[compute 04be1ad677ff1627]", "[compute 052a2316a03b9ba1]", "[compute 0560ac646b358460]", "[compute 05e074ad67e0d6d6]", "[compute 119ee96f602f1668]", "[compute 11bbed94ee7a3243]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 291822a279c07067]", "[compute 2b17036bf3a1d615]", "[compute 2bfdc19dc1f25b3a]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 488b12f581b37bfc]", "[compute 497f59fd9
L21728: 2026-11-26T17:02:35.335238Z  INFO victory_gpu::copystat:   the card's time by what ran: 10.3 ms a frame in 0.1 submissions a frame: 5 lists, pipelines {"[compute 03c01507703d7449]", "[compute 05e074ad67e0d6d6]", "[compute 119ee96f602f1668]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 51e19585b4753814]", "[compute 528278df1274cb33]", "[compute 55c46e739fa0796a]", "[compute 5e436c09d90ed218]", "[compute 647443e8b7b68415]", "[compute 6a6c7b7fde59134f]", "[compute 78f54f95839e3adf]", "[compute 80a0178d3a9d8d12]", "[compute 84cab31295
```

### D-2 `ms a frame ≥ 100` 的 13 条（按数值取前 3 条整行）

13 条行号与数值：L21233=454.1、L21371=216.2、L17685=192.5、L17976=187.2、L17556=173.1、L21234=135.1、L19239=133.8、L17316=127.8、L20014=127.1、L19098=125.8、L18813=118.7、L21717=101.9、L19540=100.1。

```text
L21233: 2026-11-26T17:02:16.787244Z  INFO victory_gpu::copystat:   the card's time by what ran: 454.1 ms a frame in 0.8 submissions a frame: 7 lists, pipelines {"[compute 03c01507703d7449]", "[compute 05e074ad67e0d6d6]", "[compute 119ee96f602f1668]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 51e19585b4753814]", "[compute 528278df1274cb33]", "[compute 55c46e739fa0796a]", "[compute 5e436c09d90ed218]", "[compute 647443e8b7b68415]", "[compute 6a6c7b7fde59134f]", "[compute 78f54f95839e3adf]", "[compute 80a0178d3a9d8d12]", "[compute 84cab31295
L21371: 2026-11-26T17:02:22.259871Z  INFO victory_gpu::copystat:   the card's time by what ran: 216.2 ms a frame in 0.1 submissions a frame: 18 lists, pipelines {"[compute 03c01507703d7449]", "[compute 04be1ad677ff1627]", "[compute 05e074ad67e0d6d6]", "[compute 0fc1b11eb36efdb2]", "[compute 119ee96f602f1668]", "[compute 11bbed94ee7a3243]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 291822a279c07067]", "[compute 2b17036bf3a1d615]", "[compute 2bfdc19dc1f25b3a]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 488b12f581b37bfc]", "[compute 4996d173208d83eb]", "[compute 4edee813f
L17685: 2026-11-26T16:59:57.783745Z  INFO victory_gpu::copystat:   the card's time by what ran: 192.5 ms a frame in 0.4 submissions a frame: 10 lists, pipelines {"[compute 03c01507703d7449]", "[compute 04be1ad677ff1627]", "[compute 0fc1b11eb36efdb2]", "[compute 11bbed94ee7a3243]", "[compute 17af85f170e66f30]", "[compute 291822a279c07067]", "[compute 2b17036bf3a1d615]", "[compute 2bfdc19dc1f25b3a]", "[compute 32aa8384586e0f12]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 488b12f581b37bfc]", "[compute 4996d173208d83eb]", "[compute 4edee813f2d43b22]", "[compute 528278df1274cb33]", "[compute 55c46e739fa0796a]", "[compute 6a6c7b7fde59134f]", "[compute 6aa0d2e1c65940f3]", "[compute 731a39171b568298]", "[compute 80a0178d3a9d8d12]", "[compute 85dea520c
```

## E `waits for every earlier shader write` 末 3 条

```text
L21383: 2026-11-26T17:02:22.329033Z  INFO victory_gpu::copystat:   waits for every earlier shader write, per frame: 759 for the title's barrier groups, 9 for its barriers on buffers; 191 indirect commands bounded (a dispatch of ours between two such waits each); barrier experiment 0
L21553: 2026-11-26T17:02:28.462179Z  INFO victory_gpu::copystat:   waits for every earlier shader write, per frame: 763 for the title's barrier groups, 9 for its barriers on buffers; 190 indirect commands bounded (a dispatch of ours between two such waits each); barrier experiment 0
L21729: 2026-11-26T17:02:35.335354Z  INFO victory_gpu::copystat:   waits for every earlier shader write, per frame: 769 for the title's barrier groups, 9 for its barriers on buffers; 185 indirect commands bounded (a dispatch of ours between two such waits each); barrier experiment 0
```

## F 两张观察面汇总行（原文，供代码侧对照）

```text
2026-11-26T17:02:40.809021Z  INFO victory_gpu::host: the card's clock per frame: nothing of ours queued 162.3 ms (the card about 58% busy by this count), 152.9 ms of that while the submitting thread was working (the card idle behind us), the rest while the title had not submitted; the submitting thread stood waiting for the card 226.7 ms
2026-11-26T17:02:40.812715Z  INFO victory_gpu::host: 2.6 fps, 382.1 ms/frame (69.5 preparing: copies 29.1 ms 127.7 MB, textures 0.7 ms 12.6 MB; 225.8 on the GPU; 76.1 copying back 57.4 MB), 3239 draws/frame, dropped 430 without a host pipeline (0 being made) and 567 indirect; heap buffers 1.0 passes 16.2 ms;                  texture slots written so far: 1231927 placed, 723710 of objects; textures picked by index: 10737 uploaded so far (4621 MB), 25629 waiting, 9252 passed over unmapped; depth textures with                  unordered access: 83 made, bound as depth 36686x, cleared as depth 712x,                  unordered views refused 0x; buffer views left null as the host would refuse them: 0 (447 copies made of views off their buffer's elements); depth twins: 83 alive, 0 depth textures left without one; twin copies per frame: 12.0 into depth textures, 10.0 into twins; depth planes: 1.0 drawn from their twins per frame, 751 times not given back to a twin, 753 times used before the pass
```

## G 未改动项

1. `data\bench-v2.csv` 未追加（仍 11 行，L8–L11 为 R5 四组）；`data\bench.csv` L1–12 未动。
2. 未改源码 / `Cargo.toml` / `.cargo\config.toml` / `rust-toolchain.toml`；未覆盖 `target\release\victory.exe`（49681038 B，SHA `58E60D62…A4EFF45`）与 `victory-baseline.exe`。
3. 本单只跑一局；未开 `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES`；未跑分。
4. runner 脚本 `r02-a11-run.ps1`（UTF-8 带 BOM，`Parser::ParseFile` 0 错）。

## 附录 全部 42 条标题采样

```text
10s|Americas | VIctory 30 fps 33.4 ms/frame 8 draws/frame
20s|Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame
30s|Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame
40s|Americas | VIctory 30 fps 33.3 ms/frame 10 draws/frame
50s|Americas | VIctory 29 fps 34.4 ms/frame 8 draws/frame
60s|Americas | VIctory 29 fps 34.5 ms/frame 9 draws/frame
70s|Americas | VIctory 1 fps 1058.6 ms/frame 1997 draws/frame
80s|Americas | VIctory 3 fps 386.3 ms/frame 1560 draws/frame
90s|Americas | VIctory 2 fps 468.1 ms/frame 1513 draws/frame
100s|Americas | VIctory 2 fps 579.6 ms/frame 4384 draws/frame
110s|Americas | VIctory 2 fps 541.7 ms/frame 3788 draws/frame
120s|Americas | VIctory 2 fps 515.8 ms/frame 3457 draws/frame
130s|Americas | VIctory 2 fps 427.2 ms/frame 1042 draws/frame
140s|Americas | VIctory 2 fps 441.0 ms/frame 4775 draws/frame
150s|Americas | VIctory 2 fps 439.2 ms/frame 4480 draws/frame
160s|Americas | VIctory 2 fps 438.1 ms/frame 4937 draws/frame
170s|Americas | VIctory 2 fps 473.4 ms/frame 5807 draws/frame
180s|Americas | VIctory 2 fps 477.3 ms/frame 5895 draws/frame
190s|Americas | VIctory 2 fps 467.0 ms/frame 4496 draws/frame
200s|Americas | VIctory 2 fps 451.7 ms/frame 5120 draws/frame
210s|Americas | VIctory 2 fps 435.1 ms/frame 3449 draws/frame
220s|Americas | VIctory 2 fps 458.8 ms/frame 5051 draws/frame
230s|Americas | VIctory 2 fps 455.3 ms/frame 5056 draws/frame
240s|Americas | VIctory 2 fps 453.2 ms/frame 5064 draws/frame
250s|Americas | VIctory 1 fps 1139.3 ms/frame 5059 draws/frame
260s|Americas | VIctory 2 fps 449.0 ms/frame 4900 draws/frame
270s|Americas | VIctory 2 fps 525.3 ms/frame 6886 draws/frame
280s|Americas | VIctory 2 fps 478.0 ms/frame 6710 draws/frame
290s|Americas | VIctory 2 fps 447.7 ms/frame 6329 draws/frame
300s|Americas | VIctory 2 fps 440.8 ms/frame 6259 draws/frame
310s|Americas | VIctory 2 fps 462.6 ms/frame 6257 draws/frame
320s|Americas | VIctory 2 fps 456.1 ms/frame 6274 draws/frame
330s|Americas | VIctory 2 fps 406.7 ms/frame 6377 draws/frame
340s|Americas | VIctory 2 fps 402.9 ms/frame 6266 draws/frame
350s|Americas | VIctory 2 fps 407.6 ms/frame 5611 draws/frame
360s|Americas | VIctory 2 fps 405.1 ms/frame 5640 draws/frame
370s|Americas | VIctory 3 fps 387.7 ms/frame 5590 draws/frame
380s|Americas | VIctory 3 fps 393.1 ms/frame 5601 draws/frame
390s|Americas | VIctory 3 fps 395.5 ms/frame 5410 draws/frame
400s|Americas | VIctory 3 fps 397.2 ms/frame 5457 draws/frame
410s|Americas | VIctory 2 fps 555.4 ms/frame 5410 draws/frame
420s|Americas | VIctory 3 fps 389.2 ms/frame 3238 draws/frame
```
