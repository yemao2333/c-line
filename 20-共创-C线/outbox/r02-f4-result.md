# r02-f4 回填 · 按序移植 3 个 Kelvaroq 补丁

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0900-24.md`。**三个补丁全部在 `git apply --check` 阶段失败，按任务单「apply 失败就跳过，不许手改冲突」全部跳过**：未打补丁、未编译、未跑冒烟、未写 csv 行、未生成 `victory-pre-*` 备份（因为树从未被改动）。

## 总表

| 序 | 补丁 | 行数 | 目标 | check_EXIT | patch_EXIT | build_EXIT | errors | smoke_EXIT | csv 行 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `0032-contiguous-readback-copies.patch` | 89 | `crates\victory-gpu\src\host.rs` | **1** | 未执行 | 未执行 | 未执行 | 未执行 | 无 |
| 2 | `0023-compare-result-reuse.patch` | 145 | `crates\victory-gpu\src\host.rs` | **1** | 未执行 | 未执行 | 未执行 | 未执行 | 无 |
| 3 | `0030-scoped-card-barriers.patch` | 139 | `crates\victory-gpu\src\host.rs` | **1** | 未执行 | 未执行 | 未执行 | 未执行 | 无 |

命令（三个补丁同一形状，`cwd = <ROOT>\cool_fox\cool_fox-main`，git 为 `<GIT>\cmd\git.exe`）：

```powershell
& git apply --check --verbose "<ROOT>\kelvaroq-main\native\patches\<patch>"
```

> 注：该树**不是 git 仓库**（`.git` 不存在），但 `git apply` 不需要仓库即可对本工作目录的文件做检查/应用；本次只用 `--check`，未做任何写入。

---

## 1 `0032-contiguous-readback-copies.patch`（89 行）

`check_EXIT=1`；期望 hunk `@@ -2272,6 +2272,21 @@`。

前 20 行原文（共 11 行，全贴）：

```text
Checking patch crates/victory-gpu/src/host.rs...
error: while searching for:
    flags.iter().filter(|f| f.2).map(|f| (f.0, f.1)).collect()
}

/// Whether pieces fetched on a copy queue beside later flights are fetched
/// again when those flights land (`VICTORY_QUEUE2_REFETCH=0`: not, as
/// before; on by default with `VICTORY_QUEUE2` bit 1).

error: patch failed: crates/victory-gpu/src/host.rs:2272
error: crates/victory-gpu/src/host.rs: patch does not apply
```

我们树 `host.rs`（10,728 行）相关行号（只读 `Select-String`）：

| 锚点 | 我们树 | 补丁期望 |
| --- | --- | --- |
| `flags.iter().filter(｜f｜ f.2)` | **L2550**（`let mut pieces: Vec<(usize, u32)> = flags.iter().filter(...)...`） | L2272 附近（偏移 +278） |
| `VICTORY_QUEUE2_REFETCH` | **0 命中**（该开关在我们树里不存在，见 `three-way.md` §1.1 A_ONLY） | hunk 的尾随上下文 |

---

## 2 `0023-compare-result-reuse.patch`（145 行）

`check_EXIT=1`；期望 hunk `@@ -1587,9 +1587,9 @@`。

前 20 行原文（共 14 行，全贴）：

```text
Checking patch crates/victory-gpu/src/host.rs...
error: while searching for:
    differs: (ID3D12Resource, usize, u64),
    /// Where the pieces that differ are fetched to: PC memory, mapped.
    fetched: Option<(ID3D12Resource, usize, u64)>,
    /// The dwords of `differs` taken by plans whose results were not read
    /// yet.
    taken: u32,
    /// Plans made and not done with (`Host::card_done`).
    out: u32,
    /// The fetch inside flights ([`inflight_fetch`]), if it is on and was

