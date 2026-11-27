# r02-a8 回填（重启后：页面文件持久化核对）

task_id: `r02-a8` ｜ 执行侧：豆包 ｜ verified_by=code-side ｜ 判定：PASS

## 数字（原文抄录，8 项）

```
post_reboot_at=2026-11-26 23:46:14
last_boot=2026-11-26 23:43:30
Win32_PageFileUsage: C:\pagefile.sys 2048 + G:\pagefile.sys 16384
Win32_PageFileSetting: C:\pagefile.sys 2048/2048 + G:\pagefile.sys 16384/32768
commit_limit_gb=49.84
commit_used_gb=11.34
commit_free_gb=38.5
automatic_managed=False
残留进程 0
```

## 验收对照

| 验收项 | 通过线 | 实测 | 判定 |
| --- | --- | --- | --- |
| `G:\pagefile.sys` 设置 | InitialSize 16384 / MaximumSize 32768 | `16384 / 32768` | 通过 |
| `commit_limit_gb` | ≥ 48 | `49.84` | 通过 |
| `automatic_managed` | `False` | `False` | 通过 |
| 残留进程 | 0 | `0` | 通过 |

## 来源

| 项 | 来源 |
| --- | --- |
| 上列 8 项 + 残留进程 | verified_by=code-side（代码侧复采，本回填逐字抄录） |
| 执行侧首采（同一次重启后，供对照） | `post_reboot_at=2026-11-26 23:46:13`、`commit_used_gb=11.26`、`automatic_managed=False`、`last_boot=2026-11-26 23:43:30`；`G:\pagefile.sys` 磁盘文件 `16384.00` MB @ `2026/11/26 23:43:40` |

## 未做

- 未改任何页面文件设置，未删/未卸 `G:\pagefile.sys`；本任务未跑游戏、未跑分。
- 未解释 `commit_limit_gb` / `commit_free_gb` 数值的来源与变化。
- 未复跑本任务（代码侧已代核，按要求不重跑）。

