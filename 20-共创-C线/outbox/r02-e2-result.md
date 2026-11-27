# r02-e2 回填 · 三阶段流水线（A 自动进世界 / B 冒烟回归 / C 最小移植）

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0440-19.md`。每阶段单独成节，只报数不判读。

## A / P1 —— 自动进世界（`10-实验脚本\auto-enter.ps1`）

脚本：`G:\GTA\cool_fox-优化方案\10-实验脚本\auto-enter.ps1`（UTF-8 带 BOM，`Parser::ParseFile` 0 错）。

| 参数 | 值 |
| --- | --- |
| `-Label` | A1-keys / A2-keys |
| `-Exe` | `target\release\victory.exe`（SHA256 `58E60D62…A4EFF45`） |
| `-Seconds` | 240（默认） |
| `-Keys` | `25:Enter,30:Enter,35:Enter,40:Enter,45:Space`（默认） |
| `VICTORY_KEYS` | 同 `-Keys`，进程启动前注入 |
| 判据 | 窗口标题首个 `draws ≥ 1000` |

`VICTORY_KEYS` 的键表（源码 `crates\victory-hle\src\modules\gameinput.rs:1254-1266`）只认 `Enter`/`Esc`/`Tab`/`Back`/`Up`/`Down`/`Left`/`Right` 与单个字母数字；**`Space` 不在表内，会走 `_ => return None`（该条被丢弃）**。默认串里 `45:Space` 因此不生效，其余四条有效；本阶段按任务单给的默认串原样使用，未改。

### 两次运行（标题序列每 5 s 一条，见 `data\e2-A1-console.log` / `e2-A2-console.log`）

| 次 | entered | entered_at_s | entered_draws | samples | leftover | 收尾时刻 |
| --- | --- | --- | --- | --- | --- | --- |
| A1-keys | True | 68 | 1756 | 48 | 0 | 2026-11-27 04:48:09 |
| A2-keys | True | 65 | 2536 | 48 | 0 | 2026-11-27 04:53:16 |

两次判定行原文：

```text
A1: >> ENTERED at t=68 s draws=1756   / entered=True entered_at_s=68 leftover=0
A2: >> ENTERED at t=65 s draws=2536   / entered=True entered_at_s=65 leftover=0
```

前 40 s 两串都在菜单（`draws=1…8`，`30 fps 33.3 ms/frame`），按钮/键在 `25/30/35/40 s` 注入后于 65–68 s 落到世界段（`draws` 先 1756/2536，随后稳定在 4300–4560）。

**门禁 A：绿**（两次 `entered=True`，`entered_at_s` 68 / 65 s，均在 120 s 内，`leftover=0`）。

## B / P1 —— 冒烟回归（`10-实验脚本\smoke.ps1` + `70-项目E\regression.md`）

脚本：`G:\GTA\cool_fox-优化方案\10-实验脚本\smoke.ps1`（UTF-8 带 BOM，`Parser::ParseFile` 0 错，`parse_errors=0`）。判据全部来自 `10-实验脚本\bench.ps1` 的 filter v2（`Ms>40 且 Draws>=200`），脚本本身不复制判据、只读 `data\bench-v3.csv` 末行断言四项：`world_samples >= 25`、`world_from_s` 非空、`leftover_procs = 0`、`median_ms_world` 非空。退出码 `SMOKE=PASS` → 0，`SMOKE=FAIL` → 1。

回归口径一页：`G:\GTA\cool_fox-优化方案\70-项目E\regression.md`（2739 B）。基线取 `bench-v3.csv` L2 `R10-control` 的 `median_ms_world=250.2`，回归线 `<= 275.2`（+10%），比对段固定 `world_seconds=200`、`-Profile fork`。

### smoke-01：作废（执行端中止，未注入按键）

首轮 `smoke-01` 的预检段通过（`preflight_EXIT=0`），但 bench 段调用 `13-bench-ab.ps1` 时**未把 `VICTORY_KEYS` 传进去**，整段停在菜单（`30 fps / 33.3 ms / draws=8`，至 `t=207 s` 未变），世界窗始终不开。执行端于 `t≈208 s` 收掉进程，bench 自行落行，`bench-v3.csv` L4 为该轮记录（原样保留，按“只追加”不动）：

```text
2026-11-27 04:59:27,smoke-01,200,420,34,,0,ms>40&draws>=200,0,,6.95,18.01,24.33,0,run-smoke-01-1127-045541.log
```

该行 `world_from_s` 为空、`world_samples=0`、`median_ms_world=0`：菜单帧，无世界样本，作废、不参与任何比较。

修正：`smoke.ps1` 增加 `-Keys`（默认同 A 段串），预检与 bench 段都注入（bench 段经 `13-bench-ab.ps1 -Extra "VICTORY_KEYS=<keys>"`）。判据与断言未改。

### smoke-01b：有效

| 项 | 值 |
| --- | --- |
| 标签 | `smoke-01b` |
| 起止 | 2026-11-27 04:59:59 → 05:06:13（374 s） |
| 预检 | `preflight_EXIT=0`（`auto-enter` 150 s，`entered=True`） |
| bench | `bench_EXIT=0`，`-Profile fork`，`-Seconds 420`，`-WorldSeconds 200` |
| 世界窗 | `world_from_s=73`，`window = world+200 s (from t=73 s)` |
| samples | 45（采样总条数） |
| world_samples | 35 |
| median_ms_world | 246 |
| median_draws | 4421 |
| max_priv_gb | 20.83 |
| min_free_gb | 3.64 |
| min_commit_free_gb | 10.38 |
| leftover_procs | 0 |
| post_run_leftover | 0 |
| 退出码 | `SMOKE=PASS` |

新增台账行 `data\bench-v3.csv` L5（原文）：

```text
2026-11-27 05:06:10,smoke-01b,200,420,45,73,35,ms>40&draws>=200,246,4421,20.83,3.64,10.38,0,run-smoke-01b-1127-050127.log
```

`bench-v3.csv` 前后行数：3 → 5（L4 作废行 + L5 有效行）。`bench-v2.csv` 22 行、`bench.csv` 12 行本轮未触碰。日志：`data\e2-smoke01b-console.log`（全文）、`data\auto-smoke-01b-preflight-1127-050002.log`、`data\run-smoke-01b-1127-050127.log`。

相对基线 `250.2`：`246`，差 `-1.7%`（回归线 `275.2` 内）。

**门禁 B：绿**（返回码 0；`leftover_procs=0`；`world_samples=35 >= 25`）。

## C / P2 —— 最小移植（`VICTORY_SETTLE_ROOM`）

挑中开关：`VICTORY_SETTLE_ROOM`（任务单优先级第一档）。判定为自包含：单文件、单 crate、无对外接口变更，仅改 `crates\victory-gpu\src\host.rs`，落在既有两个上限之内（`late_most()` 的 256 组、`stale_under_flights()` 的 `runs_left` 512/4096）。

### 备份

| 项 | 值 |
| --- | --- |
| 备份文件 | `target\release\victory-pre-e3.exe` |
| 大小 | 49,681,038 B |
| 时间 | 2026-11-26 22:02:32 |
| SHA256 | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` |

