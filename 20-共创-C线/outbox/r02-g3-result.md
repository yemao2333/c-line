# r02-g3 执行端回填 — fork 数据目录喂入 / 进世界门禁 / S4 三 rep

时间：2026-11-28 00:28–01:58（Asia/Shanghai）。执行端：exec-runner。判读留代码侧。
状态：**S1/S2 完成；S3 门禁「draws ≥ 1000」在 90 s 窗口内为否；S3b 未进世界；S4 三 rep 未由本执行端产出**（原因见 §7）。`bench-fork.csv` 现 9 行，其中仅 2 行为非空行且均由另一会话在 00:26:47 / 00:52:59 写入。

## 0 摘要（只有事实）

1. `fork-eval-data` 在我开工时**不是空的**：11 文件 / 15 目录，与 `coolfox-data` 相对路径、字节数、SHA256 **逐一相同**（§1）。所以 S2 复制脚本的真实输出是 `exists_dir=7952987A`、`copied_*=0`、`fork_files_after=11`。
2. 解门控 exe `SHA 31D97B4D…` 在 **90 s + 6 次 Enter** 下 draws 顶点 **10**（S3，§3），**不到 1000**。
3. **同一 exe、不加任何键、跑 300 s，在 00:35–00:40 那一局 t=225 s 起进世界**：draws **1703 / 1802 / 3996 / 2086 / 2324**，ms 240.7–479.0（§5）。⇒ 「draws ≥ 1000」这件事**在该次窗口内成立**，但**不可复现**（§7）。**归属保留**：那组数字采自 t=130 s 换出来的 pid 37584，事后无法确认它是我这局的子进程还是另一会话的实例（当时对方确实在跑，§7.2）。
4. 00:54 之后本机所有尝试（共 10 局：我的 6 局 + 另一会话 4 局）**全部停在「8 draws、ms 33.3、黑屏」**，随后在 110–280 s 之间自行退出或重启后立刻退出；`bench-fork.csv` 因此只有 2 行非空。
5. 隔离核对全绿：`cool_fox-main` 未写、fork exe SHA 未变、我们 release exe SHA 未变、`bench-v2/v3.csv` 行数未变、`coolfox-data` 只读未写、每局 `leftover_procs=0`。

## 1 S1 两边 data 目录清点（原文）

命令（任务单 §S1）输出，两边均为 **11 文件 / 15 目录**，相对路径完全一致：

| 相对路径 | 字节 | ours SHA256 前 12 | fork SHA256 前 12 |
| --- | --- | --- | --- |
| `\7952987A\saves\0009000000000001\00000000-0000-0000-0000-00007952987a\Player~333dc56ddffd8ea0\v88\0` | 2012 | DC7A9E3C8D5C | DC7A9E3C8D5C |
| `…\Player~333dc56ddffd8ea0\v88\1` | 296 | 0498094A2619 | 0498094A2619 |
| `…\Player~333dc56ddffd8ea0\v88\manifest` | 58 | 2F5CDC29CEEB | 2F5CDC29CEEB |
| `…\SARC0015~f3ad35e1a05a7da0\v1\0` | 244000 | E2BF219E386C | E2BF219E386C |
| `…\SARC0015~f3ad35e1a05a7da0\v1\1` | 296 | 45EE9D58F434 | 45EE9D58F434 |
| `…\SARC0015~f3ad35e1a05a7da0\v1\manifest` | 62 | 523658B4BEA6 | 523658B4BEA6 |
| `…\SettingsProfileSettings~0b4e25fca06268d0\v1\0` | 7344 | E632EF13CBAA | E632EF13CBAA |
| `…\SettingsProfileSettings~0b4e25fca06268d0\v1\1` | 296 | 4BC7999D0625 | 4BC7999D0625 |
| `…\SettingsProfileSettings~0b4e25fca06268d0\v1\manifest` | 92 | 43CAA1D7F011 | 43CAA1D7F011 |
| `\7952987A\storage\settings\settings.xml` | 3928 | B7039EC18551 | B7039EC18551 |
| `\7952987A\temp\telemetrycache.dat` | 2097152 | 5647F05EC189 | 5647F05EC189 |

