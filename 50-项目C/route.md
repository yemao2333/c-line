# 项目 C · 时间线：准备与等卡能不能重叠

开项：2026-11-27 03:30（用户指示「开新项目 C」）
前置：上一批次（round-01…03）与项目 A+B 均已结项。本项目是新项目，停止条件重置。

---

## 1 要回答的唯一问题

`r02-a11` 的汇总行给出世界的结构：

```
the card's clock per frame: nothing of ours queued 162.3 ms（卡约 58% 忙），
  其中 152.9 ms 发生在提交线程正在干活时（卡在我们身后空转）；
the submitting thread stood waiting for the card 226.7 ms
382.1 ms/frame（69.5 preparing：copies 29.1 ms / 127.7 MB；76.1 copying back 57.4 MB），3239 draws/frame
```

**问题**：这 382 ms 里，「CPU 准备 ~150 ms」和「等卡 227 ms」是**串行**的（卡在准备期空转），
还是其实已经部分重叠、只是被某些**同步点**切开？如果能重叠，理论上有 2× 空间；如果不能（比如读回写强制同帧同步），就只能改数据流。

## 2 手段

`VICTORY_TIMELINE=<起>+<起>,<帧数>,<文件>`：写一份 Chrome trace（JSON，可在 `chrome://tracing` / Perfetto 打开）
+ 一份文本摘要（`.txt`，逐帧列出 present 的「工作与等待链」）。它记录：

- 我们的 span（标题的调用、提交线程的各阶段、relay、池子的活、纹理与流式工作）；
- 等待与唤醒（标题线程用的同步函数被包了 wrapper），带「谁唤醒的、在哪等」；
- 内核调用（地址空间上耗时长的）；
- **卡：每次提交的开始与结束（时间戳）**。

需要用 **diag 产物**（这套 hooks 在 `#[cfg(feature="diagnostics")]` 后面）：
`target\diag\victory.exe`，SHA256 `710857B5…15DA7C7D5`（2026-11-27 00:31:57 构建）。

## 3 执行方式（一次运行，用户在场）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<ROOT>\cool_fox-优化方案\50-项目C\run-timeline.ps1"
```

**关键操作**：脚本起跑后 **90 秒内手动点进世界**，之后别动鼠标键盘。
时间线在 **200 s 与 320 s** 各抓 3 帧（两段是为了避免"没进世界"白跑）。

产物：`data\timeline*.json`（trace）、同目录 `.txt`（摘要）、`data\r11-timeline{,.err}.log`。

## 4 停止条件（全绿才说结项）

| # | 条件 | 当前 |
| --- | --- | --- |
| **E1** | trace 抓到，且**确认落在世界内**（`.txt` 里能看到世界帧的等待链） | **绿**：两段各 3 帧，`196.2 / 199.3 ms` 每帧，事件 42,094 / 46,211 |
| **E2** | 我用 trace 回答第 1 节的问题，给出**数字** | **绿**：6 帧分三类——**快帧 ≈70 ms（我们准备 17–19 ms）**、**慢帧 A ≈270–280 ms（`outside our spans` on title 176–180 ms）**、**慢帧 B ≈235–257 ms（`the card running submissions` 163–207 ms）** ⇒ 慢帧不是我们的串行化，重叠改造只能救快帧 |
| **E3** | 结论写进 `30-结项报告.md` | **绿**：§5.9（含我们自己的可优化面 ≈59 ms/帧：slots 26.4 + snapshots 14.8 + lists' steps 17.9） |

### 4.1 结论要点（供复核）

1. 我们这层的成本在快帧里可见：`lists' steps 17–19 ms`、`a job 11–15`、`a copy's refresh 7.8` ⇒ **7–14 fps 是能到的**。
2. 慢帧的头号成因是 `the card running submissions`（163–207 ms）或 `outside our spans on a title thread`（176–180 ms，可能是标题 CPU，也可能是卡在驱动里等卡）—— **两者都不是我们的准备阶段**。
3. 上游「记录/提交重叠」只能改善快帧；**2× 期望不成立**，已写入报告 §5.9，避免后人重复投入。

## 5 纪律

1. trace 是二进制/大文件，**不进仓库**（asset-policy），只放 `data\`；
2. 用户手动进世界这件事**已计入口径**：`world_at_s` 从窗口标题 `draws ≥ 1000` 判定，不由时间假设；
3. 一次运行就够，不重复抓；若 E1 不满足（没进世界），只许重跑一次并写明原因；
4. 本项目的产出是**结论 + 改造建议**，不写代码、不跑分、不改产物。
