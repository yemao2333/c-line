# r02-a7 回填（P0 已过：线程 / 纹理 floor 两个单变量，四组串行）

task_id: `r02-a7` ｜ 执行侧：豆包 ｜ 2026-11-26 23:07:47–23:24:59

## 状态

```
commit_limit_gb=49.84 commit_used_gb=17.41 commit_free_gb=32.43   -> 49.84 >= 44，放行（未触发 SKIP_R4）
SHA256_victory=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
SHA256_baseline=9627DF10A7E7B498B86F7A6B8B3F52DD32958F735072F1A0161DE1BDD0CAEC73
R4-A2-baseline   23:07:53 起跑 / 23:12:03 落行 / post-clean leftover_procs=0
R4-B-reverted    23:12:09 起跑 / 23:16:24 落行 / post-clean leftover_procs=0
R4-B-threads-old 23:16:29 起跑 / 23:20:41 落行 / post-clean leftover_procs=0
R4-B-floor2g     23:20:46 起跑 / 23:24:54 落行 / post-clean leftover_procs=0
跑后复核 ^victory 残留 = 0
```

## 数字（逐字，未换算、未重算）

`data\bench-v2.csv` 全文（7 行 = 表头 + L2/L3 + 本次 4 行）：

```
1: time,label,seconds,samples,world_filter,world_samples,median_ms_world,median_draws,max_priv_gb,min_free_gb,min_commit_free_gb,leftover_procs,log
2: 2026-11-26 22:44:50,R3-A2-baseline-v2,200,40,ms>40&draws>=200,29,255.8,4463,20.19,2.94,0.26,0,run-R3-A2-baseline-v2-1126-224038.log
3: 2026-11-26 22:49:03,R3-B-reverted-v2,200,40,ms>40&draws>=200,32,272.5,4387,20.36,2.74,0.38,0,run-R3-B-reverted-v2-1126-224455.log
4: 2026-11-26 23:12:03,R4-A2-baseline,200,40,ms>40&draws>=200,32,272.9,4889,19.83,2.91,7.81,0,run-R4-A2-baseline-1126-230753.log
5: 2026-11-26 23:16:24,R4-B-reverted,200,40,ms>40&draws>=200,30,270.1,4465,19.87,2.97,7.97,0,run-R4-B-reverted-1126-231209.log
6: 2026-11-26 23:20:41,R4-B-threads-old,200,40,ms>40&draws>=200,28,286.9,4650,20.25,2.93,7.6,0,run-R4-B-threads-old-1126-231629.log
7: 2026-11-26 23:24:54,R4-B-floor2g,200,40,ms>40&draws>=200,24,269.2,4687,19.58,2.8,7.85,0,run-R4-B-floor2g-1126-232046.log
```

## 四行对照（列名与 csv 一致）

| label | world_samples | median_ms_world | median_draws | max_priv_gb | min_free_gb | min_commit_free_gb | leftover_procs |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R4-A2-baseline | 32 | 272.9 | 4889 | 19.83 | 2.91 | 7.81 | 0 |
| R4-B-reverted | 30 | 270.1 | 4465 | 19.87 | 2.97 | 7.97 | 0 |
| R4-B-threads-old | 28 | 286.9 | 4650 | 20.25 | 2.93 | 7.6 | 0 |
| R4-B-floor2g | 24 | 269.2 | 4687 | 19.58 | 2.8 | 7.85 | 0 |

四组 `world_filter` 均为 `ms>40&draws>=200`；`seconds=200`、`samples=40`。

## `-Extra` 生效回显（第 3 / 4 组原文）

```
extra=VICTORY_THIN_THREADS=8;VICTORY_PIPELINE_WORKERS=8;VICTORY_VIEW_THREADS=6;VICTORY_UNDER_THREADS=6
extra=VICTORY_TEXTURE_BUDGET_MB=2048
```

## 逐样本（每 5 秒一行，原文，缺省空行已去掉）

### R4-A2-baseline（`data\r02-a7-console.clean.log:6-97`，40 行）

