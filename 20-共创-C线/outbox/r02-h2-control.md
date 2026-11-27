# r02-h2 对照回填 — 还原 play.rs 后（着色器缓存已热）再测 2 次

时间：2026-11-28 05:19–05:26（Asia/Shanghai）。执行端：exec-runner。只报数，结论由代码侧写。

## 0 数字总览

| rep | 补丁 | 缓存 | 进世界 t | 世界点数 | 最后 4 稳态点 median ms | median draws | **µs/draw** | priv 峰 | leftover |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| repA（05:08:33） | 有 | 热 | 75 s | 19 | 112.25 | 4524 | 24.81 | 19494 MB | 0 |
| repB（05:11:38） | 有 | 热 | 75 s | 19 | 110.55 | 4494.5 | 24.60 | 19603 MB | 0 |
| repC（05:14:44） | 有 | 热 | 85 s | 17 | 121.95 | 4051 | 30.10 | 19473 MB | 0 |
| **repD（05:19:23）** | **无（已还原）** | 热 | 75 s | 18 | **109.20** | **4162** | **26.24** | 19533 MB | 0 |
| **repE（05:22:29）** | **无（已还原）** | 热 | 75 s | 19 | **95.05** | **3625.5** | **26.22** | 19811 MB | 0 |

- 两次对照的 µs/draw = **26.24** 与 **26.22**，都落在任务单给的 **20–35** 区间（任务单口径：落在 20–35 ⇒ 补丁无效、那 3 次是缓存热；回落到 70–130 ⇒ 补丁真有 3–4 倍收益）。本执行端不做判定。
- 项目 `bench.ps1` 口径（upper-median，`Skip([int](n/2)) -First 1`）同表：repD 110.3 / 4263 = **25.87**；repE 104.8 / 4106 = **25.52**；对照 task-2：repA 119.1 / 4881 = 24.40、repB 118.2 / 4987 = 23.70、repC 125.3 / 4723 = 26.53。

## 1 S1 还原 play.rs

| 项 | 值 |
| --- | --- |
| 备份文件 | `<ROOT>\VIctory-NVIDIA-main\apps\victory\src\play.rs.h1-orig`，46,599 B，SHA `F0230B50AF6D2BAC25277C32F65242D9CC89EBB9BE75A9A8785D0F822B16CF2B` |
| 还原前（打过补丁） | 46,980 B，SHA `C1D6460FD01AA70F80A98483A34697A64A45764B17B8296A0028D8BEFE2BFCBC` |
| 还原动作 | `Copy-Item play.rs.h1-orig → play.rs -Force` |
| 还原后 | 46,599 B，996 行，SHA **`F0230B50AF6D2BAC25277C32F65242D9CC89EBB9BE75A9A8785D0F822B16CF2B`**（`sha_ok=True`，与任务单要求的 `F0230B50…` 一致） |

还原后关键字面量回到改装前原文：

```
L58: ("VICTORY_JOIN_PARTS", "8"),
L83: ("VICTORY_LEVELS_ON_DEMAND", "0"),
```

（追加的 8 条 `VICTORY_*_THREADS / *_MB` 随还原一并消失：`Select-String 'VICTORY_THIN_THREADS'` 命中 0。）

## 2 S2 重建（还原版）

| 项 | 值 |
| --- | --- |
| 环境 | `CARGO_HOME=G:\rust\cargo`、`RUSTUP_HOME=G:\rust\rustup`、`PATH=G:\rust\cargo\bin;D:\YunX-toolchain\w64devkit\w64devkit\bin;C:\Windows\System32;…` |
| 命令 | `cargo build --release --locked -p victory`（cwd = `<ROOT>\VIctory-NVIDIA-main`） |
| EXIT | **0** |
| 耗时 | 16.7 s（`Finished release [optimized + debuginfo] target(s) in 15.13s`） |
| errors / warnings | **errors=0**，warnings=13（与打补丁那次同量，均为既有 warning） |
| 新 exe | **78,204,213 B**（`expect_size_78204213=True`），SHA `77FCC6283A0FB86FBCA770167E05EB45C6EF9714010958D95A6F9075C8026B1D`，mtime 11-28 05:19:19 |
| 对照打补丁版 | 78,204,689 B，SHA `C74A030F95991FD2BD822C579A7AAAC2221594CDA3A17C952C4B523AECAD45A4` |
| 与改装前一致 | 是（改装前的 exe 就是 78,204,213 B / `77FCC628…`） |

## 3 S3 两次对照（未打补丁 + 缓存已热）

