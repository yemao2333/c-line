# A 任务简报｜round-01：让显存预算在 8 GB 卡上自洽

> 交给 DeepSeek 的完整输入。请在读完下面全部片段后再出方案，不要凭"常见做法"补代码。

## 1 背景（这台机器的硬事实）

| 项 | 值 |
| --- | --- |
| 显卡 | RTX 3060 Ti，8 GB（`video_memory()` 能返回 `[budget, used, ..]`） |
| 内存 | 31.8 GB 物理，页面文件 2 GB，提交上限 33.84 GB |
| 场景 | Xbox Series 版 GTA6，Series S 档位；世界内 674 draws / 824 ms 一帧，私有内存 16.7 GB |
| 代码来源 | `<ROOT>\cool_fox\cool_fox-main`（VIctory 的 AMD 优化分支，GPL-3.0） |

已知的账：默认三个预算项相加 **9,216 MB = 8,192 MB 预算的 112.5%**，所以世界首帧必定互相拒绝。

## 2 源码片段（原样引用，行号是当前快照的）

### 2.1 `crates/victory-gpu/src/resource.rs:1655-1666`

```rust
/// Unconditional host-texture floor for a given local VRAM budget (`None` when
/// the adapter does not report one): up to 2 GiB, capped at a quarter of the
/// reported budget so 4–6 GiB cards do not bypass the budget check early.
#[cfg(any(windows, test))]
fn texture_floor_bytes(vram_budget: Option<u64>) -> u64 {
    const MAX_FLOOR: u64 = 2 << 30;
    match vram_budget {
        Some(budget) => MAX_FLOOR.min(budget / 4),
        None => MAX_FLOOR,
    }
}
```

### 2.2 `crates/victory-gpu/src/resource.rs:1668-1705`

```rust
/// Whether more host copies of textures the title fills may be made for
/// shaders that pick textures by index (`draw.rs` `heap_textures`): always
/// up to [`texture_floor_bytes`] bytes of them, beyond that while the card's
/// memory in use by this process is under nine tenths of the budget the system
/// gives it ([`room_percent`] says another share; `VICTORY_TEXTURE_BUDGET_MB`
/// sets a limit on those copies' bytes instead). Past the budget the system moves the card's memory into the PC's,
/// which ended runs 20 and 24.
#[cfg(windows)]
pub(crate) fn room(memory: Option<[u64; 4]>) -> bool {
    use std::sync::atomic::Ordering::Relaxed;
    const WITHOUT_BUDGET: u64 = 4 << 30;
    static LIMIT: std::sync::OnceLock<Option<u64>> = std::sync::OnceLock::new();
    let limit = *LIMIT.get_or_init(|| {
        let mb = std::env::var("VICTORY_TEXTURE_BUDGET_MB").ok()?;
        mb.trim().parse::<u64>().ok().map(|mb| mb << 20)
    });
    // (With the tiles of the copies made level by level, whose own bytes
    // count as none: `crate::tiles`.)
    let filled = KINDS[1].load(Relaxed) + crate::tiles::given_total();
    if let Some(limit) = limit {
        return filled < limit;
    }
    let floor = texture_floor_bytes(memory.map(|[budget, ..]| budget));
    if filled < floor {
        return true;
    }
    match memory {
        // What is kept for card copies of title buffers not made yet
        // (`crate::shadow::card_room_kept`) and for the render targets a
        // world makes in its first frame ([`targets_room_kept`]) counts as
        // used.
        Some([budget, used, ..]) => {
            used.saturating_sub(crate::pool::texture_room()) + crate::shadow::card_room_kept() + targets_room_kept()
                < budget / 100 * room_percent()
        }
        None => filled < WITHOUT_BUDGET,
    }
}
```

### 2.3 `crates/victory-gpu/src/resource.rs:1707-1737`

```rust
/// The bytes of the card's memory the texture queue leaves free for
/// render targets and other host copies the host itself writes that are
/// not made yet: `VICTORY_CARD_ROOM_FOR_TARGETS_MB` (3,072; 0: none, as
/// before) less what such copies hold now.
///
/// Measured (runs 193, 197, 198): 652 MB of them before the world, 2,255
/// to 2,352 MB right after its first frame, 2,800 to 3,100 MB two minutes
/// on, none of them idle (run 198's census). They are made with no room
/// test, in the same frame as the card copies of title buffers (762 MB),
/// after the texture queue has filled the card to its line with textures
/// written while the world loaded (7.3 GB of them at the first world frame
/// of run 193, of which 2.3 GB were let go again within 13 seconds). The
/// card then stood at 99 to 100.5 % of its budget, buffer copies were
/// turned down for good (31 of 95 made: the frame 355 ms where 95 give
/// 238), and the queue was refused from the first world frame on. With
/// their room kept, the queue stops that much earlier while the world
/// loads and gets it back as the targets are made.
#[cfg(windows)]
pub(crate) fn targets_room_kept() -> u64 {
    use std::sync::atomic::Ordering::Relaxed;
    static MOST: std::sync::OnceLock<u64> = std::sync::OnceLock::new();
    let most = *MOST.get_or_init(|| {
        std::env::var("VICTORY_CARD_ROOM_FOR_TARGETS_MB")
            .ok()
            .and_then(|v| v.trim().parse::<u64>().ok())
            .map_or(3072 << 20, |mb| mb.min(8192) << 20)
    });
    // Every host texture's bytes less those of the copies the title fills.
    let targets = HOST_TEXTURES[1].load(Relaxed).saturating_sub(KINDS[1].load(Relaxed));
    most.saturating_sub(targets)
}
```

