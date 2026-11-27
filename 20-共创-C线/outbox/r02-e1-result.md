# r02-e1 · `fxceless/victory-fork` 取源 / 差异清点 / 隔离构建

> 执行端：本机 Windows。任务单 `20-共创-C线\inbox\task-20261127-0430-18.md`。只列差异与数字，不含合并建议。

## S1 取源

| 项 | 值 |
| --- | --- |
| 命令 | `git clone --depth 1 https://github.com/fxceless/victory-fork.git <ROOT>\fork-eval\victory-fork` |
| clone_EXIT | 0 |
| clone 耗时 | 7 s |
| commit | `52ac4ec0f8a03f103c146e60228e53612759d435` |
| date | `2026-11-26 13:05:17 -0500` |
| subject | `GPU: dynamic descriptor slots go back only to the heap that took them (#1324)` |
| files | 223 |
| size_mb | 224 |
| remote（本机 git 的 `insteadOf` 生效后原样） | fetch/push：`https://gh-proxy.com/https://github.com/fxceless/victory-fork.git` |
| 本地目标 | `<ROOT>\fork-eval\victory-fork`（新建；我们的树不是 git 仓库，`<ROOT>\cool_fox\cool_fox-main\.git` 不存在） |

## S2 差异清点

### S2-a 环境开关全集差（`.rs` 全文扫 `VICTORY_[A-Z0-9_]+`，`Select-String` 默认大小写不敏感，故清单里含少量小写标识符前缀，原样保留）

| 项 | 计数 |
| --- | --- |
| theirs_switches | 314 |
| ours_switches | 364 |
| ONLY_IN_THEIRS | 124 |
| ONLY_IN_OURS | 174 |

### ONLY_IN_THEIRS（124）

