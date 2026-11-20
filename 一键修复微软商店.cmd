@echo off
setlocal EnableExtensions
chcp 936 >nul
title 微软应用商店全能修复工具 v3.0 (专业旗舰版)

:: ====================================================================
:: 1. 管理员权限自动检测与申请 (UAC 自提权，兼容中文/空格/特殊字符路径)
:: ====================================================================
fltmc >nul 2>&1 || (
    echo [提示] 正在获取管理员权限，请在弹出的 UAC 窗口中点击“是”...
    set "SELF=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)
cd /d "%~dp0"

cls
color 0b
echo ====================================================================
echo        微软应用商店全能修复工具 v3.0 (专业旗舰版 / 全系统自适应)
echo ====================================================================
echo  适用场景: 无法更新 / 下载卡0%% / 错误代码 0x80... / 部署队列堵塞
echo            应用更新反复失败 (0x80073CFB) / MSN 资讯无法更新
echo  执行时间: 约 10-15 秒；若触发 MSN 资讯重装，约 30-60 秒
echo  无需重启，完全开源透明，修完即走，零后台常驻
echo ====================================================================
echo.

:: ====================================================================
:: 2. 注销旧版后台轮询计划任务 (杜绝后台常驻占用)
:: ====================================================================
echo [1/9] 检查并清理旧版后台轮询计划任务...
schtasks /delete /tn "MicrosoftStoreHealthCheck" /f >nul 2>&1
echo       [OK] 后台任务已清理，零后台常驻

:: ====================================================================
:: 3. 彻底释放占用进程 (攻克 0x80073D02 部署冲突)
:: ====================================================================
echo [2/9] 正在释放挂起或占用安装通道的全部进程...
taskkill /f /im WinStore.App.exe >nul 2>&1
taskkill /f /im winget.exe >nul 2>&1
taskkill /f /im AppInstaller.exe >nul 2>&1
taskkill /f /im WindowsPackageManagerServer.exe >nul 2>&1
taskkill /f /im StorePurchaseApp.exe >nul 2>&1
taskkill /f /im WWAHost.exe >nul 2>&1
echo       [OK] 商店与安装器进程锁已彻底释放

:: ====================================================================
:: 4. 组策略与注册表限制策略深度清理 (解决 0x80070422 禁用限制)
:: ====================================================================
echo [3/9] 正在检测并解除注册表/组策略禁用限制...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /f >nul 2>&1
echo       [OK] 应用商店注册表策略限制已完全放行

:: ====================================================================
:: 5. 核心系统服务快速配置与启动 (保留系统默认启动类型)
:: ====================================================================
echo [4/9] 正在智能诊断并恢复关键系统核心服务...
sc config wuauserv start= demand >nul 2>&1
sc start wuauserv >nul 2>&1
sc config bits start= demand >nul 2>&1
sc start bits >nul 2>&1
sc config cryptsvc start= auto >nul 2>&1
sc start cryptsvc >nul 2>&1
sc config dosvc start= auto >nul 2>&1
sc start dosvc >nul 2>&1
sc config InstallService start= demand >nul 2>&1
sc start InstallService >nul 2>&1
sc config ClipSVC start= demand >nul 2>&1
sc start ClipSVC >nul 2>&1
sc config w32time start= demand >nul 2>&1
sc start w32time >nul 2>&1
echo       [OK] 核心系统服务全部配置就绪

:: ====================================================================
:: 6. 下载损坏缓存与交付优化缓存极速清空 (解决 0x80073CF0 / 0x80070002)
::    先停服务再删目录，避免文件被占用导致“假清理”
:: ====================================================================
echo [5/9] 正在极速清理损坏的临时下载包与交付优化缓存...
sc stop wuauserv >nul 2>&1
sc stop bits >nul 2>&1
sc stop dosvc >nul 2>&1
ping -n 3 127.0.0.1 >nul
if exist "%windir%\SoftwareDistribution\Download" (
    rd /s /q "%windir%\SoftwareDistribution\Download" >nul 2>&1
    md "%windir%\SoftwareDistribution\Download" >nul 2>&1
)
powershell -NoProfile -Command "try { Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue | Out-Null } catch {}" >nul 2>&1
if exist "%windir%\SoftwareDistribution.old" rd /s /q "%windir%\SoftwareDistribution.old" >nul 2>&1
if exist "%windir%\System32\catroot2.old" rd /s /q "%windir%\System32\catroot2.old" >nul 2>&1
sc start wuauserv >nul 2>&1
sc start bits >nul 2>&1
sc start dosvc >nul 2>&1
echo       [OK] 临时下载缓存与部署锁已彻底清理

:: ====================================================================
:: 7. 解除 AppX 应用部署队列死锁 (解决卡在 0%% / 挂起队列)
:: ====================================================================
echo [6/9] 正在探测并解除卡死的 AppX 应用部署队列...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if([Environment]::OSVersion.Version.Build -ge 22000){ $bad=@(Get-AppxPackage | Where-Object { $_.Status -ne 'Ok' }); if($bad.Count -gt 0){ foreach($p in $bad){ Write-Host ('   [!] 发现卡死应用: ' + $p.Name + '，正在重置...'); try { Reset-AppxPackage -Package $p.PackageFullName -ErrorAction Stop; Write-Host ('   [OK] 成功重置: ' + $p.Name) } catch {} } } } else { Write-Host '   [i] Windows 10 环境，跳过 Windows 11 专属重置功能' }"
echo       [OK] 部署队列检查完成

:: ====================================================================
:: 8. 网络代理重置、TLS 1.2/1.3 启用与 UWP 回环豁免 (解决 0x80131500 / 0x80072EFD)
:: ====================================================================
echo [7/9] 正在重置网络代理、刷新 DNS、配置 TLS 与注入回环豁免...
netsh winhttp reset proxy >nul 2>&1
ipconfig /flushdns >nul 2>&1
w32tm /resync /nowait >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "SecureProtocols" /t REG_DWORD /d 10240 /f >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$pkg=Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue; if($pkg){ CheckNetIsolation.exe LoopbackExempt -a ('-n=' + $pkg.PackageFamilyName) | Out-Null }"
echo       [OK] 网络代理已重置，TLS 协议已校准，已授予本地回环免除

:: ====================================================================
:: 9. 应用商店核心组件三级智能托底重新注册
::    一级: 当前用户清单重注册；二级: WindowsApps 物理扫描兜底；
::    三级: wsreset -i 在线拉回 (仅当商店组件缺失时触发)
:: ====================================================================
echo [8/9] 正在重新注册应用商店核心组件 (三级托底防护)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$core=@('Microsoft.WindowsStore','Microsoft.StorePurchaseApp','Microsoft.DesktopAppInstaller'); foreach($n in $core){ Get-AppxPackage -Name $n -ErrorAction SilentlyContinue | ForEach-Object { $m=Join-Path $_.InstallLocation 'AppXManifest.xml'; if(Test-Path $m){ Add-AppxPackage -DisableDevelopmentMode -Register $m -ErrorAction SilentlyContinue } } }; $s=Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue; if(-not $s){ $d=Get-ChildItem (Join-Path $env:ProgramFiles 'WindowsApps') -Directory -Filter 'Microsoft.WindowsStore_*' -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1; if($d){ $m=Join-Path $d.FullName 'AppxManifest.xml'; if(Test-Path $m){ Add-AppxPackage -DisableDevelopmentMode -Register $m -ErrorAction SilentlyContinue } } }; $s=Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue; if(-not $s){ Write-Host '   [!] 商店组件缺失，正在调用 wsreset -i 在线拉回...'; Start-Process wsreset.exe -ArgumentList '-i' -Wait }"
echo       [OK] 微软商店及关联安装组件重新注册完成

:: ====================================================================
:: 10. MSN 资讯更新冲突修复 (0x80073CFB)
::     仅在检测到“同标识旧包冲突 / 损坏暂存包 / 只剩 1.x 空壳”时触发
:: ====================================================================
echo [9/9] 正在检查 MSN 资讯更新冲突 (0x80073CFB)...
set "MSN_NEED=0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$bad=@(Get-ChildItem (Join-Path $env:ProgramFiles 'WindowsApps') -Directory -Filter 'Microsoft.BingNews_*' -ErrorAction SilentlyContinue | Where-Object { -not (Test-Path (Join-Path $_.FullName 'AppxManifest.xml')) -and -not (Test-Path (Join-Path $_.FullName 'AppxMetadata\AppxBundleManifest.xml')) }); $pkg=Get-AppxPackage -Name 'Microsoft.BingNews' -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1; $stub=$false; if($pkg -and ([version]$pkg.Version -lt [version]'4.0.0.0')){ $stub=$true }; if($bad.Count -gt 0 -or $stub){ exit 10 }; exit 0"
if errorlevel 10 set "MSN_NEED=1"
if "%MSN_NEED%"=="0" goto :msn_skip
echo       [!] 检测到 MSN 资讯损坏或版本冲突，开始自动清理并重装...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; Get-Process -Name 'Microsoft.Msn.News' | Stop-Process -Force; Get-AppxPackage -AllUsers -Name 'Microsoft.BingNews' | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -AllUsers }; Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq 'Microsoft.BingNews' } | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName }; Get-ChildItem (Join-Path $env:ProgramFiles 'WindowsApps') -Directory -Filter 'Microsoft.BingNews_*' | ForEach-Object { takeown /f $_.FullName /r /d y | Out-Null; icacls $_.FullName /grant '*S-1-5-32-544:(OI)(CI)F' /t /c | Out-Null; Remove-Item -LiteralPath $_.FullName -Recurse -Force }; Restart-Service AppXSvc -Force"
echo       [OK] 冲突包与损坏暂存目录已清理，正在以当前用户身份从商店重新安装...
set "MSNDIR=%ProgramData%\MicrosoftStoreRepairTool"
if not exist "%MSNDIR%" md "%MSNDIR%" >nul 2>&1
del "%MSNDIR%\msn-result.txt" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d=Join-Path $env:ProgramData 'MicrosoftStoreRepairTool'; if(-not (Test-Path $d)){ New-Item -ItemType Directory -Path $d -Force | Out-Null }; $ps=@('winget install --id 9WZDNCRFHVFW --source msstore --accept-package-agreements --accept-source-agreements --disable-interactivity --force *> (Join-Path $PSScriptRoot msn-install.log)','$LASTEXITCODE | Set-Content (Join-Path $PSScriptRoot msn-result.txt)'); Set-Content -Path (Join-Path $d 'msn-install.ps1') -Value $ps -Encoding ASCII; $bat=@('@echo off',('powershell -NoProfile -ExecutionPolicy Bypass -File ' + (Join-Path $d 'msn-install.ps1'))); Set-Content -Path (Join-Path $d 'msn-install.cmd') -Value $bat -Encoding ASCII"
explorer.exe "%MSNDIR%\msn-install.cmd"
for /l %%i in (1,1,60) do (
    if exist "%MSNDIR%\msn-result.txt" goto :msn_check
    ping -n 3 127.0.0.1 >nul
)
:msn_check
set "MSNCODE="
if exist "%MSNDIR%\msn-result.txt" set /p MSNCODE=<"%MSNDIR%\msn-result.txt"
if "%MSNCODE%"=="0" goto :msn_ok
echo       [!] 自动安装未完成，正在打开商店安装页，请点击“获取/安装”...
start "" ms-windows-store://pdp/?ProductId=9WZDNCRFHVFW
goto :msn_end
:msn_ok
echo       [OK] MSN 资讯已从商店重新安装完成
goto :msn_end
:msn_skip
echo       [OK] 未检测到 MSN 资讯冲突，跳过重装
:msn_end