```
  t=   8s fps=    25 ms=      40 draws=     1 priv=  6.01 commitfree=  21.1
  t=  14s fps=    32 ms=    31.5 draws=     4 priv=  7.38 commitfree= 20.47
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.46 commitfree=  20.5
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.28 commitfree= 20.61
  t=  32s fps=    30 ms=    33.3 draws=     9 priv=  7.71 commitfree= 20.05
  t=  38s fps=    30 ms=    33.3 draws=     9 priv=  7.98 commitfree= 19.79
  t=  44s fps=    30 ms=    33.8 draws=     9 priv=  9.82 commitfree= 14.93
  t=  50s fps=    25 ms=    39.5 draws=    10 priv= 12.29 commitfree= 14.15
  t=  56s fps=     3 ms=   324.1 draws=   446 priv= 17.53 commitfree=    10
  t=  63s fps=     3 ms=   352.8 draws=  1645 priv= 18.53 commitfree=  9.08
  t=  69s fps=     3 ms=   386.7 draws=  4889 priv= 19.26 commitfree=  8.51
  t=  75s fps=     2 ms=   636.2 draws=  1482 priv= 19.64 commitfree=  8.01
  t=  81s fps=     3 ms=   373.4 draws=  2107 priv=  19.7 commitfree=  8.02
  t=  87s fps=     3 ms=   338.9 draws=   757 priv= 19.37 commitfree=  8.39
  t=  93s fps=     2 ms=   428.2 draws=  3726 priv= 19.51 commitfree=   8.2
  t=  99s fps=     3 ms=   362.3 draws=  1662 priv= 19.67 commitfree=  8.04
  t= 105s fps=     1 ms=   735.8 draws=  3338 priv= 19.58 commitfree=     8
  t= 111s fps=     3 ms=   351.8 draws=  1632 priv= 19.83 commitfree=  7.81
  t= 117s fps=     3 ms=   298.7 draws=  1121 priv=  19.8 commitfree=  7.94
  t= 123s fps=     4 ms=   262.5 draws=  3859 priv= 19.81 commitfree=  8.07
  t= 129s fps=     1 ms=     830 draws=  4851 priv= 19.57 commitfree=  8.44
  t= 135s fps=     4 ms=   251.9 draws=  4773 priv= 19.42 commitfree=  8.53
  t= 141s fps=     4 ms=   250.2 draws=  4566 priv= 19.26 commitfree=  8.64
  t= 147s fps=     4 ms=   272.9 draws=  4914 priv= 19.26 commitfree=  8.63
  t= 153s fps=     4 ms=   275.2 draws=  6209 priv= 19.33 commitfree=  8.58
  t= 159s fps=     4 ms=   264.9 draws=  4741 priv= 19.35 commitfree=  8.56
  t= 165s fps=     4 ms=   272.8 draws=  5695 priv= 19.33 commitfree=  8.57
  t= 171s fps=     4 ms=   254.7 draws=  4689 priv= 19.36 commitfree=  8.52
  t= 177s fps=     4 ms=   263.5 draws=  5224 priv=  19.4 commitfree=  8.49
  t= 183s fps=     4 ms=   265.8 draws=  5239 priv= 19.37 commitfree=  8.51
  t= 189s fps=     4 ms=   263.8 draws=  5243 priv= 19.37 commitfree=  8.51
  t= 195s fps=     4 ms=   263.1 draws=  5245 priv=  19.4 commitfree=  8.48
  t= 201s fps=     4 ms=   263.4 draws=  5232 priv=  19.4 commitfree=  8.49
  t= 207s fps=     3 ms=   287.4 draws=  5231 priv=  19.4 commitfree=  8.48
  t= 213s fps=     4 ms=   277.2 draws=  5230 priv=  19.4 commitfree=  8.46
  t= 219s fps=     4 ms=   260.7 draws=  5233 priv= 19.43 commitfree=  8.46
  t= 225s fps=     4 ms=   259.1 draws=  5235 priv= 19.42 commitfree=  8.46
  t= 231s fps=     4 ms=   261.7 draws=  5170 priv= 19.43 commitfree=  8.46
  t= 237s fps=     4 ms=   271.7 draws=  6091 priv=  19.5 commitfree=  8.38
  t= 243s fps=     4 ms=   256.7 draws=  6076 priv= 19.51 commitfree=  8.37
```