起跑与 task-2 完全一致：先 `Stop-Process -Name victory` 循环到 0（每局输出 `pre_leftover=0`），再经 `<ROOT>\fork-eval\h1-launch-mode5.ps1` 调 `scripts\play-foxhound.ps1`，开关与 task-2 逐项相同：

```
-Exe <game>\game_scarlett_master.exe -Build release -SeriesS -Dlss performance -FrameGen -Fps 1000
-More @{ VICTORY_PLACED_ORDER='1'; VICTORY_KEYS='30:Enter,45:Enter,60:Enter,75:Enter,90:Enter,105:Enter,120:Enter,150:Enter,180:Enter' }
```

采样同 task-2：战前 15 s 一点；进世界（`draws ≥ 1500`）后每 5 s 一点，采 20 点；`count` 列全程 **1**（同一时刻只有一个 victory）。

### 3.1 repD（start 05:19:23，launcher_pid 22880，world_from_s=75，elapsed 183 s）

```
t=  15s pid=1664 count=1 priv_MB=6749.1 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  30s pid=1664 count=1 priv_MB=6776 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  45s pid=1664 count=1 priv_MB=7024.8 draws=4 ms=5.6 [Americas | VIctory-NVIDIA 179 fps 5.6 ms/frame 4 draws/frame]
t=  60s pid=1664 count=1 priv_MB=7454.9 draws=9 ms=33.3 [Americas | VIctory-NVIDIA 30 fps 33.3 ms/frame 9 draws/frame]
t=  75s pid=1664 count=1 priv_MB=17211.6 draws=4042 ms=168.5 [Americas | VIctory-NVIDIA 6 fps 168.5 ms/frame 4042 draws/frame]  <-- WORLD
t=  80s pid=1664 count=1 priv_MB=18411.8 draws=2852 ms=153.3 [Americas | VIctory-NVIDIA 7 fps 153.3 ms/frame 2852 draws/frame]
t=  85s pid=1664 count=1 priv_MB=18720 draws=2932 ms=92.4 [Americas | VIctory-NVIDIA 11 fps 92.4 ms/frame 2932 draws/frame]
t=  90s pid=1664 count=1 priv_MB=18703.2 draws=1606 ms=74.7 [Americas | VIctory-NVIDIA 13 fps 74.7 ms/frame 1606 draws/frame]
t=  95s pid=1664 count=1 priv_MB=18984.8 draws=3563 ms=97.1 [Americas | VIctory-NVIDIA 10 fps 97.1 ms/frame 3563 draws/frame]
t= 100s pid=1664 count=1 priv_MB=18994.6 draws=3397 ms=89.5 [Americas | VIctory-NVIDIA 11 fps 89.5 ms/frame 3397 draws/frame]
t= 105s pid=1664 count=1 priv_MB=18952.1 draws=554 ms=56.9 [Americas | VIctory-NVIDIA 18 fps 56.9 ms/frame 554 draws/frame]
t= 110s pid=1664 count=1 priv_MB=18876.5 draws=549 ms=52.7 [Americas | VIctory-NVIDIA 19 fps 52.7 ms/frame 549 draws/frame]
t= 115s pid=1664 count=1 priv_MB=19041.8 draws=3043 ms=84.5 [Americas | VIctory-NVIDIA 12 fps 84.5 ms/frame 3043 draws/frame]
t= 120s pid=1664 count=1 priv_MB=18955.9 draws=2953 ms=81.9 [Americas | VIctory-NVIDIA 12 fps 81.9 ms/frame 2953 draws/frame]
t= 125s pid=1664 count=1 priv_MB=18883.9 draws=3489 ms=77.5 [Americas | VIctory-NVIDIA 13 fps 77.5 ms/frame 3489 draws/frame]
t= 130s pid=1664 count=1 priv_MB=19013.2 draws=585 ms=54.1 [Americas | VIctory-NVIDIA 18 fps 54.1 ms/frame 585 draws/frame]
t= 135s pid=1664 count=1 priv_MB=19276.4 draws=3872 ms=92.1 [Americas | VIctory-NVIDIA 11 fps 92.1 ms/frame 3872 draws/frame]
t= 140s pid=1664 count=1 priv_MB=19321.8 draws=2740 ms=78.7 [Americas | VIctory-NVIDIA 13 fps 78.7 ms/frame 2740 draws/frame]
t= 145s pid=1664 count=1 priv_MB=19240.2 draws=2483 ms=72.2 [Americas | VIctory-NVIDIA 14 fps 72.2 ms/frame 2483 draws/frame]
t= 150s pid=1664 count=1 priv_MB=19249.9 draws=2747 ms=102.9 [Americas | VIctory-NVIDIA 10 fps 102.9 ms/frame 2747 draws/frame]
t= 155s pid=1664 count=1 priv_MB=19313.9 draws=3180 ms=91.1 [Americas | VIctory-NVIDIA 11 fps 91.1 ms/frame 3180 draws/frame]
t= 160s pid=1664 count=1 priv_MB=19322.5 draws=4263 ms=110.3 [Americas | VIctory-NVIDIA 9 fps 110.3 ms/frame 4263 draws/frame]
t= 165s pid=1664 count=1 priv_MB=19294.1 draws=4061 ms=108.1 [Americas | VIctory-NVIDIA 9 fps 108.1 ms/frame 4061 draws/frame]
t= 170s pid=1664 count=1 priv_MB=19532.7 draws=4745 ms=112.9 [Americas | VIctory-NVIDIA 9 fps 112.9 ms/frame 4745 draws/frame]
world_from_s=75 post_points=20 -> stop (cap reached)
leftover_procs=0
```