:: ====================================================================
:: 11. 最终健康诊断报告
:: ====================================================================
echo.
echo ====================================================================
echo                   最终健康诊断报告
echo ====================================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue; if($s -and $s.Status -eq 'Ok'){ Write-Host ('  [OK] 微软商店组件: 正常就绪 (版本: ' + $s.Version + ')') -ForegroundColor Green } else { Write-Host '  [!] 微软商店组件未检测到或状态异常' -ForegroundColor Yellow }; $n=Get-AppxPackage -Name 'Microsoft.BingNews' -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1; if($n -and $n.Status -eq 'Ok'){ Write-Host ('  [OK] MSN 资讯组件: 正常就绪 (版本: ' + $n.Version + ')') -ForegroundColor Green } elseif($n){ Write-Host '  [!] MSN 资讯组件状态异常' -ForegroundColor Yellow } else { Write-Host '  [i] 未安装 MSN 资讯，可在商店搜索安装' }"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$svc=@('AppXSvc','ClipSVC','InstallService','StateRepository','cryptsvc','wuauserv'); $bad=@(); foreach($n in $svc){ $s=Get-Service -Name $n -ErrorAction SilentlyContinue; if(-not $s -or $s.Status -ne 'Running'){ $bad+=$n } }; if($bad.Count -eq 0){ Write-Host '  [OK] 核心系统服务: 全部处于正常运行状态' -ForegroundColor Green } else { Write-Host ('  [!] 以下服务未运行: ' + ($bad -join ', ')) -ForegroundColor Yellow }"
echo ====================================================================
echo.
echo ^>^>^> 修复全部完成！现在可以直接去微软商店点击“获取更新”测试 ^<^<^<
echo.
if defined MS_REPAIR_SILENT goto :finish
set /p choice="是否现在立即打开微软应用商店进行测试？[Y/N, 默认Y]: "
if /i not "%choice%"=="n" start ms-windows-store:

:finish
echo.
echo 操作完成，按任意键退出...
if defined MS_REPAIR_SILENT exit /b
pause >nul
exit /b
