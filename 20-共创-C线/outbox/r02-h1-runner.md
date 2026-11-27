# r02-h1 执行端回填 — VIctory-NVIDIA 按本机硬件改 SETTINGS 默认值 + 三 rep 复测

时间：2026-11-28 04:53–05:20（Asia/Shanghai）。执行端：exec-runner。只报数。
机器：RTX 3060 Ti 8 GB / 31.84 GB RAM / 8 逻辑核（`ProcessorCount` 决定脚本只加 `VICTORY_PLACED_ORDER=1`，不加 16/24 核那套池子）。

## 0 摘要（数字）

| rep | 进世界 t | 世界点数 | 最后 4 稳态点 median ms | median draws | **µs/draw** | priv 峰 | leftover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| repA（05:08:33） | 75 s | 19 | 112.25 | 4524 | **24.81** | 19494 MB | 0 |
| repB（05:11:38） | 75 s | 19 | 110.55 | 4494.5 | **24.60** | 19603 MB | 0 |
| repC（05:14:44） | 85 s | 17 | 121.95 | 4051 | **30.10** | 19473 MB | 0 |

同口径（项目里 `bench.ps1` 的 upper-median = `Skip([int](n/2)) -First 1`）值：repA 119.1 ms / 4881 = **24.40**；repB 118.2 ms / 4987 = **23.70**；repC 125.3 ms / 4723 = **26.53**。

## 1 S1 改动（只改 `apps\victory\src\play.rs`）

备份：`play.rs.h1-orig`，46,599 B，SHA `F0230B50AF6D2BAC25277C32F65242D9CC89EBB9BE75A9A8785D0F822B16CF2B`（= 改前本体）。

改后：46,980 B，SHA `C1D6460FD01AA70F80A98483A34697A64A45764B17B8296A0028D8BEFE2BFCBC`，行数 996 → 1005（+9 行：8 条追加 + 1 行注释）。

该树不是 git 仓库（`<ROOT>\VIctory-NVIDIA-main\.git` 不存在），故贴 `Select-String` 原文（L58、L83 改动，L106–L113 追加）：

```
L58:     ("VICTORY_JOIN_PARTS", "6"),
L83:     ("VICTORY_LEVELS_ON_DEMAND", "1"),
L106:     ("VICTORY_THIN_THREADS", "6"),
L107:     ("VICTORY_UNDER_THREADS", "4"),
L108:     ("VICTORY_LAND_THREADS", "4"),
L109:     ("VICTORY_PIPELINE_WORKERS", "4"),
L110:     ("VICTORY_MEMORY_CARD_MB", "1536"),
L111:     ("VICTORY_KEEP_SNAPSHOTS_MB", "64"),
L112:     ("VICTORY_INPLACE_MB", "512"),
L113:     ("VICTORY_TEXTURE_BUDGET_MB", "768"),
```

追加前核对：这 8 个 key 在 `play.rs` 里原本命中数均为 0（无重复定义）。`const SETTINGS` 仍从 L55 起，`];` 由 L105 变为 L114。除这 10 行外的字面量未动。

## 2 S2 重建

| 项 | 值 |
| --- | --- |
| 环境 | `CARGO_HOME=G:\rust\cargo`、`RUSTUP_HOME=G:\rust\rustup`、`PATH=G:\rust\cargo\bin;D:\YunX-toolchain\w64devkit\w64devkit\bin;C:\Windows\System32;…` |
| 工具链 | `cargo 1.98.1 (797e8a9bc 2026-08-05)`、`rustc 1.98.1 (48a229cea 2026-09-01)` |
| 命令 | `cargo build --release --locked -p victory`（cwd = `<ROOT>\VIctory-NVIDIA-main`） |
| EXIT | **0**（`build_LASTEXITCODE=0`） |
| 耗时 | 11.3 s（增量：只有 `victory` bin crate 重编，`Finished release [optimized + debuginfo] target(s) in 11.30s`） |
| errors / warnings | **errors=0**，warnings=13（`victory-gpu (lib) generated 12 warnings` + 1 条汇总；均为既有 warning，见 `h1-build.err.log`） |
| 新 exe | `target\release\victory.exe` **78,204,689 B**，SHA `C74A030F95991FD2BD822C579A7AAAC2221594CDA3A17C952C4B523AECAD45A4`，mtime 11-28 04:54:00 |
| 原 exe | 78,204,213 B，SHA `77FCC6283A0FB86FBCA770167E05EB45C6EF9714010958D95A6F9075C8026B1D` |
| 复验 | 再跑一次 `cargo build --release --locked -p victory` → `Finished in 0.24s`、`LASTEXITCODE=0`、exe SHA 不变 |