- 顶层目录两边都只有 `7952987A`；`ours` 顶层无文件（`top_level_files_in_ours=0`）。
- **是否同形：同形**（路径集合、层级、字节数、内容 SHA 全部相同）。
- 两边都不是 junction / symlink：`coolfox-data`、`fork-eval-data` 的 `Attributes=Directory`、`LinkType=` 空；逐文件 `LinkType` 扫描无输出。
- 时间戳差异只有 `telemetrycache.dat`：ours `created 11-27 20:32:44 / mtime 11-27 14:51:56`，fork `created 11-27 23:18:37 / mtime 11-28 00:12:41`（内容 SHA 相同）。

## 2 S2 复制（只增不删）回填

任务单 §S2 脚本逐条输出（原文）：

```
exists_dir=7952987A
top_level_files_in_ours=0
fork_files_after=11
fork_dirs_after=15
```

- `copied_dir` / `copied_file`：**各 0 条**（对方已有同名目录；ours 顶层无文件）。
- `exists_dir=7952987A` 1 条；`exists_file`：0 条。
- `fork_files_after=11`、`fork_dirs_after=15`。

### 2.1 之后 fork 侧数据目录自身发生的变化（记录，全部由标题自己写）

| 时间 | 变化 |
| --- | --- |
| 11-28 00:12:41 | `7952987A\temp\telemetrycache.dat` mtime 被标题推进 |
| 11-28 00:40:31 | 标题把存档从 `Player~…\v88`（3 文件）**迁移为 `v90`**（2012/296/58 B），v88 目录被删 |
| 11-28 01:00:20 | `telemetrycache.dat` 被截断为 **0 B**（01:23:24 又被写回 2,097,152 B） |
| 11-28 01:13 | 我从 ours 覆盖回 `v88` 三件（sha 与 ours 相同），`restored_count=3` |
| 11-28 01:34 | 把 `v90` 目录移出到 `G:\GTA\victory-data\fork-eval-data.quarantine-0134`，再从 ours 放回 `v88` 三件（为排除「v90 半写坏存档」假设；**该假设被随后一局否掉，见 §7**） |

## 3 S3 90 s 探测（`VICTORY_KEYS=15/20/25/30/35/40:Enter`，`VICTORY_LOG=warn`）

`exe_sha=31D97B4D70ECEF693550A7A7AA89AC6E128FD0FFCB7E265110A0C4F38B57CEB5`（与任务单一致）

标题序列原文（按进程名采样，18 条；`pid` 全程 28716，唯一的进程）：

```
t=5s  [Americas | VIctory 31 fps 32.3 ms/frame 1 draws/frame]
t=10s [Americas | VIctory 30 fps 33.1 ms/frame 4 draws/frame]
t=15s [Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=20s [Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=25s [Americas | VIctory 20 fps 49.2 ms/frame 4 draws/frame]
t=30s [Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=35s [Americas | VIctory 30 fps 33.5 ms/frame 9 draws/frame]
t=40s [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=45s [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=50s [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=55s [Americas | VIctory 30 fps 33.4 ms/frame 8 draws/frame]
t=60s [Americas | VIctory 14 fps 70.1 ms/frame 10 draws/frame]
t=65s [Americas | VIctory 1 fps 1459.8 ms/frame 10 draws/frame]
t=70s [Americas | VIctory 11 fps 95.1 ms/frame 9 draws/frame]
t=75s [Americas | VIctory 8 fps 123.8 ms/frame 10 draws/frame]
t=80s [Americas | VIctory 12 fps 80.4 ms/frame 10 draws/frame]
t=85s [Americas | VIctory 14 fps 73.8 ms/frame 10 draws/frame]
t=90s [Americas | VIctory 30 fps 33.7 ms/frame 10 draws/frame]
```

- **draws 是否 ≥ 1000：否。** 峰值 `10 draws/frame`，`ms/frame` 除两次尖峰外恒 33.3（= 30 fps 上限）。
- 按键生效（8→4→9→10 每次 Enter 变一级），`leftover_procs=0`（本次结束时清残留曾残留 1 个，已单独清掉并复测为 0）。
- 备注：第一版按父 PID 采样的那局在 t=25 s 失联，原因是另一会话的 `^victory` 清残留把它杀了（§7.2）。

## 4 S3b 长键脚本（30×Enter，每 8 s，跑 300 s）