### 3.2 repE（start 05:22:29，launcher_pid 9972，world_from_s=75，elapsed 180 s）

```
t=  15s pid=6716 count=1 priv_MB=6629.1 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  30s pid=6716 count=1 priv_MB=6484.6 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  45s pid=6716 count=1 priv_MB=6773.7 draws=4 ms=5.7 [Americas | VIctory-NVIDIA 175 fps 5.7 ms/frame 4 draws/frame]
t=  60s pid=6716 count=1 priv_MB=7279.2 draws=9 ms=33.4 [Americas | VIctory-NVIDIA 30 fps 33.4 ms/frame 9 draws/frame]
t=  75s pid=6716 count=1 priv_MB=17667 draws=2935 ms=147.7 [Americas | VIctory-NVIDIA 7 fps 147.7 ms/frame 2935 draws/frame]  <-- WORLD
t=  80s pid=6716 count=1 priv_MB=18462 draws=1264 ms=66.9 [Americas | VIctory-NVIDIA 15 fps 66.9 ms/frame 1264 draws/frame]
t=  85s pid=6716 count=1 priv_MB=18590.3 draws=2749 ms=73.6 [Americas | VIctory-NVIDIA 14 fps 73.6 ms/frame 2749 draws/frame]
t=  90s pid=6716 count=1 priv_MB=18743.8 draws=1569 ms=73.5 [Americas | VIctory-NVIDIA 14 fps 73.5 ms/frame 1569 draws/frame]
t=  95s pid=6716 count=1 priv_MB=18985.5 draws=3335 ms=87.2 [Americas | VIctory-NVIDIA 11 fps 87.2 ms/frame 3335 draws/frame]
t= 100s pid=6716 count=1 priv_MB=19000.2 draws=3322 ms=78.7 [Americas | VIctory-NVIDIA 13 fps 78.7 ms/frame 3322 draws/frame]
t= 105s pid=6716 count=1 priv_MB=18976.9 draws=530 ms=52.7 [Americas | VIctory-NVIDIA 19 fps 52.7 ms/frame 530 draws/frame]
t= 110s pid=6716 count=1 priv_MB=19083.8 draws=2905 ms=91.8 [Americas | VIctory-NVIDIA 11 fps 91.8 ms/frame 2905 draws/frame]
t= 115s pid=6716 count=1 priv_MB=19033 draws=2959 ms=75.9 [Americas | VIctory-NVIDIA 13 fps 75.9 ms/frame 2959 draws/frame]
t= 120s pid=6716 count=1 priv_MB=19009.8 draws=3747 ms=76.4 [Americas | VIctory-NVIDIA 13 fps 76.4 ms/frame 3747 draws/frame]
t= 125s pid=6716 count=1 priv_MB=18880.9 draws=2044 ms=64.6 [Americas | VIctory-NVIDIA 15 fps 64.6 ms/frame 2044 draws/frame]
t= 130s pid=6716 count=1 priv_MB=19096.1 draws=3745 ms=84.9 [Americas | VIctory-NVIDIA 12 fps 84.9 ms/frame 3745 draws/frame]
t= 135s pid=6716 count=1 priv_MB=19234.4 draws=2512 ms=75.1 [Americas | VIctory-NVIDIA 13 fps 75.1 ms/frame 2512 draws/frame]
t= 140s pid=6716 count=1 priv_MB=19292 draws=3144 ms=79 [Americas | VIctory-NVIDIA 13 fps 79.0 ms/frame 3144 draws/frame]
t= 145s pid=6716 count=1 priv_MB=19259.9 draws=2714 ms=67.9 [Americas | VIctory-NVIDIA 15 fps 67.9 ms/frame 2714 draws/frame]
t= 150s pid=6716 count=1 priv_MB=19230.6 draws=3170 ms=84 [Americas | VIctory-NVIDIA 12 fps 84.0 ms/frame 3170 draws/frame]
t= 155s pid=6716 count=1 priv_MB=19304 draws=3015 ms=81.3 [Americas | VIctory-NVIDIA 12 fps 81.3 ms/frame 3015 draws/frame]
t= 160s pid=6716 count=1 priv_MB=19498.7 draws=4106 ms=299.2 [Americas | VIctory-NVIDIA 3 fps 299.2 ms/frame 4106 draws/frame]
t= 165s pid=6716 count=1 priv_MB=19716.3 draws=3145 ms=85.3 [Americas | VIctory-NVIDIA 12 fps 85.3 ms/frame 3145 draws/frame]
t= 170s pid=6716 count=1 priv_MB=19810.5 draws=5322 ms=104.8 [Americas | VIctory-NVIDIA 10 fps 104.8 ms/frame 5322 draws/frame]
world_from_s=75 post_points=20 -> stop (cap reached)
leftover_procs=0
```