## 3 S3 复测（mode 5）

启动命令（每次起跑前先 `Stop-Process -Name victory` 循环到 0，每局之间与每局结束都确认 0）：

```
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\play-gta6-framegen.ps1 -GameDir '<ROOT>\<DUMP>' -Mode 5
```

**必须记录的一处偏离**：`play.rs:854-866` 会把所有继承来的 `VICTORY_*`（`KEPT` 之外）**先删掉再设自己的**，而 `play-gta6-framegen.ps1:123` 又用 `$opts.More = $more` 覆盖了 `-More`，所以 mode 5 自身无法携带按键。第一次按任务原文跑（无键）时，标题停在**「选择账户　Y　PLAYER　A」**界面（截图 `h1-rep2-shot-050355.png`），`priv_MB` 恒 6823、`8 draws` 6 分钟不动；`SendKeys` 也抢不到前台（`SetForegroundWindow` 返回后 `GetForegroundWindow() != 游戏窗口`）。因此三次正式 rep 改为**同一 mode 5 开关 + 只多一条 `-More @{VICTORY_KEYS=...}`**，经由我自己的启动器 `<ROOT>\fork-eval\h1-launch-mode5.ps1` 调用同一个 `scripts\play-foxhound.ps1`：

```
-Exe <game>\game_scarlett_master.exe -Build release -SeriesS -Dlss performance -FrameGen -Fps 1000
-More @{ VICTORY_PLACED_ORDER='1'; VICTORY_KEYS='30:Enter,45:Enter,60:Enter,75:Enter,90:Enter,105:Enter,120:Enter,150:Enter,180:Enter' }
```

（`play-gta6-framegen.ps1` 的 mode 5 = `SeriesS + Dlss performance + FrameGen + Fps 1000`，另加 `VICTORY_PLACED_ORDER=1` 与 High priority；`-More` 里那条 placed order 我保留了。**未改任何脚本、未改 play.rs 以外源码**。）

采样：战前每 15 s 一点；进世界（`draws ≥ 1500`）后每 5 s 一点，采到 20 点。进程表用 `Get-Process -Name victory`，取 `Path` 以仓库为前缀、`StartTime` 最新者；`count` 列全程为 **1**（同一时刻只有一个 victory）。

### 3.1 repA（start 05:08:33，launcher_pid 19724，world_from_s=75，elapsed 182 s）

