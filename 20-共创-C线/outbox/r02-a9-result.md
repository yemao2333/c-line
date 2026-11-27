# r02-a9 回填（R5 四组：control / wideback0 / cardsteps0 / relaycopy0）

task_id: `r02-a9` ｜ 执行侧：豆包 ｜ 2026-11-26 23:55:47–2026-11-27 00:12:48

## 状态

```
commit_limit_gb=49.84 commit_used_gb=10.53 commit_free_gb=39.31   -> 门禁已过（>= 44）
SHA256_victory=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
R5-control    23:55:53 起跑 / 00:00:02 落行 / post-clean leftover_procs=0
R5-wideback0  00:00:07 起跑 / 00:04:15 落行 / post-clean leftover_procs=0
R5-cardsteps0 00:04:20 起跑 / 00:08:30 落行 / post-clean leftover_procs=0
R5-relaycopy0 00:08:35 起跑 / 00:12:43 落行 / post-clean leftover_procs=0
跑后复核 ^victory 残留 = 0
```

## 数字（逐字，未换算、未重算）

`data\bench-v2.csv:8-11`（只追加，L1–L7 未动）：

```
8: 2026-11-27 00:00:02,R5-control,200,40,ms>40&draws>=200,30,248.6,5015,20.44,2.85,13.86,0,run-R5-control-1126-235553.log
9: 2026-11-27 00:04:15,R5-wideback0,200,40,ms>40&draws>=200,33,268.1,4569,20.29,2.72,13.49,0,run-R5-wideback0-1127-000008.log
10: 2026-11-27 00:08:30,R5-cardsteps0,200,40,ms>40&draws>=200,33,292.8,4832,20.53,3.46,14.31,0,run-R5-cardsteps0-1127-000421.log
11: 2026-11-27 00:12:43,R5-relaycopy0,200,40,ms>40&draws>=200,32,304.4,4703,21.12,4.55,13.85,0,run-R5-relaycopy0-1127-000836.log
```

| label | world_samples | median_ms_world | median_draws | max_priv_gb | min_free_gb | min_commit_free_gb | leftover_procs |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R5-control | 30 | 248.6 | 5015 | 20.44 | 2.85 | 13.86 | 0 |
| R5-wideback0 | 33 | 268.1 | 4569 | 20.29 | 2.72 | 13.49 | 0 |
| R5-cardsteps0 | 33 | 292.8 | 4832 | 20.53 | 3.46 | 14.31 | 0 |
| R5-relaycopy0 | 32 | 304.4 | 4703 | 21.12 | 4.55 | 13.85 | 0 |

## `-Extra` 生效回显（第 2/3/4 组原文；第 1 组无 Extra，故无该行）

```
extra=VICTORY_WIDE_BACK=0
extra=VICTORY_CARD_STEPS=0
extra=VICTORY_RELAY_COPY=0
```

## 与控制组的算术差（只算，不判读）

| label | median_ms_world 差（ms） | 相对控制组 |
| --- | --- | --- |
| R5-wideback0 | +19.5 | +7.84% |
| R5-cardsteps0 | +44.2 | +17.78% |
| R5-relaycopy0 | +55.8 | +22.45% |

规则核对（按 `task-20261126-2355-09.md` §条件步骤）：没有任何一组的 `median_ms_world` 比 `R5-control` 低，触发条件未成立，**未补跑 `VICTORY_LOG=info` 的 60 s 组**，因此「`of the waiting for the card in settles` / `the relay per frame` / `list calls translated by threads of ours per frame`」三行原文本回填不含（未产生该日志）。

## 逐样本（每 5 秒一行，原文）

### R5-control（`data\r02-a9-console.log:5-96`，40 行）

