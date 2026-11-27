# r02-f5 回填 · 开关级 A/B（补丁路线关闭后）

> 执行端本机 Windows。任务单 `inbox\task-20261127-0905-25.md`。六次冒烟全部 `SMOKE=PASS`；`bench-v3.csv` 由 10 行追加到 16 行（L11–L16）。未改源码、未编译、未改判据。

## S1 候选清单（只读生成）

四个计数（任务单脚本原样输出）：

```text
all=365 hot=51 used=40 cand=43
```

补充事实：`cand` 的 43 条里含 3 条小写日志字段名（`victory_safe_copy_after` / `victory_safe_copy_at` / `victory_safe_copy_failed`，因 `Select-String` 默认不区分大小写被并入），按 env 开关口径的大写候选为 **40** 条。按名字排序前三个即本轮 S1/S2/S3：

| 序 | 开关 | 定义处 |
| --- | --- | --- |
| S1 | `VICTORY_ALIAS_COPY` | `crates\victory-gpu\src\resource.rs:1414/1421/1427` |
| S2 | `VICTORY_ASYNC_SUBMIT` | `crates\victory-gpu\src\queue\behind.rs:2/644/649/654/671/692` |
| S3 | `VICTORY_BARRIER_TEST` | `crates\victory-gpu\src\copystat.rs:267/275`（另见 `indirect.rs:515`、`list.rs:2142`） |

前 3 名原文（逐字，含行号）：

```text
resource.rs:1414  /// `VICTORY_ALIAS_COPY=0`: none is found, as before; `=1`: only textures
resource.rs:1421      || !*ON.get_or_init(|| std::env::var_os("VICTORY_ALIAS_COPY").is_none_or(|v| v != "0"))
resource.rs:1427      *WHOLE.get_or_init(|| std::env::var_os("VICTORY_ALIAS_COPY").is_none_or(|v| v != "1"));

queue\behind.rs:2    //! the thread of the title that submits them (`VICTORY_ASYNC_SUBMIT=1`).
queue\behind.rs:644  /// (`VICTORY_ASYNC_SUBMIT=1`; needs flights with the present sent ahead, as
queue\behind.rs:649  if let Some(on) = crate::ab::pick("VICTORY_ASYNC_SUBMIT") {
queue\behind.rs:654      (std::env::var_os("VICTORY_ASYNC_SUBMIT").is_some_and(|v| v == "1") || crate::list::thin::wanted()) && started()
queue\behind.rs:671      tracing::warn!("VICTORY_ASYNC_SUBMIT=1 needs the relay and lists cut at their waits: submissions are prepared by the thread that makes them");
queue\behind.rs:692      "submissions are prepared and sent by a thread of ours, not by the thread that submits (VICTORY_ASYNC_SUBMIT=1)"

copystat.rs:267  /// Whether an experiment on barriers is on (`VICTORY_BARRIER_TEST`): bit 0
copystat.rs:275      *TEST.get_or_init(|| match std::env::var("VICTORY_BARRIER_TEST").as_deref() {
indirect.rs:515   // Diagnostics: counted; `VICTORY_BARRIER_TEST=indirect` leaves the two
list.rs:2142      // Diagnostics: counted, and left out under `VICTORY_BARRIER_TEST=groups`.
```

> 口径事实（不判读）：`VICTORY_ALIAS_COPY` 的默认态即“开”（`is_none_or(|v| v != "0")`），`=1` 在源码里表示“只纹理”这一变体；因此本轮 `sw-VICTORY_ALIAS_COPY-off` 行的 env 是空、`-on` 行的 env 是 `=1`，两者不是同一条布尔轴的两端。`VICTORY_ASYNC_SUBMIT` 默认关，`=1` 才启用，且源码注明需要 relay 与“列表在等待处截断”。`VICTORY_BARRIER_TEST` 按位解析（`=1` 即 bit 0）。

## S2 六次冒烟（顺序固定，一开关一 off/on）

| # | label | 起止 | 预检 entered_at_s | preflight_EXIT | bench_EXIT | SMOKE | csv 行 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `sw-VICTORY_ALIAS_COPY-off` | 09:05:55–09:11:53 | 55 | 0 | 0 | PASS | L11 |
| 2 | `sw-VICTORY_ALIAS_COPY-on`（`VICTORY_ALIAS_COPY=1`） | 09:12:02–09:18:14 | 65 | 0 | 0 | PASS | L12 |
| 3 | `sw-VICTORY_ASYNC_SUBMIT-off` | 09:18:20–09:24:50 | 70 | 0 | 0 | PASS | L13 |
| 4 | `sw-VICTORY_ASYNC_SUBMIT-on`（`VICTORY_ASYNC_SUBMIT=1`） | 09:24:57–09:30:50 | 55 | 0 | 0 | PASS | L14 |
| 5 | `sw-VICTORY_BARRIER_TEST-off` | 09:30:59–09:36:47 | 55 | 0 | 0 | PASS | L15 |
| 6 | `sw-VICTORY_BARRIER_TEST-on`（`VICTORY_BARRIER_TEST=1`） | 09:36:54–09:42:59 | 75 | 0 | 0 | PASS | L16 |

