# C-证据台账（round-02）

生成：`r02-a5` 执行侧（豆包）｜ 2026-11-26 22:38
口径声明：**本台账只抄原始文件，不做换算、不做重算、不下结论。**
筛子声明：`bench.csv`（第 1–12 行）为 **filter v1**（`Ms>40`，无 draws 下限）；`bench-v2.csv`（**2026-11-26 22:49 起已落盘，2 行数据**）为 **filter v2**（`Ms>40 且 Draws≥200`）。两者不混表。

---

## 1 强制字段表（E01–E10）

| 代号 | 轮次 | 字段 | 值 | 出处 | 备注 |
| --- | --- | --- | --- | --- | --- |
| E01 | r02 | 跑前提交额度 | `commit_limit_gb=33.84 commit_used_gb=16.51 commit_free_gb=17.33` | `data\r02-a2-console.log:3` | a2 守卫行原文；a5 probe 启动前另为 `16.81 / 17.03`（`data\r02-a5-probe.log:2`） |
| E02 | r02 | 产物指纹 | `exe_bytes=49681038 written=2026-11-26 22:02:32 SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` | `20-共创-C线\outbox\r02-a1-result.md:9`；`data\build-r02-a1.log` | 构建 `EXIT=0 elapsed=126s errors=0` |
| E03 | r02 | 单测一行 + 失败列表 | `test result: FAILED. 334 passed; 2 failed; 34 ignored; 0 measured; 0 filtered out; finished in 10.81s`；failures = `indirect::tests::host_list_budget_starts_empty_at_each_submission`、`indirect::tests::warp_batch_charges_every_execution` | `data\test-final.log:452`、`:449`、`:450` | 两例为基线已知失败（空 `RUSTFLAGS` 复跑仍 panic，`data\test-warp-generic.log`） |
| E04 | r02 | 基线五项 | `world_samples=33 world_median_ms=265.8 max_draws=5770 max_priv_gb=20.35 min_commit_free_gb=0.31` | `data\bench.csv:11`（filter v1） | csv 行原文见 §2 |
| E05 | r02 | 回滚版五项 | `world_samples=30 world_median_ms=271.9 max_draws=5959 max_priv_gb=20.26 min_commit_free_gb=0.53` | `data\bench.csv:12`（filter v1） | 回填原写 14/15，实际 11/12，已更正（P1-5） |
| E06 | r02 | 逐样本表（两段，63 行，`Ms>45` 取法） | 原文见 `20-共创-C线\outbox\r02-a2-result.md:29-95`（基线 33 行、回滚 30 行） | 同上 | 未截断、未四舍五入 |
| E07 | r02 | 账本 5 行 | `threads=6`；`workers=4`；`vram_budget_mb=7256 card_buffers_min_kb=64 card_buffers_max_mb=512`；`most_mb=3072`；`most_mb=4096 card_mb=6625` | `data\ledger-a1-1126-223308.err.log:54`、`:63`、`:258`、`:283`、`:8812` | `asked_mb` 未出现 = 未设置（`tracing` 对 `Option::None` 不记录字段），非缺失；任务单原期望 `asked_mb=None` 作废（P1-7） |
| E08 | r02 | 世界内 `available_commit_mib` 最低值 | `3633`（全文仅 1 处，`n=1`，故 min=max） | `data\ledger-a1-1126-223308.err.log:6355` | 同一行 `physical_free_mib=14952` |
| E09 | r02 | 编排者重算中位（filter v2） | A=`265.8` / B=`272.8` | `20-共创-C线\round-02\F-核对结论.md:68-69` | **照抄编排侧重算值，执行侧未重算**；v2 样本数 A=33 / B=27 |
| E10 | r02 | `leftover_procs` | A 组=`0` / B 组=`0` | `data\bench-v2.csv:2`、`:3`（第 12、13 列原文 `…,0.26,0,…` / `…,0.38,0,…`） | R3 两组收尾均为 0；a5 probe 自身曾 `leftover=1`（已修 10×2 s 重试，`outbox\r02-a5-result.md` 异常 1） |

---

## 2 原始 csv 行（逐字）

`data\bench.csv`（filter v1，第 1–12 行冻结，未改写）：

```
L11: 2026-11-26 22:07:08,R2-A2-baseline,200,40,33,265.8,20.35,3.06,0.31,run-R2-A2-baseline-1126-220303.log
L12: 2026-11-26 22:26:47,R2-B-reverted,200,40,30,271.9,20.26,2.95,0.53,run-R2-B-reverted-1126-222239.log
```

`data\bench-v2.csv`（filter v2，`r02-a6` 落盘，表头 + 2 行）：

```
L1: time,label,seconds,samples,world_filter,world_samples,median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log
L2: 2026-11-26 22:44:50,R3-A2-baseline-v2,200,40,ms>40&draws>=200,29,255.8,4463,20.19,2.94,0.26,0,run-R3-A2-baseline-v2-1126-224038.log
L3: 2026-11-26 22:49:03,R3-B-reverted-v2,200,40,ms>40&draws>=200,32,272.5,4387,20.36,2.74,0.38,0,run-R3-B-reverted-v2-1126-224455.log
```

`bench-v2.csv` 首次落盘前的两次核对（`Test-Path = False`，22:33 与 22:38）与落盘后不矛盾：该文件由 `bench.ps1` 第一次 v2 跑分时创建。

---

## 3 口径与样本构成（只记观测，不判读）

| 组 | 采样秒数 | 采样条数 | v1 世界样本数 | v1 中位 ms | v2 世界样本数（编排侧） | v2 中位 ms（编排侧） |
| --- | --- | --- | --- | --- | --- | --- |
| R2-A2-baseline | 200 | 40 | 33 | 265.8 | 33 | 265.8 |
| R2-B-reverted | 200 | 40 | 30 | 271.9 | 27 | 272.8 |

回滚组被 v2 剔除的 3 条（`Ms>40` 但 `Draws<200`），逐字自 `outbox\r02-a2-result.md` E06 段：

```
T=51 Ms=67 Draws=9 PrivGB=13.17
T=57 Ms=47.6 Draws=9 PrivGB=11.72
T=75 Ms=58.8 Draws=10 PrivGB=11.73
```

---

## 4 未观测项（不得当作已通过）

| 项 | 状态 | 原因 |
| --- | --- | --- |
| S5 干净对照（`R3-A2-baseline-v2` / `R3-B-reverted-v2`） | **已跑**（22:40:38–22:49:03） | 门禁 `commit_free_gb=16.78 ≥ 12` 放行，未触发 `SKIP_S5`；页面文件仍未扩（`Commit Limit=33.84 GB`） |
| E10 `leftover_procs` | 已观测 = `0` / `0` | 见 E10 行 |
| E07 `asked_mb=None` | `MISSING`（字段未出现在该行） | 已裁决：`Option::None` 不记录字段，非缺失（P1-7） |

---

## 5 台账自检

| 检查 | 结果 |
| --- | --- |
| E01–E10 是否齐 | E01–E10 全有值（E10 已由 `r02-a6` 补） |
| 每个值是否有 `文件:行` | 是（E10 指 `bench-v2.csv:2/:3`） |
| filter v1 / v2 是否混表 | 未混；v1（`bench.csv` L11/L12）与 v2（`bench-v2.csv` L2/L3）分节列，median 不跨口径比较 |
| 是否含结论句 | 无（仅观测与口径说明） |