### R4-B-reverted（`data\r02-a7-console.clean.log:98-189`，40 行）

```
  t=   9s fps=    24 ms=    42.2 draws=     1 priv=  5.16 commitfree= 21.55
  t=  15s fps=    31 ms=    31.9 draws=     4 priv=  7.46 commitfree= 20.49
  t=  21s fps=    30 ms=    33.3 draws=     4 priv=  7.46 commitfree= 20.68
  t=  27s fps=    30 ms=    33.3 draws=     4 priv=  7.29 commitfree= 20.68
  t=  33s fps=    30 ms=    33.3 draws=     8 priv=  7.71 commitfree= 20.24
  t=  39s fps=    30 ms=    33.3 draws=    10 priv=  7.88 commitfree= 19.31
  t=  45s fps=    31 ms=    31.8 draws=     9 priv= 13.04 commitfree= 14.86
  t=  51s fps=    30 ms=    33.4 draws=     8 priv= 12.06 commitfree= 15.92
  t=  57s fps=    26 ms=    38.5 draws=    10 priv= 11.99 commitfree= 15.87
  t=  63s fps=    29 ms=    34.7 draws=     9 priv= 11.86 commitfree= 16.01
  t=  69s fps=     4 ms=   283.7 draws=  2092 priv= 17.24 commitfree= 10.25
  t=  75s fps=     2 ms=   529.2 draws=  1715 priv= 19.01 commitfree=  9.23
  t=  81s fps=     3 ms=   299.8 draws=  4666 priv= 19.43 commitfree=  8.46
  t=  87s fps=     4 ms=   261.2 draws=  1365 priv= 19.68 commitfree=  8.24
  t=  94s fps=     4 ms=   279.3 draws=  3289 priv= 19.75 commitfree=  8.08
  t= 100s fps=     4 ms=   264.3 draws=  2534 priv= 19.75 commitfree=  8.18
  t= 106s fps=     4 ms=   285.5 draws=  3213 priv= 19.82 commitfree=  7.97
  t= 112s fps=     3 ms=   344.7 draws=  3305 priv= 19.56 commitfree=  8.29
  t= 118s fps=     4 ms=   280.4 draws=  3325 priv= 19.57 commitfree=  8.34
  t= 124s fps=     3 ms=   374.8 draws=  4041 priv= 19.86 commitfree=  8.04
  t= 130s fps=     3 ms=     354 draws=  1430 priv= 19.78 commitfree=  8.12
  t= 136s fps=     3 ms=     295 draws=  4000 priv= 19.87 commitfree=  8.03
  t= 142s fps=     2 ms=   550.9 draws=  3423 priv= 19.73 commitfree=  8.19
  t= 148s fps=     4 ms=   269.3 draws=  4936 priv= 19.58 commitfree=  8.38
  t= 154s fps=     4 ms=   254.9 draws=  6029 priv= 19.41 commitfree=  8.54
  t= 160s fps=     3 ms=   346.8 draws=  4126 priv= 19.32 commitfree=  8.56
  t= 166s fps=     4 ms=   254.2 draws=  3616 priv= 19.33 commitfree=  8.66
  t= 172s fps=     4 ms=   228.5 draws=  4597 priv= 19.25 commitfree=  8.66
  t= 178s fps=     4 ms=   265.6 draws=  4441 priv= 19.25 commitfree=  8.66
  t= 184s fps=     4 ms=   268.1 draws=  5577 priv= 19.31 commitfree=  8.61
  t= 190s fps=     4 ms=   273.1 draws=  5634 priv= 19.37 commitfree=  8.54
  t= 196s fps=     4 ms=   266.1 draws=  4465 priv= 19.35 commitfree=  8.57
  t= 202s fps=     4 ms=   270.1 draws=  4858 priv= 19.37 commitfree=  8.52
  t= 208s fps=     4 ms=   265.8 draws=  5398 priv= 19.43 commitfree=  8.48
  t= 214s fps=     4 ms=   270.3 draws=  5036 priv= 19.42 commitfree=  8.52
  t= 220s fps=     4 ms=   261.4 draws=  5156 priv= 19.41 commitfree=   8.5
  t= 226s fps=     4 ms=   265.6 draws=  5708 priv= 19.42 commitfree=  8.49
  t= 232s fps=     4 ms=   269.1 draws=  5708 priv= 19.41 commitfree=   8.5
  t= 238s fps=     4 ms=   266.9 draws=  5654 priv= 19.42 commitfree=  8.49
  t= 244s fps=     4 ms=   267.8 draws=  5544 priv= 19.43 commitfree=  8.48
```

