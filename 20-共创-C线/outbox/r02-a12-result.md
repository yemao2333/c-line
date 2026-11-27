# r02-a12 回填 · R6 四组（拷贝与流水线，release 产物，各 200 s）

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0105-12.md`。只报数，不判读。

## A 前置守卫

| 项 | 值 | 出处 |
| --- | --- | --- |
| SHA256（release） | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` | `data\r02-a12-console.log` L1–L2 |
| 产物 | `G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe`（未用 diag 产物） | 同 L3 |
| commit_limit_gb | 49.84 | 同 L3（`commit_limit_gb=49.84 commit_free_gb=38.15`） |
| 门禁 | ≥ 44，通过 | — |

## B 四组结果（`data\bench-v2.csv` L12–L15，原样）

```csv
2026-11-27 01:10:54,R6-control,200,40,ms>40&draws>=200,30,268,4679,20.59,3.89,12.73,0,run-R6-control-1127-010646.log
2026-11-27 01:15:11,R6-sendown0,200,40,ms>40&draws>=200,30,258.5,4550,20.43,4.81,13.34,0,run-R6-sendown0-1127-011100.log
2026-11-27 01:19:25,R6-inplace0,200,40,ms>40&draws>=200,32,309.3,4764,20.94,3.77,12.89,0,run-R6-inplace0-1127-011518.log
2026-11-27 01:23:43,R6-latewait1,200,40,ms>40&draws>=200,32,334,4352,19.66,4.66,13.93,0,run-R6-latewait1-1127-011930.log
```

| 序 | label | `-Extra` | world_samples | median_ms_world | median_draws | leftover_procs |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | R6-control | （无） | 30 | 268 | 4679 | 0 |
| 2 | R6-sendown0 | `VICTORY_SEND_OWN=0` | 30 | 258.5 | 4550 | 0 |
| 3 | R6-inplace0 | `VICTORY_COPIES_IN_PLACE=0` | 32 | 309.3 | 4764 | 0 |
| 4 | R6-latewait1 | `VICTORY_LATE_WAIT=1` | 32 | 334 | 4352 | 0 |

各组的 median 行原文（`data\r02-a12-console.log`）：

```text
median_ms_world = 268 （filter v2，30 条世界样本，中位 draws=4679）；max_priv_gb = 20.59 ；min_free_gb = 3.89 ；min_commit_free_gb = 12.73 ；leftover_procs = 0
median_ms_world = 258.5 （filter v2，30 条世界样本，中位 draws=4550）；max_priv_gb = 20.43 ；min_free_gb = 4.81 ；min_commit_free_gb = 13.34 ；leftover_procs = 0
median_ms_world = 309.3 （filter v2，32 条世界样本，中位 draws=4764）；max_priv_gb = 20.94 ；min_free_gb = 3.77 ；min_commit_free_gb = 12.89 ；leftover_procs = 0
median_ms_world = 334 （filter v2，32 条世界样本，中位 draws=4352）；max_priv_gb = 19.66 ；min_free_gb = 4.66 ；min_commit_free_gb = 13.93 ；leftover_procs = 0
```

## C 环境回显（第 2/3/4 组，原文）

```text
L4: === group R6-control extra= at 01:06:45
L96: === group R6-sendown0 extra=VICTORY_SEND_OWN=0 at 01:11:00
L97: extra=VICTORY_SEND_OWN=0
L189: === group R6-inplace0 extra=VICTORY_COPIES_IN_PLACE=0 at 01:15:16
L190: extra=VICTORY_COPIES_IN_PLACE=0
L282: === group R6-latewait1 extra=VICTORY_LATE_WAIT=1 at 01:19:30
L283: extra=VICTORY_LATE_WAIT=1
```

## D 收尾计数

| 项 | 值 |
| --- | --- |
| 各组 leftover_after_group | 0 / 0 / 0 / 0（console L95 / L188 / L281 / L374） |
| final_procs | 0（console L375） |
| 组间等待 | 每组后 kill 全部 `^victory` + `Start-Sleep 5` |
| 串行 | 01:06:45 → 01:11:00 → 01:15:16 → 01:19:30，无并发 |
| start / done | 2026-11-27 01:06:38 / 01:23:49 |

## E console 全文

文件：`data\r02-a12-console.log`（25361 B，UTF-8）。原始重定向文件因内层 `powershell.exe` 以 GBK 输出中文而混编码，已按 GBK→UTF-8 转码，数字与英文字段逐字未动；未转码原件保留为 `data\r02-a12-console.raw.log`。

