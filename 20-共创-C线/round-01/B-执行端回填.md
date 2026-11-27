# B-执行端回填（清单 §1–§4、§6）

执行端：豆包（本机 Windows 执行面，只做构建/跑分/抓日志，未改源码）
时间：2026-11-26 21:38–22:00
产物：`victory.exe` 47.40 MB（20:59 构建）、`victory-baseline.exe` 69.10 MB（20:24 保留）

---

## A. 构建与单测

```
build: 沿用 20:59 的既有产物，本轮未重编（EXIT=0 记录见 data\build-opt.log）
       exe=49,684,428 bytes（target\release\victory.exe，47.40 MB）
test : test result: FAILED. 334 passed; 2 failed; 34 ignored; 0 measured; 0 filtered out; 10.81s
       failures: indirect::tests::host_list_budget_starts_empty_at_each_submission
                 indirect::tests::warp_batch_charges_every_execution
```

两个失败用例与清单 §2 列出的基线已知失败**完全一致**，其它 0 失败 → §2 判据通过。

§6 归因（通用 target-cpu 复跑）见本文件末「§6 结果」。

环境补充（下一轮直接照这个前缀，省 30 秒）：

```powershell
$env:CARGO_HOME="G:\rust\cargo"; $env:RUSTUP_HOME="G:\rust\rustup"
$env:PATH="G:\rust\cargo\bin;D:\YunX-toolchain\w64devkit\w64devkit\bin;C:\Windows\System32;"+$env:PATH
Remove-Item Env:\RUSTFLAGS -ErrorAction SilentlyContinue
```

不设 `dlltool` 路径会直接 `error calling dlltool 'dlltool.exe': program not found`，构建/测试都挂。

---

## B. 跑分（`-Profile fork`，两组环境完全一致，各 200 s）

| label | seconds | world_samples | world_median_ms | max_draws | max_priv_gb | min_commit_free_gb | log |
| --- | --- | --- | --- | --- | --- | --- | --- |
| F-A-baseline | 200 | 1 | 341.5 | 1,062 | 17.30 | 0.44 | run-F-A-baseline-1126-213828.log |
| F-A2-baseline（补跑） | 200 | 4 | 263.2 | 3,427 | 18.43 | 0.60 | run-F-A2-baseline-1126-214704.log |
| F-B-final | 200 | 14 | 301.1 | 4,011 | **20.53** | **0.03** | run-F-B-final-1126-214233.log |

F-A 只采到 1 条世界样本（进世界太晚，244 s 才到 1,062 draws），按 §3 判据作废；补跑 F-A2 后基线有效。

### 按 draws 对齐的逐样本对照（这才是可判读的口径）

| draws | 基线 ms（A2） | 新码 ms（B） | 差 |
| --- | --- | --- | --- |
| 3,406–3,427 | 263.2 | 348.3 | +32% |
| 2,670–2,760 | 313.6 | 290.2 | −7% |
| 1,899–1,990 | 254.8 | 378.9 / 394.3 | +49% |
| 1,161–1,224 | 250.4 | 470.1 | +88% |

### 判读

1. **帧时间未赢**：301.1 vs 263.2 = **+14.4%（更慢）**，不满足「新 < 基线 且 ≥10%」。按 draws 对齐后仍是新码更慢，低 draws 段差得最多。
2. **内存更大**：峰值私有 20.53 GB vs 18.43 GB（+2.1 GB），不满足「不高于基线」。
3. **提交额度触底**：`min_commit_free_gb = 0.03`（基线 0.60）。这个数比帧时间更能说明问题——新码把 2 GB 额外提交压在同一堵 33.84 GB 的墙上，最后一截只剩 30 MB，页面调度本身就在拖帧。
4. 结论：**在当前 2 GB 页面文件下，B 组数据不可信，且大概率是负收益**。同一套改动换到 Commit Limit ≥48 GB 的机器上要重测才能定性。

---

## C. 卡内账本 5 行（§4 原样）

```
2026-11-26T13:51:53.885574Z  INFO victory_gpu::list::thin: threads that translate lists (VICTORY_THIN_THREADS) threads=6
2026-11-26T13:51:54.294056Z  INFO victory_gpu::pipeline::make: pipeline workers workers=4
2026-11-26T13:51:56.394524Z  INFO victory_gpu::shadow: card buffer limits vram_budget_mb=5834 card_buffers_min_kb=64 card_buffers_max_mb=512
2026-11-26T13:51:56.802377Z  INFO victory_gpu::resource: the card's room kept for the render targets a world makes in its first frame (VICTORY_CARD_ROOM_FOR_TARGETS_MB) most_mb=1183 card_mb=5918
```

第 5 行（上卡内存上限那一行）**没采到**：这次 info 级运行在 **5 秒**处就被内存墙打死，最后一条是

```
2026-11-26T13:51:56.802134Z  WARN victory_gpu::residency: host memory pressure:
    limiting texture prefetch and idle upload storage pid=27596 frame=11
    physical_free_mib=3071 available_commit_mib=158
```

`available_commit_mib=158` → 随后进程死，日志停在 13:51:56.841。所以：

- 账本前三行证明新默认值真的生效（`threads=6`、`workers=4`、`vram_budget_mb=5834`）。
- `card_buffers_max_mb=512` 与 `min_kb=64` 也生效，但 `vram_budget_mb` 是 **5,834**，不是 `11-实施记录.md` 里记的 7,256——这一版把 ambient=0.8 与旧开关集叠加后的实测预算就是 5,834，需要代码侧确认这是预期还是账本口径变了。
- `most_mb=1183` 说明 targets 的 3,072 MB 默认在 8 GiB 卡上被压到 1,183 MB（`most_mb` 是「最多能留」的值），这正好是方案 §03 想要的钳制，但它生效的同时提交额度只有 158 MB → 卡侧省了，主存侧没省。
- 第 5 行要在页面文件扩到 48 GB 之后用同样命令补采，**不要在现在这堵墙下反复重启**：三次 info 级运行里有两次是 3–5 秒内被 `0x8007000E` 打死的。

---

## §6 结果（通用 target-cpu 复跑两个 WARP 用例）

见 `data\test-warp-generic.log`；结论：**仍然失败**（与本机 native/LTO 代码生成无关，归因闭合到本机 WARP/驱动语义或上游既有失败，记进 `11-实施记录.md` §5）。

---

## 执行端给代码侧的三条建议（按优先级）

1. **先扩页面文件再谈 A/B**：`min_commit_free_gb` 已经到 0.03 / `available_commit_mib` 158，任何 ±20% 的帧时间判据都会被页面调度污染。扩到 48 GB 后，同样的 A2 vs B 两组重跑一次，才谈得上「固化哪些开关」。
2. **B 组先别固化**：帧时间 +14.4%、峰值 +2.1 GB、提交触底。至少把「+2 GB 提交」这一项定位出来（怀疑 `physical_cores()` 改动带来的线程/缓冲尺寸变化，或 LTO 让某些缓冲不再被复用）。
3. **账本口径核对**：`vram_budget_mb=5834` 与 `11` 记的 7,256 不一致，先把这条差 1.4 GB 的来源说清楚，再谈逐条开关固化。