### R4-B-threads-old（`data\r02-a7-console.clean.log:190-282`，40 行）

```
extra=VICTORY_THIN_THREADS=8;VICTORY_PIPELINE_WORKERS=8;VICTORY_VIEW_THREADS=6;VICTORY_UNDER_THREADS=6
```

```
  t=   8s fps=    25 ms=    40.5 draws=     1 priv=  6.27 commitfree= 20.74
  t=  14s fps=    30 ms=    33.3 draws=     8 priv=  7.21 commitfree= 20.74
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.17 commitfree= 20.76
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.27 commitfree= 20.61
  t=  32s fps=    30 ms=    33.3 draws=     4 priv=  7.28 commitfree= 20.58
  t=  38s fps=    30 ms=      33 draws=     9 priv=  7.65 commitfree= 20.14
  t=  44s fps=    30 ms=    33.4 draws=     9 priv=  7.92 commitfree= 19.92
  t=  50s fps=    14 ms=    72.4 draws=     9 priv= 12.83 commitfree= 15.09
  t=  56s fps=    30 ms=    33.3 draws=     9 priv= 11.91 commitfree= 16.02
  t=  62s fps=    30 ms=    33.3 draws=     8 priv= 11.78 commitfree= 16.15
  t=  68s fps=    30 ms=    32.9 draws=    11 priv= 11.79 commitfree= 16.15
  t=  76s fps=    26 ms=    38.2 draws=    10 priv= 11.75 commitfree= 15.03
  t=  82s fps=     4 ms=   282.6 draws=  1609 priv= 17.48 commitfree= 10.15
  t=  88s fps=     4 ms=   273.1 draws=  3279 priv= 18.77 commitfree=  8.96
  t=  94s fps=     4 ms=   277.5 draws=  3004 priv= 19.33 commitfree=  8.54
  t= 100s fps=     3 ms=   286.7 draws=  2182 priv= 19.54 commitfree=  8.19
  t= 106s fps=     3 ms=   371.5 draws=  3549 priv= 19.91 commitfree=  7.94
  t= 112s fps=     3 ms=   344.7 draws=  3323 priv= 20.02 commitfree=  7.81
  t= 118s fps=     3 ms=   350.3 draws=  3919 priv= 19.88 commitfree=  7.97
  t= 124s fps=     3 ms=   382.2 draws=  1503 priv= 19.88 commitfree=  7.98
  t= 130s fps=     3 ms=   353.4 draws=  3390 priv= 19.98 commitfree=  7.87
  t= 136s fps=     3 ms=   295.2 draws=  1033 priv= 20.14 commitfree=  7.72
  t= 142s fps=     3 ms=   311.2 draws=  5061 priv= 20.25 commitfree=   7.6
  t= 148s fps=     3 ms=   294.8 draws=  4943 priv= 20.15 commitfree=  7.73
  t= 154s fps=     3 ms=   300.7 draws=  4758 priv= 19.64 commitfree=  8.22
  t= 160s fps=     3 ms=   294.4 draws=  4650 priv= 19.61 commitfree=  8.26
  t= 166s fps=     3 ms=   298.6 draws=  4319 priv= 19.48 commitfree=  8.38
  t= 172s fps=     3 ms=   299.4 draws=  4780 priv= 19.46 commitfree=  8.41
  t= 178s fps=     3 ms=     343 draws=  4728 priv= 19.43 commitfree=  8.44
  t= 184s fps=     3 ms=   286.9 draws=  4650 priv= 19.42 commitfree=   8.2
  t= 190s fps=     4 ms=   257.6 draws=  4894 priv= 19.41 commitfree=  8.24
  t= 196s fps=     4 ms=   257.1 draws=  4742 priv= 19.42 commitfree=  8.23
  t= 202s fps=     4 ms=     259 draws=  4705 priv= 19.44 commitfree=  8.21
  t= 209s fps=     4 ms=   256.7 draws=  4824 priv= 19.45 commitfree=  8.23
  t= 215s fps=     4 ms=   255.1 draws=  4818 priv= 19.46 commitfree=   8.5
  t= 221s fps=     4 ms=   253.7 draws=  4702 priv= 19.46 commitfree=  8.51
  t= 227s fps=     4 ms=   253.3 draws=  4582 priv= 19.46 commitfree=  8.49
  t= 233s fps=     4 ms=   263.2 draws=  3638 priv= 19.54 commitfree=  8.42
  t= 239s fps=     4 ms=   271.3 draws=  5938 priv= 19.58 commitfree=  8.32
  t= 245s fps=     4 ms=   279.8 draws=  5682 priv= 19.63 commitfree=  8.31
```

