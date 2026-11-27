#Requires -RunAsAdministrator
<#
    12-页面文件.ps1 —— P0-1：把提交上限从 33.84 GB 抬到 48 GB 以上

    为什么：31.8 GB 物理内存 + 2 GB 页面文件 = 提交上限 33.84 GB；实测世界内
    最小提交余量只剩 0.26–0.38 GB（round-02 的 A/B 两组都是），这台机器真正的
    墙在这里，不在帧时间。

    做什么：
      1) 关掉「自动管理页面文件」；
      2) 把 C:\pagefile.sys 钉在 2048 / 2048 MB（崩溃转储够用，且不让它吃掉 C: 的剩余空间）；
      3) 在 G:（CF600 1TB NVMe SSD）加 16384 / 32768 MB；
      4) 重启后提交上限 = 31.8 + 2 + 16…32 ≈ 49.8…65.8 GB。

    用法（本机没有 pwsh 在 PATH 上，用 powershell 5.1）：
        右键「使用 PowerShell 运行」→ UAC 选“是”
      或先开管理员 PowerShell，再：
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        & 'G:\GTA\cool_fox-优化方案\12-页面文件.ps1'

    回滚（同样需要管理员 + 重启）：
        & 'G:\GTA\cool_fox-优化方案\12-页面文件.ps1' -Revert

    历史：2026-11-26 首次运行时 New-CimInstance 抛 InvalidType(0x80041005)，
    原因是 Win32_PageFileSetting.InitialSize 为 UInt32 而 PS 传的是 Int32。
    现改为 Set-WmiInstance 优先、[uint32] 兜底、设完回读自校验。
#>
[CmdletBinding()]
param(
    [string]$Drive = 'G:',
    [int]$InitialMB = 16384,
    [int]$MaximumMB = 32768,
    [int]$SystemDriveMB = 2048,
    [switch]$Revert
)

$ErrorActionPreference = 'Stop'

function Show-Now {
    '--- 现状 ---'
    Get-CimInstance Win32_PageFileUsage | Select-Object Name, AllocatedBaseSize, PeakUsage | Format-Table -AutoSize
    $limit = (Get-Counter '\Memory\Commit Limit').CounterSamples[0].CookedValue
    '提交上限: {0:N2} GB' -f ($limit / 1GB)
    '自动管理页面文件: {0}' -f (Get-CimInstance Win32_ComputerSystem).AutomaticManagedPagefile
}

# 建/改一个页面文件条目。
# Win32_PageFileSetting 的 InitialSize / MaximumSize 是 UInt32：先走 Set-WmiInstance
# （自己会做类型转换），失败再用 [uint32] 显式构造。返回值只给 bool，回显走 Write-Host。
function Set-PageFile([string]$Name, [int]$InitialMB, [int]$MaxMB) {
    try {
        Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{
            Name        = $Name
            InitialSize = $InitialMB
            MaximumSize = $MaxMB
        } -ErrorAction Stop | Out-Null
        Write-Host ('  [WMI] {0} -> {1} / {2} MB' -f $Name, $InitialMB, $MaxMB)
        return $true
    } catch {
        Write-Host ('  [WMI] 失败: {0}' -f $_.Exception.Message)
    }
    try {
        New-CimInstance -ClassName Win32_PageFileSetting -Property @{
            Name        = $Name
            InitialSize = [uint32]$InitialMB
            MaximumSize = [uint32]$MaxMB
        } -ErrorAction Stop | Out-Null
        Write-Host ('  [CIM] {0} -> {1} / {2} MB' -f $Name, $InitialMB, $MaxMB)
        return $true
    } catch {
        Write-Host ('  [CIM] 失败: {0}' -f $_.Exception.Message)
    }
    return $false
}

Show-Now