`keys_len=286`（`8:Enter,16:Enter,…,240:Enter`）。标题序列原文（29 条，pid 34536）：

```
t=5s   [Americas | VIctory 20 fps 50.6 ms/frame 1 draws/frame]
t=10s  [Americas | VIctory 30 fps 33.3 ms/frame 1 draws/frame]
t=15s  [Americas | VIctory 31 fps 32.5 ms/frame 4 draws/frame]
t=20s  [Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=25s  [Americas | VIctory 30 fps 33.5 ms/frame 4 draws/frame]
t=30s  [Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=35s  [Americas | VIctory 31 fps 32.6 ms/frame 9 draws/frame]
t=40s  [Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=45s  [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=50s  [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=55s  [Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=60s  [Americas | VIctory 30 fps 33.3 ms/frame 10 draws/frame]
t=65s  [Americas | VIctory 30 fps 33.3 ms/frame 10 draws/frame]
t=70s  [Americas | VIctory 30 fps 33.4 ms/frame 8 draws/frame]
t=75s  [Americas | VIctory 30 fps 33.4 ms/frame 10 draws/frame]
t=80s  [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=85s  [Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=90s  [Americas | VIctory 31 fps 32.7 ms/frame 10 draws/frame]
t=95s  [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=100s [Americas | VIctory 27 fps 37.6 ms/frame 9 draws/frame]
t=105s [Americas | VIctory 19 fps 51.9 ms/frame 8 draws/frame]
t=110s [Americas | VIctory 28 fps 35.1 ms/frame 10 draws/frame]
t=115s [Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=120s [Americas | VIctory 27 fps 36.7 ms/frame 8 draws/frame]
t=125s [Americas | VIctory 27 fps 36.7 ms/frame 8 draws/frame]
t=130s [Americas | VIctory 27 fps 36.7 ms/frame 8 draws/frame]
t=135s [Americas | VIctory ]          ← 标题被清空
t=140s [Americas | VIctory ]          ← 标题被清空
t=145s <no victory process>           ← 进程消失
```

- **draws 是否 ≥ 1000：否。** 全程 1–10 draws。
- 这局在 t≈140 s 消失，不是自己走完：另一会话此时开新局，其 `^victory` 清残留把它杀了（§7.2）。
- 结束时 `fork-eval-data` 文件数：**11**（未新增设置/存档文件）。

## 5 关键额外事实：无键 300 s 探针**进过世界**（00:35–00:40 那局）

同一解门控 exe、`VICTORY_KEYS` 未设置、`VICTORY_LOG=warn`、同名命令。t=130 s 发生**标题自我重启**（pid 36740 → 37584），t=225 s 起 draws 跳到四位数。原文（截取 t=120–255 s）：

```
t=120s n=1 [pid=36740:Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=125s n=1 [pid=36740:Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=130s n=1 [pid=37584:]                                          ← 重启，新 pid
t=135s n=1 [pid=37584:Americas | VIctory 21 fps 48.4 ms/frame 1 draws/frame]
t=140s n=1 [pid=37584:Americas | VIctory 30 fps 33.4 ms/frame 1 draws/frame]
t=145s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=150s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=155s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=160s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 4 draws/frame]
t=165s n=1 [pid=37584:Americas | VIctory 30 fps 33.5 ms/frame 10 draws/frame]
t=170s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 10 draws/frame]
t=175s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 8 draws/frame]
t=180s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 10 draws/frame]
t=185s n=1 [pid=37584:Americas | VIctory 28 fps 35.6 ms/frame 9 draws/frame]
t=190s n=1 [pid=37584:Americas | VIctory 27 fps 36.9 ms/frame 9 draws/frame]
t=195s n=1 [pid=37584:Americas | VIctory 30 fps 32.8 ms/frame 9 draws/frame]
t=200s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=205s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=210s n=1 [pid=37584:Americas | VIctory 30 fps 33.4 ms/frame 8 draws/frame]
t=215s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 9 draws/frame]
t=220s n=1 [pid=37584:Americas | VIctory 30 fps 33.3 ms/frame 10 draws/frame]
t=225s n=1 [pid=37584:Americas | VIctory 4 fps 240.7 ms/frame 1703 draws/frame]
t=230s n=1 [pid=37584:Americas | VIctory 3 fps 364.5 ms/frame 1802 draws/frame]
t=235s n=1 [pid=37584:Americas | VIctory 2 fps 479.0 ms/frame 3996 draws/frame]
t=240s n=1 [pid=37584:Americas | VIctory 3 fps 365.3 ms/frame 2086 draws/frame]
t=245s n=1 [pid=37584:Americas | VIctory 3 fps 334.8 ms/frame 2324 draws/frame]
t=250s n=1 [pid=37584:]                                          ← 标题清空（另一会话清残留）
t=255s <no victory process>
```