```
t=  15s pid=17932 count=1 priv_MB=6567.8 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  30s pid=17932 count=1 priv_MB=6410.3 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  45s pid=17932 count=1 priv_MB=6894.6 draws=4 ms=5.6 [Americas | VIctory-NVIDIA 179 fps 5.6 ms/frame 4 draws/frame]
t=  60s pid=17932 count=1 priv_MB=7272.9 draws=9 ms=33.4 [Americas | VIctory-NVIDIA 30 fps 33.4 ms/frame 9 draws/frame]
t=  75s pid=17932 count=1 priv_MB=16942.1 draws=3139 ms=384 [Americas | VIctory-NVIDIA 3 fps 384.0 ms/frame 3139 draws/frame]  <-- WORLD
t=  80s pid=17932 count=1 priv_MB=17360 draws=2202 ms=307.1 [Americas | VIctory-NVIDIA 3 fps 307.1 ms/frame 2202 draws/frame]
t=  85s pid=17932 count=1 priv_MB=17712.4 draws=- ms=- []          <- 标题瞬间为空
t=  90s pid=17932 count=1 priv_MB=17860.8 draws=1508 ms=297.4 [Americas | VIctory-NVIDIA 3 fps 297.4 ms/frame 1508 draws/frame]
t=  95s pid=17932 count=1 priv_MB=18194.5 draws=2917 ms=301.7 [Americas | VIctory-NVIDIA 3 fps 301.7 ms/frame 2917 draws/frame]
t= 100s pid=17932 count=1 priv_MB=18301.6 draws=2978 ms=308.2 [Americas | VIctory-NVIDIA 3 fps 308.2 ms/frame 2978 draws/frame]
t= 105s pid=17932 count=1 priv_MB=18388.8 draws=471 ms=289.5 [Americas | VIctory-NVIDIA 3 fps 289.5 ms/frame 471 draws/frame]
t= 110s pid=17932 count=1 priv_MB=18612.8 draws=4320 ms=413.6 [Americas | VIctory-NVIDIA 2 fps 413.6 ms/frame 4320 draws/frame]
t= 115s pid=17932 count=1 priv_MB=18813.5 draws=3125 ms=295.8 [Americas | VIctory-NVIDIA 3 fps 295.8 ms/frame 3125 draws/frame]
t= 120s pid=17932 count=1 priv_MB=18834.8 draws=4322 ms=320 [Americas | VIctory-NVIDIA 3 fps 320.0 ms/frame 4322 draws/frame]
t= 125s pid=17932 count=1 priv_MB=18924.3 draws=4370 ms=414.2 [Americas | VIctory-NVIDIA 2 fps 414.2 ms/frame 4370 draws/frame]
t= 130s pid=17932 count=1 priv_MB=19019.8 draws=2680 ms=266.5 [Americas | VIctory-NVIDIA 4 fps 266.5 ms/frame 2680 draws/frame]
t= 135s pid=17932 count=1 priv_MB=19164.3 draws=4113 ms=298.1 [Americas | VIctory-NVIDIA 3 fps 298.1 ms/frame 4113 draws/frame]
t= 140s pid=17932 count=1 priv_MB=18995.7 draws=3497 ms=243.2 [Americas | VIctory-NVIDIA 4 fps 243.2 ms/frame 3497 draws/frame]
t= 145s pid=17932 count=1 priv_MB=19116 draws=2586 ms=87.2 [Americas | VIctory-NVIDIA 11 fps 87.2 ms/frame 2586 draws/frame]
t= 150s pid=17932 count=1 priv_MB=19169.7 draws=2547 ms=167 [Americas | VIctory-NVIDIA 6 fps 167.0 ms/frame 2547 draws/frame]
t= 155s pid=17932 count=1 priv_MB=19019.4 draws=3429 ms=93.2 [Americas | VIctory-NVIDIA 11 fps 93.2 ms/frame 3429 draws/frame]
t= 160s pid=17932 count=1 priv_MB=19083.6 draws=4167 ms=105.4 [Americas | VIctory-NVIDIA 9 fps 105.4 ms/frame 4167 draws/frame]
t= 165s pid=17932 count=1 priv_MB=19441.6 draws=5379 ms=583.6 [Americas | VIctory-NVIDIA 2 fps 583.6 ms/frame 5379 draws/frame]
t= 170s pid=17932 count=1 priv_MB=19494 draws=4881 ms=119.1 [Americas | VIctory-NVIDIA 8 fps 119.1 ms/frame 4881 draws/frame]
world_from_s=75 post_points=20 -> stop (cap reached)
leftover_procs=0
```

### 3.2 repB（start 05:11:38，launcher_pid 13772，world_from_s=75，elapsed 183 s）

