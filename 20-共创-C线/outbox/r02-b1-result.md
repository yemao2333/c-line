# r02-b1 回填 · 新口径（进世界后 200 s）两组：R10-control / R10-sendown0

> 执行端：本机 Windows。任务单 `inbox\task-20261127-0248-16.md`。只报数，未判读。

## A 守卫

| 项 | 值 |
| --- | --- |
| SHA256（release） | `58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45` |
| 产物 | `target\release\victory.exe`（未用 diag） |
| commit_limit_gb / commit_free_gb（开跑前） | 49.84 / 37.13 |
| `bench-v2.csv` 前后 | 22 行 / SHA256 均 `FC8189D8A70B72F1E9C7F2BAFCBE75CA2D4EA8C9607B158BBE913D417C52FD33`（未变） |
| `bench.csv` 前后 | 12 行 / SHA256 均 `0FF0549288706F5B94EF3E221CD82236E9D8FD993EB20B9FB94BD4C9C10F2D00`（未变） |

## B 两组结果（`data\bench-v3.csv` 原样）

```csv
time,label,world_seconds,cap_seconds,samples,world_from_s,world_samples,world_filter,median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log
2026-11-27 02:59:09,R10-control,200,420,74,259,35,ms>40&draws>=200,250.2,4030,20.98,2.99,11.74,0,run-R10-control-1127-025116.log
2026-11-27 03:03:37,R10-sendown0,200,420,42,51,35,ms>40&draws>=200,301.7,5976,20.33,3.51,12.37,0,run-R10-sendown0-1127-025917.log
```

| 组 | Extra | group_EXIT | waited_s | samples | world_from_s | world_samples | median_ms_world | median_draws | max_priv_gb | min_free_gb | min_commit_free_gb | leftover |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R10-control | （无） | 0 | 475 | 74 | 259 | 35 | 250.2 | 4030 | 20.98 | 2.99 | 11.74 | 0 |
| R10-sendown0 | `VICTORY_SEND_OWN=0` | 0 | 265 | 42 | 51 | 35 | 301.7 | 5976 | 20.33 | 3.51 | 12.37 | 0 |

## C 新口径生效行（两组 console 原文）

`R10-control`（`data\r10-r10-control-console.log`）：

```text
  >> 进世界：draws=2085，世界窗自 t=259 s 起，采 200 s
window = world+200 s (from t=259 s) ；采样 74 条，窗内 35 条
```

`R10-sendown0`（`data\r10-r10-sendown0-console.log`）：

```text
  >> 进世界：draws=2300，世界窗自 t=51 s 起，采 200 s
window = world+200 s (from t=51 s) ；采样 42 条，窗内 35 条
```

## D 收尾与时刻

| 项 | 值 |
| --- | --- |
| 两组串行 | R10-control 02:51:11–02:59:00；R10-sendown0 02:59:16–03:03:41 |
| leftover_after_control / after_sendown0 | 0 / 0 |
| final_procs | 0 |
| runner 结束 | 2026-11-27 03:03:53 |

## E 附：R10-control console 全文（74 条采样）

