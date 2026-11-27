# r02-a10 回填 · diagnostics 按管线归因（S1 编 diag / S2 150 s GPU_TIMING 探针）

> 执行端：本机 Windows（豆包执行面）。任务单 `inbox\task-20261127-0028-10.md`。
> 只回填原文与数字，不判读、不换算、不改口径。

## A 任务单核对

| 项 | 任务单要求 | 本次实际 |
| --- | --- | --- |
| S1 构建命令 | `cargo build --profile diag -p victory --features diagnostics --locked` | 同命令，工作目录 `<ROOT>\cool_fox\cool_fox-main` |
| S1 产物 | `target\diag\victory.exe` | `target\diag\victory.exe`，回填见 §B |
| S1 侧证 | release 产物未被覆盖，SHA 仍 `58E60D62…A4EFF45` | 构前 `release_sha256_before`、构后 `release_sha256_after` 均 `58E60D62…A4EFF45`，见 §B |
| S2 可执行 | `target\diag\victory.exe` | 同 |
| S2 时长 | 150 s | `lived_s=150` |
| S2 环境 | `VICTORY_LOG=info` + `VICTORY_GPU_TIMING=1` | 父进程设置后由 `Start-Process` 继承，见 §C 环境清单 |
| S2 禁项 | 禁开 `VICTORY_CAPTURE_FRAMES` / `VICTORY_RECORD_FRAMES` | 全程未设，见 §C |
| S2 早退处置 | < 30 s 死掉则只留 GPU_TIMING 重试一次 | 未触发：单次跑满 150 s，无重试 |
| bench-v2.csv | 本单不追加 | 未写，文件保持 11 行 |

## B S1 构建（diagnostics 产物）

| 字段 | 值 | 出处 |
| --- | --- | --- |
| EXIT | 0 | `data\r02-a10-console.log`（`EXIT=0 elapsed=275s`） |
| elapsed | 275 s | 同上 |
| errors | 0 | 同上（`errors=0`） |
| diag_bytes | 72459641 | 同上（`diag_bytes=72459641 written=2026-11-27 00:31:57`） |
| diag_mtime | 2026-11-27 00:31:57 | 同上 |
| diag_sha256 | `710857B58C00BA3E1AB71141DE1C23ED039A156AFEB78B7AC3CFB0115DA7C7D5` | 同上；本次重算一致 |
| release_sha256_before | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` | 同上 |
| release_sha256_after | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` | 同上；本次重算一致 |
| release 产物 | 49681038 B @ 2026-11-26 22:02:32（未覆盖） | `Get-Item` |

构建日志：`data\build-diag.log`。

## C S2 探针运行（150 s，`VICTORY_LOG=info` + `VICTORY_GPU_TIMING=1`）

| 字段 | 值 | 出处 |
| --- | --- | --- |
| pid | 12992 | `data\r02-a10-console.log`（`pid=12992`） |
| lived_s | 150 | 同上 |
| leftover_procs | 1（runner 在 kill 后 2 s 计数）；外部复核收尾后为 0 | 同上 `lived_s=150 leftover_procs=1`；`Get-Process -Name ^victory` 复核 0 |
| err_bytes | 3661062 | 同上（`err_bytes=3661062`） |
| 日志文件 | `data\r02-a10-gputiming-info.err.log` 3661062 B @ 2026-11-27 00:34:32 | `Get-Item` |
| info 重定向文件 | `data\r02-a10-gputiming-info.log` 1035 B @ 2026-11-27 00:32:06 | `Get-Item` |
| hits_total（runner 自带统计：by what ran 或 commands 或 settles） | 373 | `data\r02-a10-console.log` |

日志命中统计（`Select-String -SimpleMatch` 对 `.err.log` 逐条计数）：