```text
VICTORY_ABSENT_MS
VICTORY_ABSENT_ONCE
VICTORY_ASYNC_PRESENT
VICTORY_BACK_OWN_CHECK
VICTORY_BACK_OWN_VIEW
VICTORY_BACK_READS
VICTORY_BAKE_SOURCES
VICTORY_BAKE_SOURCES_MB
VICTORY_BVH_HOLD
VICTORY_BVH_NO_HIT
VICTORY_CAPTURE_WORLD_EVERY
VICTORY_CARD_CHANGED_LIST
VICTORY_CARD_FETCH_INFLIGHT
VICTORY_CARD_FETCH_INFLIGHT_MB
VICTORY_CARD_HASH_WIDE
VICTORY_CARD_METER
VICTORY_CARD_METER_CLAMPS
VICTORY_CARD_METER_PIPELINES
VICTORY_CARD_SYNC_BATCH
VICTORY_CHANGED_RUNS
VICTORY_CLAMP_LEAN
VICTORY_CLAMP_WINDOW
VICTORY_CLZERO_LOOP15
VICTORY_COPY_CHANGED
victory_copy_guarded
victory_copy_guarded_at
victory_copy_guarded_fault
VICTORY_COPY_PLAIN
VICTORY_D3D12_DRED_FRAME_NAMES
VICTORY_DECODE
VICTORY_DECODE_WAVE64
VICTORY_DENY_PIPELINES
VICTORY_DIRTY_4K
VICTORY_DISK_CORES
VICTORY_DISPATCH_SPREAD
VICTORY_DRIVER_WATCH
VICTORY_FILL_WAIT
VICTORY_FILLS_PLAIN
VICTORY_FPS_COUNTER
VICTORY_FRAME_LOG
VICTORY_GATHER_BY_COPY
VICTORY_GATHER_DISPATCHES
VICTORY_GATHER_SEGMENTS
VICTORY_HEADS_ONLY
VICTORY_HEAP_LOCKS
VICTORY_HEAP_PASS_MARKED
VICTORY_HEAP_RECHECK_EVERY
VICTORY_HEAP_SYNC_CUT
VICTORY_HEAP_SYNC_PAGE
VICTORY_HEAP_SYNC_TABLES
VICTORY_HEAP_WORKER
VICTORY_INDIRECT_GATHER
VICTORY_INDIRECT_WINDOW_CHECK
VICTORY_JOIN_MOST
VICTORY_LIST_REUSE
VICTORY_LOOKUP_CACHE
VICTORY_MERGE_GAP
VICTORY_MERGE_RACE
VICTORY_MERGE_RUNS
VICTORY_MERGE_RUNS_ALT
VICTORY_NATIVE_HEADS
VICTORY_NATIVE_PSO_DUMP
VICTORY_NEAR_WRITES
VICTORY_OCCLUSION
VICTORY_PARALLEL_REFRESH
victory_profile_
VICTORY_PROFILE_AFTER
VICTORY_PROFILE_BUDGET
VICTORY_PROFILE_BUSY
VICTORY_PROFILE_DEPTH
VICTORY_PROFILE_EVERY
VICTORY_PROFILE_FOR
VICTORY_PROFILE_HZ
VICTORY_PROFILE_INLINE
VICTORY_PROFILE_JITTER_US
VICTORY_PROFILE_MAX_THREADS
VICTORY_PROFILE_OUT
VICTORY_PROFILE_REUSE
VICTORY_PROFILE_STACK_KB
victory_profile_test
victory_profile_test_
VICTORY_PROFILE_TEST_WALKS
VICTORY_PROFILE_THREADS
VICTORY_QUEUE2
VICTORY_QUEUE2_LANDING_MB
VICTORY_QUEUE2_REFETCH
victory_rdc
VICTORY_REAPER
VICTORY_REASK_BLANK
VICTORY_REFRESH_COUNT
VICTORY_REFRESH_ONCE
VICTORY_REGION_SKIP
VICTORY_REMAP_METER
VICTORY_REMAP_SPLIT
VICTORY_RENDERDOC
VICTORY_RENDERDOC_AT
VICTORY_RENDERDOC_OUT
VICTORY_RETIRE_LEAN
VICTORY_SETTLE_ROOM
VICTORY_SHADER_CACHE_KEY
VICTORY_SHOT
VICTORY_SHOT_AT
VICTORY_SHOT_FULL
VICTORY_SHOT_LISTS
VICTORY_SHOT_MAX
VICTORY_SHOT_MB
VICTORY_SHOT_TIMES
VICTORY_SPREAD
VICTORY_SPREAD_SPARE
VICTORY_STAGING_POOL
VICTORY_STAGING_POOL_MB
VICTORY_STEP_INDEX
VICTORY_SYNC_BESIDE
VICTORY_TABLE_STAGES
VICTORY_TARGET_VARIANTS
VICTORY_TILES_SMALL_WHEN_FULL_MB
VICTORY_VIDEO_LOOK
VICTORY_VIEW_ASK
VICTORY_VIEW_KNOWN
VICTORY_VIEW_OWN_COPY
VICTORY_VIEWS_REMADE_QUIET
VICTORY_WAVE_WIDE_ONLY
VICTORY_WINDOW_JUMP
VICTORY_WINDOW_UPLOAD
```

### ONLY_IN_OURS（174）