```
t=  15s pid=22012 count=1 priv_MB=6535.1 draws=8 ms=5.5 [Americas | VIctory-NVIDIA 180 fps 5.5 ms/frame 8 draws/frame]
t=  30s pid=22012 count=1 priv_MB=6558.3 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  45s pid=22012 count=1 priv_MB=6743.8 draws=4 ms=6.4 [Americas | VIctory-NVIDIA 157 fps 6.4 ms/frame 4 draws/frame]
t=  60s pid=22012 count=1 priv_MB=7092.7 draws=8 ms=33.3 [Americas | VIctory-NVIDIA 30 fps 33.3 ms/frame 8 draws/frame]
t=  75s pid=22012 count=1 priv_MB=16951.8 draws=3424 ms=324.6 [Americas | VIctory-NVIDIA 3 fps 324.6 ms/frame 3424 draws/frame]  <-- WORLD
t=  80s pid=22012 count=1 priv_MB=17622.5 draws=2143 ms=348.5 [Americas | VIctory-NVIDIA 3 fps 348.5 ms/frame 2143 draws/frame]
t=  85s pid=22012 count=1 priv_MB=17971.6 draws=2721 ms=430 [Americas | VIctory-NVIDIA 2 fps 430.0 ms/frame 2721 draws/frame]
t=  90s pid=22012 count=1 priv_MB=18389.9 draws=1425 ms=94.2 [Americas | VIctory-NVIDIA 11 fps 94.2 ms/frame 1425 draws/frame]
t=  95s pid=22012 count=1 priv_MB=18806.6 draws=3383 ms=116.3 [Americas | VIctory-NVIDIA 9 fps 116.3 ms/frame 3383 draws/frame]
t= 100s pid=22012 count=1 priv_MB=18879.7 draws=3436 ms=99.2 [Americas | VIctory-NVIDIA 10 fps 99.2 ms/frame 3436 draws/frame]
t= 105s pid=22012 count=1 priv_MB=18769 draws=547 ms=63.8 [Americas | VIctory-NVIDIA 16 fps 63.8 ms/frame 547 draws/frame]
t= 110s pid=22012 count=1 priv_MB=18929.9 draws=3357 ms=150.5 [Americas | VIctory-NVIDIA 7 fps 150.5 ms/frame 3357 draws/frame]
t= 115s pid=22012 count=1 priv_MB=18693.6 draws=3009 ms=104.3 [Americas | VIctory-NVIDIA 10 fps 104.3 ms/frame 3009 draws/frame]
t= 120s pid=22012 count=1 priv_MB=18656.3 draws=3763 ms=94 [Americas | VIctory-NVIDIA 11 fps 94.0 ms/frame 3763 draws/frame]
t= 125s pid=22012 count=1 priv_MB=18670.7 draws=1917 ms=75.5 [Americas | VIctory-NVIDIA 13 fps 75.5 ms/frame 1917 draws/frame]
t= 130s pid=22012 count=1 priv_MB=18812.9 draws=3072 ms=119 [Americas | VIctory-NVIDIA 8 fps 119.0 ms/frame 3072 draws/frame]
t= 135s pid=22012 count=1 priv_MB=19029.3 draws=3178 ms=104.3 [Americas | VIctory-NVIDIA 10 fps 104.3 ms/frame 3178 draws/frame]
t= 140s pid=22012 count=1 priv_MB=19025.4 draws=3189 ms=90.3 [Americas | VIctory-NVIDIA 11 fps 90.3 ms/frame 3189 draws/frame]
t= 145s pid=22012 count=1 priv_MB=19073 draws=3001 ms=84.2 [Americas | VIctory-NVIDIA 12 fps 84.2 ms/frame 3001 draws/frame]
t= 150s pid=22012 count=1 priv_MB=19170.5 draws=3158 ms=102.7 [Americas | VIctory-NVIDIA 10 fps 102.7 ms/frame 3158 draws/frame]
t= 155s pid=22012 count=1 priv_MB=19206 draws=3207 ms=97.3 [Americas | VIctory-NVIDIA 10 fps 97.3 ms/frame 3207 draws/frame]
t= 160s pid=22012 count=1 priv_MB=19296.5 draws=4002 ms=102.9 [Americas | VIctory-NVIDIA 10 fps 102.9 ms/frame 4002 draws/frame]
t= 165s pid=22012 count=1 priv_MB=19386.3 draws=6135 ms=516.7 [Americas | VIctory-NVIDIA 2 fps 516.7 ms/frame 6135 draws/frame]
t= 170s pid=22012 count=1 priv_MB=19603.2 draws=4987 ms=118.2 [Americas | VIctory-NVIDIA 8 fps 118.2 ms/frame 4987 draws/frame]
world_from_s=75 post_points=20 -> stop (cap reached)
leftover_procs=0
```