### R4-B-floor2g（`data\r02-a7-console.clean.log:283-384`，40 行）

```
extra=VICTORY_TEXTURE_BUDGET_MB=2048
```

```
  t=   8s fps=    31 ms=    31.8 draws=     1 priv=   6.2 commitfree= 20.92
  t=  14s fps=    30 ms=    33.3 draws=     8 priv=  7.15 commitfree= 20.87
  t=  20s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree=    21
  t=  26s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 20.96
  t=  32s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree=  20.9
  t=  38s fps=    30 ms=    33.3 draws=     8 priv=  6.98 commitfree= 20.85
  t=  44s fps=    33 ms=    30.6 draws=     4 priv=  7.15 commitfree= 20.53
  t=  50s fps=    30 ms=    33.3 draws=     4 priv=  7.26 commitfree= 20.51
  t=  56s fps=    30 ms=    33.3 draws=     4 priv=  7.26 commitfree= 20.51
  t=  62s fps=    30 ms=    33.4 draws=     8 priv=  7.66 commitfree=  20.1
  t=  68s fps=    30 ms=    33.3 draws=    10 priv=  7.89 commitfree= 19.13
  t=  74s fps=    29 ms=    34.7 draws=    10 priv=  12.1 commitfree= 16.09
  t=  81s fps=    30 ms=    33.4 draws=     8 priv= 11.43 commitfree= 16.33
  t=  87s fps=    30 ms=    33.4 draws=     9 priv= 11.24 commitfree= 16.45
  t=  93s fps=    30 ms=    33.3 draws=     9 priv= 11.25 commitfree= 16.44
  t=  99s fps=    32 ms=    31.4 draws=     8 priv= 15.99 commitfree= 11.82
  t= 105s fps=     3 ms=   293.2 draws=  2415 priv= 17.49 commitfree=  9.87
  t= 111s fps=     4 ms=   281.1 draws=  2293 priv= 18.12 commitfree=  9.62
  t= 117s fps=     3 ms=   320.9 draws=  1522 priv= 18.62 commitfree=  8.32
  t= 123s fps=     4 ms=   257.2 draws=  2030 priv= 19.51 commitfree=  8.69
  t= 129s fps=     3 ms=   334.6 draws=  4139 priv= 19.21 commitfree=  7.85
  t= 135s fps=     3 ms=     364 draws=  3029 priv= 19.41 commitfree=  8.48
  t= 141s fps=     3 ms=   351.2 draws=  3814 priv= 19.28 commitfree=  8.27
  t= 147s fps=     3 ms=   301.6 draws=  1503 priv= 19.35 commitfree=  8.29
  t= 153s fps=     4 ms=   283.5 draws=  3366 priv= 19.42 commitfree=  8.22
  t= 159s fps=     3 ms=   312.2 draws=  1030 priv=  19.5 commitfree=  8.13
  t= 165s fps=     3 ms=   317.7 draws=  6246 priv= 19.58 commitfree=  8.36
  t= 171s fps=     4 ms=   268.7 draws=  4974 priv= 19.52 commitfree=  8.44
  t= 177s fps=     4 ms=   257.3 draws=  4687 priv= 19.04 commitfree=  8.91
  t= 183s fps=     4 ms=   251.8 draws=  3975 priv= 18.99 commitfree=  8.97
  t= 189s fps=     4 ms=   259.3 draws=  4608 priv= 18.86 commitfree=  9.19
  t= 195s fps=     4 ms=   272.4 draws=  5579 priv= 18.86 commitfree=  9.08
  t= 201s fps=     4 ms=     269 draws=  5018 priv= 18.91 commitfree=  9.04
  t= 207s fps=     4 ms=     240 draws=  4734 priv= 18.92 commitfree=  9.01
  t= 213s fps=     4 ms=   268.4 draws=  4953 priv= 18.95 commitfree=  8.97
  t= 219s fps=     4 ms=   269.2 draws=  4981 priv= 18.96 commitfree=  8.96
  t= 225s fps=     4 ms=   265.7 draws=  4975 priv= 18.97 commitfree=  8.96
  t= 231s fps=     4 ms=   264.6 draws=  4744 priv= 18.94 commitfree=  9.13
  t= 237s fps=     4 ms=   262.6 draws=  4791 priv= 18.94 commitfree=  9.14
  t= 243s fps=     4 ms=   267.8 draws=  4886 priv=    19 commitfree=  9.07
```