- **draws 是否 ≥ 1000：是**（1703 / 1802 / 3996 / 2086 / 2324）。
- 这局是同一天里我这一侧唯一一次看到四位数 draws，且发生在**没有注入任何键**的条件下；但如 §0 第 3 条所述，t=130 s 之后的 pid 37584 归属未能事后确认（对方会话同时在跑），所以只能记为「该时间窗内某实例进过世界」。
- 对照：同一 exe 注入 6 次 Enter（S3）与注入 30 次 Enter（S3b）时，draws 峰值分别只有 10 / 10，`ms` 恒 33.3 → **注入 VICTORY_KEYS 的两种脚本都停在 1–10 draws**。
- 另一会话自己的两行台账（fork-1 00:26:47 world_from_s=237、fork-2b 00:52:59 world_from_s=99）说明：00:12–00:53 期间该机器上确有实例能进世界，进入耗时 99–237 s 不等。

## 6 S4：`bench-fork.csv` 现状与每行 µs/draw

命令（三条串行、无 `VICTORY_KEYS`）：`.\bench-fork.ps1 -Label <L> -Seconds 800 -WorldSeconds 600`。`bench-fork.ps1` **未改一字**（无注入行可删，其本身不写 `VICTORY_KEYS`）。

`bench-fork.csv` 现 9 行（含表头）。**我产出的所有 rep 均为空行**，唯一两行有效数据由另一会话写入，我未删改它们：

| time | label | samples | world_from_s | world_samples | median_ms_world | median_draws | **µs/draw** | leftover | 产出者 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 00:26:47 | fork-1 | 137 | 237 | 101 | 522.2 | 4230 | **123.45** | 0 | 非本执行端（另一会话） |
| 00:52:59 | fork-2b | 116 | 99 | 101 | 241.2 | 4371 | **55.18** | 0 | 非本执行端（另一会话） |

空行（`world_samples=0`，全部 `leftover_procs=0`）：

| time | label | samples | 产出者 | 说明 |
| --- | --- | --- | --- | --- |
| 00:29:50 | fork-2 | 0 | 另一会话 | 起跑即被杀（两侧互杀，§7.2） |
| 00:35:09 | fork-2b | 1 | 另一会话 | 同上 |
| 01:08:48 | fork-clean-1 | 29 | 本执行端 | 8 draws 停滞、t≈155 s 进程消失 |
| 01:08:56 | fork-3b | 0 | 另一会话 | 被我方看门狗/清残留杀 |
| 01:14:37 | fork-3c | 0 | 另一会话 | 同上 |
| 01:19:39 | fork-clean-1r | 18 | 本执行端 | 8 draws 停滞、t≈105 s 进程消失 |
| 01:28:03 | fork-clean-2 | 46 | 本执行端 | 8 draws 停滞、t≈280 s 进程消失 |

- µs/draw 计算式：`median_ms_world × 1000 / median_draws`（522.2×1000/4230 = 123.45；241.2×1000/4371 = 55.18）。
- 另有四局被我在中途主动中止、**未写 csv 行**：fork-clean-1（01:00:16 起，t=240 s 黑屏停滞）、fork-clean-2（01:21:14 起，被外来实例压住）、fork-clean-3/4（01:28:30 起的批次，随批次被停）。
- 验收线上 `world_samples ≥ 25` 只由那两行（101 / 101）满足；**本执行端的 rep 全部不满足**。

## 7 为什么 00:54 之后再没进过世界（事实层记录，不做判读）

### 7.1 失败形态（10 局一致）