```
  t=   9s fps=       ms=         draws=       priv=  4.75 commitfree= 28.28
  t=  15s fps=    30 ms=    33.3 draws=     8 priv=  7.17 commitfree= 27.15
  t=  21s fps=    30 ms=    33.3 draws=     8 priv=  7.27 commitfree= 27.12
  t=  27s fps=    30 ms=    33.3 draws=     4 priv=  7.51 commitfree= 27.03
  t=  33s fps=    30 ms=    33.3 draws=     4 priv=  7.22 commitfree= 27.26
  t=  39s fps=    30 ms=    33.8 draws=    10 priv=  7.41 commitfree= 26.93
  t=  45s fps=    30 ms=    33.3 draws=    10 priv=  7.88 commitfree= 26.49
  t=  51s fps=    30 ms=    33.4 draws=     8 priv=  9.29 commitfree= 22.88
  t=  57s fps=    28 ms=    35.2 draws=    10 priv=  12.7 commitfree= 21.63
  t=  63s fps=    30 ms=    33.6 draws=    10 priv= 12.28 commitfree=  20.5
  t=  70s fps=     3 ms=     297 draws=  1699 priv=  17.9 commitfree= 16.33
  t=  76s fps=     4 ms=   260.1 draws=  1393 priv= 18.74 commitfree= 15.53
  t=  82s fps=     3 ms=   319.4 draws=  2810 priv= 19.04 commitfree= 15.28
  t=  88s fps=     4 ms=   229.4 draws=  1432 priv=  19.1 commitfree= 15.26
  t=  94s fps=     4 ms=   228.5 draws=  1643 priv= 19.12 commitfree= 15.15
  t= 100s fps=     4 ms=   263.7 draws=   960 priv= 19.81 commitfree= 14.49
  t= 106s fps=     3 ms=   357.9 draws=  5015 priv= 20.15 commitfree= 14.24
  t= 112s fps=     3 ms=   290.9 draws=  3034 priv= 20.19 commitfree=  14.2
  t= 118s fps=     3 ms=   351.9 draws=  4592 priv= 20.28 commitfree= 14.07
  t= 124s fps=     4 ms=   268.6 draws=  1809 priv= 20.44 commitfree= 13.91
  t= 130s fps=     4 ms=   248.7 draws=  1097 priv= 20.41 commitfree= 13.86
  t= 136s fps=     4 ms=   251.6 draws=  5085 priv= 20.07 commitfree= 14.28
  t= 142s fps=     4 ms=   250.7 draws=  4989 priv= 19.53 commitfree= 14.85
  t= 148s fps=     4 ms=   244.7 draws=  5452 priv= 19.56 commitfree= 14.83
  t= 154s fps=     4 ms=   240.7 draws=  4665 priv= 19.52 commitfree= 14.84
  t= 160s fps=     5 ms=   209.6 draws=  3443 priv= 19.55 commitfree= 14.83
  t= 166s fps=     4 ms=     259 draws=  7259 priv= 19.54 commitfree= 14.85
  t= 172s fps=     4 ms=   232.3 draws=  3256 priv= 19.48 commitfree= 14.89
  t= 178s fps=     4 ms=     259 draws=  4133 priv= 19.58 commitfree=  14.8
  t= 184s fps=     4 ms=   248.6 draws=  5116 priv= 19.59 commitfree= 14.79
  t= 190s fps=     4 ms=   246.7 draws=  5136 priv= 19.56 commitfree= 14.82
  t= 196s fps=     4 ms=   247.2 draws=  5142 priv= 19.56 commitfree= 14.82
  t= 202s fps=     4 ms=   244.5 draws=  5139 priv= 19.54 commitfree= 14.84
  t= 208s fps=     4 ms=   245.7 draws=  5135 priv= 19.55 commitfree= 14.83
  t= 214s fps=     3 ms=   289.4 draws=  5163 priv= 19.57 commitfree= 14.79
  t= 220s fps=     4 ms=   245.9 draws=  6275 priv=  19.6 commitfree= 14.77
  t= 226s fps=     4 ms=   243.3 draws=  5992 priv= 19.59 commitfree= 14.78
  t= 232s fps=     4 ms=     246 draws=  6537 priv= 19.61 commitfree= 14.78
  t= 238s fps=     4 ms=     245 draws=  6463 priv=  19.6 commitfree= 14.79
  t= 244s fps=     4 ms=   244.1 draws=  5428 priv= 19.58 commitfree=  14.8
```

### R5-wideback0（`data\r02-a9-console.log:97-189`，40 行）

```
extra=VICTORY_WIDE_BACK=0
```