改前 `victory.exe` 与备份逐字节一致（同长度、同 SHA256），备份未覆盖。

### 改动（`host.rs`，新增 48 行，两处调用 + 一个函数）

| 位置（改后行号） | 内容 |
| --- | --- |
| `host.rs:2607-2613` | `late_most()` 体重排为 `let most = …; if settle_room() { most * 2 } else { most }` |
| `host.rs:2615-2652` | 新增 `fn settle_room() -> bool`（`OnceLock<u8>`：`"1"`→1、`"alt"`→2、其余 0；alt 每 20 s 交替并 `tracing::info!`），doc 注明来源 fxceless/victory-fork |
| `host.rs:3107-3113` | `stale_under_flights()` 内 `runs_left` 起点之后插 `if settle_room() { runs_left = (runs_left * 8).min(1 << 16); }` |

注：本树没有 fork 的 `VICTORY_MERGE_RUNS` 那个 `OnceLock`（`runs_left` 起点直接是 `if card_steps::stage() > 0 { 4096 } else { 512 }`），故 ×8 直接作用在该值上；语义与 fork 一致。`alt` 分支的 `Ordering` 来自本文件既有 `use std::sync::atomic::{AtomicU32, Ordering};`（`host.rs:8`），未新增 import。

### 编译

| 项 | 值 |
| --- | --- |
| 命令 | `cargo build --release --locked -p victory`（`CARGO_HOME=G:\rust\cargo`、`RUSTUP_HOME=G:\rust\rustup`、`RUSTFLAGS=-C target-cpu=native`，工作目录 `G:\GTA\cool_fox\cool_fox-main`） |
| 起止 | 2026-11-27 05:08:37 → 05:10:49 |
| cargo 自报 | `Finished \`release\` profile [optimized + debuginfo] target(s) in 2m 11s` |
| errors | 0（`e2-c3-build.err.log` 中 `^error` 行 0 条） |
| warnings | `victory-gpu` (lib) 12 条（含 `dead_code`/`unused` 类，未逐条核对是否新增） |
| 新产物 | `target\release\victory.exe` 49,691,451 B @2026-11-27 05:10:49，SHA256 `4230CCF9B085D040489EBF2AB7421290AAF7DC3151B6C938EB2BAB793ABC5F3C` |
| 体积差 | +10,413 B（相对 pre-e3） |