- 进程起来 → t≈10–15 s 到 `8 draws/frame`、`ms 33.3`、画面纯黑（截图 `g3-shot-010434.png`：仅 fpsbox，`30.0 FPS 33 MS / GAME 0.1 CORES / GPU 2% / VRAM 0.8/7.1 GB / RAM 6.3 GB FREE 16.4 GB`）。
- 停在 8 draws 的时间：110 s / 140 s / 155 s / 240 s / 280 s / >300 s 不等，然后进程消失；有的先自我重启（新 pid、空标题）再立刻退出。
- 失败局 `.err.log` 的最后一行都停在同一位置附近（`victory_gpu::device: … slot=0x1c8 calls=16384` 之后、`victory_hle::modules::kernel: refused dll="amd_fidelityfx_upscaler_xbox.dll"` 之前）；成功局会在这条之后 3.7 s 打出该 `refused dll` 行。
- 失败局**没有**写任何新 shader 到 `fork-eval-cache`（最近写入停在 00:58:24），即没走到世界加载阶段。

### 7.2 两个执行端在同一台机器上互杀（最主要的人为因素）

- 另一会话（父进程链 `Doubao.exe → sandbox_runtime\...\pwsh.exe`）在 00:26–01:21 之间也在跑 `bench-fork.ps1`，标签 `fork-1 / fork-2 / fork-2b / fork-3b / fork-3c`。
- 双方脚本收尾都执行 `^victory` 全量 `Stop-Process`（bench-fork.ps1 第 82–92 行，判据不许改），于是：它的收尾杀掉我的局，我的收尾杀掉它的局。实测对应关系：我的 S3 死于 t=25 s、S3b 死于 t≈140 s、nokeys300 死于 t=250 s；它的 fork-2 得 0 样本、fork-2b 得 1 样本、fork-3b/3c 得 0 样本。
- 我用 `Get-CimInstance Win32_Process` 逐局核对过归属：例如 00:54:15 起的 28868、01:21:18 起的 26252 的祖辈都是 `Doubao.exe`。
- 我 01:17 起的 `g3-watchdog.ps1` **判据写错**（只排除了「父进程是 bench-fork.ps1」的情况），结果把我自己手测的进程当外来户杀了：`g3-watchdog.log` 里 01:10:36 / 01:11:22 / 01:12:13 / 01:12:33 / 01:13:04 / 01:13:24 / 01:16:53 / 01:17:08 八条 kill 全是我自己的 keytest/min/trace/postrestore/ctrl/ctrl2。**因此「标题 3–6 s 自杀」这一批观察无效，已作废**；改为 `g3-watchdog2.ps1`（只杀父链含 `Doubao`/`sandbox_runtime` 的），01:22:43 起生效。

### 7.3 已排除的假设（每条都做了对照）

| 假设 | 对照做法 | 结果 |
| --- | --- | --- |
| 存档被写坏（v90 半写） | 01:34 隔离 `v90`、从 ours 放回 `v88` 三件，再跑 300 s | 仍 8 draws；t≈210 s 进程消失，t=225 s 出现的 pid 39736 经看门狗日志核对为**外来实例**（parent 31928，01:32:52 被 wd2 杀），不是自我重启 → **未复现世界** |
| `telemetrycache.dat` 被截断 | 从 ours 覆盖回 2,097,152 B（SHA 5647F05EC189）再跑 | 无变化 |
| `host-pipelines.bin`（218,011,450 B，00:57:35 写、其后进程被 kill）半写坏 | 改名让它重建跑一局；随后把原文件恢复 | 重建版只有 5,652 B；两态都停在 8 draws |
| 整个 shader/pipeline 缓存坏了 | 01:33 把 `fork-eval-cache`（28,273 文件 / 1,293 MB）整体移走、用**空缓存**跑满 300 s | 全程 8 draws、`ms 33.3`，**未进世界也未死**；已恢复原缓存（28,274 文件 / 1,293 MB） |
| 数据目录本身 | 用全新 `data_dir`（`fork-eval-data-ctrl`）跑一局 | 同形态停住（该局当时被我的错误看门狗杀，见 §7.2，结论仅作参考） |
| 游戏文件坏块 | 全读 `amd_fidelityfx_upscaler_xbox.dll`（786,432 B，SHA FAFF02F2…）：`read_ok bytes=786432 of 786432`；`game_scarlett_master.exe`、`data.rpf`、`gameos.xvd` 等逐个整读 OK。系统日志 01:04–01:05 的 `disk … bad block` 全部指向 `\Device\Harddisk1\DR1`（= E:，WDC 465 GB），**不是** G:（CF600 1TB） | 未见游戏侧读错误 |
| GPU/驱动 TDR | `nvidia-smi`：RTX 3060 Ti，8192 MiB，占用 862 MiB，util 27%；System 日志近 2 h 无 4101/4102/13/14 | 无 TDR |
| Defender 拦截 | `Get-MpPreference`：`EnableControlledFolderAccess=0`、ASR 规则列表为空、`EnableNetworkProtection=0`；Defender 事件近 1 h 只有 00:48:31 的特征库更新与 00:48:32 的配置变更（ID 5007），无 1116/1117 检测 | 未见拦截记录 |
| 内存不足 | `Win32_OperatingSystem`：总 31.84 GB、可用 22.27 GB；Get-Counter 曾读到 `Available MBytes=0`，与 WMI 冲突，按 bench 脚本注释视为计数器抖动 | 未见真实压力 |

