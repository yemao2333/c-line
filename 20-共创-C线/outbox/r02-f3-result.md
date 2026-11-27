# r02-f3 回填 · 三棵树只读清点

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0855-23.md`。只读、不编译、不运行、不改任何东西、不写结论。

产物：`<ROOT>\kelvaroq-eval\three-way.md`，26,386 B / 507 行，UTF-8（无 BOM）。

## 三棵树

| 代号 | 树 | 本次读数 |
| --- | --- | --- |
| A | `<ROOT>\fork-eval\victory-fork` | `.rs` 160 个、全树文件 223 个、最新 mtime 2026-11-27 04:30:28 |
| B | `<ROOT>\VIctory-Belobug-AMD-a-publier` | `.rs` 237 个、全树文件 271 个、最新 mtime 2026-11-27 08:53:33（早于本任务开始） |
| O | `<ROOT>\cool_fox\cool_fox-main` | `.rs` 226 个（含 `target\` 下 12 个生成文件）、最新 mtime 05:10:50 |

## §1 三方开关（`VICTORY_[A-Z0-9_]+`，`*.rs` 全树去重）

| 项 | 值 |
| --- | --- |
| A 开关数 | **314** |
| B 开关数 | **429** |
| O 开关数 | **365** |
| `A_ONLY`（A 有、O 无） | **123** |
| `B_ONLY`（B 有、O 无） | **67** |
| `A∩B−O`（A、B 都有且 O 无） | **0**（空集） |
| 三树并集 | **555** |

与 `r02-e1`（e1 当时：theirs 314 / ours 364 / ONLY_IN_THEIRS 124）的差：`O` 现为 365、`A_ONLY` 现为 123，差 1 项即 05:10 移植进来的 `VICTORY_SETTLE_ROOM`（`outbox\r02-e2-result.md` C 节）。

## §2 模块缺口（`.rs` 相对路径差集，只列 O 缺的）

| 项 | 值 |
| --- | --- |
| A 有、O 无 | **17** 个文件 |
| B 有、O 无 | **23** 个文件 |

A 独有的 17 个（清单原文见 `three-way.md` §2.1）：`backreads.rs`、`cardmeter.rs`、`drvwatch.rs`、`fpsbox.rs`、`framelog.rs`、`heap_pass.rs`、`heap_worker.rs`、`plaincopy.rs`、`profile.rs`、`profile\tests.rs`、`queue2.rs`、`renderdoc.rs`、`shot.rs`、`spread.rs`、`stats.rs`、`emit\dispatch_threads.rs`、`emit\halves.rs`。

B 独有的 23 个（原文见 `three-way.md` §2.2）：含 `apps\victory\src\fsr_4k.rs`、`crates\victory-gpu\src\lightprobe.rs`、`port.rs` / `port_cbv.rs` / `port_descriptors.rs` / `port_journal.rs`、`texlate.rs`、`texstore.rs`、`crates\victory-hle\src\modules\fidelityfx.rs`、`crates\victory-loader\src\{descriptor_sites,frame_rate,resolution}.rs`、`xtask\src\switches.rs` 等。

## §3 光追 / 间接光命中行

匹配式（任务单原文）：`ray.?trac|AccelerationStructure|DXR|indirect light|ambient occl|RTGI`，范围 `*.rs,*.md`，每行截 120 字符。

| 树 | 命中总条数 | 文档内贴出 |
| --- | --- | --- |
| A | **72** | 40 |
| B | **89** | 40 |

## §4 README 前 60 行

| 树 | `README.md` 大小 | 文档内贴出 |
| --- | --- | --- |
| A | 58,886 B | 60 行原文 |
| B | 11,773 B | 60 行原文 |

（A 的 README 前 60 行含「Playable, slowly: about 8 to 9.5 world frames per second…」「Shadowed areas are still black」等原文；B 的含「about 45 ms a frame（about 22 fps, 44.9 ms in run merge-5）」「Ray tracing was off for these runs」等原文。以上均照抄，未改写。）

## 未纳入的两棵树（按任务单备注）

| 树 | 事实 |
| --- | --- |
| `Zettrox/ztrx` | **未纳入**。本机 `<ROOT>` 下按 `ztrx` / `zettrox` / `scarlett` 匹配的目录只有 `OpenScarlett-main`，**没有** ztrx 相关目录 ⇒ 无法清点。 |
| `californiaAlmonds/OpenScarlett` | **未纳入**。`<ROOT>\<DUMP>`（游戏 dump）内 `.rs` 数 = **0**，该目录是游戏数据，不含源码。另注事实：本机存在 `<ROOT>\OpenScarlett-main`（545 个文件、`.rs` **0** 个、`CMakeLists.txt` / `build.cmd` 等，非 Rust 工程，最新 mtime 2026-11-26 08:17:32）——它不在本任务单的三棵树范围内，故同样**未纳入**；若要清点需另开单。 |

## 红线核对

| 项 | 结果 |
| --- | --- |
| 编译 / 运行游戏 | 均未 |
| 改三棵树（含 `target\`、`Cargo.toml`） | 未改；全流程只有 `Get-ChildItem` / `Select-String` / `Compare-Object` / `Test-Path` |
| 结论/建议 | 未写；`three-way.md` 只有清单、计数与原文 |
| 数字与路径 | 未改写；路径逐字来自 `FullName.Replace(...)` 原文 |
| 输出位置 | 仅 `<ROOT>\kelvaroq-eval\`（`three-way.md` + `f3-s1/s2/s3/s4.txt` + `build-threeway.ps1`） |

## 交付文件

| 文件 | 大小（B） | 说明 |
| --- | --- | --- |
| `<ROOT>\kelvaroq-eval\three-way.md` | 26,386 | 正式产物（§1–§4） |
| `<ROOT>\kelvaroq-eval\f3-s1.txt` | 15,626 | S1 原始输出（含三张清单与并集） |
| `<ROOT>\kelvaroq-eval\f3-s2.txt` | 1,572 | S2 原始输出 |
| `<ROOT>\kelvaroq-eval\f3-s3.txt` | 9,628 | S3 原始输出（各 40 行） |
| `<ROOT>\kelvaroq-eval\f3-s4.txt` | 8,960 | S4 原始输出（各 60 行） |
| `<ROOT>\kelvaroq-eval\build-threeway.ps1` | 6,609 | 生成脚本（只读输入，可复跑） |