```text
﻿label=R10-control exe=<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe profile=fork seconds=420 world_seconds=200
  t=   8s fps=       ms=         draws=       priv=  5.13 commitfree= 26.29
  t=  14s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.66
  t=  20s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.67
  t=  26s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.68
  t=  32s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.75
  t=  38s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.73
  t=  44s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.73
  t=  50s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.73
  t=  57s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.74
  t=  64s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.74
  t=  70s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.74
  t=  76s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.75
  t=  82s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.74
  t=  88s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t=  95s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 101s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 107s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 114s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 122s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 135s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 141s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 147s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 153s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 159s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 165s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 171s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 179s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.76
  t= 185s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.91
  t= 191s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.91
  t= 198s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.91
  t= 204s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.91
  t= 210s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 25.91
  t= 216s fps=    30 ms=    33.3 draws=     4 priv=  7.21 commitfree= 25.64
  t= 222s fps=    30 ms=    33.3 draws=     4 priv=  7.24 commitfree= 25.64
  t= 228s fps=    30 ms=    33.3 draws=     4 priv=  7.24 commitfree= 25.63
  t= 235s fps=    30 ms=    33.3 draws=     9 priv=  7.76 commitfree= 25.04
  t= 241s fps=    30 ms=    33.3 draws=     9 priv=  8.12 commitfree= 24.56
  t= 247s fps=    30 ms=    33.3 draws=    10 priv= 13.79 commitfree= 18.99
  t= 253s fps=    30 ms=    33.9 draws=    11 priv= 14.08 commitfree= 18.45
  t= 259s fps=     3 ms=   332.1 draws=  2085 priv= 18.24 commitfree= 14.31
  >> 进世界：draws=2085，世界窗自 t=259 s 起，采 200 s
  t= 265s fps=     4 ms=   244.8 draws=  2183 priv= 19.26 commitfree= 13.44
  t= 271s fps=     4 ms=   253.7 draws=  2785 priv= 19.32 commitfree= 13.29
  t= 277s fps=     3 ms=   317.7 draws=  1522 priv= 19.74 commitfree=  12.9
  t= 283s fps=     4 ms=     283 draws=  2704 priv= 20.27 commitfree=  12.4
  t= 290s fps=     4 ms=   260.7 draws=  3699 priv= 20.46 commitfree= 12.24
  t= 296s fps=     4 ms=   284.4 draws=  3983 priv= 20.59 commitfree= 12.09
  t= 302s fps=     4 ms=   281.2 draws=  1528 priv= 20.62 commitfree= 12.09
  t= 308s fps=     3 ms=   300.3 draws=  3392 priv= 20.53 commitfree= 12.14
  t= 314s fps=     3 ms=   338.9 draws=  1013 priv= 20.76 commitfree= 11.96
  t= 320s fps=     3 ms=   333.5 draws=  6278 priv= 20.98 commitfree= 11.74
  t= 326s fps=     4 ms=   269.9 draws=  3705 priv= 20.51 commitfree= 12.21
  t= 332s fps=     4 ms=   250.2 draws=  4734 priv=    20 commitfree= 12.72
  t= 338s fps=     4 ms=   239.9 draws=  4638 priv= 19.88 commitfree= 12.86
  t= 344s fps=     4 ms=   233.8 draws=  4542 priv= 19.81 commitfree= 12.89
  t= 350s fps=     5 ms=   209.1 draws=  4529 priv= 19.77 commitfree= 12.85
  t= 356s fps=     4 ms=   232.7 draws=  4539 priv= 19.68 commitfree=    13
  t= 362s fps=     4 ms=   231.7 draws=  4550 priv= 19.67 commitfree= 13.03
  t= 368s fps=     4 ms=   228.3 draws=  4558 priv= 19.67 commitfree= 13.14
  t= 374s fps=     4 ms=   230.9 draws=  3896 priv=  19.7 commitfree= 13.11
  t= 380s fps=     4 ms=   253.6 draws=  3946 priv= 19.86 commitfree= 12.91
  t= 386s fps=     4 ms=   244.6 draws=  4010 priv=  19.9 commitfree= 12.91
  t= 392s fps=     4 ms=   255.6 draws=  4116 priv= 19.92 commitfree= 12.87
  t= 398s fps=     4 ms=   247.8 draws=  4042 priv= 19.91 commitfree= 12.89
  t= 404s fps=     4 ms=   240.1 draws=  4038 priv=  19.9 commitfree= 12.89
  t= 410s fps=     4 ms=     247 draws=  4028 priv= 19.89 commitfree=  12.9
  t= 416s fps=     4 ms=   243.6 draws=  4012 priv= 19.92 commitfree= 12.86
  t= 422s fps=     4 ms=   253.4 draws=  4028 priv= 19.92 commitfree= 12.85
  t= 428s fps=     4 ms=   242.9 draws=  4015 priv= 19.91 commitfree= 12.89
  t= 434s fps=     4 ms=     246 draws=  4036 priv= 19.94 commitfree= 12.86
  t= 440s fps=     4 ms=   241.6 draws=  4034 priv= 19.94 commitfree= 12.87
  t= 446s fps=     4 ms=   242.6 draws=  4030 priv= 19.94 commitfree= 12.86
  t= 452s fps=     4 ms=   254.1 draws=  5782 priv= 19.98 commitfree= 12.82
  t= 458s fps=     4 ms=   251.9 draws=  4864 priv=    20 commitfree= 12.78
  t= 464s fps=     4 ms=   247.1 draws=  5800 priv= 20.05 commitfree= 12.71

  T Fps Ms    Draws PrivGB RssGB FreeGB CommitFreeGB
  - --- --    ----- ------ ----- ------ ------------
  8                   5.13   3.5  18.08        26.29
 14 30  33.3  8       6.98   4.5  17.67        25.66
 20 30  33.3  8       6.98   4.5  17.81        25.67
 26 30  33.3  8       6.98  4.36  17.83        25.68
 32 30  33.3  8       6.98  4.36  17.89        25.75
 38 30  33.3  8       6.98  4.36  17.87        25.73
 44 30  33.3  8       6.98  4.36  17.89        25.73
 50 30  33.3  8       6.98  4.36  17.89        25.73
 57 30  33.3  8       6.98  4.36  17.89        25.74
 64 30  33.3  8       6.98  4.36   17.9        25.74
 70 30  33.3  8       6.98  4.36   17.9        25.74
 76 30  33.3  8       6.98  4.36   17.9        25.75
 82 30  33.3  8       6.98  4.36   17.9        25.74
 88 30  33.3  8       6.98  4.36  17.91        25.76
 95 30  33.3  8       6.98  4.36  17.91        25.76
101 30  33.3  8       6.98  4.36  17.91        25.76
107 30  33.3  8       6.98  4.36  17.91        25.76
114 30  33.3  8       6.98  4.36  17.92        25.76
122 30  33.3  8       6.98  4.36  17.91        25.76
135 30  33.3  8       6.98  4.36  17.92        25.76
141 30  33.3  8       6.98  4.36  17.91        25.76
147 30  33.3  8       6.98  4.36  17.92        25.76
153 30  33.3  8       6.98  4.36  17.92        25.76
159 30  33.3  8       6.98  4.36  17.92        25.76
165 30  33.3  8       6.98  4.36  17.92        25.76
171 30  33.3  8       6.98  4.36  17.92        25.76
179 30  33.3  8       6.98  4.36  17.91        25.76
185 30  33.3  8       6.98  4.36     18        25.91
191 30  33.3  8       6.98  4.36  17.99        25.91
198 30  33.3  8       6.98  4.36  17.99        25.91
204 30  33.3  8       6.98  4.36  17.98        25.91
210 30  33.3  8       6.98  4.36  17.99        25.91
216 30  33.3  4       7.21  4.88  17.31        25.64
222 30  33.3  4       7.24   4.9  17.31        25.64
228 30  33.3  4       7.24  4.85   17.3        25.63
235 30  33.3  9       7.76  5.84  16.21        25.04
241 30  33.3  9       8.12  6.24  15.63        24.56
247 30  33.3  10     13.79 10.18  10.95        18.99
253 30  33.9  11     14.08 11.16   9.75        18.45
259 3   332.1 2085   18.24 17.01   5.53        14.31
265 4   244.8 2183   19.26 18.23   4.67        13.44
271 4   253.7 2785   19.32 18.64   4.46        13.29
277 3   317.7 1522   19.74 19.34   4.01         12.9
283 4   283   2704   20.27 19.99   3.57         12.4
290 4   260.7 3699   20.46 20.32    3.4        12.24
296 4   284.4 3983   20.59 20.77   3.25        12.09
302 4   281.2 1528   20.62 20.45   3.24        12.09
308 3   300.3 3392   20.53 20.59   3.27        12.14
314 3   338.9 1013   20.76 20.82   3.09        11.96
320 3   333.5 6278   20.98 20.73   2.99        11.74
326 4   269.9 3705   20.51 19.64   3.47        12.21
332 4   250.2 4734      20 19.27   3.97        12.72
338 4   239.9 4638   19.88 19.06   4.18        12.86
344 4   233.8 4542   19.81 18.93   4.21        12.89
350 5   209.1 4529   19.77  18.9   4.18        12.85
356 4   232.7 4539   19.68 18.81   4.31           13
362 4   231.7 4550   19.67 18.79   4.32        13.03
368 4   228.3 4558   19.67 18.79   4.45        13.14
374 4   230.9 3896    19.7 18.84   4.38        13.11
380 4   253.6 3946   19.86 18.94   4.26        12.91
386 4   244.6 4010    19.9 18.94   4.26        12.91
392 4   255.6 4116   19.92 18.96   4.26        12.87
398 4   247.8 4042   19.91 18.45   4.87        12.89
404 4   240.1 4038    19.9 18.44   4.88        12.89
410 4   247   4028   19.89 18.43   4.89         12.9
416 4   243.6 4012   19.92 18.44   4.86        12.86
422 4   253.4 4028   19.92 18.44   4.85        12.85
428 4   242.9 4015   19.91 18.44   4.88        12.89
434 4   246   4036   19.94 18.47   4.84        12.86
440 4   241.6 4034   19.94 18.46   4.83        12.87
446 4   242.6 4030   19.94 18.46   4.83        12.86
452 4   254.1 5782   19.98 18.55   4.76        12.82
458 4   251.9 4864      20 18.59   4.72        12.78
464 4   247.1 5800   20.05 18.69   4.61        12.71



window = world+200 s (from t=259 s) ；采样 74 条，窗内 35 条
median_ms_world = 250.2 （filter v2，35 条世界样本，中位 draws=4030）；max_priv_gb = 20.98 ；min_free_gb = 2.99 ；min_commit_free_gb = 11.74 ；leftover_procs = 0
详情写入 bench-v3.csv

```

