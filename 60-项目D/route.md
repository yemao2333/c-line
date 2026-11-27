# 项目 D · 待用户描述后开单

开项：2026-11-27 03:35（用户指示「启动D，我来描述」）
前置：round-01…03、项目 A+B、项目 C 均已结项。本项目为新项目，停止条件重置。

---

## 1 三个既有候选（来自结项报告 §6「未验证」）

| 代号 | 事项 | 现状 | 成本 |
| --- | --- | --- | --- |
| D-1 | **画质**：树/植被/远景闪烁、贴图迟到 | 从未截图对比（唯一没验的判据） | 需人看，~10 分钟/组 |
| D-2 | **构建 flags 单独 A/B**：`RUSTFLAGS=""` vs `-C target-cpu=native` | 只与代码改动同批测过，未分离 | 2 次构建 + 2 次跑 ≈40 分钟 |
| D-3 | **P3 着色器**：26 个 wave64 + 5 个「描述符只读」的命中统计 | 未统计 | ~20 分钟（需管线册） |

## 2 用户描述（2026-11-27 03:37，原话保真）

> **进游戏后现象为画面昏暗，主角（玩家操控的人物）有建模和颜色其他人看不出来明显面部细节，只有黑色，衣服也是，画面卡顿，可能是因为帧率有关**

随附截图 `image.png`（sha256 `b0b93210…`，1820×1025）：标题栏 `Americas | VIctory 4 fps 222.3 ms/frame 4443 draws/frame`；画面为日落逆光下的第三人称背影（主角：金色发辫、红上衣、有颜色），中央有一块**明亮的矩形内嵌画面**（人群/塔楼，与周围暗场景色调完全不同）。

### 2.1 拆成四条可查的症状

| 代号 | 症状 | 可能机制 |
| --- | --- | --- |
| **S1** | **整体昏暗** | ① 环境光替代（`VICTORY_AMBIENT*` 三档）参数不足；② 色调映射/曝光链缺失；③ HDR→SDR 直出无 tonemap |
| **S2** | **NPC 面部与衣服全黑**（主角正常） | ① 某类 lighting/skinning compute 被丢弃（本机已见 `dropped 1.0/frame without a host pipeline: compute 02384a60fda6f2d0`）；② 非主角的贴图流式未到；③ 阴影/光照 buffer 对非主角未绑定 |
| **S3** | **中央明亮的矩形内嵌画面** | 视口/裁剪或 RT 尺寸错配：某张应为全屏的纹理按小四边形绘制（这类 bug 在翻译层=viewport/scissor 或 screen-space 变换差异） |
| **S4** | **卡顿** | 已知：222.3 ms/帧、4,443 draws（与 round-01…03 测量一致），**与 S1–S3 是两个独立问题**，不混谈 |

### 2.2 代码侧已取到的线索（无需跑机器）

| 线索 | 证据 |
| --- | --- |
| 每帧丢 1 个 compute dispatch | `r11-timeline.err.log`：`dropped 1.0/frame without a host pipeline: compute 02384a60fda6f2d0`（同日志 `dropped` 命中 402 次、`without a host pipeline` 254 次） |
| 5 个着色器翻不动 | 同日志 `WARN victory_gpu::pipeline: shader does not translate; its pipelines' draws are dropped stage="compute" hash=926c46bab3b86bd6 … GFX10 code at 0x0: no wave32 lowering for this wave64 program` |
| 环境光替代的三档开关 | `VICTORY_AMBIENT`(ambient.rs:97)、`VICTORY_AMBIENT_AIR`(:110)、`VICTORY_AMBIENT_SHADE`(:120)；启动脚本现设 `AMBIENT=0.8`、`AMBIENT_AIR=1.5` |

**S2 的头号嫌疑由此确定**：被丢弃的那个 compute（`02384a60fda6f2d0`）如果正是光照/皮肤/阴影相关的 pass，就会表现为"非主角全黑、主角正常"（主角常走专门的着色路径）。

### 2.3 第二张截图（室内，2026-11-27 03:4x，sha256 `5b9360b9…`）

用户说明：「现在是在室内，没有办法去室外」。

画面特征，与 `ambient.rs` 的头注释逐字对上：