```
  t=   8s fps=    31 ms=    32.1 draws=     1 priv=  6.22 commitfree= 27.46
  t=  14s fps=    30 ms=    33.3 draws=     4 priv=  7.19 commitfree= 27.23
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=   7.2 commitfree= 27.24
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=   7.2 commitfree= 27.35
  t=  32s fps=    30 ms=    33.3 draws=     9 priv=  7.66 commitfree= 26.85
  t=  38s fps=    30 ms=    33.3 draws=     9 priv=  8.61 commitfree= 25.44
  t=  44s fps=    27 ms=    37.2 draws=    10 priv= 12.91 commitfree=  21.5
  t=  50s fps=     4 ms=   269.7 draws=  2180 priv= 18.37 commitfree= 16.16
  t=  56s fps=     2 ms=   447.2 draws=  2264 priv= 19.31 commitfree= 14.97
  t=  62s fps=     4 ms=   284.3 draws=  4118 priv= 19.38 commitfree= 14.99
  t=  68s fps=     4 ms=   262.2 draws=  1824 priv= 19.67 commitfree= 14.81
  t=  74s fps=     4 ms=   268.1 draws=  2233 priv= 19.96 commitfree=  14.3
  t=  80s fps=     4 ms=   283.3 draws=   934 priv= 20.12 commitfree= 13.49
  t=  86s fps=     3 ms=   326.2 draws=  3756 priv= 20.01 commitfree= 14.59
  t=  92s fps=     2 ms=   556.2 draws=  3210 priv= 20.07 commitfree= 14.52
  t=  98s fps=     2 ms=   612.7 draws=  3312 priv= 20.11 commitfree=  14.5
  t= 104s fps=     1 ms=   993.3 draws=  3362 priv= 20.15 commitfree= 14.43
  t= 110s fps=     3 ms=   385.7 draws=  1069 priv= 20.21 commitfree= 14.37
  t= 116s fps=     4 ms=   255.8 draws=  3910 priv= 20.29 commitfree= 14.29
  t= 122s fps=     3 ms=   344.3 draws=  5052 priv= 20.07 commitfree= 14.47
  t= 128s fps=     3 ms=   340.7 draws=  4745 priv= 19.89 commitfree= 14.94
  t= 134s fps=     4 ms=   252.4 draws=  6094 priv= 19.57 commitfree= 14.92
  t= 140s fps=     1 ms=     754 draws=  5877 priv= 19.87 commitfree= 14.71
  t= 146s fps=     4 ms=   248.2 draws=  3904 priv= 19.81 commitfree= 14.76
  t= 152s fps=     4 ms=   259.7 draws=  5142 priv= 19.72 commitfree= 14.84
  t= 158s fps=     4 ms=   262.8 draws=  5196 priv= 19.74 commitfree= 14.84
  t= 164s fps=     4 ms=     253 draws=  4577 priv=  19.7 commitfree= 14.87
  t= 170s fps=     4 ms=   248.9 draws=  4569 priv= 19.69 commitfree=  14.9
  t= 176s fps=     5 ms=   219.8 draws=  4591 priv=  19.7 commitfree=  14.9
  t= 183s fps=     4 ms=   253.1 draws=  4571 priv= 19.71 commitfree= 14.89
  t= 189s fps=     4 ms=   257.1 draws=  4569 priv= 19.72 commitfree= 14.89
  t= 195s fps=     4 ms=   250.8 draws=  4551 priv= 19.73 commitfree= 14.88
  t= 201s fps=     4 ms=   259.9 draws=  4572 priv= 19.72 commitfree= 14.87
  t= 207s fps=     4 ms=     253 draws=  4571 priv= 19.73 commitfree= 14.87
  t= 213s fps=     4 ms=   282.7 draws=  4550 priv= 19.73 commitfree= 14.85
  t= 219s fps=     4 ms=   274.6 draws=  5129 priv= 19.73 commitfree= 14.96
  t= 225s fps=     4 ms=   269.1 draws=  5102 priv= 19.74 commitfree= 15.31
  t= 231s fps=     4 ms=   274.5 draws=  5777 priv= 19.77 commitfree= 15.37
  t= 237s fps=     4 ms=   251.9 draws=  6334 priv=  19.8 commitfree= 15.35
  t= 243s fps=     4 ms=   254.8 draws=  6020 priv= 19.81 commitfree= 15.34
```

### R5-cardsteps0（`data\r02-a9-console.log:190-282`，40 行）

```
extra=VICTORY_CARD_STEPS=0
```