日志：`data\e2-c3-build.log`、`data\e2-c3-build.err.log`。

### after 行（`smoke.ps1`，`-Extra "VICTORY_SETTLE_ROOM=1"`）

| 项 | 值 |
| --- | --- |
| 标签 | `smoke-02-settle-room` |
| 起止 | 2026-11-27 05:12:30 → 05:18:47（377 s） |
| 注入原文行 | `extra=VICTORY_KEYS=25:Enter,30:Enter,35:Enter,40:Enter,45:Space;VICTORY_SETTLE_ROOM=1` |
| 预检 | `preflight_EXIT=0` |
| bench | `bench_EXIT=0`，`-Profile fork`，`-Seconds 420`，`-WorldSeconds 200` |
| 世界窗 | `world_from_s=68`，`window = world+200 s (from t=68 s)` |
| samples | 44 |
| world_samples | 34 |
| median_ms_world | 242.8 |
| median_draws | 4315 |
| max_priv_gb | 20.68 |
| min_free_gb | 3.37 |
| min_commit_free_gb | 10.51 |
| leftover_procs | 0 / post_run 0 |
| 退出码 | `SMOKE=PASS` |

新增台账行 `data\bench-v3.csv` L6（原文）：

```text
2026-11-27 05:18:43,smoke-02-settle-room,200,420,44,68,34,ms>40&draws>=200,242.8,4315,20.68,3.37,10.51,0,run-smoke-02-settle-room-1127-051409.log
```

### 三条行对照（同开关同判据，`world_seconds=200`、`-Profile fork`）

| 标签 | 产物 SHA 前缀 | world_samples | median_ms_world | median_draws | max_priv_gb | min_commit_free_gb | leftover |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `R10-control`（L2） | `58E60D62` | 35 | 250.2 | 4030 | 20.98 | 11.74 | 0 |
| `smoke-01b`（L5，before，新产物无开关） | `4230CCF9` | 35 | 246 | 4421 | 20.83 | 10.38 | 0 |
| `smoke-02-settle-room`（L6，after，新产物 + 开关） | `4230CCF9` | 34 | 242.8 | 4315 | 20.68 | 10.51 | 0 |

差：`smoke-01b` → `smoke-02-settle-room` 为 `-3.2 ms`（`-1.3%`）；对 `R10-control` 为 `-7.4 ms`（`-3.0%`）。均为单次、n=1，未做置换检验。

### 红线核对

| 项 | 结果 |
| --- | --- |
| `data\bench.csv` | 12 行，SHA `0FF0549288706F5B…`，mtime 11-26 22:26:47，未动 |
| `data\bench-v2.csv` | 22 行，SHA `FC8189D8A70B72F1…`，mtime 11-27 02:29:32，未动 |
| `data\bench-v3.csv` | 6 行（表头 + 5），只追加 |
| `crates\victory-core\src\policy.rs` | mtime 11-25 22:33:14，未动 |
| `xtask\src\policy.rs` | mtime 11-25 22:33:14，未动 |
| `rust-toolchain.toml` | mtime 11-25 22:33:14，未动 |
| `.cargo\config.toml` | mtime 11-26 21:34:57，未动 |
| `crates\victory-shader\**` | 最新 mtime 11-25 22:33:14，未动 |
| `target\release\victory-baseline.exe` | 72,407,911 B，SHA `9627DF10…`，未覆盖 |
| `G:\GTA\victory-data\coolfox-cache\pipelines` | 8 个文件长度与 mtime 与清点一致（最新 11-27 03:53:07），未写 |
| `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES` | 全程未设 |
| 并发 | 全程单局，`procs=0` 收尾 |

**门禁 C：绿**（自包含、编译 errors=0、`smoke.ps1` 返回 0、after 行已入 `bench-v3.csv` L6）。

> 附注（05:24）：`smoke-01` 与 `smoke-01b` 跑的都是 pre-e3 产物（SHA256 `58E60D62…A4EFF45`，49,681,038 B）；`smoke-02-settle-room` 跑的是移植后重新编译的产物（SHA256 `4230CCF9…BC5F3C`，49,691,451 B）。