```text
VICTORY_A
VICTORY_AB
VICTORY_ACTIVATE_RAYS
VICTORY_AMBIENT
VICTORY_AMBIENT_AIR
VICTORY_AMBIENT_SHADE
VICTORY_ASK_EARLY
VICTORY_B
VICTORY_BAKE_EXACT
VICTORY_BENCH_CS
VICTORY_BENCH_FILE
VICTORY_BENCH_HOLES
VICTORY_BENCH_N
VICTORY_BENCH_S
VICTORY_BENCH_THREADS
VICTORY_BENCH_WARP
VICTORY_BIND_CACHE
VICTORY_BLOCK_WAY
VICTORY_BOOK
VICTORY_BURY_LAG
VICTORY_BVH_BOUNDS
VICTORY_BVH_FENCES
VICTORY_BVH_SIZES_WAIT
VICTORY_BVH_TRACE
VICTORY_CARD_ALL
VICTORY_CARD_AWAKE
VICTORY_CARD_SPANS
VICTORY_CARD_STEPS
VICTORY_COPIES_IN_PLACE
VICTORY_COPY_BESIDE
VICTORY_COPY_OVER_TITLE
VICTORY_DECLARE_ONCE
VICTORY_DSTORAGE_HALF
VICTORY_DSTORAGE_IO
VICTORY_DSTORAGE_LOG
VICTORY_DSTORAGE_STAGING_MB
VICTORY_DSTORAGE_TRACE
VICTORY_DYNAMIC_SLOTS
VICTORY_EARLY_ALL
VICTORY_EXACT_BACK
VICTORY_FAULT_BOOK
VICTORY_FAULT_BOOK_AT
VICTORY_FETCH_CHECK
VICTORY_FILL_TITLE
VICTORY_GPU_LOAD_MS
VICTORY_GUARD_REST
VICTORY_HEAP_PASS_ASIDE
VICTORY_HEAP_SPREAD
VICTORY_HEAP_SYNC_ASIDE
VICTORY_HEAP_SYNC_EARLY
VICTORY_HELD_LEVELS
VICTORY_HELPER_OWN
VICTORY_HOST_LOCK_CHILD
VICTORY_HOST_RDNA
VICTORY_IMAGE_WATCH
VICTORY_INDIRECT_BATCH
VICTORY_INDIRECT_REST
VICTORY_INDIRECT_WIDE
VICTORY_KEEP_FREED
VICTORY_KEEP_SHOWN
VICTORY_KNOWN_HOLES
VICTORY_LAND
VICTORY_LAND_ANYTIME
VICTORY_LAND_BESIDE
VICTORY_LAND_ECHO
VICTORY_LAND_SKIP
VICTORY_LAND_TAKEN
VICTORY_LAND_THREADS
VICTORY_LENT_HEAP
VICTORY_LIST_VIEWS
VICTORY_MAP_LEAN
VICTORY_MAP_THREADS
VICTORY_MAPPED_BY_VIEWS
VICTORY_MEMORY_CARD_MB
VICTORY_MEMORY_DUMP
VICTORY_NONE_SUCH
VICTORY_ONE_PAD
VICTORY_OPEN_ONE_VIEW
VICTORY_PAGE_PARTS
VICTORY_PANEL
VICTORY_PATCH_CLZERO
VICTORY_PATCH_WAITS
VICTORY_PICKED_MB
VICTORY_PICKED_WRITES
VICTORY_PIPELINE_BOOK
VICTORY_PIPELINE_LOWEST
VICTORY_PIPELINE_SLOW
VICTORY_PIPELINE_WORKERS
VICTORY_PLACED_ORDER
VICTORY_POKE
VICTORY_POP_ALL
VICTORY_POP_FOLDER
VICTORY_POP_WATCH
VICTORY_PROBE
VICTORY_PROCESS_PRIORITY
VICTORY_QUICK_FIND
VICTORY_QUICK_MIRROR
VICTORY_RAW_VIEWS
VICTORY_RDNA_FLOAT
VICTORY_READY_ONCE
VICTORY_RECORD
VICTORY_RECORD_ALWAYS
VICTORY_RECORD_AT
VICTORY_RECORD_FRAMES
VICTORY_REFRESH_AHEAD
VICTORY_REFRESH_FRONT
VICTORY_RELAY_COPY
VICTORY_REPLAY_GBV
VICTORY_REPLAY_PEEK
VICTORY_RIPE_BLOCKS
VICTORY_RT_RESOLVE
VICTORY_SAFE_COPY
victory_safe_copy_after
victory_safe_copy_at
victory_safe_copy_failed
victory_safe_merge
victory_safe_merge_after
victory_safe_merge_at
victory_safe_merge_failed
victory_safe_put
victory_safe_put_after
victory_safe_put_at
victory_safe_put_failed
VICTORY_SAME_RECORDS
VICTORY_SCREEN_WAIT_MS
VICTORY_SECTION_WINDOW
VICTORY_SEND_BAR
VICTORY_SEND_CHANGED
VICTORY_SEND_OWN
VICTORY_SHOW_AFTER
VICTORY_SKIP_CPU_CHECK
VICTORY_SLOT_CHECK
VICTORY_SLOT_HOLDS
VICTORY_SNAPSHOT_POOL
VICTORY_STORE_BESIDE
VICTORY_STREAM_NOTICE
VICTORY_STREAM_PRIORITY
VICTORY_SUBMIT_DEPTH
VICTORY_SUBMIT_FRAMES
VICTORY_TAKE_PARTS
VICTORY_TEST_D3D_DEBUG
VICTORY_TEST_ROUNDS
VICTORY_TEXTURE_AWAY_MS
VICTORY_TEXTURE_FILL
VICTORY_TEXTURE_HOT
VICTORY_TEXTURE_KEEP
VICTORY_TEXTURE_ONCE
VICTORY_TEXTURE_POOL
VICTORY_TEXTURE_SAME
VICTORY_THIN
VICTORY_THIN_THREADS
VICTORY_THREAD_DIMENSIONS
VICTORY_TIMELINE
VICTORY_TIMELINE_AT
VICTORY_TIMELINE_FRAMES
VICTORY_TITLE_PRIORITIES
VICTORY_TRANSLATOR
VICTORY_UNDER_THREADS
VICTORY_UNDER_WIDE
VICTORY_UNDER_WORDS
VICTORY_UPCOPY_CHECK
VICTORY_UPLOAD_AHEAD
VICTORY_UPLOAD_LOW
VICTORY_VIEW_BYTES
VICTORY_VIEW_COPY
VICTORY_VIEW_THREADS
VICTORY_WAIT_RESIDENT
VICTORY_WIDE_FILLS
VICTORY_WIDE_SPIN
VICTORY_WIDE_TEXTURES
VICTORY_WINDOW_MAX
VICTORY_WINDOWS_BAR_MB
VICTORY_WINDOWS_OWN
VICTORY_WRITE_SITES
```