六次均 `entered=True`、`leftover=0`、`post_run_leftover=0`，无早退、无重试。每次 `exe_sha256=4230CCF9B085D040489EBF2AB7421290AAF7DC3151B6C938EB2BAB793ABC5F3C`（与 `victory.exe` 现行产物一致，未重编译）。

## S3 数据（csv 原文 + 每 draw µs）

```text
L11 2026-11-27 09:11:50,sw-VICTORY_ALIAS_COPY-off,200,420,44,62,35,ms>40&draws>=200,274.1,4532,20.13,1.98,8.66,0,run-sw-VICTORY_ALIAS_COPY-off-1127-090712.log
L12 2026-11-27 09:18:11,sw-VICTORY_ALIAS_COPY-on,200,420,44,62,35,ms>40&draws>=200,237.8,4319,20.15,3,10.39,0,run-sw-VICTORY_ALIAS_COPY-on-1127-091335.log
L13 2026-11-27 09:24:47,sw-VICTORY_ASYNC_SUBMIT-off,200,420,45,68,35,ms>40&draws>=200,247.8,4351,20.44,2.75,10.26,0,run-sw-VICTORY_ASYNC_SUBMIT-off-1127-092003.log
L14 2026-11-27 09:30:47,sw-VICTORY_ASYNC_SUBMIT-on,200,420,43,56,35,ms>40&draws>=200,237.8,4268,20.22,2.67,9.99,0,run-sw-VICTORY_ASYNC_SUBMIT-on-1127-092621.log
L15 2026-11-27 09:36:43,sw-VICTORY_BARRIER_TEST-off,200,420,42,50,35,ms>40&draws>=200,252.2,4296,20.45,2.91,10.06,0,run-sw-VICTORY_BARRIER_TEST-off-1127-093220.log
L16 2026-11-27 09:42:56,sw-VICTORY_BARRIER_TEST-on,200,420,42,50,35,ms>40&draws>=200,248,4484,20.49,2.65,10,0,run-sw-VICTORY_BARRIER_TEST-on-1127-093837.log
```

每 draw µs（`median_ms_world*1000/median_draws`，2 位小数）：

| 开关 | off µs | on µs |
| --- | --- | --- |
| `VICTORY_ALIAS_COPY` | 274.1×1000/4532 = **60.48** | 237.8×1000/4319 = **55.06** |
| `VICTORY_ASYNC_SUBMIT` | 247.8×1000/4351 = **56.95** | 237.8×1000/4268 = **55.72** |
| `VICTORY_BARRIER_TEST` | 252.2×1000/4296 = **58.71** | 248×1000/4484 = **55.31** |

六行的其余读数（逐字）：`world_samples` 均为 35；`world_from_s` 依次 62 / 62 / 68 / 56 / 50 / 50；`max_priv_gb` 20.13 / 20.15 / 20.44 / 20.22 / 20.45 / 20.49；`min_commit_free_gb` 8.66 / 10.39 / 10.26 / 9.99 / 10.06 / 10；`leftover_procs` 全 0。

## 异常与原文

- 六次无一早退，故无“早退原文”可贴。
- 三份 `-on` 运行日志中 `Select-String` 对 `VICTORY_ASYNC_SUBMIT` / `VICTORY_ALIAS_COPY` / `VICTORY_BARRIER_TEST` 与 `needs the relay` 的命中均为 **0**（`queue\behind.rs:671` 的 `tracing::warn!` 未出现在本次日志中）。
- 第 2、5、6 次预检首帧出现 `fps=0/ms=3019.4`、`draws=7898` 等进世界瞬间的瞬时值，均为 `auto-enter` 的 5 s 采样窗口原始行，未参与 bench 窗口统计（bench 窗起点分别 62 / 50 / 50 s）。

## 红线核对

| 项 | 结果 |
| --- | --- |
| 改源码 / 编译 | 未做；`host.rs`、`resource.rs`、`copystat.rs` 等均未编辑 |
| 改判据 / 改脚本 | 未改 `smoke.ps1`、`bench.ps1`、`auto-enter.ps1` 任一行 |
| `-Extra` 键数 | 每次仅 1 个 `VICTORY_<S1|S2|S3>=1` |
| csv | 仅追加 L11–L16（v3 现 16 行）；`bench.csv` 12 行、`bench-v2.csv` 22 行未动 |
| `victory-baseline.exe` / `victory-pre-e3.exe` | 未覆盖（`9627DF10…` / `58E60D62…`） |
| `victory-data\` 缓存 | 未删改 |
| 进程 | 收尾 `procs=0` |