| 模式 | 命中数 | 说明 |
| --- | --- | --- |
| `the card's time by what ran:` | 183 | `copystat.rs` L1305 输出，按 lists/pipelines 归因等卡微秒 |
| `per frame` | 1484 | 多类 per-frame 汇总行的公共子串 |
| `the card's time by command (timing run)` | 0 | 命令计时归因未产出，原因见 §E |
| `of the waiting for the card in settles` | 0 | 字面 0 条 |
| `timing`（字面） | 0 | 连带为 0 |
| `waits for every earlier shader write, per frame` | 27 | 另一条 per-frame 命令计数行，原文见 §D-2 |
| `slow host list ms=… commands=0` | 约 190 条（WARN） | 噪声行，无归因信息 |

## D 原文（整行，行号指 `.err.log`）

### D-1 `by what ran` 末 3 条

> 原始行在 `.err.log` 里带 tracing 的 ANSI 转义序列（ESC[2m / ESC[32m / ESC[0m）；下表为去掉转义后的同一行，其余字符逐字一致。行末被截断来自 `copystat.rs` L1309 的 `take(700)` 上限（原文如此）。

```text
L13866: 2026-11-26T16:34:29.470152Z  INFO victory_gpu::copystat:   the card's time by what ran: 12.4 ms a frame in 0.2 submissions a frame: 1 lists, pipelines {"[compute 3cf39f4495b908d0]", "[compute 4518151afe8c6c09]", "[compute 48426bae580a080c]", "[compute 72f552f4553fb5f9]", "[compute 82a2ad6d07417d36]", "[compute 8f9eb68d0c6dd5cf]", "[compute 904e7a51e3fab26c]", "[compute 969c1cef8b783b39]", "[compute dd24ff46af3ae6ee]", "[compute e30970f1727063fd]"}
L13867: 2026-11-26T16:34:29.470232Z  INFO victory_gpu::copystat:   the card's time by what ran: 12.4 ms a frame in 0.1 submissions a frame: 25 lists, pipelines {"[compute 03c01507703d7449]", "[compute 04be1ad677ff1627]", "[compute 052a2316a03b9ba1]", "[compute 0560ac646b358460]", "[compute 05e074ad67e0d6d6]", "[compute 0fc1b11eb36efdb2]", "[compute 119ee96f602f1668]", "[compute 11bbed94ee7a3243]", "[compute 17af85f170e66f30]", "[compute 214cae4f6e1ef745]", "[compute 23d507cbb6a22e86]", "[compute 291822a279c07067]", "[compute 2b17036bf3a1d615]", "[compute 2bfdc19dc1f25b3a]", "[compute 2da18cc9fbbe9a91]", "[compute 32aa8384586e0f12]", "[compute 3c196d81eca7ff15]", "[compute 3d147e8190574516]", "[compute 44fdeb707f882b7d]", "[compute 477b52e73ddeb6f2]", "[compute 47d8c225abfcb246]", "[compute 4848dd3d7139514c]", "[compute 488b12f58
L13868: 2026-11-26T16:34:29.470316Z  INFO victory_gpu::copystat:   the card's time by what ran: 9.3 ms a frame in 0.6 submissions a frame: 15 lists, pipelines {"[compute 00e6aef268b1ef81]", "[compute 03e3e26783a5799b]", "[compute 06bb6e728c7c99bf]", "[compute 08055d95e9ee79c0]", "[compute 0873f80dd84a3c5c]", "[compute 0a5d4f9047b3dce4]", "[compute 0b66319d2ec8ee68]", "[compute 0b922bb75dab88ed]", "[compute 0f0b95cf52ddeb26]", "[compute 117143a278e9a631]", "[compute 11eeb27c2d15980d]", "[compute 130d3d04172e5456]", "[compute 14264103296aa43a]", "[compute 17e736204a05a105]", "[compute 1b6fe0fd2e81c2dc]", "[compute 24da8a76ee9d2bda]", "[compute 2781ba7ca7d68e34]", "[compute 27eda70a9b51b1b7]", "[compute 2809db6c31de483d]", "[compute 28153514665eb0ad]", "[compute 29cb081b31c4db70]", "[compute 2cc4c197ee29e291]", "[compute 2dc364df5
```

### D-2 `waits for every earlier shader write, per frame` 末 3 条（替代计数，非 commands 计时归因）

```text
L13505: 2026-11-26T16:34:18.756253Z  INFO victory_gpu::copystat:   waits for every earlier shader write, per frame: 965 for the title's barrier groups, 8 for its barriers on buffers; 150 indirect commands bounded (a dispatch of ours between two such waits each); barrier experiment 0
L13682: 2026-11-26T16:34:23.959573Z  INFO victory_gpu::copystat:   waits for every earlier shader write, per frame: 981 for the title's barrier groups, 10 for its barriers on buffers; 156 indirect commands bounded (a dispatch of ours between two such waits each); barrier experiment 0
L13869: 2026-11-26T16:34:29.470431Z  INFO victory_gpu::copystat:   waits for every earlier shader write, per frame: 958 for the title's barrier groups, 9 for its barriers on buffers; 135 indirect commands bounded (a dispatch of ours between two such waits each); barrier experiment 0
```

## E 未产出项（照实回填）

1. `the card's time by command (timing run)` 系列行 0 条：`by.is_empty()` 为真，`COMMANDS_BY_WORK` 未收集到任何条目。
2. 源码依据（陈述，非推断）：`crates\victory-gpu\src\host.rs` L1742–L1743 注释写明「the commands are noted with `VICTORY_D3D12_DRED` on」；`crates\victory-gpu\src\copystat.rs` L1306–L1313 的汇总块仅在 `!by.is_empty()` 时打印。
3. 本单实际设置的环境变量只有 `VICTORY_LOG=info`、`VICTORY_GPU_TIMING=1`（另加 `-Profile fork` 项），未设 `VICTORY_D3D12_DRED`；开关语义见 `crates\victory-gpu\src\switch.rs` L9–L16（`value_is_on`：已设置且不等于 `0` 即为开）。
4. `of the waiting for the card in settles` 在 150 s、info 级别下字面 0 条；同批日志里可用的等卡原文为 §D-1 的 `by what ran` 与 §D-2 的 barrier/indirect 计数行。
5. S2b（`VICTORY_TIMELINE=95,3,…timeline.json` 3 帧时间线）为本单可选段，未跑。

## F 环境变量实际清单（S2 子进程继承前由父进程设置）

| 变量 | 值 | 备注 |
| --- | --- | --- |
| `VICTORY_LOG` | `info` | 与 a9 一致 |
| `VICTORY_GPU_TIMING` | `1` | 本单新增 |
| `VICTORY_ASYNC_SUBMIT` | 未设（日志 L53 出现相关 WARN） | 原文：`VICTORY_ASYNC_SUBMIT=1 needs the relay and lists cut at their waits…`，属仓库自身告警路径 |
| `VICTORY_CAPTURE_FRAMES` | 未设 | 任务单禁项 |
| `VICTORY_RECORD_FRAMES` | 未设 | 任务单禁项 |
| `VICTORY_D3D12_DRED` | 未设 | 见 §E-2 |
| `VICTORY_WIDE_BACK` / `VICTORY_CARD_STEPS` / `VICTORY_RELAY_COPY` | 未设 | 本单不需 |

## G 未改动项

1. `data\bench-v2.csv` 未追加（仍 11 行）；`data\bench.csv` L1–12 未动。
2. 源码、`Cargo.toml`、`.cargo\config.toml`、`rust-toolchain.toml`、`crates\victory-shader\**`、`policy.rs` 均未改。
3. `target\release\victory.exe` 与 `target\release\victory-baseline.exe` 未覆盖；`target\diag\victory.exe` 为本单新产物。
4. 未启动第二局，未跑分；三条待办（画质截图 / flags 单独 A/B / P3 着色器）未开工。