### S2-b `.rs` 文件差

| 项 | 计数 |
| --- | --- |
| rs_theirs | 160 |
| rs_ours | 226 |
| RS_ONLY_IN_THEIRS | 17 |
| RS_ONLY_IN_OURS | 83 |

> 口径说明（原样）：扫描含 `<ROOT>\cool_fox\cool_fox-main\target\` 下由 build script 生成的 `out\private.rs`（12 条），任务单命令未排除 `target\`，此处不额外过滤。

### RS_ONLY_IN_THEIRS（17）

```text
crates\victory-gpu\src\backreads.rs
crates\victory-gpu\src\cardmeter.rs
crates\victory-gpu\src\drvwatch.rs
crates\victory-gpu\src\fpsbox.rs
crates\victory-gpu\src\framelog.rs
crates\victory-gpu\src\heap_pass.rs
crates\victory-gpu\src\heap_worker.rs
crates\victory-gpu\src\plaincopy.rs
crates\victory-gpu\src\profile.rs
crates\victory-gpu\src\profile\tests.rs
crates\victory-gpu\src\queue2.rs
crates\victory-gpu\src\renderdoc.rs
crates\victory-gpu\src\shot.rs
crates\victory-gpu\src\spread.rs
crates\victory-gpu\src\stats.rs
crates\victory-shader\src\emit\dispatch_threads.rs
crates\victory-shader\src\emit\halves.rs
```

### RS_ONLY_IN_OURS（83）

```text
apps\victory\src\replay.rs
apps\victory\src\warm.rs
apps\victory\tests\census.rs
crates\victory-formats\examples\texture_layout_bench.rs
crates\victory-gpu\build.rs
crates\victory-gpu\src\ab.rs
crates\victory-gpu\src\ambient.rs
crates\victory-gpu\src\book.rs
crates\victory-gpu\src\compose.rs
crates\victory-gpu\src\cores.rs
crates\victory-gpu\src\faultbook.rs
crates\victory-gpu\src\host\aside.rs
crates\victory-gpu\src\host\awake.rs
crates\victory-gpu\src\host\card_steps.rs
crates\victory-gpu\src\host\indirects.rs
crates\victory-gpu\src\host\panel.rs
crates\victory-gpu\src\host\place.rs
crates\victory-gpu\src\host\send.rs
crates\victory-gpu\src\host\spans.rs
crates\victory-gpu\src\host\stamps.rs
crates\victory-gpu\src\host\torn.rs
crates\victory-gpu\src\host\traffic.rs
crates\victory-gpu\src\host\upcheck.rs
crates\victory-gpu\src\indirect\batch.rs
crates\victory-gpu\src\land.rs
crates\victory-gpu\src\land\tests.rs
crates\victory-gpu\src\list\thin.rs
crates\victory-gpu\src\picked.rs
crates\victory-gpu\src\pipeline\known.rs
crates\victory-gpu\src\pool.rs
crates\victory-gpu\src\popwatch.rs
crates\victory-gpu\src\queue\behind.rs
crates\victory-gpu\src\replay\edit.rs
crates\victory-gpu\src\replay\gpu.rs
crates\victory-gpu\src\replay\hook.rs
crates\victory-gpu\src\replay\mod.rs
crates\victory-gpu\src\replay\play.rs
crates\victory-gpu\src\replay\play\diverge.rs
crates\victory-gpu\src\replay\play\look.rs
crates\victory-gpu\src\replay\play\merge.rs
crates\victory-gpu\src\replay\play\pixel.rs
crates\victory-gpu\src\replay\play\upcopies.rs
crates\victory-gpu\src\replay\pso.rs
crates\victory-gpu\src\replay\record.rs
crates\victory-gpu\src\replay\snap.rs
crates\victory-gpu\src\replay\states.rs
crates\victory-gpu\src\replay\wire.rs
crates\victory-gpu\src\residency.rs
crates\victory-gpu\src\safecopy.rs
crates\victory-gpu\src\switch.rs
crates\victory-gpu\src\tdr.rs
crates\victory-gpu\src\texture\ahead.rs
crates\victory-gpu\src\timeline.rs
crates\victory-gpu\src\timeline\hooks.rs
crates\victory-gpu\src\timeline\record.rs
crates\victory-gpu\src\timeline\report.rs
crates\victory-gpu\src\titlewrite.rs
crates\victory-gpu\src\titlewrite\decode.rs
crates\victory-gpu\src\upload.rs
crates\victory-gpu\tests\replay_big.rs
crates\victory-gpu\tests\replay.rs
crates\victory-hle\src\image_watch.rs
crates\victory-hle\src\modules\rpcrt4.rs
crates\victory-loader\src\profile.rs
crates\victory-loader\src\publish.rs
crates\victory-loader\src\write_sites.rs
crates\victory-shader\benches\guard_runs.rs
crates\victory-shader\src\emit\cube_lod_tests.rs
crates\victory-shader\src\emit\permlane_tests.rs
crates\victory-shader\src\emit\probe_tests.rs
crates\victory-shader\src\emit\size_tests.rs
target\debug\build\serde_core-9fcfaeee854946d2\out\private.rs
target\debug\build\serde-b5b898fd2d9f92bc\out\private.rs
target\debug\build\thiserror-1c90ea3aaafcb569\out\private.rs
target\diag\build\serde_core-bf06e6089b8b46f1\out\private.rs
target\diag\build\serde-04fec5408683f864\out\private.rs
target\diag\build\thiserror-2975b2fe3760bb99\out\private.rs
target\release\build\serde_core-a5a59ed63537f784\out\private.rs
target\release\build\serde_core-bf06e6089b8b46f1\out\private.rs
target\release\build\serde-04fec5408683f864\out\private.rs
target\release\build\serde-2d38ca3654b786a6\out\private.rs
target\release\build\thiserror-2975b2fe3760bb99\out\private.rs
target\release\build\thiserror-f682a0f10ecd83b8\out\private.rs
```

### S2-c 构建配置

| 项 | theirs | ours |
| --- | --- | --- |
| rust-toolchain.toml | channel 1.98.1 / targets `x86_64-pc-windows-msvc` / components rustfmt,clippy / profile minimal | 逐字相同 |
| `[profile.*]` 节名 | `[profile.dev.package."*"]`、`[profile.release]`、`[profile.diag]` | 同上 |
| `[profile.release]` | `debug = "line-tables-only"` | `debug = "line-tables-only"` + `codegen-units = 1` + `lto = "thin"` + `panic = "unwind"` |
| workspace members | `members = ["crates/*", "apps/*", "xtask"]` / `exclude = ["tests/fixtures"]` | 逐字相同 |
| apps/ | victory | victory |
| Cargo.lock | 22158 B，SHA256 `BFBBB8B827F71A48125BFBF206283CBD2A7959EB2F6668E9D39573F0BBEF23E4` | 22158 B，SHA256 `BFBBB8B827F71A48125BFBF206283CBD2A7959EB2F6668E9D39573F0BBEF23E4`（一致） |
| `.cargo/config.toml` | 49 B，只有 `[alias] xtask = ...` | 635 B，`[alias]` 同上，另有 `[target.x86_64-pc-windows-gnu] rustflags = ["-C","target-cpu=native"]` |

`[profile.release]` 原文（theirs）：

```toml
[profile.release]
debug = "line-tables-only"
```

`[profile.release]` 原文（ours）：

```toml
[profile.release]
debug = "line-tables-only"
# This fork: one codegen unit and thin LTO, for the cross-crate inlining the
# list translator, the GPU side and the emulator's hot paths expect between
# `victory-shader`, `victory-gpu` and `victory-hle` (a build takes minutes
# longer, a run does not).
codegen-units = 1
lto = "thin"
# Not `abort`: `victory-gpu/src/list/thin.rs` catches a panicking list
# translation with `catch_unwind`, and aborting ends the process instead.
panic = "unwind"
```

## S3 隔离构建

| 项 | 值 |
| --- | --- |
| 命令 | `cargo build --release --locked -p victory`（工作目录 `<ROOT>\fork-eval\victory-fork`） |
| CARGO_TARGET_DIR | `<ROOT>\fork-eval\target` |
| CARGO_HOME / RUSTUP_HOME | `<RUST>\cargo` / `<RUST>\rustup` |
| RUSTFLAGS | `'`（空） |
| build_EXIT | 0 |
| elapsed | 116 s（日志末行 `Finished `release` profile [optimized + debuginfo] target(s) in 1m 54s`） |
| errors | 0 |
| exe 路径 | `<ROOT>\fork-eval\target\release\victory.exe` |
| exe_bytes | 65035254 |
| written | 2026-11-27 04:33:11 |
| exe_sha256 | `4B3D4D225A0800328C3A88DCD1496A339A89995563CFF2EBFB45628E264B2DA2` |
| our_release_sha256（构建前） | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` |
| our_release_sha256（构建后） | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` |

