> **项目暂停：2026-11-28 09:00 前暂停，晚间恢复。归档/只读已撤销，仓库保持可写；暂停期间不起进程、不写台账，只做文件交接与只读分析。**

# c-line

C 线工程档案：`cool_fox`（VIctory 的 AMD 分支，模拟运行 Xbox Series 版 GTA VI）的性能优化台账、实验脚本、代码侧／执行端往返交接单。

本仓库是**文本接力通道**：代码侧写 `20-共创-C线/inbox/`，执行端写 `20-共创-C线/outbox/`，双方不直接对话，靠文件交接。暂停期间（09:00 前）通道仍可写，只做文件交接与只读分析。

## 当前状态（2026-11-28 暂停，晚间恢复）

| 项 | 值 |
| --- | --- |
| 主线 | P0 已达标：Commit Limit **49.84 GB**（扩页面文件后），`min_commit_free` 曾低至 **0.03 GB** 的 `0x8007000E` 崩溃不再复现 |
| 帧时 | z2 的 −5.3% 判为噪声撤回（3 rep 区间重叠，点差 −0.64%～+0.78%） |
| 内存 | 四键 `MEMORY_CARD_MB=1536 / KEEP_SNAPSHOTS_MB=64 / INPLACE_MB=512 / TEXTURE_BUDGET_MB=768` 保留，只作稳定性，不声称性能收益 |
| 代码改动 | 三处候选改动 **BLOCK**（rig 只能判 ≥8% 的效应，三项现实收益达不到门槛） |
| 上游 fork | `fxceless/victory-fork` 已完整跑通并落三 rep，见 `data/bench-fork.csv` |
| 硬件天花板 | i5-12400F + 3060 Ti 8 GB，`50–55 µs/draw` 即该平台物理水平；4070 级按比例约 8–9 fps |

## 上游与归属