```text
=== r02-a12 start 2026-11-27 01:06:38
SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
commit_limit_gb=49.84 commit_free_gb=38.15
=== group R6-control extra= at 01:06:45
label=R6-control exe=G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe profile=fork seconds=200
  t=   8s fps=    30 ms=    33.3 draws=     1 priv=  6.48 commitfree= 26.66
  t=  14s fps=    30 ms=    33.3 draws=     4 priv=  7.16 commitfree= 26.23
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.25 commitfree= 26.32
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.25 commitfree= 26.33
  t=  33s fps=    30 ms=    33.4 draws=     9 priv=  7.66 commitfree= 25.91
  t=  39s fps=    30 ms=    33.3 draws=     9 priv=  7.87 commitfree= 25.54
  t=  45s fps=    30 ms=    33.7 draws=     9 priv= 13.22 commitfree= 20.32
  t=  51s fps=    30 ms=    33.3 draws=     9 priv= 12.29 commitfree= 21.26
  t=  57s fps=    30 ms=    33.3 draws=     8 priv= 12.17 commitfree= 21.23
  t=  63s fps=    30 ms=    33.2 draws=    10 priv= 13.16 commitfree= 20.09
  t=  69s fps=     3 ms=     332 draws=  2011 priv= 17.58 commitfree= 15.59
  t=  75s fps=     3 ms=   365.9 draws=  1719 priv= 18.52 commitfree= 14.66
  t=  81s fps=     4 ms=   270.3 draws=  2892 priv= 19.06 commitfree= 13.87
  t=  87s fps=     4 ms=     284 draws=  1349 priv= 19.54 commitfree= 13.65
  t=  94s fps=     3 ms=   364.9 draws=  4578 priv= 20.01 commitfree= 13.27
  t= 100s fps=     4 ms=   275.7 draws=  3254 priv= 20.16 commitfree= 12.93
  t= 106s fps=     3 ms=   359.9 draws=  4836 priv= 20.33 commitfree= 12.95
  t= 112s fps=     3 ms=   309.8 draws=  2016 priv=  20.4 commitfree= 13.02
  t= 118s fps=     3 ms=     384 draws=  4535 priv=  20.5 commitfree= 12.95
  t= 124s fps=     4 ms=     283 draws=  1560 priv= 20.53 commitfree= 12.89
  t= 130s fps=     4 ms=   283.8 draws=  1079 priv= 20.53 commitfree= 12.73
  t= 136s fps=     4 ms=     280 draws=  5057 priv= 20.59 commitfree= 13.03
  t= 142s fps=     4 ms=   266.8 draws=  3612 priv= 20.41 commitfree= 13.04
  t= 148s fps=     4 ms=     268 draws=  5228 priv= 19.98 commitfree= 13.49
  t= 154s fps=     4 ms=   245.1 draws=  4574 priv= 19.95 commitfree= 13.52
  t= 160s fps=     4 ms=     242 draws=  4549 priv= 19.92 commitfree= 13.57
  t= 166s fps=     4 ms=   246.4 draws=  4553 priv= 19.85 commitfree= 13.63
  t= 172s fps=     4 ms=     258 draws=  4574 priv= 19.83 commitfree= 13.65
  t= 178s fps=     4 ms=   252.2 draws=  4679 priv= 19.82 commitfree= 13.66
  t= 184s fps=     4 ms=   266.5 draws=  5939 priv= 19.87 commitfree=  13.6
  t= 190s fps=     4 ms=     275 draws=  6072 priv= 19.94 commitfree= 13.54
  t= 196s fps=     4 ms=     255 draws=  4875 priv= 19.96 commitfree= 13.56
  t= 202s fps=     4 ms=   258.4 draws=  4732 priv= 20.03 commitfree= 13.52
  t= 208s fps=     4 ms=   258.8 draws=  4866 priv= 20.03 commitfree= 13.52
  t= 214s fps=     4 ms=   259.9 draws=  5194 priv= 20.03 commitfree= 13.52
  t= 220s fps=     4 ms=   258.7 draws=  5212 priv= 20.01 commitfree= 13.55
  t= 226s fps=     4 ms=   272.5 draws=  5204 priv= 20.03 commitfree= 13.53
  t= 232s fps=     4 ms=   259.6 draws=  5202 priv= 20.03 commitfree= 13.53
  t= 238s fps=     4 ms=   259.6 draws=  5192 priv= 20.02 commitfree= 13.52
  t= 244s fps=     4 ms=   258.4 draws=  5205 priv= 20.02 commitfree= 13.52

  T Fps    Ms Draws PrivGB RssGB FreeGB CommitFreeGB
  - ---    -- ----- ------ ----- ------ ------------
  8  30  33.3     1   6.48  3.77  18.38        26.66
 14  30  33.3     4   7.16   4.6  17.66        26.23
 20  30  33.3     4   7.25  4.73  17.71        26.32
 26  30  33.3     4   7.25  4.73  17.71        26.33
 33  30  33.4     9   7.66  5.35  17.01        25.91
 39  30  33.3     9   7.87  5.58  16.58        25.54
 45  30  33.7     9  13.22  9.29  12.52        20.32
 51  30  33.3     9  12.29  8.52  13.63        21.26
 57  30  33.3     8  12.17  8.28  13.54        21.23
 63  30  33.2    10  13.16  9.59  11.49        20.09
 69   3   332  2011  17.58 15.63   7.15        15.59
 75   3 365.9  1719  18.52 17.16   6.02        14.66
 81   4 270.3  2892  19.06 18.26   5.15        13.87
 87   4   284  1349  19.54 18.87   4.82        13.65
 94   3 364.9  4578  20.01 19.49    4.4        13.27
100   4 275.7  3254  20.16 19.87    4.1        12.93
106   3 359.9  4836  20.33 20.27   4.16        12.95
112   3 309.8  2016   20.4 20.14   4.14        13.02
118   3   384  4535   20.5 20.57   4.05        12.95
124   4   283  1560  20.53 20.45   4.02        12.89
130   4 283.8  1079  20.53 20.31   3.89        12.73
136   4   280  5057  20.59  19.6   4.23        13.03
142   4 266.8  3612  20.41 19.38   4.26        13.04
148   4   268  5228  19.98 18.93   4.72        13.49
154   4 245.1  4574  19.95 18.82   4.75        13.52
160   4   242  4549  19.92 18.79   4.81        13.57
166   4 246.4  4553  19.85 18.47   5.09        13.63
172   4   258  4574  19.83 18.49   5.08        13.65
178   4 252.2  4679  19.82 18.47    5.1        13.66
184   4 266.5  5939  19.87 18.59   5.08         13.6
190   4   275  6072  19.94 18.59   5.05        13.54
196   4   255  4875  19.96 18.62   5.02        13.56
202   4 258.4  4732  20.03 18.73   4.97        13.52
208   4 258.8  4866  20.03 18.73   4.96        13.52
214   4 259.9  5194  20.03 18.71   4.99        13.52
220   4 258.7  5212  20.01 18.67   5.02        13.55
226   4 272.5  5204  20.03 18.69   4.99        13.53
232   4 259.6  5202  20.03 18.68   5.02        13.53
238   4 259.6  5192  20.02 18.63   5.04        13.52
244   4 258.4  5205  20.02  18.6   5.09        13.52



median_ms_world = 268 （filter v2，30 条世界样本，中位 draws=4679）；max_priv_gb = 20.59 ；min_free_gb = 3.89 ；min_commit_free_gb = 12.73 ；leftover_procs = 0
详情写入 G:\GTA\cool_fox-优化方案\data\bench-v2.csv
group_exit=0
leftover_after_group=0
=== group R6-sendown0 extra=VICTORY_SEND_OWN=0 at 01:11:00
extra=VICTORY_SEND_OWN=0
label=R6-sendown0 exe=G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe profile=fork seconds=200
  t=   8s fps=    31 ms=    32.7 draws=     1 priv=  6.46 commitfree= 26.73
  t=  14s fps=    30 ms=    33.3 draws=     8 priv=  7.12 commitfree= 26.57
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.22 commitfree=  26.5
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.22 commitfree=  26.5
  t=  32s fps=    30 ms=    33.3 draws=     9 priv=  7.55 commitfree= 26.08
  t=  38s fps=    30 ms=    33.3 draws=    10 priv=  7.84 commitfree= 25.87
  t=  44s fps=    32 ms=    31.2 draws=     9 priv= 13.44 commitfree= 20.18
  t=  50s fps=    30 ms=    33.4 draws=     8 priv= 12.27 commitfree= 21.37
  t=  56s fps=    30 ms=    33.3 draws=    10 priv= 12.14 commitfree= 21.49
  t=  62s fps=    30 ms=    33.2 draws=    10 priv= 13.51 commitfree= 19.26
  t=  68s fps=     3 ms=   304.3 draws=  1680 priv= 17.54 commitfree= 16.12
  t=  74s fps=     3 ms=   303.6 draws=  3966 priv= 18.62 commitfree= 15.08
  t=  80s fps=     4 ms=     263 draws=  3976 priv= 19.05 commitfree= 14.61
  t=  86s fps=     4 ms=   267.1 draws=  1323 priv= 19.32 commitfree= 14.34
  t=  92s fps=     3 ms=   366.2 draws=  3542 priv= 19.73 commitfree=    14
  t=  98s fps=     3 ms=   340.7 draws=   995 priv= 19.79 commitfree= 13.86
  t= 104s fps=     3 ms=   347.7 draws=  3919 priv= 19.93 commitfree= 13.79
  t= 110s fps=     3 ms=   347.8 draws=  1872 priv= 20.06 commitfree= 13.67
  t= 116s fps=     3 ms=   339.8 draws=  3573 priv=  20.1 commitfree= 13.66
  t= 122s fps=     3 ms=   338.2 draws=  2124 priv= 20.11 commitfree= 13.63
  t= 129s fps=     3 ms=   285.7 draws=  2394 priv= 20.15 commitfree= 13.34
  t= 135s fps=     4 ms=   245.4 draws=  4029 priv= 20.43 commitfree= 13.47
  t= 141s fps=     4 ms=   244.4 draws=  4538 priv= 20.22 commitfree= 13.78
  t= 147s fps=     4 ms=   250.9 draws=  5038 priv= 19.76 commitfree= 13.98
  t= 153s fps=     4 ms=   259.8 draws=  6398 priv= 19.74 commitfree= 14.03
  t= 159s fps=     4 ms=   257.8 draws=  6150 priv= 19.76 commitfree= 14.01
  t= 165s fps=     4 ms=     248 draws=  4693 priv=  19.7 commitfree= 14.07
  t= 171s fps=     4 ms=   256.2 draws=  4902 priv= 19.72 commitfree= 14.03
  t= 177s fps=     4 ms=   250.3 draws=  4752 priv=  19.7 commitfree= 14.06
  t= 183s fps=     4 ms=   247.7 draws=  4589 priv= 19.66 commitfree=  14.1
  t= 189s fps=     4 ms=   247.1 draws=  4603 priv= 19.65 commitfree= 14.11
  t= 195s fps=     4 ms=   258.1 draws=  4572 priv= 19.66 commitfree= 14.09
  t= 201s fps=     4 ms=   253.7 draws=  4474 priv= 19.68 commitfree= 14.07
  t= 207s fps=     4 ms=   257.1 draws=  4642 priv= 19.69 commitfree= 14.06
  t= 213s fps=     4 ms=   253.1 draws=  4594 priv= 19.71 commitfree= 14.05
  t= 219s fps=     4 ms=   247.2 draws=  4550 priv=  19.7 commitfree= 14.05
  t= 225s fps=     4 ms=   247.8 draws=  4519 priv= 19.71 commitfree= 14.05
  t= 231s fps=     4 ms=   263.3 draws=  4578 priv= 19.71 commitfree= 14.04
  t= 237s fps=     4 ms=   267.2 draws=  5482 priv= 19.72 commitfree= 14.04
  t= 243s fps=     4 ms=   258.5 draws=  5065 priv= 19.73 commitfree= 14.03

  T Fps    Ms Draws PrivGB RssGB FreeGB CommitFreeGB
  - ---    -- ----- ------ ----- ------ ------------
  8  31  32.7     1   6.46  3.75  18.58        26.73
 14  30  33.3     8   7.12  4.55  18.05        26.57
 20  30  33.3     4   7.22   4.7  18.01         26.5
 26  30  33.3     4   7.22  4.71     18         26.5
 32  30  33.3     9   7.55  5.25  17.29        26.08
 38  30  33.3    10   7.84  5.56  17.06        25.87
 44  32  31.2     9  13.44  9.27  12.57        20.18
 50  30  33.4     8  12.27  8.65  13.53        21.37
 56  30  33.3    10  12.14  8.11   13.8        21.49
 62  30  33.2    10  13.51  9.87  10.67        19.26
 68   3 304.3  1680  17.54 15.64   7.52        16.12
 74   3 303.6  3966  18.62  17.4   6.37        15.08
 80   4   263  3976  19.05 18.27   5.68        14.61
 86   4 267.1  1323  19.32 18.69   5.34        14.34
 92   3 366.2  3542  19.73 19.27      5           14
 98   3 340.7   995  19.79  19.1   5.25        13.86
104   3 347.7  3919  19.93 19.48   5.16        13.79
110   3 347.8  1872  20.06 19.38   5.03        13.67
116   3 339.8  3573   20.1 19.66   5.01        13.66
122   3 338.2  2124  20.11  19.5   5.01        13.63
129   3 285.7  2394  20.15  19.5   4.81        13.34
135   4 245.4  4029  20.43 18.95   4.98        13.47
141   4 244.4  4538  20.22 18.83    5.3        13.78
147   4 250.9  5038  19.76 18.35   5.47        13.98
153   4 259.8  6398  19.74  18.3   5.51        14.03
159   4 257.8  6150  19.76 18.29    5.5        14.01
165   4   248  4693   19.7 18.26   5.53        14.07
171   4 256.2  4902  19.72 18.33    5.5        14.03
177   4 250.3  4752   19.7 18.28   5.53        14.06
183   4 247.7  4589  19.66 18.22   5.57         14.1
189   4 247.1  4603  19.65 18.19   5.58        14.11
195   4 258.1  4572  19.66  18.2   5.56        14.09
201   4 253.7  4474  19.68 18.23   5.55        14.07
207   4 257.1  4642  19.69 18.24   5.54        14.06
213   4 253.1  4594  19.71 18.24   5.54        14.05
219   4 247.2  4550   19.7 18.23   5.55        14.05
225   4 247.8  4519  19.71 18.24   5.55        14.05
231   4 263.3  4578  19.71 18.23   5.54        14.04
237   4 267.2  5482  19.72 18.35   5.53        14.04
243   4 258.5  5065  19.73 18.34   5.52        14.03



median_ms_world = 258.5 （filter v2，30 条世界样本，中位 draws=4550）；max_priv_gb = 20.43 ；min_free_gb = 4.81 ；min_commit_free_gb = 13.34 ；leftover_procs = 0
详情写入 G:\GTA\cool_fox-优化方案\data\bench-v2.csv
group_exit=0
leftover_after_group=0
=== group R6-inplace0 extra=VICTORY_COPIES_IN_PLACE=0 at 01:15:16
extra=VICTORY_COPIES_IN_PLACE=0
label=R6-inplace0 exe=G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe profile=fork seconds=200
  t=   7s fps=       ms=         draws=       priv=  0.11 commitfree= 30.53
  t=  13s fps=    30 ms=    33.3 draws=     1 priv=  6.65 commitfree= 26.95
  t=  19s fps=    30 ms=    33.3 draws=     4 priv=  7.26 commitfree= 26.61
  t=  25s fps=    30 ms=    33.3 draws=     4 priv=  7.25 commitfree= 26.63
  t=  31s fps=    30 ms=    33.3 draws=     4 priv=  7.25 commitfree= 26.63
  t=  37s fps=    30 ms=    33.3 draws=     9 priv=  7.71 commitfree= 26.12
  t=  44s fps=    30 ms=    33.3 draws=     8 priv=  8.64 commitfree= 25.02
  t=  50s fps=    30 ms=    33.7 draws=    10 priv= 12.56 commitfree= 21.22
  t=  56s fps=     3 ms=   335.2 draws=  3078 priv= 17.42 commitfree= 16.24
  t=  62s fps=     3 ms=   306.6 draws=  1712 priv= 18.29 commitfree= 15.24
  t=  68s fps=     3 ms=   288.2 draws=  3247 priv= 18.83 commitfree= 14.77
  t=  74s fps=     3 ms=   305.7 draws=  2418 priv= 19.43 commitfree= 14.26
  t=  80s fps=     4 ms=   281.7 draws=  1749 priv= 19.79 commitfree= 13.79
  t=  86s fps=     3 ms=   334.5 draws=  1940 priv= 20.02 commitfree= 13.66
  t=  92s fps=     3 ms=   335.3 draws=  4059 priv= 20.24 commitfree= 13.46
  t=  98s fps=     4 ms=     278 draws=  4184 priv= 20.38 commitfree=  13.3
  t= 104s fps=     3 ms=   327.2 draws=  2327 priv= 20.44 commitfree= 13.23
  t= 110s fps=     3 ms=   326.8 draws=  3385 priv= 20.51 commitfree= 13.17
  t= 116s fps=     3 ms=   343.8 draws=  1062 priv= 20.67 commitfree= 13.05
  t= 122s fps=     3 ms=   315.9 draws=  5217 priv= 20.94 commitfree= 12.89
  t= 128s fps=     3 ms=   312.2 draws=  5170 priv= 20.45 commitfree= 13.28
  t= 134s fps=     3 ms=   286.6 draws=  4472 priv= 20.27 commitfree= 13.46
  t= 140s fps=     3 ms=   293.1 draws=  4911 priv= 20.21 commitfree=  13.5
  t= 146s fps=     3 ms=     310 draws=  6014 priv= 20.24 commitfree= 13.53
  t= 152s fps=     3 ms=   326.7 draws=  5093 priv= 20.14 commitfree= 13.61
  t= 158s fps=     3 ms=     291 draws=  3256 priv= 20.11 commitfree= 13.63
  t= 164s fps=     3 ms=   309.5 draws=  6644 priv= 20.13 commitfree=  13.6
  t= 170s fps=     3 ms=   294.9 draws=  3452 priv= 20.15 commitfree= 13.58
  t= 176s fps=     3 ms=   288.3 draws=  5270 priv= 20.15 commitfree= 13.59
  t= 182s fps=     3 ms=   307.1 draws=  5291 priv= 20.14 commitfree= 13.59
  t= 188s fps=     3 ms=   309.3 draws=  5271 priv= 20.09 commitfree= 13.65
  t= 194s fps=     3 ms=   315.2 draws=  5226 priv= 20.09 commitfree= 13.65
  t= 200s fps=     3 ms=   329.4 draws=  5317 priv= 20.18 commitfree= 13.57
  t= 206s fps=     3 ms=     311 draws=  6409 priv=  20.2 commitfree= 13.55
  t= 213s fps=     3 ms=   309.8 draws=  6020 priv= 20.19 commitfree= 13.59
  t= 219s fps=     3 ms=     304 draws=  5387 priv= 20.14 commitfree=  13.6
  t= 225s fps=     3 ms=   296.9 draws=  4764 priv= 20.09 commitfree= 13.65
  t= 231s fps=     3 ms=   299.4 draws=  4766 priv= 20.11 commitfree= 13.64
  t= 237s fps=     3 ms=   306.7 draws=  4740 priv= 20.11 commitfree= 13.64
  t= 243s fps=     3 ms=   299.8 draws=  4740 priv=  20.1 commitfree= 13.65

  T Fps Ms    Draws PrivGB RssGB FreeGB CommitFreeGB
  - --- --    ----- ------ ----- ------ ------------
  7                   0.11  0.11  21.78        30.53
 13 30  33.3  1       6.65  3.96  18.63        26.95
 19 30  33.3  4       7.26  4.88  17.86        26.61
 25 30  33.3  4       7.25  4.74     18        26.63
 31 30  33.3  4       7.25   4.7  17.97        26.63
 37 30  33.3  9       7.71  5.41   17.2        26.12
 44 30  33.3  8       8.64  5.94  15.83        25.02
 50 30  33.7  10     12.56  9.33  12.47        21.22
 56 3   335.2 3078   17.42  15.8   7.33        16.24
 62 3   306.6 1712   18.29 17.46   6.06        15.24
 68 3   288.2 3247   18.83 18.12   5.62        14.77
 74 3   305.7 2418   19.43 19.03   4.96        14.26
 80 4   281.7 1749   19.79 19.77   4.46        13.79
 86 3   334.5 1940   20.02 19.95    4.3        13.66
 92 3   335.3 4059   20.24 20.33   4.09        13.46
 98 4   278   4184   20.38 20.27   4.03         13.3
104 3   327.2 2327   20.44 20.52   3.93        13.23
110 3   326.8 3385   20.51 20.78   3.87        13.17
116 3   343.8 1062   20.67 20.66   3.77        13.05
122 3   315.9 5217   20.94 20.19    3.8        12.89
128 3   312.2 5170   20.45 19.63   4.24        13.28
134 3   286.6 4472   20.27 19.32   4.41        13.46
140 3   293.1 4911   20.21 18.77   5.05         13.5
146 3   310   6014   20.24 18.73   5.08        13.53
152 3   326.7 5093   20.14 18.62   5.17        13.61
158 3   291   3256   20.11 18.61   5.17        13.63
164 3   309.5 6644   20.13 18.67   5.12         13.6
170 3   294.9 3452   20.15  18.7   5.09        13.58
176 3   288.3 5270   20.15 18.67    5.1        13.59
182 3   307.1 5291   20.14 18.66   5.11        13.59
188 3   309.3 5271   20.09 18.58   5.16        13.65
194 3   315.2 5226   20.09 18.57   5.16        13.65
200 3   329.4 5317   20.18 18.72   5.04        13.57
206 3   311   6409    20.2 18.76   5.01        13.55
213 3   309.8 6020   20.19 18.74   5.04        13.59
219 3   304   5387   20.14 18.68   5.05         13.6
225 3   296.9 4764   20.09 18.63    5.1        13.65
231 3   299.4 4766   20.11 18.63    5.1        13.64
237 3   306.7 4740   20.11 18.62    5.1        13.64
243 3   299.8 4740    20.1  18.6    5.1        13.65



median_ms_world = 309.3 （filter v2，32 条世界样本，中位 draws=4764）；max_priv_gb = 20.94 ；min_free_gb = 3.77 ；min_commit_free_gb = 12.89 ；leftover_procs = 0
详情写入 G:\GTA\cool_fox-优化方案\data\bench-v2.csv
group_exit=0
leftover_after_group=0
=== group R6-latewait1 extra=VICTORY_LATE_WAIT=1 at 01:19:30
extra=VICTORY_LATE_WAIT=1
label=R6-latewait1 exe=G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe profile=fork seconds=200
  t=   8s fps=    30 ms=    33.2 draws=     1 priv=  6.22 commitfree= 26.97
  t=  14s fps=    30 ms=    33.3 draws=     7 priv=  7.04 commitfree= 26.84
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.16 commitfree= 26.77
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.16 commitfree= 26.67
  t=  33s fps=    30 ms=    33.3 draws=     8 priv=  7.57 commitfree= 26.12
  t=  39s fps=    30 ms=    33.3 draws=    10 priv=  7.82 commitfree= 25.26
  t=  45s fps=    29 ms=    33.9 draws=    10 priv= 13.31 commitfree= 21.21
  t=  52s fps=    30 ms=    32.9 draws=    11 priv= 16.63 commitfree= 16.76
  t=  58s fps=     3 ms=     389 draws=  1732 priv= 17.44 commitfree= 16.03
  t=  64s fps=     3 ms=   336.5 draws=  1718 priv= 17.77 commitfree= 15.93
  t=  70s fps=     3 ms=   350.1 draws=  2763 priv= 17.96 commitfree= 15.63
  t=  76s fps=     3 ms=   392.2 draws=  1985 priv= 18.29 commitfree= 15.12
  t=  82s fps=     2 ms=   430.5 draws=  3848 priv= 18.93 commitfree= 14.62
  t=  88s fps=     2 ms=   439.4 draws=  4336 priv= 19.05 commitfree= 14.64
  t=  94s fps=     2 ms=   471.7 draws=  3928 priv= 19.19 commitfree=  14.3
  t= 100s fps=     2 ms=   411.5 draws=  1500 priv= 19.23 commitfree= 14.27
  t= 106s fps=     2 ms=   434.4 draws=  3309 priv=  19.4 commitfree= 14.28
  t= 112s fps=     3 ms=   395.3 draws=  1017 priv= 19.46 commitfree= 14.03
  t= 118s fps=     2 ms=   528.9 draws=  6442 priv= 19.66 commitfree= 13.93
  t= 124s fps=     2 ms=   407.6 draws=  5136 priv= 19.54 commitfree= 14.02
  t= 130s fps=     3 ms=   371.6 draws=  4784 priv=  19.4 commitfree= 14.17
  t= 137s fps=     3 ms=   364.3 draws=  4663 priv= 19.14 commitfree= 14.38
  t= 143s fps=     3 ms=     334 draws=  4857 priv= 18.99 commitfree= 14.23
  t= 149s fps=     3 ms=   313.6 draws=  5683 priv= 18.95 commitfree= 14.41
  t= 155s fps=     3 ms=   329.9 draws=  5866 priv= 18.97 commitfree= 14.41
  t= 162s fps=     3 ms=   305.2 draws=  4706 priv= 18.97 commitfree= 14.43
  t= 168s fps=     3 ms=   313.8 draws=  5872 priv= 18.98 commitfree= 14.43
  t= 174s fps=     3 ms=   319.1 draws=  4159 priv= 19.02 commitfree= 14.39
  t= 180s fps=     3 ms=   305.6 draws=  4625 priv= 19.01 commitfree= 14.41
  t= 186s fps=     3 ms=   308.5 draws=  4622 priv= 18.99 commitfree= 14.45
  t= 192s fps=     3 ms=   301.4 draws=  4328 priv= 18.97 commitfree= 14.44
  t= 198s fps=     3 ms=   298.7 draws=  4348 priv= 18.95 commitfree= 14.52
  t= 204s fps=     3 ms=   293.6 draws=  4352 priv= 18.96 commitfree= 14.54
  t= 210s fps=     3 ms=   298.9 draws=  4276 priv= 18.94 commitfree= 14.54
  t= 216s fps=     3 ms=   293.6 draws=  4262 priv= 18.95 commitfree= 14.54
  t= 222s fps=     3 ms=   294.1 draws=  4343 priv= 18.95 commitfree= 14.53
  t= 228s fps=     3 ms=   299.5 draws=  4405 priv= 18.96 commitfree=  14.5
  t= 234s fps=     3 ms=     336 draws=  5622 priv=  19.1 commitfree= 14.44
  t= 243s fps=     3 ms=   321.8 draws=  6498 priv= 19.03 commitfree= 14.47
  t= 249s fps=     3 ms=   312.8 draws=  5897 priv= 19.02 commitfree=  14.5

  T Fps    Ms Draws PrivGB RssGB FreeGB CommitFreeGB
  - ---    -- ----- ------ ----- ------ ------------
  8  30  33.2     1   6.22  3.72  18.69        26.97
 14  30  33.3     7   7.04   4.5  18.13        26.84
 20  30  33.3     4   7.16  4.67  18.15        26.77
 26  30  33.3     4   7.16  4.67  18.14        26.67
 33  30  33.3     8   7.57   5.3  17.39        26.12
 39  30  33.3    10   7.82  5.57  16.68        25.26
 45  29  33.9    10  13.31  9.33  12.62        21.21
 52  30  32.9    11  16.63 14.94   7.96        16.76
 58   3   389  1732  17.44 16.22   6.88        16.03
 64   3 336.5  1718  17.77 16.49   6.89        15.93
 70   3 350.1  2763  17.96 17.05   6.51        15.63
 76   3 392.2  1985  18.29 17.62   6.03        15.12
 82   2 430.5  3848  18.93 18.58   5.47        14.62
 88   2 439.4  4336  19.05  18.8   5.34        14.64
 94   2 471.7  3928  19.19  19.3   5.09         14.3
100   2 411.5  1500  19.23 19.21   5.06        14.27
106   2 434.4  3309   19.4 19.56   4.95        14.28
112   3 395.3  1017  19.46 19.52   4.84        14.03
118   2 528.9  6442  19.66 19.43   4.66        13.93
124   2 407.6  5136  19.54 18.72   4.84        14.02
130   3 371.6  4784   19.4 18.63   4.97        14.17
137   3 364.3  4663  19.14 18.35   5.26        14.38
143   3   334  4857  18.99 18.15   5.29        14.23
149   3 313.6  5683  18.95 18.11   5.31        14.41
155   3 329.9  5866  18.97 18.09   5.32        14.41
162   3 305.2  4706  18.97 18.11   5.33        14.43
168   3 313.8  5872  18.98 18.16   5.28        14.43
174   3 319.1  4159  19.02 18.29   5.22        14.39
180   3 305.6  4625  19.01 18.24   5.25        14.41
186   3 308.5  4622  18.99 18.21   6.15        14.45
192   3 301.4  4328  18.97 17.42   6.23        14.44
198   3 298.7  4348  18.95 17.38   6.32        14.52
204   3 293.6  4352  18.96 17.38   6.33        14.54
210   3 298.9  4276  18.94 17.38   6.33        14.54
216   3 293.6  4262  18.95 17.38   6.32        14.54
222   3 294.1  4343  18.95 17.39   6.32        14.53
228   3 299.5  4405  18.96 17.41   6.29         14.5
234   3   336  5622   19.1 17.84   5.83        14.44
243   3 321.8  6498  19.03 17.64   6.11        14.47
249   3 312.8  5897  19.02 17.63   6.13         14.5



median_ms_world = 334 （filter v2，32 条世界样本，中位 draws=4352）；max_priv_gb = 19.66 ；min_free_gb = 4.66 ；min_commit_free_gb = 13.93 ；leftover_procs = 0
详情写入 G:\GTA\cool_fox-优化方案\data\bench-v2.csv
group_exit=0
leftover_after_group=0
=== final_procs=0
=== bench-v2.csv ===
 1: time,label,seconds,samples,world_filter,world_samples,median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log
 2: 2026-11-26 22:44:50,R3-A2-baseline-v2,200,40,ms>40&draws>=200,29,255.8,4463,20.19,2.94,0.26,0,run-R3-A2-baseline-v2-1126-224038.log
 3: 2026-11-26 22:49:03,R3-B-reverted-v2,200,40,ms>40&draws>=200,32,272.5,4387,20.36,2.74,0.38,0,run-R3-B-reverted-v2-1126-224455.log
 4: 2026-11-26 23:12:03,R4-A2-baseline,200,40,ms>40&draws>=200,32,272.9,4889,19.83,2.91,7.81,0,run-R4-A2-baseline-1126-230753.log
 5: 2026-11-26 23:16:24,R4-B-reverted,200,40,ms>40&draws>=200,30,270.1,4465,19.87,2.97,7.97,0,run-R4-B-reverted-1126-231209.log
 6: 2026-11-26 23:20:41,R4-B-threads-old,200,40,ms>40&draws>=200,28,286.9,4650,20.25,2.93,7.6,0,run-R4-B-threads-old-1126-231629.log
 7: 2026-11-26 23:24:54,R4-B-floor2g,200,40,ms>40&draws>=200,24,269.2,4687,19.58,2.8,7.85,0,run-R4-B-floor2g-1126-232046.log
 8: 2026-11-27 00:00:02,R5-control,200,40,ms>40&draws>=200,30,248.6,5015,20.44,2.85,13.86,0,run-R5-control-1126-235553.log
 9: 2026-11-27 00:04:15,R5-wideback0,200,40,ms>40&draws>=200,33,268.1,4569,20.29,2.72,13.49,0,run-R5-wideback0-1127-000008.log
10: 2026-11-27 00:08:30,R5-cardsteps0,200,40,ms>40&draws>=200,33,292.8,4832,20.53,3.46,14.31,0,run-R5-cardsteps0-1127-000421.log
11: 2026-11-27 00:12:43,R5-relaycopy0,200,40,ms>40&draws>=200,32,304.4,4703,21.12,4.55,13.85,0,run-R5-relaycopy0-1127-000836.log
12: 2026-11-27 01:10:54,R6-control,200,40,ms>40&draws>=200,30,268,4679,20.59,3.89,12.73,0,run-R6-control-1127-010646.log
13: 2026-11-27 01:15:11,R6-sendown0,200,40,ms>40&draws>=200,30,258.5,4550,20.43,4.81,13.34,0,run-R6-sendown0-1127-011100.log
14: 2026-11-27 01:19:25,R6-inplace0,200,40,ms>40&draws>=200,32,309.3,4764,20.94,3.77,12.89,0,run-R6-inplace0-1127-011518.log
15: 2026-11-27 01:23:43,R6-latewait1,200,40,ms>40&draws>=200,32,334,4352,19.66,4.66,13.93,0,run-R6-latewait1-1127-011930.log
=== r02-a12 done 2026-11-27 01:23:49
```

## F 未改动项

1. `data\bench-v2.csv` 仅追加 L12–L15，L1–L11 未动；`data\bench.csv` L1–12 未动。
2. 未改 `bench.ps1` / `13-bench-ab.ps1` 判据；`-Extra` 只用 `VICTORY_SEND_OWN=0`、`VICTORY_COPIES_IN_PLACE=0`、`VICTORY_LATE_WAIT=1` 三个变量。
3. 未改源码 / `Cargo.toml` / `.cargo\config.toml` / `rust-toolchain.toml`；未覆盖 release 与 baseline 产物；未用 diag 产物。
4. runner 脚本 `r02-a12-run.ps1`（UTF-8 带 BOM，`Parser::ParseFile` 0 错）。