### 2.4 `crates/victory-gpu/src/resource.rs:1757-1773`

```rust
/// The share of the card's budget, in percent, up to which host copies of
/// textures picked by index are made ([`room`]): 90 unless
/// `VICTORY_TEXTURE_ROOM_PERCENT` says another (50 to 97). At 90 about a
/// tenth of the budget, 1,020 MB of 10,200, stays unused while thousands of
/// textures wait (runs 170-174); the card copies of title buffers from
/// 1 MiB up take 449 MB more of the card than before (941 against 492),
/// and 94 gives the textures about that much back.
#[cfg(windows)]
fn room_percent() -> u64 {
    static PERCENT: std::sync::OnceLock<u64> = std::sync::OnceLock::new();
    *PERCENT.get_or_init(|| {
        std::env::var("VICTORY_TEXTURE_ROOM_PERCENT")
            .ok()
            .and_then(|v| v.trim().parse::<u64>().ok())
            .map_or(90, |percent| percent.clamp(50, 97))
    })
}
```

### 2.5 `crates/victory-gpu/src/shadow.rs:5195-5203`（标题内存上卡的额度）

```rust
    // `VICTORY_MEMORY_CARD_MB` says otherwise), and while it has room; past
    // that the side shaders see is in the PC's memory.
    static MOST: std::sync::OnceLock<u64> = std::sync::OnceLock::new();
    static USED: AtomicU64 = AtomicU64::new(0);
    let most = *MOST.get_or_init(|| {
        let mb = std::env::var("VICTORY_MEMORY_CARD_MB").ok().and_then(|v| v.trim().parse::<u64>().ok());
        mb.unwrap_or(4096) << 20
    });
    let room = host.video_memory().is_none_or(|[budget, used, ..]| used + len < budget / 100 * 97);
```

## 3 约束

1. **保留环境变量语义**：`VICTORY_TEXTURE_BUDGET_MB`、`VICTORY_CARD_ROOM_FOR_TARGETS_MB`、`VICTORY_TEXTURE_ROOM_PERCENT`、`VICTORY_MEMORY_CARD_MB` 必须继续能覆盖默认值，且取值域不放宽。
2. **≥10 GB 卡的默认行为不变**：这批默认值是在 10,200 MB 卡上测出来的（run 193/197/198），大卡上不得退化。
3. `video_memory()` 返回 `None`（适配器不报预算）时必须有确定行为，不能 panic。
4. 只用现有依赖（标准库 + `windows`/`windows-sys`），不新增 crate。
5. 不重命名公开函数；`room()`、`targets_room_kept()`、`room_percent()`、`texture_floor_bytes()` 的签名保持不变，便于 diff 套用。

## 4 需要你回答的问题

1. `texture_floor_bytes` 在 8 GB 卡上给多少合理？是按比例（budget/8）还是按绝对值（1 GiB）？为什么不能沿用"预算四分之一"这个比例？
2. `targets_room_kept` 的默认 3,072 MB 怎么改成"跟预算走"？世界首帧之后这部分已经落地，`room()` 里却仍把整块算作"将被用掉"，释放时机该怎么改才不引入竞态（注意 `MOST`/`USED` 是 `OnceLock` + 原子，模块是 `#[cfg(windows)]`）？
3. 上面三个预算（floor / targets / memory_card）同时存在，谁应该最先让步？给出优先顺序和理由。
4. 改完之后，8 GB 卡上卡内 used 应该落在预算的百分之多少？给出你预测的区间和依据。

## 5 输出格式（缺段退回）

```
## 诊断
（一句话）

## patch
```diff
--- a/crates/victory-gpu/src/resource.rs
+++ b/crates/victory-gpu/src/resource.rs
@@ ...
```

## 影响矩阵
| 场景 | ≥10 GB 卡 | 8 GB 卡 | video_memory()=None |

## 验证
（观测点 + 判据 + 用哪条日志确认）

## 回滚
（一行）
```

## 6 执行线的验收标准（你给的方案要能被这些指标检验）

| 指标 | 通过线 | 采法 |
| --- | --- | --- |
| 卡内 used / budget | 稳定在 85–92%，不再贴 99–100.5% | `VICTORY_LOG=info` 的卡内账本行 |
| 世界内帧时间中位数 | 相对 baseline 下降 ≥20% | `bench.ps1` 180 秒采样，取 `Ms > 40` 的样本中位数 |
| 私有内存峰值 | ≤ 24 GB | 同一次采样 |
| 画质 | flicker / 贴图迟到不明显恶化 | 三个固定场景人工比对 |
