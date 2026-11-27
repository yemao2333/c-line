@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

if not defined VICTORY_GAME_DIR set "VICTORY_GAME_DIR=G:\GTA\GTA6.Xbox.v1.0.2.1-CYBERLEEK"
if not exist "%VICTORY_GAME_DIR%\game_scarlett_master.exe" (
  echo Set VICTORY_GAME_DIR to the dump folder containing game_scarlett_master.exe. 1>&2
  exit /b 2
)

set "runner=%~dp0target\release\victory.exe"
if not exist "%runner%" (
  echo Build first: cargo build --release --locked -p victory 1>&2
  exit /b 2
)

REM ---- 本 fork 默认加速开关（等价 Play-VIctory.cmd 的 pareto-residency）----
if not defined VICTORY_AMBIENT_AIR set "VICTORY_AMBIENT_AIR=1.5"
if not defined VICTORY_CACHE_DIR set "VICTORY_CACHE_DIR=G:\GTA\victory-data\coolfox-cache"
if not defined VICTORY_DATA_DIR set "VICTORY_DATA_DIR=G:\GTA\victory-data\coolfox-data"
if not defined VICTORY_TEXTURE_NO_WAIT set "VICTORY_TEXTURE_NO_WAIT=1"
if not defined VICTORY_RELAY set "VICTORY_RELAY=2"
if not defined VICTORY_WIDE_BACK set "VICTORY_WIDE_BACK=1"
if not defined VICTORY_CARD_REHASH_RUNS set "VICTORY_CARD_REHASH_RUNS=1"
if not defined VICTORY_JOIN_COPIES set "VICTORY_JOIN_COPIES=1"
if not defined VICTORY_INDIRECT_WINDOW set "VICTORY_INDIRECT_WINDOW=1"
if not defined VICTORY_RELAY_COPY set "VICTORY_RELAY_COPY=1"
if not defined VICTORY_CARD_STEPS set "VICTORY_CARD_STEPS=2"
if not defined VICTORY_INDIRECT_BATCH set "VICTORY_INDIRECT_BATCH=2"
if not defined VICTORY_MAP_THREADS set "VICTORY_MAP_THREADS=1"
if not defined VICTORY_CARD_AWAKE set "VICTORY_CARD_AWAKE=1"
if not defined VICTORY_SHOW_AFTER set "VICTORY_SHOW_AFTER=1"
if not defined VICTORY_AMBIENT set "VICTORY_AMBIENT=0.8"
if not defined VICTORY_THIN set "VICTORY_THIN=1"
if not defined VICTORY_JOIN_PARTS set "VICTORY_JOIN_PARTS=6"
if not defined VICTORY_UPLOAD_AHEAD set "VICTORY_UPLOAD_AHEAD=1"
if not defined VICTORY_LEVELS_ON_DEMAND set "VICTORY_LEVELS_ON_DEMAND=1"
if not defined VICTORY_CARD_BUFFERS_MIN_KB set "VICTORY_CARD_BUFFERS_MIN_KB=64"
if not defined VICTORY_LOG if not defined RUST_LOG set "VICTORY_LOG=warn"

REM 8 GB 显存 / 32 GB 内存：Series S 机型 + 不开光追
"%runner%" run "%VICTORY_GAME_DIR%\game_scarlett_master.exe" --console series-s --execute %*
exit /b %errorlevel%