```
  t=  10s fps=    30 ms=    33.3 draws=     1 priv=   6.1 commitfree= 27.97
  t=  16s fps=    30 ms=    33.3 draws=     4 priv=  7.33 commitfree= 27.72
  t=  22s fps=    30 ms=    33.3 draws=     4 priv=  7.33 commitfree= 27.73
  t=  28s fps=    29 ms=    34.1 draws=     5 priv=  7.23 commitfree= 27.62
  t=  34s fps=    30 ms=    33.3 draws=     8 priv=  7.78 commitfree= 27.22
  t=  40s fps=    30 ms=    33.8 draws=     9 priv=  9.43 commitfree= 21.37
  t=  46s fps=    28 ms=    36.1 draws=    12 priv= 13.72 commitfree= 20.81
  t=  52s fps=     3 ms=   292.8 draws=  1701 priv=    18 commitfree= 16.85
  t=  58s fps=     3 ms=   320.5 draws=  1687 priv= 18.65 commitfree= 16.18
  t=  64s fps=     3 ms=   290.1 draws=  3354 priv= 19.04 commitfree= 15.77
  t=  70s fps=     3 ms=   333.1 draws=  1752 priv= 19.41 commitfree= 15.42
  t=  76s fps=     3 ms=   357.9 draws=  3667 priv=  19.9 commitfree= 14.94
  t=  82s fps=     3 ms=   342.9 draws=   975 priv= 19.91 commitfree= 14.98
  t=  88s fps=     3 ms=   361.1 draws=  5075 priv= 20.06 commitfree= 14.76
  t=  94s fps=     3 ms=   343.4 draws=  2241 priv= 20.16 commitfree= 14.68
  t= 100s fps=     3 ms=   385.1 draws=  3439 priv=  20.3 commitfree= 14.55
  t= 106s fps=     3 ms=     338 draws=  1616 priv= 20.38 commitfree= 14.47
  t= 112s fps=     3 ms=   317.2 draws=  1104 priv= 20.34 commitfree= 14.33
  t= 118s fps=     3 ms=   297.4 draws=  4832 priv= 20.53 commitfree= 14.31
  t= 124s fps=     3 ms=   290.1 draws=  4817 priv= 20.16 commitfree= 14.72
  t= 130s fps=     4 ms=   274.5 draws=  4731 priv= 19.97 commitfree= 14.88
  t= 136s fps=     4 ms=   283.7 draws=  4625 priv= 19.92 commitfree= 14.92
  t= 142s fps=     4 ms=   283.3 draws=  4614 priv= 19.87 commitfree= 14.99
  t= 148s fps=     4 ms=   285.3 draws=  4595 priv= 19.83 commitfree= 15.02
  t= 154s fps=     4 ms=   267.2 draws=  3362 priv=  19.8 commitfree= 15.05
  t= 160s fps=     3 ms=   307.1 draws=  5462 priv= 19.89 commitfree= 14.93
  t= 166s fps=     3 ms=   308.6 draws=  6181 priv= 20.02 commitfree= 14.84
  t= 172s fps=     3 ms=   304.1 draws=  5877 priv= 20.02 commitfree= 14.85
  t= 178s fps=     3 ms=   286.4 draws=  4950 priv=    20 commitfree= 14.87
  t= 184s fps=     4 ms=   283.1 draws=  4898 priv=    20 commitfree= 14.87
  t= 190s fps=     3 ms=     288 draws=  5238 priv=    20 commitfree= 14.86
  t= 196s fps=     3 ms=   292.2 draws=  5255 priv= 20.02 commitfree= 14.85
  t= 202s fps=     3 ms=   293.8 draws=  5210 priv= 20.01 commitfree= 14.86
  t= 208s fps=     3 ms=   293.7 draws=  5214 priv= 20.01 commitfree= 14.85
  t= 215s fps=     3 ms=   287.9 draws=  5220 priv=    20 commitfree= 14.86
  t= 221s fps=     3 ms=   290.7 draws=  5217 priv= 20.01 commitfree= 14.85
  t= 227s fps=     3 ms=   288.7 draws=  5066 priv= 20.03 commitfree= 14.82
  t= 233s fps=     3 ms=   290.9 draws=  6002 priv= 20.07 commitfree= 14.79
  t= 239s fps=     3 ms=   295.3 draws=  5974 priv= 20.09 commitfree= 14.77
  t= 245s fps=     3 ms=   290.3 draws=  5977 priv= 20.06 commitfree=  14.8
```