error: patch failed: crates/victory-gpu/src/host.rs:1587
error: crates/victory-gpu/src/host.rs: patch does not apply
```

我们树 `host.rs` 相关行号：

| 锚点 | 我们树 | 补丁期望 |
| --- | --- | --- |
| `differs: (ID3D12Resource, usize, u64)` | **L1997** | L1587 附近（偏移 +410） |
| `taken: u32` | **L2002** | L1595 附近 |
| `fetched: Option<(ID3D12Resource, usize, u64)>` | 未逐条核对（结构体字段顺序与我们不同，见上两行偏移） | — |

---

## 3 `0030-scoped-card-barriers.patch`（139 行）

`check_EXIT=1`；期望 hunk `@@ -1701,6 +1701,26 @@`。

前 20 行原文（共 11 行，全贴）：

```text
Checking patch crates/victory-gpu/src/host.rs...
error: while searching for:
    *ON.get_or_init(|| relay() && std::env::var_os("VICTORY_CARD_FETCH_INFLIGHT").is_some_and(|v| v == "1"))
}

/// The bytes of the PC's memory pieces fetched inside flights go to
/// ([`inflight_fetch`]; `VICTORY_CARD_FETCH_INFLIGHT_MB`, 64): 1,024 slots
/// ([`inflight_slots`]). A flight whose flagged pieces find no free slot

error: patch failed: crates/victory-gpu/src/host.rs:1701
error: crates/victory-gpu/src/host.rs: patch does not apply
```

我们树 `host.rs` 相关行号：

| 锚点 | 我们树 | 补丁期望 |
| --- | --- | --- |
| `VICTORY_CARD_FETCH_INFLIGHT` | **0 命中**（该开关在我们树里不存在，见 `three-way.md` §1.1 A_ONLY） | hunk 首条上下文 |
| `VICTORY_CARD_FETCH_INFLIGHT_MB` | **0 命中** | hunk doc 段 |

---

## 结论性事实（不含判读）

- 三个补丁的失败原因同形：**hunk 行号偏移**（+278 / +410 / 未知）叠加**尾随上下文引用了我们树不存在的开关**（`VICTORY_QUEUE2_REFETCH`、`VICTORY_CARD_FETCH_INFLIGHT`）。
- 三个补丁的整份 diff 里都只有 `crates/victory-gpu/src/host.rs` 一个目标文件（见 `shortlist.md`），不存在越界改别的文件的问题。
- 本次未产生任何 `victory-pre-<tag>.exe`：因为检查阶段即失败、文件未变，按任务单「失败即回滚 / 跳过」口径不需要备份。

## 红线核对

| 项 | 结果 |
| --- | --- |
| 手改冲突 / 手写等价实现 | **未做**（严格按「apply 失败就跳过」） |
| 改任何文件 | **无改动**；`host.rs` 最新 mtime 仍为 `2026-11-27 05:08:31`（本轮之前） |
| 编译 / 跑冒烟 | 均未触发（`build_EXIT`、`errors`、`smoke_EXIT` 记「未执行」） |
| `bench-v2.csv` / `bench-v3.csv` | 未追加（v3 仍 10 行 = 表头 + 9）；`bench.csv` 12 行 |
| `victory-baseline.exe` / `victory-pre-e3.exe` | 未覆盖（仍 `9627DF10…` / `58E60D62…`） |
| `policy.rs` / `rust-toolchain.toml` / `victory-shader\**` | 未触碰 |
| `victory-data\` 缓存 | 未删改 |
| 附加补丁 | 未做第 4 个 |

## 证据文件

| 文件 | 说明 |
| --- | --- |
| `<ROOT>\kelvaroq-eval\f4-check-0032-contiguous-readback-copies.log` | `git apply --check --verbose` 原始输出（11 行） |
| `<ROOT>\kelvaroq-eval\f4-check-0023-compare-result-reuse.log` | 同上（14 行） |
| `<ROOT>\kelvaroq-eval\f4-check-0030-scoped-card-barriers.log` | 同上（11 行） |