| 观察 | 源码原文 | 判读 |
| --- | --- | --- |
| 天花板灯**过曝成纯白**，其余全暗 | （HDR→SDR 的色调映射链） | 高光无滚降 = 典型的 tonemap 缺失或曝光偏低 |
| 整幅画面盖着一层**褐色雾/薄纱** | 「The air of a room is lit by the same probes: without rays they hold the sky's light indoors too, **a brown veil at sunset**. `VICTORY_AMBIENT_AIR` bounds what the air scatters by a multiple of the light around.」 | **这就是 `VICTORY_AMBIENT_AIR=1.5` 的褐纱**：没有光追时，环境探针把天空的光也搬进室内 |
| 主角红衣服过饱和、边缘发亮 | — | 与「AMBIENT 份额 0.8」一致：替代光在给主体补光 |

⇒ **S1 的机制在源码里写明了**，不需要出门：室内的褐纱就是 `AMBIENT_AIR`；过曝灯是高光映射。室内反而**更适合**做 A/B（场景静止、不流式）。

### 2.4 两张"基线"互相不一样 —— 环境光估计有滞回（重要方法学）

同一存档、同一位置、同一份 env（都用 `Start-GTA6.cmd` 默认），两张图差异明显：

| | 第一张 `5b9360b9…` | 第二张 `c78c8f53…` |
| --- | --- | --- |
| 整体亮度 | 暗 | **明显更亮** |
| 褐纱 | 薄 | **厚得多**，充满房间 |
| 天花板灯 | 纯白过曝 | 带**紫/蓝**色调 |

原因就在 `ambient.rs` 的头注释里：

> 「what is not on screen sends out what is (with **a slow mean of the last seconds**, so that turning into a dark corner is not black at once)」

即**环境光估计是"最近几秒"的滑动平均** ⇒ 亮度取决于你**进这个房间前看过什么**、以及**站了多久**。

**因此本项目的 A/B 必须固定"停留时长"**：进世界 → 走到同一位置 → **站住数 20 秒再截图**（三局都一样）。否则测到的是滞回，不是开关。

### 2.5 第 1 局 `VICTORY_AMBIENT_AIR=0`（2026-11-27 03:50，sha256 `36dcbf28…`）—— 褐纱确实来自 AMBIENT_AIR

| 项 | 基线（`c78c8f53…`，默认 0.8/1.5） | `AIR=0`（`36dcbf28…`） |
| --- | --- | --- |
| 房间空气 | **厚琥珀色雾**，充满整个房间 | **明显变薄**，远处墙面与窗框看得清 |
| 右墙的窗/红灯箱 | 被雾糊住 | **轮廓清楚**，红灯箱与窗都显出来 |
| 对比度 | 低（雾压平） | 高（暗部更暗、亮面更亮） |
| 天花板灯 | 纯白过曝 | **仍然纯白过曝**（与本开关无关） |
| 红衣服 | 过饱和发亮 | 仍然过饱和 |

**判读**：S1 的"褐纱"这一半**确认是 `VICTORY_AMBIENT_AIR`**（源码注释里那句 "a brown veil at sunset" 被实测复现）。剩下的"昏暗"和"高光爆白"是两件独立的事，需要第 2 局 `AMBIENT=0` 才能分清。

**注意**：该帧出现了字幕「靠近一个狱友并与之互动」，说明位置/进度与基线不完全一致；但雾的差别太大，不是场景漂移能解释的。

### 2.6 第 2 局 `VICTORY_AMBIENT=0`（2026-11-27 03:5x，sha256 `79fd854c…`）—— 标题自己能出图

| 项 | 基线 `0.8/1.5` | `AIR=0` | **`AMBIENT=0`（AIR 仍 1.5）** |
| --- | --- | --- | --- |
| 天花板灯 | 一团纯白 | 一团纯白 | **看清一根根灯管**（高频细节回来了） |
| 雾 | 厚 | 薄 | 中等（仍在，因为 `AIR=1.5` 没关） |
| 房间暗部 | 被雾压平 | 对比高 | 偏暗但结构清楚 |
| 结论 | 替代光在压细节 | — | **标题自己的输出存在、可用**；本局的雾来自仍开着的 `AIR=1.5` |

