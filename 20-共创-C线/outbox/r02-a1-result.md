# r02-a1 回填（build）

task_id: `r02-a1` ｜ 执行时间：2026-11-26 22:00:26–22:02:32 ｜ 执行侧：豆包

## 状态

```
EXIT=0 elapsed=126s
```

## 数字

```
E02 exe_bytes=49681038 written=2026-11-26 22:02:32 SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
errors=0
baseline_intact=True
```

原样输出块（未换算、未改写）：

```
EXIT=0 elapsed=126s
exe_bytes=49681038 written=2026-11-26 22:02:32
SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
errors=0
baseline_intact=True
```

## 证据路径

| 项 | 路径 |
| --- | --- |
| 构建日志 | `G:\GTA\cool_fox-优化方案\data\build-r02-a1.log` |
| 产物 | `G:\GTA\cool_fox\cool_fox-main\target\release\victory.exe` |
| A 组对照物（未覆盖） | `G:\GTA\cool_fox\cool_fox-main\target\release\victory-baseline.exe` |
| SHA256 取法 | `Get-FileHash target\release\victory.exe -Algorithm SHA256` |

## 异常

无。构建前已按映像名清理 `victory*` 残留（`Get-Process -Name victory | Stop-Process -Force`，清理后计数 0）。

## 给 a2/a3 的绑定值

`r02-a2` / `r02-a3` 回填必须复述以下两项，用于版本指纹核对：

```
written=2026-11-26 22:02:32
SHA256=58E60D624CABC7BDD9EC203F24AF3EEC1CA4A65FB1865B27CBC57E299A4EFF45
```
