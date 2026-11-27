# r02-f2 回填 · Kelvaroq 可移植候选短名单

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0845-22.md`。只列表，不改任何东西、不写结论。

产物：`G:\GTA\kelvaroq-eval\shortlist.md`，13,277 B / 186 行，UTF-8（无 BOM）。

## 过滤落地（三条全满足才入表）

| 条件 | 落地方式 |
| --- | --- |
| ① 目标全部 PRESENT | 取 `r02-f1` §2.1 的 57 个（`f1-presence.json` 每目标 `there=true`） |
| ② 行数 ≤ 400 | `Measure-Object -Line` 逐条计数，未换算 |
| ③ 热文件集 | 路径字面匹配：叶子名 `host.rs` / `queue.rs` / `shadow.rs` / `resource.rs` / `draw.rs` / `copystat.rs`；含 `list/thin.rs`；含 `pipeline/`（目录）；含 `descriptor`；含 `tile`。任一目标命中即算 |

## 两条统计

| 统计 | 值 |
| --- | --- |
| 命中数 | **23** |
| 其中行数 ≤ 150 | **12**（名单见下行） |

（12 个 ≤150 的名单：`0048` 28、`0043` 32、`0001` 41、`0009` 51、`0015` 76、`0016` 87、`0032` 89、`0006` 116、`0030` 139、`0042` 143、`0023` 145、`0010` 149。）

## 23 个命中（按行数升序）

| patch | 行数 | 目标文件 |
| --- | --- | --- |
| 0048-async-present-default.patch | 28 | `crates/victory-gpu/src/queue.rs` |
| 0043-window-name.patch | 32 | `crates/victory-gpu/src/host.rs` |
| 0001-frame-pacing.patch | 41 | `crates/victory-gpu/src/frame.rs` `crates/victory-gpu/src/host.rs` |
| 0009-shadow-compare.patch | 51 | `crates/victory-gpu/src/shadow.rs` |
| 0015-texture-stage-budget.patch | 76 | `crates/victory-gpu/src/draw.rs` |
| 0016-pipeline-wait.patch | 87 | `crates/victory-gpu/src/draw.rs` `crates/victory-gpu/src/pipeline/make.rs` |
| 0032-contiguous-readback-copies.patch | 89 | `crates/victory-gpu/src/host.rs` |
| 0006-frame-workload.patch | 116 | `crates/victory-gpu/src/host.rs` `crates/victory-gpu/src/list.rs` `crates/victory-gpu/src/pipeline.rs` |
| 0030-scoped-card-barriers.patch | 139 | `crates/victory-gpu/src/host.rs` |
| 0042-clamp-merge-counters.patch | 143 | `crates/victory-gpu/src/host.rs` `crates/victory-gpu/src/indirect.rs` |
| 0023-compare-result-reuse.patch | 145 | `crates/victory-gpu/src/host.rs` |
| 0010-texture-invalidations.patch | 149 | `crates/victory-gpu/src/descriptor/host.rs` |
| 0017-texture-heaps.patch | 203 | `crates/victory-gpu/src/resource.rs` |
| 0038-direct-constants.patch | 210 | `crates/victory-gpu/src/draw.rs` |
| 0005-heap-timing.patch | 221 | `crates/victory-gpu/src/draw.rs` |
| 0022-gpu-upload-inputs.patch | 251 | `crates/victory-gpu/src/descriptor/host.rs` `crates/victory-gpu/src/host.rs` |
| 0027-coherent-texture-refresh.patch | 255 | `crates/victory-gpu/src/host.rs` `crates/victory-gpu/src/texture.rs` |
| 0028-small-readonly-card.patch | 261 | `crates/victory-gpu/src/resource.rs` |
| 0012-staging-pool.patch | 263 | `crates/victory-gpu/src/host.rs` |
| 0021-submit-queue-lifetime.patch | 265 | `crates/victory-gpu/src/host.rs` `crates/victory-gpu/src/queue.rs` |
| 0026-pipeline-warm-list.patch | 279 | `crates/victory-gpu/src/pipeline/library.rs` |
| 0039-rebar-copies.patch | 281 | `crates/victory-gpu/src/host.rs` |
| 0002-texture-residency.patch | 349 | `crates/victory-gpu/src/draw.rs` `crates/victory-gpu/src/texture.rs` |

## 字面口径的一个边界（事实，不含判读）

`crates/victory-gpu/src/pipeline.rs` 是**文件**、不在 `pipeline/` 目录下，故按上式不构成命中。仅因此未入表的补丁 **1 个**：`0061-no-draw.patch`（48 行，目标 `crates/victory-gpu/src/pipeline.rs`，该文件在我们树里存在）。若把「`pipeline.rs` 也算 pipeline」，命中数 +1 = 24，≤150 的数 +1 = 13。`shortlist.md` 内按字面口径出表，并在文档内注明这一条。

## 三个最小补丁的完整 diff（已贴入 `shortlist.md` 末尾）

| 顺序 | patch | 行数 | hunks | 分隔行 |
| --- | --- | --- | --- | --- |
| 1 | `0048-async-present-default.patch` | 28 | 见原文 | `=== 0048-async-present-default.patch ===` |
| 2 | `0043-window-name.patch` | 32 | 见原文 | `=== 0043-window-name.patch ===` |
| 3 | `0001-frame-pacing.patch` | 41 | 见原文 | `=== 0001-frame-pacing.patch ===` |

完整性核对：`shortlist.md` 内 `^```diff` 3 个、闭合 3 个；`^@@` 命中 7 条，与三个源文件的 `@@` 合计 7 条一致（28/32/41 行逐行照抄，无截断）。

## 首 3 行说明（事实）

61 个补丁文件均无 `Subject:` / `#` 提交头（`Get-Content -TotalCount 40` 未见）；`shortlist.md` 表内「首 3 行」取文件第 1–3 行原文，即 `diff --git …`、`index …`、`--- a/…`。

## 红线核对

| 项 | 结果 |
| --- | --- |
| 应用补丁 / 编译 / 运行游戏 | 三者均未；全流程只有 `Get-ChildItem` / `Get-Content` / `Select-String` / `Test-Path` / 字符串匹配 |
| 改任何树 | 未改；本轮新增仅 `G:\GTA\kelvaroq-eval\shortlist.md` 与 `build-shortlist.ps1` |
| 结论/建议 | 未写；`shortlist.md` 只有过滤口径、表、两条统计、原文 diff |
| 行数与文件名 | 未改写、未换算；补丁名逐字来自目录 |

## 交付文件

| 文件 | 大小（B） | 说明 |
| --- | --- | --- |
| `G:\GTA\kelvaroq-eval\shortlist.md` | 13,277 | 正式产物（过滤口径 + 23 行短名单 + 两条统计 + 三个完整 diff） |
| `G:\GTA\kelvaroq-eval\build-shortlist.ps1` | 4,802 | 生成脚本（只读输入，可复跑） |
