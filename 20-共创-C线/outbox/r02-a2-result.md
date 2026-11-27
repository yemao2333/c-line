# r02-a2 回填（bench）

task_id: `r02-a2` ｜ 执行侧：豆包 ｜ 两组串行，各 `-Profile fork`、`-Seconds 200`

## 状态

```
R2-A2-baseline   完成，csv 行已追加（2026-11-26 22:07:08）
R2-B-reverted    完成，csv 行已追加（2026-11-26 22:26:47）
SKIP_BENCH       未触发
```

## 数字

```
E01 commit_limit_gb=33.84 commit_used_gb=16.51 commit_free_gb=17.33
E02 SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45 written=2026-11-26 22:02:32
E04 R2-A2-baseline world_samples=33 world_median_ms=265.8 max_draws=5770 max_priv_gb=20.35 min_commit_free_gb=0.31 csv_line=14
E05 R2-B-reverted world_samples=30 world_median_ms=271.9 max_draws=5959 max_priv_gb=20.26 min_commit_free_gb=0.53 csv_line=15
```

`csv_line` 按 `data\bench.csv` 行号计（表头为第 1 行；E04 在 14 行、E05 在 15 行，逐字如下）：

```
2026-11-26 22:07:08,R2-A2-baseline,200,40,33,265.8,20.35,3.06,0.31,run-R2-A2-baseline-1126-220303.log
2026-11-26 22:26:47,R2-B-reverted,200,40,30,271.9,20.26,2.95,0.53,run-R2-B-reverted-1126-222239.log
```

### E06 逐样本表（`Ms > 45` 取法，两段原文）

R2-A2-baseline：

```
T=51 Ms=156 Draws=326 PrivGB=17.2
T=57 Ms=275.7 Draws=1698 PrivGB=18.28
T=63 Ms=293.3 Draws=4423 PrivGB=19.02
T=69 Ms=299.4 Draws=2505 PrivGB=19.49
T=75 Ms=275.6 Draws=3144 PrivGB=19.71
T=81 Ms=304.7 Draws=3633 PrivGB=19.83
T=87 Ms=283.7 Draws=2854 PrivGB=20.06
T=93 Ms=286.2 Draws=3353 PrivGB=20.18
T=99 Ms=277.3 Draws=1476 PrivGB=20.04
T=105 Ms=286.2 Draws=3422 PrivGB=20.21
T=111 Ms=266.1 Draws=1082 PrivGB=20.24
T=117 Ms=261.7 Draws=5246 PrivGB=20.15
T=123 Ms=223.6 Draws=3998 PrivGB=19.78
T=129 Ms=245.9 Draws=4450 PrivGB=19.77
T=135 Ms=242 Draws=4403 PrivGB=19.72
T=141 Ms=236.6 Draws=4344 PrivGB=19.65
T=147 Ms=238.5 Draws=4337 PrivGB=19.61
T=153 Ms=235.4 Draws=4338 PrivGB=19.63
T=159 Ms=232.1 Draws=4349 PrivGB=19.66
T=165 Ms=232 Draws=4368 PrivGB=19.63
T=171 Ms=234.5 Draws=4374 PrivGB=19.62
T=177 Ms=237.8 Draws=4369 PrivGB=19.63
T=183 Ms=246.2 Draws=4290 PrivGB=19.66
T=189 Ms=302.9 Draws=4457 PrivGB=19.71
T=195 Ms=344.6 Draws=5770 PrivGB=19.93
T=201 Ms=364.8 Draws=5601 PrivGB=20.1
T=207 Ms=421.7 Draws=5636 PrivGB=20.33
T=214 Ms=526.5 Draws=5753 PrivGB=20.35
T=220 Ms=286.1 Draws=5744 PrivGB=20.11
T=226 Ms=265.8 Draws=5758 PrivGB=20.11
T=232 Ms=262.3 Draws=5742 PrivGB=20.11
T=238 Ms=263.5 Draws=5747 PrivGB=20.12
T=244 Ms=265.6 Draws=5750 PrivGB=20.12
```

R2-B-reverted：

```
T=51 Ms=67 Draws=9 PrivGB=13.17
T=57 Ms=47.6 Draws=9 PrivGB=11.72
T=75 Ms=58.8 Draws=10 PrivGB=11.73
T=87 Ms=287.7 Draws=1709 PrivGB=17.68
T=93 Ms=245.2 Draws=3995 PrivGB=18.57
T=99 Ms=269.7 Draws=3813 PrivGB=19.06
T=105 Ms=269.8 Draws=1666 PrivGB=19.33
T=111 Ms=387.9 Draws=3509 PrivGB=19.73
T=117 Ms=256.1 Draws=3236 PrivGB=19.9
T=123 Ms=290.8 Draws=3712 PrivGB=20.02
T=129 Ms=288.3 Draws=2208 PrivGB=20.15
T=135 Ms=365.1 Draws=4572 PrivGB=20.21
T=141 Ms=329.7 Draws=1352 PrivGB=20.23
T=147 Ms=277 Draws=1102 PrivGB=20.26
T=153 Ms=245.4 Draws=4972 PrivGB=20.23
T=159 Ms=263.6 Draws=4827 PrivGB=19.83
T=165 Ms=271.6 Draws=4518 PrivGB=19.79
T=171 Ms=256.5 Draws=4394 PrivGB=19.7
T=177 Ms=265.2 Draws=5086 PrivGB=19.66
T=183 Ms=265.3 Draws=5108 PrivGB=19.67
T=189 Ms=300.1 Draws=4819 PrivGB=19.67
T=195 Ms=275.3 Draws=5364 PrivGB=19.7
T=201 Ms=258.5 Draws=5959 PrivGB=19.72
T=207 Ms=381.6 Draws=5685 PrivGB=19.89
T=213 Ms=294.6 Draws=5105 PrivGB=19.83
T=219 Ms=292 Draws=5300 PrivGB=19.82
T=225 Ms=274.1 Draws=3924 PrivGB=19.87
T=231 Ms=272.8 Draws=5227 PrivGB=19.89
T=237 Ms=271.9 Draws=5241 PrivGB=19.9
T=243 Ms=269.6 Draws=5244 PrivGB=19.9
```

## 证据路径

| 项 | 路径 |
| --- | --- |
| 两次运行控制台原文 | `data\r02-a2-console.log` |
| csv（只追加，未改写历史行） | `data\bench.csv`（第 14、15 行） |
| 基线组日志 | `data\run-R2-A2-baseline-1126-220303.log` / `.err.log` |
| 回滚组日志 | `data\run-R2-B-reverted-1126-222239.log` / `.err.log` |

## 异常

1. **基线组收尾不干净**：基线组 22:07:08 出数后，`victory` 进程未随脚本收尾立刻消失，其 `run-R2-A2-baseline-1126-220303.err.log` 持续写到 22:19:32；后台壳中断（exit -1，`kill sandbox processes failed`）导致脚本末尾的按映像名清理没有执行。
2. **处置**：补跑 B 组前执行 `Get-Process | Where-Object { $_.ProcessName -match '^victory' } | Stop-Process -Force`，清理后进程计数 0，再起 B 组；B 组跑完计数同样为 0。
3. **未并发**：两组串行，中间 `Start-Sleep 5`。