## 4 S4 两次对照的「最后 4 个稳态点」

稳态判据与 task-2 相同：点在世界窗口内（`draws ≥ 1500`），据此剔除各局 `draws < 1500` 的过场点（repD t=105 s 的 554、t=110 s 的 549、t=130 s 的 585；repE t=80 s 的 1264、t=90 s 的 1569 保留、t=105 s 的 530 剔除）。

| rep | 最后 4 个稳态点（t: ms / draws） | median ms | median draws | µs/draw |
| --- | --- | --- | --- | --- |
| repD | t155: 91.1 / 3180；t160: 110.3 / 4263；t165: 108.1 / 4061；t170: 112.9 / 4745 | **109.20** | **4162** | **26.24** |
| repE | t155: 81.3 / 3015；t160: 299.2 / 4106；t165: 85.3 / 3145；t170: 104.8 / 5322 | **95.05** | **3625.5** | **26.22** |

- median 取 4 点中间两值平均；µs/draw = `median_ms × 1000 / median_draws`（repD 109.20×1000/4162 = 26.24；repE 95.05×1000/3625.5 = 26.22）。
- 世界窗全量单点（未做任何剔除）：repD ms 168.5, 168.5, 153.3, 92.4, 74.7, 97.1, 89.5, 84.5, 81.9, 77.5, 92.1, 78.7, 72.2, 102.9, 91.1, 110.3, 108.1, 112.9；repE ms 147.7, 147.7, 73.6, 73.5, 87.2, 78.7, 91.8, 75.9, 76.4, 64.6, 84.9, 75.1, 79.0, 67.9, 84.0, 81.3, 299.2, 85.3, 104.8。
- 两次对照的区间落点（只报落点，不判定）：**26.24 / 26.22，均在任务单 20–35 区间内**；未落在 70–130 区间。
- 与 task-2 三次（24.81 / 24.60 / 30.10）的差值：+1.43 / +1.64 / −3.88 µs/draw。

## 5 边界与隔离核对

| 项 | 结果 |
| --- | --- |
| 本轮改动文件 | 仅 `apps\victory\src\play.rs`（还原动作，SHA 回到 `F0230B50…`）；备份 `play.rs.h1-orig` 保留 |
| 编译产物 | 仅 `<ROOT>\VIctory-NVIDIA-main\target`（78,204,213 B / `77FCC628…`） |
| `<ROOT>\cool_fox\cool_fox-main` | 未写（本轮未触碰；其 `target\release\victory.exe` 仍为 `4230CCF9…`） |
| `<ROOT>\victory-data*` | 未写 |
| bench/smoke 脚本 | 未改（`play-gta6-framegen.ps1`、`play-foxhound.ps1` 只被调用） |
| 同一时刻 victory 进程数 | 每 5 s 采样 `count` 列全为 1 |
| 每局 leftover | repD / repE 均 `leftover_procs=0`；收尾 `Get-Process -Name victory` = 0 |
| 起跑前清场 | 每局 `pre_leftover=0` |

## 6 出处

- 还原：`<ROOT>\VIctory-NVIDIA-main\apps\victory\src\play.rs`（+`.h1-orig`）。
- 构建：`<ROOT>\fork-eval\h2-build.log`。
- 运行/采样：`<ROOT>\fork-eval\h1-launch-mode5.ps1`、`h1-run2.ps1`、`h2-repD.out.txt`、`h2-repE.out.txt`、`h1-repD-samples.txt`、`h1-repE-samples.txt`、`h1-repD-launch.log(.err.log)`、`h1-repE-launch.log(.err.log)`。
- 对照数据（task-2）：`h1-repA/B/C-samples.txt`、`h1-repA/B/C.out.txt`。