### R5-relaycopy0（`data\r02-a9-console.log:283-388`，40 行）

```
extra=VICTORY_RELAY_COPY=0
```

```
  t=   8s fps=    30 ms=    33.4 draws=     1 priv=  6.53 commitfree= 28.03
  t=  14s fps=    30 ms=    33.3 draws=     8 priv=  6.95 commitfree= 28.05
  t=  20s fps=    30 ms=    33.3 draws=     4 priv=  7.22 commitfree=  27.8
  t=  26s fps=    30 ms=    33.3 draws=     4 priv=  7.22 commitfree= 27.81
  t=  32s fps=    30 ms=    33.3 draws=    10 priv=  7.39 commitfree=  27.5
  t=  38s fps=    30 ms=    33.3 draws=    10 priv=  7.79 commitfree= 27.18
  t=  44s fps=    30 ms=    33.6 draws=     8 priv= 10.49 commitfree= 21.17
  t=  50s fps=    31 ms=    32.6 draws=    12 priv= 14.36 commitfree= 18.33
  t=  56s fps=     3 ms=   301.4 draws=  1651 priv= 18.34 commitfree= 16.59
  t=  62s fps=     3 ms=   286.1 draws=  2825 priv= 19.02 commitfree= 15.98
  t=  68s fps=     3 ms=   303.4 draws=  2898 priv= 19.24 commitfree= 15.73
  t=  74s fps=     3 ms=   298.9 draws=  1895 priv= 19.39 commitfree= 15.57
  t=  80s fps=     3 ms=   347.2 draws=  2229 priv= 19.98 commitfree= 14.93
  t=  86s fps=     3 ms=   301.7 draws=  3869 priv= 20.39 commitfree= 14.58
  t=  92s fps=     3 ms=   387.5 draws=  4131 priv= 20.72 commitfree= 14.24
  t=  98s fps=     3 ms=   317.2 draws=  1783 priv= 20.83 commitfree= 14.09
  t= 104s fps=     3 ms=   315.6 draws=  3456 priv= 21.04 commitfree= 13.99
  t= 110s fps=     3 ms=     352 draws=  1959 priv=  20.9 commitfree= 14.14
  t= 116s fps=     3 ms=   336.3 draws=  1110 priv= 21.02 commitfree= 13.85
  t= 122s fps=     3 ms=   319.7 draws=  3717 priv= 21.12 commitfree= 13.95
  t= 128s fps=     4 ms=   283.9 draws=  6259 priv= 20.99 commitfree= 14.01
  t= 134s fps=     3 ms=   290.8 draws=  4356 priv= 20.55 commitfree= 14.45
  t= 140s fps=     3 ms=   290.1 draws=  3730 priv= 20.47 commitfree=  14.5
  t= 147s fps=     3 ms=     318 draws=  5667 priv=  20.4 commitfree= 14.45
  t= 153s fps=     3 ms=     321 draws=  5713 priv= 20.41 commitfree=  14.5
  t= 159s fps=     3 ms=   325.9 draws=  4864 priv= 20.45 commitfree=  14.4
  t= 165s fps=     3 ms=   291.4 draws=  4510 priv= 20.44 commitfree= 14.42
  t= 171s fps=     3 ms=   296.8 draws=  6108 priv= 20.42 commitfree= 14.43
  t= 177s fps=     3 ms=     304 draws=  4703 priv= 20.47 commitfree= 14.38
  t= 183s fps=     3 ms=   295.8 draws=  4599 priv= 20.52 commitfree= 14.34
  t= 189s fps=     4 ms=   271.2 draws=  4968 priv= 20.55 commitfree= 14.29
  t= 195s fps=     3 ms=   314.4 draws=  4936 priv= 20.56 commitfree= 14.31
  t= 201s fps=     3 ms=   315.8 draws=  4920 priv= 20.54 commitfree= 14.35
  t= 207s fps=     3 ms=   304.4 draws=  4988 priv= 20.63 commitfree= 14.26
  t= 213s fps=     3 ms=   310.8 draws=  4988 priv= 20.64 commitfree= 14.26
  t= 219s fps=     3 ms=   302.5 draws=  4969 priv= 20.59 commitfree=  14.3
  t= 225s fps=     4 ms=   265.9 draws=  5265 priv=  20.6 commitfree= 14.29
  t= 231s fps=     3 ms=   298.6 draws=  5336 priv= 20.61 commitfree= 14.28
  t= 237s fps=     3 ms=   313.3 draws=  6677 priv= 20.59 commitfree=  14.3
  t= 243s fps=     3 ms=   312.1 draws=  5872 priv= 20.58 commitfree= 14.31
```

