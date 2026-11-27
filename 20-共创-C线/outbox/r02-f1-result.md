# r02-f1 回填 · Kelvaroq 只读清点

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0835-21.md`。只清点、不改任何东西、不下结论。

产物：`G:\GTA\kelvaroq-eval\inventory.md`，24,206 B / 289 行，UTF-8（无 BOM）。

## 清点对象与规模

| 项 | 值 |
| --- | --- |
| 被清点仓库 | `G:\GTA\kelvaroq-main`（只读） |
| 补丁目录 | `G:\GTA\kelvaroq-main\native\patches`（唯一目录，`-Recurse` 全量） |
| 补丁个数 | **61**（与任务单的 61 一致） |
| 补丁行数合计 | 见 §1 表「行数」列，逐条照抄 `Measure-Object -Line` |
| 目标文件条目合计 | **83**（61 个补丁去重后的 `--- a/`、`+++ b/` 目标路径） |
| 参照树 | `G:\GTA\cool_fox\cool_fox-main`（`Test-Path` 逐条判定） |
| 无 diff 头的补丁 | **0** |

## 存在性统计（`Test-Path` 结果，仅计数）

| 分类 | 个数 |
| --- | --- |
| 全部目标都在我们树里 | **57** |
| 部分目标在 | **1**（`0040-async-submit-defaults.patch`：`crates/victory-gpu/src/queue.rs` 有，`crates/victory-gpu/src/queue2.rs` 无） |
| 全部目标都不在 | **3**（`0035-copy-queue-budget.patch` → `crates/victory-gpu/src/queue2.rs`；`0053-submit.patch` → `crates/victory-gpu/src/frame_wait.rs`；`0058-insn-clean.patch` → `crates/victory-loader/src/console_cpu.rs`） |
| 目标路径条目：有 | 79 / 83 |
| 目标路径条目：无 | 4 / 83 |

## 文档清点

| 文件 | 大小（B） | 进 inventory.md 的部分 |
| --- | --- | --- |
| `documentation.md` | 53,151 | `^#{1,3} ` 标题列表原文（23 行，正文为法文） |
| `README.md` | 32,670 | `^#{1,3} ` 标题列表原文（25 行，正文为英文） |
| `research\native_workload.md` | 5,398 | **全文照抄**（法文，含 `KELVAROQ_WORKLOAD` / `KELVAROQ_FRAME_TIMINGS` / `KELVAROQ_QUEUE_TOTAL` 段落） |
| `RELEASE_NOTES.md` | 3,043 | **全文照抄**（含 `108.5 ms` / `261.5 ms` / `132.2 ms`（7.6 fps）、外部 36 分钟会话 `10 fps`、`10.9 fps`、`30 fps` 目标 `33.3 ms` 等原文数字） |

编码探测：两份全文文件首 3 字节为 `23 20 43` / `23 20 4B`（无 BOM，按 UTF-8 读取，法文重音正常，如 `Définir`、`épinglé`）。

## inventory.md 结构（四节齐全）

| 节 | 内容 | 行号 |
| --- | --- | --- |
| 1 补丁总表 | 61 行，列 `patch / 行数 / 目标文件 / 我们树里有/没有`（多目标用 `<br>` 分列，每目标标「有」/「无」，末列 `n/m 有`） | L13–L79 |
| 2 PRESENT 清单 | 2.1 全有 57 个（编号表）；2.2 部分 1 个（有/无两列）；2.3 全无 3 个 | L81–L159 |
| 3 文档骨架 | `documentation.md`、`README.md` 标题列表原文（代码块） | L161–L215 |
| 4 全文 | `research\native_workload.md`、`RELEASE_NOTES.md` 原文（代码块） | L217–L289 |

## 红线核对

| 项 | 结果 |
| --- | --- |
| 应用补丁 | **未应用任何补丁**；`kelvaroq-main` 内 08:36 之后被修改的文件数 = **0**（该树最新 mtime 08:28:19，早于本任务） |
| 改 `cool_fox-main` | **未改**；该树最新 mtime 05:10:50（本轮之前最后一次构建） |
| 编译 / 运行游戏 | **均未**；全流程只有 `Get-ChildItem` / `Get-Content` / `Select-String` / `Test-Path` |
| 结论/建议 | **未写**；inventory.md 只有表格数据与原文照抄 |
| 输出位置 | 仅 `G:\GTA\kelvaroq-eval\`（`inventory.md`、`f1-presence.json`、`s1-rows.txt`、`build-inventory.ps1`） |
| 数字与文件名 | 未改写、未换算；补丁名与目标路径逐字来自 `--- a/`、`+++ b/` 头 |

## 交付文件

| 文件 | 大小（B） | 说明 |
| --- | --- | --- |
| `G:\GTA\kelvaroq-eval\inventory.md` | 24,206 | 正式产物（四节） |
| `G:\GTA\kelvaroq-eval\f1-presence.json` | 13,556 | S2 原始存在性数据（每补丁每目标的 `there` 布尔） |
| `G:\GTA\kelvaroq-eval\s1-rows.txt` | 4,807 | S1 原始行（`patch|lines|targets|subject`） |
| `G:\GTA\kelvaroq-eval\build-inventory.ps1` | 6,129 | 生成脚本（可复跑，只读输入） |