## F 附：R10-sendown0 console 全文（42 条采样）

```text
﻿extra=VICTORY_SEND_OWN=0
label=R10-sendown0 exe=<ROOT>\cool_fox\cool_fox-main\target\release\victory.exe profile=fork seconds=420 world_seconds=200
  t=   8s fps=    30 ms=      33 draws=     1 priv=  6.21 commitfree= 25.91
  t=  14s fps=    30 ms=    33.3 draws=     4 priv=  7.21 commitfree= 25.68
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.21 commitfree= 25.69
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.21 commitfree= 25.68
  t=  33s fps=    30 ms=    33.3 draws=     8 priv=  7.64 commitfree= 25.14
  t=  39s fps=    30 ms=    33.3 draws=    10 priv=  8.61 commitfree=  24.1
  t=  45s fps=    31 ms=    32.5 draws=     9 priv= 12.72 commitfree= 20.03
  t=  51s fps=     4 ms=   271.6 draws=  2300 priv= 17.17 commitfree= 15.32
  >> 进世界：draws=2300，世界窗自 t=51 s 起，采 200 s
  t=  57s fps=     3 ms=   359.7 draws=  1409 priv= 17.92 commitfree= 14.69
  t=  63s fps=     3 ms=   287.6 draws=  2576 priv= 18.38 commitfree= 14.24
  t=  69s fps=     3 ms=   348.1 draws=  1950 priv= 18.83 commitfree= 13.77
  t=  75s fps=     3 ms=   339.3 draws=  2057 priv=  19.5 commitfree= 13.09
  t=  81s fps=     3 ms=     338 draws=  3489 priv= 19.66 commitfree= 13.06
  t=  87s fps=     3 ms=   319.2 draws=  3152 priv= 19.72 commitfree= 12.88
  t=  93s fps=     3 ms=   321.5 draws=  2597 priv= 19.91 commitfree= 12.72
  t=  99s fps=     3 ms=   320.6 draws=  1539 priv= 19.87 commitfree= 12.79
  t= 106s fps=     3 ms=   345.4 draws=  3390 priv=    20 commitfree= 12.61
  t= 112s fps=     3 ms=   335.2 draws=  1302 priv= 20.06 commitfree= 12.62
  t= 118s fps=     3 ms=   303.6 draws=  5296 priv= 20.33 commitfree= 12.37
  t= 124s fps=     4 ms=   267.5 draws=  5090 priv= 19.97 commitfree= 12.71
  t= 130s fps=     4 ms=   280.8 draws=  4500 priv= 19.76 commitfree= 12.93
  t= 136s fps=     3 ms=   335.4 draws=  5716 priv= 19.59 commitfree= 13.07
  t= 142s fps=     3 ms=   314.6 draws=  5959 priv= 19.64 commitfree= 13.08
  t= 148s fps=     3 ms=   302.5 draws=  6377 priv= 19.55 commitfree= 13.17
  t= 154s fps=     4 ms=   283.4 draws=  2886 priv= 19.54 commitfree= 13.18
  t= 160s fps=     3 ms=   298.7 draws=  4900 priv= 19.52 commitfree=  13.2
  t= 166s fps=     3 ms=   297.2 draws=  6106 priv= 19.54 commitfree= 13.18
  t= 172s fps=     3 ms=   288.3 draws=  5976 priv= 19.59 commitfree= 13.13
  t= 178s fps=     3 ms=   351.4 draws=  6126 priv= 19.57 commitfree= 13.16
  t= 184s fps=     3 ms=   295.3 draws=  6124 priv= 19.56 commitfree= 13.15
  t= 190s fps=     3 ms=   302.7 draws=  6136 priv= 19.58 commitfree= 13.14
  t= 196s fps=     3 ms=   300.7 draws=  6136 priv= 19.57 commitfree= 13.16
  t= 202s fps=     3 ms=   294.8 draws=  6065 priv= 19.59 commitfree= 13.13
  t= 208s fps=     3 ms=   301.7 draws=  6125 priv= 19.57 commitfree= 13.16
  t= 214s fps=     3 ms=   303.8 draws=  6129 priv= 19.59 commitfree= 13.14
  t= 220s fps=     3 ms=   292.3 draws=  6233 priv= 19.59 commitfree= 13.14
  t= 226s fps=     3 ms=   287.1 draws=  6123 priv= 19.58 commitfree= 13.15
  t= 232s fps=     3 ms=   287.4 draws=  6115 priv= 19.56 commitfree= 13.18
  t= 238s fps=     3 ms=     295 draws=  6120 priv= 19.55 commitfree= 13.18
  t= 244s fps=     3 ms=   298.1 draws=  6130 priv= 19.58 commitfree= 13.13
  t= 250s fps=     3 ms=   287.6 draws=  6190 priv= 19.59 commitfree= 13.12
  t= 256s fps=     3 ms=   290.9 draws=  6122 priv=  19.6 commitfree= 13.11

  T Fps    Ms Draws PrivGB RssGB FreeGB CommitFreeGB
  - ---    -- ----- ------ ----- ------ ------------
  8  30    33     1   6.21  3.86  18.04        25.91
 14  30  33.3     4   7.21  5.04  17.34        25.68
 20  30  33.3     4   7.21   4.9  17.47        25.69
 26  30  33.3     4   7.21   4.9  17.45        25.68
 33  30  33.3     8   7.64  5.54  16.63        25.14
 39  30  33.3    10   8.61  6.11  15.45         24.1
 45  31  32.5     9  12.72  9.35  11.62        20.03
 51   4 271.6  2300  17.17 16.21    6.5        15.32
 57   3 359.7  1409  17.92 17.67   5.61        14.69
 63   3 287.6  2576  18.38 17.82   5.28        14.24
 69   3 348.1  1950  18.83 18.72   4.64        13.77
 75   3 339.3  2057   19.5  19.8   3.89        13.09
 81   3   338  3489  19.66    20   3.86        13.06
 87   3 319.2  3152  19.72 20.24   3.77        12.88
 93   3 321.5  2597  19.91  20.4   3.62        12.72
 99   3 320.6  1539  19.87 20.44   3.65        12.79
106   3 345.4  3390     20 20.77   3.51        12.61
112   3 335.2  1302  20.06 20.67   3.51        12.62
118   3 303.6  5296  20.33 20.23   3.53        12.37
124   4 267.5  5090  19.97  19.6   3.81        12.71
130   4 280.8  4500  19.76 19.38      4        12.93
136   3 335.4  5716  19.59 19.24   4.15        13.07
142   3 314.6  5959  19.64  19.2   4.17        13.08
148   3 302.5  6377  19.55 19.11   4.24        13.17
154   4 283.4  2886  19.54 18.99   4.37        13.18
160   3 298.7  4900  19.52 18.83   4.59         13.2
166   3 297.2  6106  19.54 18.68   4.66        13.18
172   3 288.3  5976  19.59 18.73    4.6        13.13
178   3 351.4  6126  19.57 18.67   4.66        13.16
184   3 295.3  6124  19.56 18.59   4.71        13.15
190   3 302.7  6136  19.58  18.6   4.71        13.14
196   3 300.7  6136  19.57 18.59   4.72        13.16
202   3 294.8  6065  19.59  18.6   4.71        13.13
208   3 301.7  6125  19.57 18.59   4.73        13.16
214   3 303.8  6129  19.59 18.61   5.07        13.14
220   3 292.3  6233  19.59 18.26   5.19        13.14
226   3 287.1  6123  19.58 18.25    5.2        13.15
232   3 287.4  6115  19.56 18.23   5.23        13.18
238   3   295  6120  19.55 18.22   5.23        13.18
244   3 298.1  6130  19.58 18.24    5.2        13.13
250   3 287.6  6190  19.59 18.24   5.19        13.12
256   3 290.9  6122   19.6 18.25   5.18        13.11



window = world+200 s (from t=51 s) ；采样 42 条，窗内 35 条
median_ms_world = 301.7 （filter v2，35 条世界样本，中位 draws=5976）；max_priv_gb = 20.33 ；min_free_gb = 3.51 ；min_commit_free_gb = 12.37 ；leftover_procs = 0
详情写入 bench-v3.csv

```

