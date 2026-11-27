# Evidence sheet — CoolFox

Self-reported, reproducible from this repository. No game files, keys or executables are hosted or linked here.

## What it is

`cool_fox` — a build on VIctory's AMD branch. It runs the Xbox Series build of GTA VI through a high-level emulation layer and reaches the open world.

Hardware used for every number below: **RTX 3060 Ti 8 GB**, i5-12400F (6C/12T), 31.8 GB RAM, Windows, 1440p output. No DLSS frame generation (needs RTX 40+).

## In-world frame times (filter: `Ms > 40 且 Draws >= 200`, 600 s window after `draws >= 1000`)

| label | window start | world samples | median ms/frame | median draws | peak private | min free | min commit free |
| --- | --- | --- | --- | --- | --- | --- | --- |
| z3-tight-1 | 69 s | 101 | 246.3 | 4180 | 17.63 GB | 2.54 | 11.18 |
| z3-tight-2 | 80 s | 101 | 243.9 | 4193 | 17.66 GB | 2.67 | 11.27 |
| z3-tight-3 | 68 s | 101 | 240.2 | 4200 | 18.35 GB | 3.09 | 10.47 |

That is **4.07–4.17 fps** in world, 4,180–4,200 draws per frame.

Plain baseline of the same build without the memory settings: 249.2 / 244.1 / 252.7 ms (3.96–4.01 fps), peak private 20.07–20.49 GB.

## Upstream fork measured on the same machine

`fxceless/victory-fork`, three reps, same filter, same 600 s window:

| label | window start | world samples | median ms/frame | median draws | peak private |
| --- | --- | --- | --- | --- | --- |
| fork-1 | 237 s | 101 | 522.2 | 4230 | 16.94 GB |
| fork-2b | 99 s | 101 | 241.2 | 4371 | 15.78 GB |
| fork-3 | 44 s | 97 | 220.0 | 4343 | 16.29 GB |

`fork-1`'s window starts at 237 s and still covers loading tail, which is why its median is high; the other two start at 99 s and 44 s.

## Stability notes

- No in-world crash inside any 600 s window; every window closed with `leftover_procs = 0`.
- Startup is less reliable: runs can exit 1–5 s in with `host pipeline refused 0x80070057` or `host view heap capped at 1000000`. On 2026-11-28, 6 of 12 launch attempts died this way before reaching the world.
- A 0-byte `telemetrycache.dat` makes the title exit in about 1 s with `refused dll="rpcrt4.dll"` as the only error line.

## What this does not claim

- Story progress, mission completion and render quality are **not assessed** here. Only frame time, draw count and memory are measured.
- The frame-time numbers are from one machine. Nothing was measured on AMD or Intel.

## Files worth reading

- `30-结项报告.md` — full write-up with every否定结论 carrying its numbers
- `data/bench-v3.csv` — 31 rows, the 600 s-window ledger
- `data/bench-fork.csv` — 11 rows, upstream fork ledger
- `10-实验脚本/bench.ps1`, `bench-fork.ps1` — the exact measurement scripts