## 出处

| 数字 | 文件:行 |
| --- | --- |
| 门禁 `49.84 / 17.41 / 32.43` | `data\r02-a7-console.clean.log:5` |
| SHA256 两个 | `data\r02-a7-console.clean.log:3`、`:4` |
| R4-A2-baseline 汇总行 | `data\r02-a7-console.clean.log:94` |
| R4-B-reverted 汇总行 | `data\r02-a7-console.clean.log:186` |
| R4-B-threads-old 汇总行 | `data\r02-a7-console.clean.log:279` |
| R4-B-floor2g 汇总行 | `data\r02-a7-console.clean.log:372` |
| 四行 csv | `data\bench-v2.csv:4`、`:5`、`:6`、`:7` |
| 四组产物日志 | `data\run-R4-A2-baseline-1126-230753.log`、`run-R4-B-reverted-1126-231209.log`、`run-R4-B-threads-old-1126-231629.log`、`run-R4-B-floor2g-1126-232046.log` |

## 异常与偏离

1. 第一次起跑失败：runner 脚本被 pwsh 以无 BOM 写出，5.1 按 ANSI 读，中文目录名变乱码，`Out-File` 报「找不到路径」，未生成 console、无 victory 进程。处置：改为 `$PSScriptRoot` 推导目录、脚本全 ASCII、写 BOM，并用绝对路径 `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` 启动；正式计时从 23:07:47 开始，失败那次未产生任何数字。
2. console 编码混写：父进程用 UTF-8 追加、子进程 `*>>` 重定向段是 UTF-16LE，直读会夹 `\0` 与乱码。已去 NUL 复原为 `data\r02-a7-console.clean.log`（本回填引用即此文件）；数字逐字不变，汇总行的汉字（「filter v2」「条世界样本」等）仍为乱码，数值部分完好。
3. 你给的 `Commit Free = 32.56 GB` 与跑前实测 `commit_free_gb=32.43` 不同：两个时刻读数，`commit_limit_gb=49.84` 两边一致。
4. 四组 `min_commit_free_gb` 从 round-02 的 0.26–0.38 升到 7.6–7.97（页面文件扩后同口径读数），仅照抄，未作解释。

## 未做 / 待办

- 未对四组之间、以及与 round-02 / round-03 的任何一组做快慢判定；上表只给数。
- 未改 `bench.ps1` / `13-bench-ab.ps1` 的判据、过滤条件与 `-Extra` 解析；`-Extra` 只用了任务列出的两个变量组。
- 未删改 `bench-v2.csv` L1–L3，只在末尾追加 4 行。
- runner 脚本 `r02-a7-run.ps1` 留在方案根目录，属临时件；需要我清理就说一声。