**判读**：`AMBIENT=0` 并不是黑屏 ⇒ 没有光追时标题自己也能出室内光，**我们的环境光替代是在"洗"画面**（把灯管、墙面高频都糊成一团）。
⇒ 下一步只需一局：**`AMBIENT=0` + `AIR=0` 一起关**，若与 `AMBIENT=0` 的观感一致或更干净，则 S1 的处置就是**把两个开关都设 0**（零代码，改 `Start-GTA6.cmd`）。

### 2.7 用户裁决（2026-11-27 04:0x，原话保真）

> **第三张，在历史对话从上往下数第三张出现的细节会更加明显，有门的边框及颜色**

五张图的编号（按对话从上往下）：

| # | sha256 前缀 | 是哪一局 | env |
| --- | --- | --- | --- |
| 1 | `b0b93210` | 户外逆光（初次描述） | 默认 |
| 2 | `5b9360b9` | 室内第一张（偏暗） | 默认 |
| **3** | **`c78c8f53`** | **用户忘记跑脚本的那局 = 默认基线** | **`AMBIENT=0.8 / AIR=1.5`** |
| 4 | `36dcbf28` | `air0` | `AIR=0` |
| 5 | `79fd854c` | `amb0` | `AMBIENT=0`（AIR 仍 1.5） |

⇒ **用户判定：默认（`0.8 / 1.5`）目前最接近实机**，理由是"细节更明显，有门的边框及颜色"。

**这一条推翻了「把 AMBIENT 关掉」的方向**：环境光替代把暗部几何抬到黑位之上，门框边缘与颜色才看得见；关掉后暗部掉进黑里，细节反而没了。**"看得清"与"没有褐纱"是同一个参数的两端**，要找的是折中点，不是 0。

### 2.8 第 4 局 `AMBIENT=1.5 / AIR=0`（2026-11-27 04:03，sha256 `6222fb40…`）—— S1 有改善，S2 纹丝不动

用户原话：**「这版主角的面部细节更好了，但是其他npc的面部依旧是一团黑」**

| 症状 | 本局结果 |
| --- | --- |
| S1 昏暗 | **改善**：主角面部/发丝细节出来；但琥珀纱仍在（说明那层雾不完全是 `AIR`，可能是标题自己的体积雾） |
| S2 NPC 全黑 | **毫无变化** ⇒ 与环境光无关，是另一条链 |
| 新发现 | 后脑勺上出现一块**硬边矩形贴片**（亮块带直角边），与最初那张图的"亮矩形"同类 ⇒ S3（视口/RT 错配）不止一处 |

### 2.9 S2 的代码侧线索：NPC 走的是 wave64 的 ped mesh 程序

| 证据 | 出处 |
| --- | --- |
| 「the widest wave the GPU runs: 32 (NVIDIA) gets console **wave64 compute programs** whose cross-lane code stays in 32-lane halves translated for waves of 32」 | `host.rs:930` 注释 |
| 「// in the **ped mesh programs**. Only wave64 programs have pairs…」 | `ir.rs:381` 注释（ped = NPC） |
| 5 个程序翻不动：`shader does not translate … stage="compute" … no wave32 lowering for this wave64 program` | `r11-timeline.err.log` |
| 每帧丢 **1.0** 个 compute dispatch（`compute 02384a60fda6f2d0`） | 同上 |

⇒ **假设 H2**：NPC 的 ped mesh/光照 compute 是 wave64，在 NVIDIA（wave32 主机）上部分降不下来 → 那些 draw/dispatch 被丢 → NPC 面部与衣服全黑，而主角走另一条着色路径所以正常。

**可用诊断**（`lower.rs:1501`）：`VICTORY_WAVE_WHY=1` —— 「why a program keeps 64-lane waves（one line per reason）」，直接打印**每个程序保持 64 lane 的原因**。

