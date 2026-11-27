# r02-portwatch-1128 — 上架文案更新 + 上架前备份（记录）

时间：2026-11-28 06:33–06:55（Asia/Shanghai）。只做文案与备份，未起任何 `victory*` 进程、未跑游戏、未改台账。

## 1 上架状态（当日事实）

| 项 | 值 |
| --- | --- |
| 站点数据 `tracker.json` | 45 条，**无 `coolfox`**；`updated=2026-11-27T19:13:01Z`（早于本仓提交） |
| PR #283 | `open`、`merged=False`、`mergeable_state=clean`、1 commit（更新后 2 commit） |
| Issue #282 | `open`、无维护者回复 |
| 候选池 | 30 条，本仓未命中任何 scout query ⇒ 自动发现通道对本仓关闭，只能走 PR |
| scout 节奏 | 16:20 → 19:14 UTC（约 3 h 一次）；`lastEditorRun=2026-11-26T09:13Z` |

## 2 文案更新（写入 PR 分支 `coolfox-entry`）

| 字段 | 旧 | 新 |
| --- | --- | --- |
| `basedOn` | `["marvis","victory-gta6"]`（占位） | `["victory-nvidia"]`（站内 id，指向 `trustno1-coder/VIctory-NVIDIA`） |
| `byline` | `Public ledger, one NVIDIA machine` | `Built on VIctory's AMD branch · tuned against trustno1-coder/VIctory-NVIDIA · public ledger` |
| `summary` | 只讲 4 fps | 补上游归属 + 本机硬件 + 上游硬件下限 + 卡型覆盖 + 未评估项 |
| `highlights` | 4 条（纯性能） | 8 条（上游对照 2 条 + 硬件 3 条 + 性能 3 条） |
| `blockers` | 4 条 | 5 条（新增「8 GB 显存是紧边」、上游 20 fps 对比） |

提交：`1344359`（分支 `coolfox-entry`，`data/tracker.json` 46 条、JSON 校验通过、`coolfox` 仍在首位）。
PR #283 正文重写、PR 评论 1 条、Issue #282 评论 1 条。

## 3 上架前备份（已校验）

| 文件 | 大小 | 条目 |
| --- | --- | --- |
| `c-line-full.bundle` | 5.3 MB | 全 refs；重克隆 HEAD `e1a68d3859e3…`、477 跟踪文件、`git bundle verify` = okay |
| `c-line-worktree-incl-git.zip` | 21.1 MB | 1,245 |
| `cool_fox-优化方案.zip` | 6.4 MB | 474 |
| `cool_fox-main-src.zip` | 2.0 MB | 252（排除 `target\`） |
| `fork-eval-src-and-meta.zip` | 94 MB | 443（排除 `target\`、`victory-data`、`*.exe`） |
| `VIctory-NVIDIA-src.zip` | 37.1 MB | 300（排除 `target\`） |
| `CHECKSUMS.sha256` | — | 12 行 SHA-256 |

位置：`<ROOT>\backup\20261128-0633-portwatch-prep`。元数据 4 份：`tracker-entry-submitted.json`、`tracker-snapshot-11-27.json`、四张 csv。

## 4 边界

| 项 | 状态 |
| --- | --- |
| `victory*` 进程 | 0 |
| 构建 / 跑分 / csv 追加 | 未做 |
| 判据与台账 | 未改 |
| 仓库 | `c-line` 推送 1 次；`portwatch-vi` 分支推送 1 次 |

## 5 异地副本决策（业主）

| 项 | 记录 |
| --- | --- |
| 时间 | 2026-11-28 07:05 |
| 决策 | **只留本机**：不传百度网盘、不推第二账号 |
| 影响 | 副本与本体同盘 `G:\`；可防仓库被删/被归档，防不住本机磁盘损坏 |

## 6 文案二次修订（07:20，业主指令）

| 项 | 旧 | 新 |
| --- | --- | --- |
| 卡型 | 写成「差异」：`卡型覆盖（上游）：RTX 20/30 走 DLSS；帧生成仅 40/50；AMD 走 FSR 3` | 改为**列举支持卡型**：RTX 20/30（DLSS）、RTX 40/50（DLSS + 帧生成）、AMD 卡（FSR 3） |
| 作者 | 只写 `public ledger` | `byline` 与 highlight 第 1 条写明 **DeepSeek + 豆包 共创**：DeepSeek 写代码、豆包跑分量测，双方记录都在公开仓 |
| 提交 | `1344359` | `bd6ed1a`（PR 共 3 commit，`efforts` 仍 46、`coolfox` 仍首位、highlights 9 条） |

## 7 文案三次修订（07:42，业主指令）

| 项 | 旧 | 新 |
| --- | --- | --- |
| 硬件 | 只有「实测机器 + 上游下限」两行 | 增加**可运行配置**一句进 summary：显存 **8 GB**、内存 **32 GB**、CPU **6 核 12 线程**，1440p |
| 提交上限 | 未提 | 新增 highlight：扩页面文件后 Commit Limit **49.84 GB**，即 `0x8007000E` 崩点被解决的原因 |
| 未验证区间 | 只在「只测过一台 NVIDIA 机器」一句里 | blockers 单列：低于 8 GB 显存、低于 6C/12T、AMD / Intel 显卡均未测 |
| 提交 | `bd6ed1a` | `1a6d056`（PR 4 commit、条目 10 条 highlights / 5 条 blockers） |