| 项 | 值 |
| --- | --- |
| 本树基础 | VIctory 的 AMD 分支 |
| 逐条对照的上游 | [`trustno1-coder/VIctory-NVIDIA`](https://github.com/trustno1-coder/VIctory-NVIDIA)（DLSS / 帧生成分支） |
| 对照口径 | 上游 40 条 `SETTINGS` 逐条比对本树启动器：**16 条本树无读取点**、**2 条取值不同**（`VICTORY_JOIN_PARTS` 8 vs 6、`VICTORY_LEVELS_ON_DEMAND` 0 vs 1） |
| 采纳规则 | 只保留通过 3 rep、区间零重叠且点差 ≥8% 的改动；其余回退或 BLOCK |
| 共创 | **DeepSeek + 豆包**：DeepSeek 写代码改动（`inbox`），豆包在机器上跑分与量测（`outbox`），往返全部留在本仓 |
| 对照原文 | `20-共创-C线/outbox/r02-h1.md`（行号 + 开关 + 值 + 注释） |

## 硬件面

| 项 | 值 |
| --- | --- |
| 可运行配置（写进上架条目） | 显存 **8 GB**、内存 **32 GB**、CPU **6 核 12 线程**；输出 1440p |
| 实测机器 | i5-12400F（6C/12T）、RTX 3060 Ti **8 GB**、32 GB RAM、1440p 输出 |
| 未验证区间 | 低于 8 GB 显存、低于 6 核 12 线程、AMD / Intel 显卡：均未测 |
| 扩页面文件后 Commit Limit | **49.84 GB**（原崩点 `0x8007000E`、`min_commit_free=0.03`） |
| 上游下限（`VIctory-NVIDIA` 文档） | 约 **8 GB** 显存；**32 GB** RAM 够用，64 GB 更舒适 |
| 支持卡型 | 列举：**NVIDIA GeForce RTX 20 / 30 系列**（DLSS）；**NVIDIA GeForce RTX 40 / 50 系列**（DLSS + DLSS 帧生成）；**AMD 卡**（FSR 3） |
| 本机帧生成 | 3060 Ti 无 DLSS 帧生成（门槛在 `play.rs` 的 `older_rtx` / `dlss_framegen_card`），由 FSR 3 2x 顶上 |
| 上游参考帧率 | 同一上游在更强卡上约 20 fps；本机 4,300 draws/帧下约 4 fps |

## 备份（对外上架前的离线副本）

| 项 | 值 |
| --- | --- |
| 位置 | `<ROOT>\backup\20261128-0633-portwatch-prep` |
| git bundle | `c-line-full.bundle`（全 refs），重克隆校验 HEAD = `e1a68d3`、477 个跟踪文件 |
| 压缩包 | 工作副本含 `.git`（1,245 条目）、优化方案（474）、本树源码（252）、上游源码（300）、`fork-eval` 源码与元数据（443） |
| 校验 | `CHECKSUMS.sha256`（12 行），`git bundle verify` 返回 `is okay` |
| 用途 | PortWatch 已有下线记录（Belobug 被删、AvatarManz 被移除），上架前后保证数据不依赖仓库存活 |
| 异地副本 | **无**。业主 2026-11-28 07:05 决策：只留本机，不传网盘、不推第二账号 |
| 该决策的含义 | 副本与本体同盘（`G:\`）。若账号被连带删除且本机数据丢失，无外部恢复点；本机副本可防「仓库被删/被归档」，防不住「本机磁盘损坏」 |

## 目录

| 路径 | 内容 |
| --- | --- |
| `20-共创-C线/inbox/` | 代码侧下发的任务单（`task-YYYYMMDD-HHMM-序号.md`） |
| `20-共创-C线/outbox/` | 执行端回的交接单（`r02-xx.md`，只报数字不下结论） |
| `20-共创-C线/round-01/`、`round-02/` | 两轮小队的简报、回填、核对结论 |
| `10-实验脚本/` | 跑分脚本。`bench.ps1`（本树）、`bench-fork.ps1`（上游隔离）、`bench-fork-watch.ps1`（仅改进程跟踪） |
| `data/` | 台账与原始日志。`bench.csv`（12 行冻结）、`bench-v2.csv`（22 行）、`bench-v3.csv`（31 行）、`bench-fork.csv`（11 行） |
| 根目录 `*.md` | 专题分析：基线与瓶颈、内存、显存、线程调度、着色器、构建，以及 `30-结项报告.md` |

## 台账口径（禁改）

- 世界样本 filter v2：`Ms > 40 且 Draws >= 200`
- 世界窗：进世界（`draws >= 1000`）后采 600 s；`world_from_s` 为该点
- 新判据（z3 起）：每组 3 rep，区间**零重叠**且点差 **≥ 8%** 才算数
- 峰值上限：`max_priv_gb ≤ 18.5`；P0：`min_commit_free_gb ≥ 6` 且 Commit Limit ≥ 48 GB

## 上游 fork 三 rep（`data/bench-fork.csv`）

| label | world_from_s | 世界样本 | median_ms_world | 中位 draws | 峰值私有 | min_free | min_commit_free |
| --- | --- | --- | --- | --- | --- | --- | --- |
| fork-1 | 237 | 101 | 522.2 | 4230 | 16.94 | 2.46 | 8.98 |
| fork-2b | 99 | 101 | 241.2 | 4371 | 15.78 | 0.79 | 0.83 |
| fork-3 | 44 | 97 | 220.0 | 4343 | 16.29 | 5.29 | 11.48 |

三局 `world_from_s` 不同（存档解包进度不同），中位数**不属同一窗口口径**。

## 复现须知

- 本仓库不含任何游戏文件、可执行文件或密钥，只有文本、脚本、日志与 csv。
- 日志中的绝对路径是执行机原始路径，仅供对账。
- 数值一律照抄，不做换算；任何结论以 `30-结项报告.md` 为准。