**可用开关**（`shader_cache.rs:64-72`，注意它们都进翻译指纹 ⇒ 改任一个都会让 25,756 个缓存重翻）：
`VICTORY_WAVE_WIDE` / `VICTORY_WAVE_DEEP_SKIPS` / `VICTORY_WAVE_OWN_BITS` / `VICTORY_WAVE_LOCAL` / `VICTORY_F16_NEAREST` / `VICTORY_HELPER_OWN` / `VICTORY_FIRSTLANE_OWN` / `VICTORY_FIRST_HALF` / `VICTORY_STRICT_JOINS` / `VICTORY_MESH_OUTPUT_STRICT` / `VICTORY_BVH_FENCES` / `VICTORY_BVH_BOUNDS`。

### 2.10 `VICTORY_WAVE_WHY=1` 结果（2026-11-27 04:1x，`data\r12-wavewhy.err.log` 4.0 MB）—— 结论：**没有开关可救**

| 项 | 读数 |
| --- | --- |
| `WAVE64-WHY` 行 | **120 条**，去重后只有 **3 种**，全部同一组原因：`group=64`(16) / `group=1024`(11) / `group=128`(10)，`lds=true` |
| 原因原文 | `[LDS in a group over 32, an LDS read and write in one lane-branch region, mask as data, v_mbcnt, v_readlane]` |
| 翻译器的重试（日志里逐个试过） | `without early-outs` → `without skips` → `scalars followed` → `local waves (APPROXIMATE)` → `local waves (APPROXIMATE, any mask)` → **每次都仍然 `wave Some(64)`** |
| 具体阻塞点 | `at 0x7e8: a wave reduction where not every lane runs is not supported`；`at 0x1ee0: a first-lane read where not every lane runs is not supported`；`not the allocation idiom at 0x21c/0x274/0x768` |
| 翻不动的着色器 | **5 个**（`stage="compute"`），其中一个正是每帧被丢的 `02384a60fda6f2d0` |

**判读**：翻译器已经把能试的近似都试完了（early-outs、skips、scalars、local waves、any mask），卡在 **LDS 跨 32 lane 的读写模式**上 —— 这是 `victory-shader` 的**代码能力边界**，不是环境变量能绕过的。

⇒ **S2 的终态（假设层面）**：NPC 的 ped mesh/光照 compute 属于这批 wave64 程序；要么被丢（1 dispatch/帧），要么走了不完整路径 ⇒ 面部/衣服黑。**修它需要给 translator 加「wave64 LDS 模式降级到 wave32」的能力 = 代码项目，不是调参。**

**还剩一个便宜的分叉要排除**：黑脸也可能是**贴图没流到**（`LEVELS_ON_DEMAND` / `TEXTURE_NO_WAIT`）。见 §3 的 D-3 单。若排除流式，S2 就定案为 translator 限制。

### 2.11 外部情报（用户提供 `portwatch-vi.xyz`，2026-11-27 04:20）

该站是 GTA VI 移植进度追踪器，数据在 `data/tracker.json`。三条与我们直接相关：

1. **上游 fork `fxceless/victory-fork`（3,255 星，11-26 18:08 仍有提交）README 自述**：
   - 「**Shadowed areas are still black**：the game's ray-traced bounce light and ray-traced lamp and sun shadows do not run yet, so anything the sun does not hit directly is black」 ← **正是我们的 S1/S2**（NPC 在阴影里 → 全黑）；
   - 帧率：first boat mission **8.2–9.5 fps**（3,000–5,000 draws，RTX 4070 / i7-14700KF / 32 GB），「the thread that prepares submissions is the limit (~70 ms/frame)」；
   - **`VICTORY_HEAP_WORKER=1` 单项把世界帧率从 6.2 提到 8.65**；`VICTORY_PARALLEL_REFRESH=1`+`SETTLE_ROOM=1` 再省 ~20 ms；`VICTORY_LOOKUP_CACHE=1` ~14 ms；`VICTORY_CARD_BUFFERS_MIN_KB=64` 卡时 68→49.8 ms。
2. **ZETTROX `ztrx`（NVIDIA 向，RTX 3050 测）**：症状同我们 —— 「anything in shadow drawn black and bright scenes overexposed」。
3. **Belobug（AMD，77.4 分）**：自己写了「a stand-in for the game's ray-traced indirect light」（室内彩色块修复），并把一个重场景的 GPU 时间从 **225 → 约 80 ms**。