if ($Revert) {
    $cs = Get-CimInstance Win32_ComputerSystem
    $cs | ForEach-Object { $_.AutomaticManagedPagefile = $true; $_ } | Set-CimInstance
    Get-CimInstance Win32_PageFileSetting | Where-Object { $_.Name -like "$Drive*" } | Remove-CimInstance -ErrorAction SilentlyContinue
    '已恢复「自动管理」，G: 上的页面文件设置已移除；重启后生效。'
    return
}

# G: 必须是固态：机械盘或网络盘上的页面文件会让换页从「慢」变成「卡死」。
$diskNumber = (Get-Partition -DriveLetter $Drive.TrimEnd(':')).DiskNumber
$media = Get-PhysicalDisk -DeviceNumber $diskNumber
if ($media.MediaType -ne 'SSD') {
    throw ("{0} 位于磁盘 {1}（{2} / MediaType={3}）：只有 SSD 才适合放页面文件" -f $Drive, $diskNumber, $media.FriendlyName, $media.MediaType)
}
'介质检查: {0} = 磁盘 {1} / {2} / {3}' -f $Drive, $diskNumber, $media.FriendlyName, $media.MediaType

# 空闲空间检查：页面文件是预分配的，别把盘撑满。
$freeGB = [math]::Round((Get-PSDrive -Name $Drive.TrimEnd(':')).Free / 1GB, 1)
'空闲空间: {0} 剩 {1} GB（本次最多写入 {2} GB）' -f $Drive, $freeGB, [math]::Round($MaximumMB / 1024, 1)
if ($freeGB -lt ($MaximumMB / 1024 + 8)) {
    throw ("{0} 只剩 {1} GB，放 {2} MB 上限的页面文件不稳妥" -f $Drive, $freeGB, $MaximumMB)
}

# 1) 关掉自动管理
$cs = Get-CimInstance Win32_ComputerSystem
if ($cs.AutomaticManagedPagefile) {
    $cs | ForEach-Object { $_.AutomaticManagedPagefile = $false; $_ } | Set-CimInstance
    '已关闭「自动管理页面文件」。'
} else {
    '「自动管理页面文件」已是关闭状态。'
}

# 2) 把 C: 钉死，避免自动管理关掉后 C: 变成「系统管理」而吃掉剩余空间
$sysName = "$($env:SystemDrive)\pagefile.sys"
if (-not (Set-PageFile $sysName $SystemDriveMB $SystemDriveMB)) {
    throw 'C: 的页面文件设置未成功，停在这里'
}

# 3) 在 G: 上建 16 GB / 最大 32 GB
$name = "$Drive\pagefile.sys"
if (-not (Set-PageFile $name $InitialMB $MaximumMB)) {
    throw ("{0} 的页面文件设置未成功；改用手动界面：Win+R -> sysdm.cpl -> 高级 -> 性能「设置」-> 高级 -> 虚拟内存「更改」" -f $name)
}

'--- 设置里已排好（重启后生效）---'
$set = @(Get-CimInstance Win32_PageFileSetting | Select-Object Name, InitialSize, MaximumSize)
$set | Format-Table -AutoSize

# 设完再读一遍：没出现目标盘就是没写进去，当场停，别等重启后才发现。
$hasTarget = @($set | Where-Object { $_.Name -like "$Drive*" }).Count -gt 0
if (-not $hasTarget) {
    throw ("设置里没有出现 {0} —— 改用手动界面：Win+R -> sysdm.cpl -> 高级 -> 性能「设置」-> 高级 -> 虚拟内存「更改」" -f $name)
}
'校验通过：{0} 已在设置里（重启后生效）' -f $name

'--- 重启后按这三行核对 ---'
'  Get-CimInstance Win32_PageFileUsage | Select-Object Name, AllocatedBaseSize'
'  (Get-Counter ''\Memory\Commit Limit'').CounterSamples[0].CookedValue / 1GB'
'  目标：Commit Limit >= 48 GB，G:\pagefile.sys 的 AllocatedBaseSize 约 16384 MB'

'--- 要回滚就 ---'
"  & '$PSCommandPath' -Revert"
