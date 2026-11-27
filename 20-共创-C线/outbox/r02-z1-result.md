# r02-z1 回填 · 代码侧离线交接（只读 + 抄写，零动作）

> 执行端本机 Windows。任务单 `inbox\task-20261127-0950-26.md`（kind: handoff）。本单只做两件事：①只读巡检取数；②把 f1–f5 的数字表抄进 `80-最终交付.md` 新增一节。全程未启动游戏、未跑分、未编译、未改源码/脚本/台账。

## ① 巡检数字（只读）

### 1.1 三个 exe（`<ROOT>\cool_fox\cool_fox-main\target\release`）

| 文件名 | 字节 | 最后写入 | SHA256 |
| --- | --- | --- | --- |
| `victory.exe` | 49,691,451 | 2026-11-27 05:10:49 | `4230CCF9B085D040489EBF2AB7421290AAF7DC3151B6C938EB2BAB793ABC5F3C` |
| `victory-pre-e3.exe` | 49,681,038 | 2026-11-26 22:02:32 | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` |
| `victory-baseline.exe` | 72,407,911 | 2026-11-26 20:24:44 | `9627DF10A7E7B498B86F7A6B8B3F52DD32958F735072F1A0161DE1BDD0CAEC73` |

三个 SHA 与 `r02-f5` 六次运行打印的 `exe_sha256` 一致；本轮未覆盖任何 exe。

### 1.2 三个 csv

| 文件 | 行数 | 末行（逐字） |
| --- | --- | --- |
| `data\bench.csv` | 12 | `2026-11-26 22:26:47,R2-B-reverted,200,40,30,271.9,20.26,2.95,0.53,run-R2-B-reverted-1126-222239.log` |
| `data\bench-v2.csv` | 22 | `2026-11-27 02:29:32,R9-after-warm2,200,40,ms>40&draws>=200,32,298.5,3205,20.46,3.06,11.78,0,run-R9-after-warm2-1127-022521.log` |
| `data\bench-v3.csv` | 16 | `2026-11-27 09:42:56,sw-VICTORY_BARRIER_TEST-on,200,420,42,50,35,ms>40&draws>=200,248,4484,20.49,2.65,10,0,run-sw-VICTORY_BARRIER_TEST-on-1127-093837.log` |

行数与 f5 收尾一致（12 / 22 / 16），本单未追加任何行。

### 1.3 进程

```text
victory_procs=0
```

### 1.4 `<ROOT>\victory-data`

总量与最新写入时间：

```text
files=26756 bytes=1614149512 max_mtime=2026-11-27 09:39:21
```

**09:00:00 之后被写过的文件共 7 个**（逐字列出，含大小与时间）：

| 相对路径 | 字节 | 写入时间 |
| --- | --- | --- |
| `\coolfox-cache\pipelines\host-pipelines.bin` | 148,201,324 | 09:22:09 |
| `\coolfox-cache\pipelines\slow-pipelines.txt` | 54,111 | 09:22:09 |
| `\coolfox-cache\pipelines\early-pipelines.txt` | 89,990 | 09:22:09 |
| `\coolfox-data\7952987A\temp\telemetrycache.dat` | 2,097,152 | 09:38:39 |
| `\coolfox-data\7952987A\saves\...\v72\0` | 2,012 | 09:39:21 |
| `\coolfox-data\7952987A\saves\...\v72\1` | 296 | 09:39:21 |
| `\coolfox-data\7952987A\saves\...\v72\manifest` | 58 | 09:39:21 |

四个已知文件的对照（含交接文档 §8 的旧读数）：

| 文件 | 现读数 | `handoff-20261127-执行端.md` §8 读数 | 是否变 |
| --- | --- | --- | --- |
| `coolfox-cache\pipelines\known-pipelines.bin` | 50,326,544 @2026-11-27 01:49:26 | 50,326,544 @01:49:26 | 未变 |
| `coolfox-cache\pipelines\host-pipelines.bin` | 148,201,324 @2026-11-27 09:22:09 | 147,961,152 @03:53:07 | 变（+240,172 B） |
| `coolfox-cache\pipelines\warm-done.txt` | 744,400 @2026-11-27 02:25:18 | 744,400 @02:25:18（14,888 行） | 未变 |
| `coolfox-cache\pipelines\warm-bad.txt` | 0 @2026-11-27 02:05:06 | 0 | 未变 |

结论性事实（不含判读）：`victory-data` **并非**“零写入”——09:00 之后有 7 个文件被写，其中 3 个在 `coolfox-cache\pipelines`（`host-pipelines.bin` 由 147,961,152 增至 148,201,324，两个 txt 重写），4 个在 `coolfox-data`（`telemetrycache.dat` 与存档 `v72\0` / `v72\1` / `manifest`）。写入时间落在 `r02-f5` 的 L12（09:12–09:18）之后的 09:22 与 L15/L16（09:30–09:42）之间的 09:38–09:39，即本机 f5 六次运行期间，由被测进程自身写出，非本端命令所致。

### 1.5 源码树指纹（供回归比对）

| 文件 | 字节 | 最后写入 |
| --- | --- | --- |
| `crates\victory-gpu\src\host.rs` | 484,421 | 2026-11-27 05:08:31 |

## ② `80-最终交付.md` 已增一节

| 项 | 值 |
| --- | --- |
| 文件 | `<ROOT>\cool_fox-优化方案\80-最终交付.md` |
| 字节 | 14,914 → **21,560** |
| 行数 | 256 → **395** |
| 新增节 | `## 7 外部项目评估（f1–f5 数字表抄录）`，起于 L260 |
| 子节 | `7.1 f1` L264；`7.2 f2` L288；`7.3 f3` L325；`7.4 f4` L357；`7.5 f5` L371 |
| 原有内容 | L1–L256（§1–§6 + 交付物清单）**逐字未动**，只在文件末尾追加 |