## 上下文对照（背景数字，均来自既有记录，未新测）

| 项 | 值 |
| --- | --- |
| 对方 README 自述 | first boat mission 8.2–9.5 fps（RTX 4070 / i7-14700KF） |
| 本机实测（既有） | ~4 fps，4,400 draws，222.3 ms/帧 |
| 我们 release 产物 | 49,681,038 B，SHA256 `58E60D62…A4EFF45` |
| 本次对方的构建产物 | 65,035,254 B，SHA256 `4B3D4D225A0800328C3A88DCD1496A339A89995563CFF2EBFB45628E264B2DA2` |

## 红线遵守

| 项 | 状态 | 依据 |
| --- | --- | --- |
| 不写 `cool_fox-main` 下任何文件 | 未写 | `Cargo.toml` LastWriteTime 仍 2026-11-26 20:56:44；`target\release\victory.exe` 仍 2026-11-26 22:02:32 / SHA 未变 |
| 不写 `victory-data\coolfox-cache` | 未写 | 本单全程未启动 victory，未传 `VICTORY_CACHE_DIR` |
| 不运行游戏 | 遵守 | 无 `victory.exe run` / `--execute` 调用 |
| 不改对方源码 | 遵守 | clone 后未编辑、未 `cargo add`/`update`；`--locked` 直接通过（两边 Cargo.lock 同一 SHA） |
| 不 push | 遵守 | 仅 `git clone` 与只读 `git log`/`remote -v` |
| 不删 `<ROOT>\fork-eval` 下任何东西 | 遵守 | 失败重试未发生（首次构建即 EXIT=0） |

## 产出文件

1. `<ROOT>\fork-eval\report-e1.md`（本文件）
2. `<ROOT>\fork-eval\build-e1.log`（cargo 全量输出，3460 B）
3. `<ROOT>\fork-eval\build-e1-runner.log`（runner 记录：EXIT/耗时/errors/exe 信息）
4. `<ROOT>\fork-eval\victory-fork\`（clone 内容）
5. `<ROOT>\fork-eval\target\release\victory.exe`（隔离构建产物）
6. `20-共创-C线\outbox\r02-e1-result.md`（回填件，内容同本文件）