### 2.12 关键对照：我们的树是**另一个 fork**，缺了那一整套开关

对 `cool_fox-main` 源码逐个 grep（不是查清单 CSV）：

| 开关 | 我们的树 | 说明 |
| --- | --- | --- |
| `VICTORY_ASYNC_SUBMIT` | **有**（`queue.rs:1058`） | 上游把它列为最大收益之一（提交从渲染线程搬到自家线程；profile 显示渲染线程 292 ms 里有 257 ms 在提交路径）→ **我们从未测过** |
| `VICTORY_LIGHT_REFRESH` / `INDIRECT_WINDOW` / `CARD_BUFFERS_MIN_KB` / `SHADER_OPT` / `PAGE_WRITES` / `MESH_OUTPUT_*` | 有 | 已在用或已测 |
| `VICTORY_HEAP_WORKER` | **无** | 上游靠它 6.2→8.65 fps |
| `VICTORY_PARALLEL_REFRESH` / `SETTLE_ROOM` / `LOOKUP_CACHE` / `STEP_INDEX` / `FILLS_PLAIN` / `COPY_PLAIN` / `QUEUE2` / `ABSENT_ONCE` / `BVH_NO_HIT` / `REASK_BLANK` | **全无** | 都属 fxceless fork 新增 |

**结论（战略级）**：我们这棵树（CGBJ/codec-d 的 cool_fox，基于 VIctory+XCL）比 fxceless 的 fork 落后一整套性能开关；**若把后者那套搬过来，按对方实测是 6.2→8.65 fps 量级的差距**。这是比继续调参更大的杠杆，但属于「换/合并上游」的工程决定。

**同时它也解释了 S1/S2 的天花板**：阴影里的黑是**上游已知未解决**问题（缺光追间接光），我们的 `VICTORY_AMBIENT*` 替代光已经是现有折中；想把 NPC 照亮，得等那条光追链路。

### 2.13 `VICTORY_AB` 试跑（04:24）：**没出阶段行，因为 AB 只在 diag 产物里**

`data\r12-absubmit.err.log`（4.6 MB）读数：

| 项 | 结果 |
| --- | --- |
| `A/B phase` 行 | **0 条** |
| `ASYNC_SUBMIT` 行 | 有：`submissions are prepared and sent by a thread of ours … frames=1 runs=64`；逐帧 `3.0 in 1.0 presents`，该线程**每帧只干 0.8–7.6 ms** |

两个结论：

1. **`VICTORY_AB` 需要 diag 产物**（`crate::ab` 挂在 `#[cfg(feature="diagnostics")]` 下），release 产物里没有 → 所以没有阶段行，不是参数写错。
2. **`VICTORY_ASYNC_SUBMIT` 在我们的基线里本来就是开的**：`behind.rs:654` 的判定是 `(env == "1" || crate::list::thin::wanted()) && started()`，而启动脚本一直有 `VICTORY_THIN=1` ⇒ **「方向 1」按构造就是空操作**，这条不是没测过，是一直开着。
3. 顺带量到：异步提交线程每帧只工作 **0.8–7.6 ms** ⇒ **提交准备不是我们的瓶颈**，与项目 C 的结论（慢帧卡在显卡 / 标题线程）一致。

⇒ 要做真正的同场景 A/B，必须换 **diag 产物**（`target\diag\victory.exe`，SHA256 `710857B5…`）。

## 3 停止条件（全绿才说结项）

| # | 条件 | 当前 |
| --- | --- | --- |
| **F1** | 用户描述被完整落成本项目 §2（原话保真） | 未开始 |
| **F2** | 据此投单并回填核对（若结论是"不可测"，需给出不可测的原因） | 未开始 |
| **F3** | 结论写入 `30-结项报告.md`（若属既有 §6 条目，则更新那条的状态） | 未开始 |

## 4 纪律

1. 用户描述里凡涉及"人参与"的环节（进世界、存档、菜单），一律先记为不可控变量（项目 A+B 的教训）；
2. 只报数不判读；判读在代码侧；
3. 不新增实验轮次，除非 F2 需要一次确认跑；
4. 报告只增不改已封版的小节。