出处逐节标注：

| 子节 | 出处文件 |
| --- | --- |
| 7.1 | `20-共创-C线\outbox\r02-f1-result.md`；产物 `kelvaroq-eval\inventory.md`（24,206 B / 289 行） |
| 7.2 | `outbox\r02-f2-result.md`；产物 `kelvaroq-eval\shortlist.md`（13,277 B / 186 行） |
| 7.3 | `outbox\r02-f3-result.md`；产物 `kelvaroq-eval\three-way.md`（26,386 B / 507 行） |
| 7.4 | `outbox\r02-f4-result.md`；证据 `kelvaroq-eval\f4-check-0032/0023/0030-*.log`（475 / 626 / 537 B） |
| 7.5 | `outbox\r02-f5-result.md`；台账 `data\bench-v3.csv` L11–L16 |

抄录范围：仅数字与原文（计数、行数、字节、SHA、µs、median、csv 列值、hunk 行号与偏移、文件名清单）。未新增任何结论、建议、“有效/无效”字样，也未改动任何既有数字。

## ③ 无其它动作声明

| 动作 | 状态 |
| --- | --- |
| 启动游戏 / 跑分 | **未做**（本单全程无 `Start-GTA6`、无 `bench.ps1`、无 `smoke.ps1`、无 `auto-enter.ps1`） |
| 编译 | **未做**（无 `cargo` 调用） |
| 改源码 | **未做**；`host.rs` 等 mtime 仍为 05:08:31 |
| 改脚本 | **未做**；`10-实验脚本\*.ps1` 未编辑 |
| 改台账 | **未做**；三个 csv 行数与末行如 §1.2 |
| 覆盖 exe | **未做**；三个 SHA 如 §1.1 |
| 动 `victory-data` | 本端**未执行任何写/删命令**；该目录内 09:00 后的 7 处写入已在 §1.4 逐条列出（由被测进程写出） |
| 下判断 | **未下**；本文件与 `80-最终交付.md` §7 均无结论句 |
| 本单写过的文件 | 仅两个：`outbox\r02-z1-result.md`（本文件）、`80-最终交付.md`（末尾追加 §7） |

代码侧回归时按 ① ② ③ 三段核对即可。