## 8 隔离核对（收尾时实测）

| 项 | 结果 |
| --- | --- |
| `G:\GTA\cool_fox\cool_fox-main` 被写 | 无（全程只读；只对它跑过 `Get-FileHash`） |
| fork exe | `31D97B4D70ECEF693550A7A7AA89AC6E128FD0FFCB7E265110A0C4F38B57CEB5`（65,738,683 B），**未变**，未重新编译 |
| 我们 release exe | `4230CCF9B085D040489EBF2AB7421290AAF7DC3151B6C938EB2BAB793ABC5F3C`（49,691,451 B），**未变** |
| `bench.csv` / `bench-v2.csv` / `bench-v3.csv` | 12 / 22 / 31 行，**未写** |
| `bench-fork.csv` | 10 行（表头+9），我只追加、未删改任何既有行 |
| `bench-fork.ps1` / `bench.ps1` / `smoke.ps1` / `auto-enter.ps1` | 判据、filter、收尾逻辑**未改**；调用一律 `-File` 传参（本机 ExecutionPolicy 未配，需 `-ExecutionPolicy Bypass`） |
| `coolfox-cache` | 25,853 文件，未写 |
| `coolfox-data` | 11 文件，未写（只做过 `Get-FileHash` 与向外 `Copy-Item`）；`settings.xml` SHA 仍 `B7039EC18551…` |
| `fork-eval-cache` | 已恢复原目录（28,274 文件 / 1,293 MB）；旁挂 `fork-eval-cache.g3-empty-0138`（17 文件，空缓存那局的产物）与 `fork-eval-cache-ctrl2`（5 文件） |
| `fork-eval-data` | 11 文件（v88 三件来自 ours；`v90` 在 `fork-eval-data.quarantine-0134`）；完整备份 `fork-eval-data.g3bak-0113` |
| 每局 `^victory` 收尾 | 全部 `leftover_procs=0`；收尾时 `Get-Process ^victory` 计数 0 |

## 9 出处

- 探针/跑批脚本：`G:\GTA\fork-eval\g3-s3.ps1`、`g3-probe.ps1`、`g3-diag.ps1`、`g3-run3.ps1`、`g3-watchdog.ps1`、`g3-watchdog2.ps1`（均为 UTF-8 BOM，`Parser::ParseFile` 0 error）。
- 采样原文：`g3-s3v2.out.txt`、`g3-s3b.out.txt`、`g3-nokeys.out.txt`、`g3-nokeys300.out.txt`、`g3-keytest*.out.txt`、`g3-v88probe.out.txt`、`g3-emptycache.out.txt`、`g3-run3*.out.txt`、`g3-rep-fork-clean-*.out.txt`。
- 进程日志：`g3-*.log` / `g3-*.err.log`、`G:\GTA\cool_fox-优化方案\data\run-fork-clean-*.log(.err.log)`、`run-fork-{1,2,2b,3b,3c}-*.log`。
- 截图：`G:\GTA\fork-eval\g3-shot-010434.png`（黑屏 + fpsbox）。
- 看门狗记录：`g3-watchdog.log`（含我的误杀 8 条）、`g3-watchdog2.log`。
- 台账：`G:\GTA\cool_fox-优化方案\data\bench-fork.csv`。