## 出处

| 数字 | 文件:行 |
| --- | --- |
| 门禁 `49.84 / 10.53 / 39.31` | `data\r02-a9-console.log:4` |
| SHA256 | `data\r02-a9-console.log:3` |
| R5-control 汇总行 | `data\r02-a9-console.log:93` |
| R5-wideback0 汇总行 | `data\r02-a9-console.log:186` |
| R5-cardsteps0 汇总行 | `data\r02-a9-console.log:279` |
| R5-relaycopy0 汇总行 | `data\r02-a9-console.log:372` |
| 四行 csv | `data\bench-v2.csv:8`、`:9`、`:10`、`:11` |
| 四组产物日志 | `data\run-R5-control-1126-235553.log`、`run-R5-wideback0-1127-000008.log`、`run-R5-cardsteps0-1127-000421.log`、`run-R5-relaycopy0-1127-000836.log` |

## 任务单核对（`inbox\task-20261126-2355-09.md`，创建 2026-11-26 23:55:38）

| 单里的要求 | 本轮回填 | 判定 |
| --- | --- | --- |
| 守卫 `commit_limit_gb ≥ 44` | `49.84` | 符合 |
| 四组顺序与 label | `R5-control` → `R5-wideback0` → `R5-cardsteps0` → `R5-relaycopy0` | 一致 |
| `-Extra` 三项 | `VICTORY_WIDE_BACK=0` / `VICTORY_CARD_STEPS=0` / `VICTORY_RELAY_COPY=0` | 一致（回显见上） |
| 产物 / `-Profile fork` / 200 s | `victory.exe`（`58E60D62…A4EFF45`）/ `fork` / `200` | 一致 |
| `bench-v2.csv` 追加 L8–L11 | L8–L11 四行，L1–L7 未动 | 符合 |
| `world_samples ≥ 8` / `leftover_procs=0` | 30 / 33 / 33 / 32；四组均 0 | 符合 |
| 条件步骤（某组低 ≥10% 才跑 info 60 s） | 未触发，未跑 | 按规则跳 |

## 异常与偏离

1. **任务单落盘时间与我的读取错位（不影响执行）**：`task-20261126-2355-09.md` 创建于 `2026-11-26 23:55:38`。我在 23:50 左右查 inbox 时它还没落盘（当时最新是 `task-20261126-2345-08.md`，全项目 Grep 也命中 0），因此按对话里的四组单执行；跑完读单逐项比对，与上表完全一致，**未重跑**。`-Extra` 取值与源码默认值对齐：`VICTORY_WIDE_BACK` 默认 `1`（`shadow.rs:1464` 判 `v != "0"`）、`VICTORY_CARD_STEPS` 默认 `2`（`card_steps.rs:79`）、`VICTORY_RELAY_COPY` 默认 `1`（`host.rs:2505` 判 `v == "1"`），关闭均写 `0`。
2. **重启时间两处读数不一致**：单里写「用户已于 2026-11-26 23:50:31 重启」，本机实测 `LastBootUpTime=2026-11-26 23:43:30`（r02-a8 回填同此值）。只记录，不解释。
3. runner 沿用 a7 的写法（`$PSScriptRoot` 推目录 + 全 ASCII + BOM + 绝对路径 5.1 + `Parser::ParseFile` 自检），子进程输出改成 `2>&1 | Out-File -Encoding utf8`，本份 console 无 NUL、无乱码。
4. 四组 `min_commit_free_gb` 13.49–14.31，`max_priv_gb` 20.29–21.12（`R5-relaycopy0` 最高），只抄不解释。

## 未做

- 未删改 `bench-v2.csv` L1–L7，只在末尾追加 4 行。
- 未改 `bench.ps1` / `13-bench-ab.ps1` 的判据、过滤条件与 `-Extra` 解析。
- 未跑 `VICTORY_LOG=info` 的 60 s 条件组（触发条件未成立）。
- 未对四组做快慢判定；`+%` 一栏是相对控制组的算术差。