## G 执行过程披露（不影响上表数字）

1. 首次尝试作废：`r02-b1-run.ps1` 第一版用了 `.WaitForExit(900)`（毫秒，不是秒），runner 在 0.9 s 后即推进到下一组并 kill 进程，两组各只剩 0 条采样。该次产物已整体移出主表，隔离为 `data\bench-v3-attempt1-void.csv`（2 行 0 值）、`data\r10-r10-control-console.attempt1.log`、`data\r10-r10-sendown0-console.attempt1.log`；正式 `bench-v3.csv` 由本次有效运行从表头重新生成，只有 L2–L3 两行。
2. 编码处理：内层 `powershell.exe`（PS 5.1）的 stdout 按 GBK 落盘为 `r10-*-console.raw.log`，再由 `GetEncoding(936)` 解码写成 UTF-8 的 `r10-*-console.log`（即 §E/§F 引用件）。`r02-b1-console.log` 同法转存，原件为 `r02-b1-console.raw.log`。
3. 诊断残留（排查首次秒退所留，未参与判定）：`data\diag-b1.log`（1035 B）、`data\diag-b1.err.log`（1129078 B，`VICTORY_LOG=info` 单次 30 s 直启）。
4. 未改 `bench.ps1` / `13-bench-ab.ps1` 判据；未开 CAPTURE/RECORD；未覆盖 release / baseline；两组串行、组间清残留并复核计数。