### 3.3 repC（start 05:14:44，launcher_pid 22820，world_from_s=85，elapsed 193 s）

```
t=  15s pid=3992 count=1 priv_MB=6669.3 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  30s pid=3992 count=1 priv_MB=6554.1 draws=8 ms=5.6 [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t=  45s pid=3992 count=1 priv_MB=6945 draws=4 ms=7.4 [Americas | VIctory-NVIDIA 136 fps 7.4 ms/frame 4 draws/frame]
t=  60s pid=3992 count=1 priv_MB=7364.1 draws=8 ms=33.4 [Americas | VIctory-NVIDIA 30 fps 33.4 ms/frame 8 draws/frame]
t=  75s pid=3992 count=1 priv_MB=11238.4 draws=9 ms=35.4 [Americas | VIctory-NVIDIA 28 fps 35.4 ms/frame 9 draws/frame]
t=  85s pid=3992 count=1 priv_MB=17610.7 draws=3457 ms=151.8 [Americas | VIctory-NVIDIA 7 fps 151.8 ms/frame 3457 draws/frame]  <-- WORLD
t=  90s pid=3992 count=1 priv_MB=18516.4 draws=1492 ms=93.4 [Americas | VIctory-NVIDIA 11 fps 93.4 ms/frame 1492 draws/frame]
t=  95s pid=3992 count=1 priv_MB=18632.6 draws=2819 ms=153 [Americas | VIctory-NVIDIA 7 fps 153.0 ms/frame 2819 draws/frame]
t= 100s pid=3992 count=1 priv_MB=18693.1 draws=3311 ms=104.1 [Americas | VIctory-NVIDIA 10 fps 104.1 ms/frame 3311 draws/frame]
t= 105s pid=3992 count=1 priv_MB=18820.5 draws=3472 ms=97.1 [Americas | VIctory-NVIDIA 10 fps 97.1 ms/frame 3472 draws/frame]
t= 110s pid=3992 count=1 priv_MB=18851.2 draws=3448 ms=95.7 [Americas | VIctory-NVIDIA 10 fps 95.7 ms/frame 3448 draws/frame]
t= 115s pid=3992 count=1 priv_MB=18819.1 draws=575 ms=86 [Americas | VIctory-NVIDIA 12 fps 86.0 ms/frame 575 draws/frame]
t= 120s pid=3992 count=1 priv_MB=18943.5 draws=3652 ms=112.3 [Americas | VIctory-NVIDIA 9 fps 112.3 ms/frame 3652 draws/frame]
t= 125s pid=3992 count=1 priv_MB=18858.7 draws=3128 ms=109.7 [Americas | VIctory-NVIDIA 9 fps 109.7 ms/frame 3128 draws/frame]
t= 130s pid=3992 count=1 priv_MB=18794.6 draws=2872 ms=3751.8 [Americas | VIctory-NVIDIA 0 fps 3751.8 ms/frame 2872 draws/frame]
t= 135s pid=3992 count=1 priv_MB=18760.8 draws=665 ms=76.9 [Americas | VIctory-NVIDIA 13 fps 76.9 ms/frame 665 draws/frame]
t= 140s pid=3992 count=1 priv_MB=18892.2 draws=3732 ms=146.3 [Americas | VIctory-NVIDIA 7 fps 146.3 ms/frame 3732 draws/frame]
t= 145s pid=3992 count=1 priv_MB=19040.6 draws=2669 ms=93.6 [Americas | VIctory-NVIDIA 11 fps 93.6 ms/frame 2669 draws/frame]
t= 150s pid=3992 count=1 priv_MB=19000.6 draws=3561 ms=107.9 [Americas | VIctory-NVIDIA 9 fps 107.9 ms/frame 3561 draws/frame]
t= 155s pid=3992 count=1 priv_MB=19019.5 draws=2959 ms=94 [Americas | VIctory-NVIDIA 11 fps 94.0 ms/frame 2959 draws/frame]
t= 160s pid=3992 count=1 priv_MB=19065.2 draws=4660 ms=131.7 [Americas | VIctory-NVIDIA 8 fps 131.7 ms/frame 4660 draws/frame]
t= 165s pid=3992 count=1 priv_MB=19009.1 draws=3374 ms=112.6 [Americas | VIctory-NVIDIA 9 fps 112.6 ms/frame 3374 draws/frame]
t= 170s pid=3992 count=1 priv_MB=19050.5 draws=3379 ms=127.6 [Americas | VIctory-NVIDIA 8 fps 127.6 ms/frame 3379 draws/frame]
t= 175s pid=3992 count=1 priv_MB=19313.1 draws=4723 ms=118.6 [Americas | VIctory-NVIDIA 8 fps 118.6 ms/frame 4723 draws/frame]
t= 180s pid=3992 count=1 priv_MB=19472.7 draws=4871 ms=125.3 [Americas | VIctory-NVIDIA 8 fps 125.3 ms/frame 4871 draws/frame]
world_from_s=85 post_points=20 -> stop (cap reached)
leftover_procs=0
```

## 4 S4 三次的「进世界后最后 4 个稳态点」

稳态判据：这些点都在世界窗口内（`draws ≥ 1500`），据此剔除各局里 `draws < 1500` 的过场点（repA t=105 s 的 471、repB t=90 s 的 1425 / t=105 s 的 547、repC t=90 s 的 1492 / t=115 s 的 575 / t=135 s 的 665）。

| rep | 最后 4 个稳态点（t: ms / draws） | median ms | median draws | µs/draw |
| --- | --- | --- | --- | --- |
| repA | t155: 93.2 / 3429；t160: 105.4 / 4167；t165: 583.6 / 5379；t170: 119.1 / 4881 | **112.25** | **4524** | **24.81** |
| repB | t155: 97.3 / 3207；t160: 102.9 / 4002；t165: 516.7 / 6135；t170: 118.2 / 4987 | **110.55** | **4494.5** | **24.60** |
| repC | t165: 112.6 / 3374；t170: 127.6 / 3379；t175: 118.6 / 4723；t180: 125.3 / 4871 | **121.95** | **4051** | **30.10** |

- median 取中间两值的平均（4 个点）；µs/draw = `median_ms × 1000 / median_draws`。
- 项目 `bench.ps1` 口径（upper-median，`Skip([int](n/2)) -First 1`）同表：repA 119.1 / 4881 = 24.40；repB 118.2 / 4987 = 23.70；repC 125.3 / 4723 = 26.53。
- 三点全窗口 min/max：ms 84.2–583.6（含加载尖峰）、draws 1425–6135；priv_MB 世界窗内 16,942–19,603。

## 5 附：不加 `VICTORY_KEYS` 的那一局（任务原文口径，只作旁证）

04:54 那一次按任务原文跑 `play-gta6-framegen.ps1 -Mode 5`（无键）：

```
t= 15s pid=7764 priv_MB=6461.8 draws=1  ms=8.3   [Americas | VIctory-NVIDIA 121 fps 8.3 ms/frame 1 draws/frame]
t= 30s pid=7764 priv_MB=6619.3 draws=8  ms=5.6   [Americas | VIctory-NVIDIA 180 fps 5.6 ms/frame 8 draws/frame]
t= 45s pid=7764 priv_MB=6767.2 draws=4  ms=6.2   [Americas | VIctory-NVIDIA 162 fps 6.2 ms/frame 4 draws/frame]
t= 60s pid=7764 priv_MB=6983.9 draws=9  ms=33.3  [Americas | VIctory-NVIDIA 30 fps 33.3 ms/frame 9 draws/frame]
t= 75s pid=7764 priv_MB=9469.7 draws=9  ms=51.4  [Americas | VIctory-NVIDIA 19 fps 51.4 ms/frame 9 draws/frame]
t= 90s pid=7764 priv_MB=17276.2 draws=2749 ms=293.6 [Americas | VIctory-NVIDIA 3 fps 293.6 ms/frame 2749 draws/frame]
t=105s pid=7764 priv_MB=18017  draws=3358 ms=319.6 [Americas | VIctory-NVIDIA 3 fps 319.6 ms/frame 3358 draws/frame]
t=120s pid=7764 priv_MB=18335  draws=422  ms=283   [Americas | VIctory-NVIDIA 4 fps 283.0 ms/frame 422 draws/frame]
t=135s pid=7764 priv_MB=18381.4 draws=3644 ms=301.1 [Americas | VIctory-NVIDIA 3 fps 301.1 ms/frame 3644 draws/frame]
t=150s pid=7764 priv_MB=18740.6 draws=- ms=- []     <- 标题为空，进程随后自行退出
t=165s <no victory process>
```

该局世界窗只有 4 点（90/105/120/135 s），进程在 ~150 s 自行退出，`leftover_procs=0`。

另一局（05:05:02 起、带键但只采 8 点就停）世界窗点：t75 3802/212.1、t80 1710/288.5、t85 2844/299.1、t90 1506/77.6、t95 3452/93.5、t100 3560/102.3、t105 545/59.9、t110 2010/101.8。

## 6 边界与隔离核对

| 项 | 结果 |
| --- | --- |
| 改动文件 | 仅 `<ROOT>\VIctory-NVIDIA-main\apps\victory\src\play.rs`（10 行字面量）；备份 `play.rs.h1-orig` 在旁 |
| 编译产物 | 仅 `<ROOT>\VIctory-NVIDIA-main\target`（78,204,689 B 新 exe） |
| `<ROOT>\cool_fox\cool_fox-main` | 未写；`target\release\victory.exe` SHA 仍 `4230CCF9B085D040489EBF2AB7421290AAF7DC3151B6C938EB2BAB793ABC5F3C` |
| `<ROOT>\victory-data*` | 未写（8 个既有目录，本轮未新增/未改；本树用的是 `%LOCALAPPDATA%\victory\data`） |
| bench/smoke 脚本 | 未改（`play-gta6-framegen.ps1`、`play-foxhound.ps1` 均未动，只被调用） |
| 同一时刻 victory 进程数 | 每 5 s 采样的 `count` 列全为 1 |
| 每局 leftover | repA / repB / repC 均 `leftover_procs=0`；收尾 `Get-Process -Name victory` = 0 |
| 起跑前清场 | 每局前 `Stop-Process -Name victory` 循环至 0（每局输出 `pre_leftover=0`） |

## 7 出处

- 源码：`<ROOT>\VIctory-NVIDIA-main\apps\victory\src\play.rs`（L55–L114）、`play.rs.h1-orig`。
- 构建：`<ROOT>\fork-eval\h1-build.ps1`、`h1-build.log`、`h1-build.err.log`、`h1-build.out.txt`。
- 启动/采样：`<ROOT>\fork-eval\h1-launch-mode5.ps1`、`h1-run2.ps1`、`h1-rep{A,B,C}-samples.txt`、`h1-rep{A,B,C}.out.txt`、`h1-rep{A,B,C}-launch.log(.err.log)`、`h1-rep1*.txt`、`h1-rep2b.out.txt`。
- 截图（卡在选账户）：`<ROOT>\fork-eval\h1-rep2-shot-050355.png`。
- 游戏侧日志：`<HOME>\AppData\Local\victory\logs\victory-nvidia-20261128-0505*.log` 等。
