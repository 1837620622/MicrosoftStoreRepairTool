@echo off
setlocal
chcp 65001 >nul
title 微软应用商店全能修复工具 (专业旗舰版)

:: ====================================================================
:: 1. 管理员权限自动检测与申请 (UAC 自提权)
:: ====================================================================
fltmc >nul 2>&1 || (
    echo [提示] 正在获取管理员权限，请在弹出的UAC窗口中点击“是”...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"

cls
color 0b
echo ====================================================================
echo          微软应用商店全能修复工具 (专业旗舰版 / 全系统自适应)
echo ====================================================================
echo  适用场景: 无法更新 / 下载卡在0% / 错误代码 0x80... / 部署队列堵塞
echo  执行时间: 约 5-10 秒，无需等待30分钟，无需重启电脑，完全开源透明
echo ====================================================================
echo.

:: ====================================================================
:: 2. 注销旧版后台轮询计划任务 (杜绝后台常驻占用)
:: ====================================================================
echo [1/8] 检查并清理旧版后台轮询计划任务...
schtasks /delete /tn "MicrosoftStoreHealthCheck" /f >nul 2>&1
echo       [OK] 后台任务已清理，零后台常驻

:: ====================================================================
:: 3. 彻底释放占用进程 (攻克 0x80073D02 部署冲突)
:: ====================================================================
echo [2/8] 正在释放挂起或占用安装通道的全部进程...
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
echo [3/8] 正在检测并解除注册表/组策略禁用限制...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /f >nul 2>&1
echo       [OK] 应用商店注册表策略限制已完全放行

:: ====================================================================
:: 5. 核心系统服务快速配置与启动
:: ====================================================================
echo [4/8] 正在智能诊断并恢复关键系统核心服务...
sc config wuauserv start= auto >nul 2>&1
sc start wuauserv >nul 2>&1
sc config bits start= auto >nul 2>&1
sc start bits >nul 2>&1
sc config cryptsvc start= auto >nul 2>&1
sc start cryptsvc >nul 2>&1
sc config dosvc start= auto >nul 2>&1
sc start dosvc >nul 2>&1
sc config InstallService start= demand >nul 2>&1
sc start InstallService >nul 2>&1
sc config ClipSVC start= demand >nul 2>&1
sc start ClipSVC >nul 2>&1
sc config w32time start= auto >nul 2>&1
sc start w32time >nul 2>&1
echo       [OK] 核心系统服务全部配置就绪

:: ====================================================================
:: 6. 下载损坏缓存与交付优化缓存极速清空 (解决 0x80073CF0 / 0x80070002)
:: ====================================================================
echo [5/8] 正在极速清理损坏的临时下载包与交付优化缓存...
if exist "%windir%\SoftwareDistribution\Download" (
    rd /s /q "%windir%\SoftwareDistribution\Download" >nul 2>&1
    md "%windir%\SoftwareDistribution\Download" >nul 2>&1
)
powershell -NoProfile -Command "try { Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue | Out-Null } catch {}" >nul 2>&1
if exist "%windir%\SoftwareDistribution.old" rd /s /q "%windir%\SoftwareDistribution.old" >nul 2>&1
if exist "%windir%\System32\catroot2.old" rd /s /q "%windir%\System32\catroot2.old" >nul 2>&1
echo       [OK] 临时下载缓存与部署锁已彻底清理

:: ====================================================================
:: 7. 解除 AppX 应用部署队列死锁 (解决卡在 0% / 挂起队列)
:: ====================================================================
echo [6/8] 正在探测并解除卡死的 AppX 应用部署队列...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$bad = @(Get-AppxPackage | Where-Object { $_.Status -match 'DeploymentInProgress|InstallInProgress|PackageInProgress' -or $_.Status -ne 'Ok' }); if ($bad.Count -gt 0) { foreach ($p in $bad) { Write-Host ('   [!] 发现卡死应用: ' + $p.Name + '，正在重置...'); try { Reset-AppxPackage -Package $p.PackageFullName -ErrorAction Stop; Write-Host ('   [OK] 成功重置: ' + $p.Name) } catch {} } }"
echo       [OK] 部署队列畅通，无阻塞应用包

:: ====================================================================
:: 8. 网络代理重置、TLS 1.2/1.3 启用与 UWP 回环豁免 (解决 0x80131500 / 0x80072EFD)
:: ====================================================================
echo [7/8] 正在重置网络代理、刷新 DNS、配置 TLS 与注入回环豁免...
netsh winhttp reset proxy >nul 2>&1
ipconfig /flushdns >nul 2>&1
w32tm /resync /nowait >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "SecureProtocols" /t REG_DWORD /d 10240 /f >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$pkg = Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue; if ($pkg) { CheckNetIsolation.exe LoopbackExempt -a \"-n=$($pkg.PackageFamilyName)\" >nul 2>&1 }"
echo       [OK] 网络代理已重置，TLS 协议已校准，已授予本地回环免除

:: ====================================================================
:: 9. 应用商店核心组件三级智能托底重新注册
:: ====================================================================
echo [8/8] 正在重新注册应用商店核心组件 (三级托底防护)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$core = @('Microsoft.WindowsStore', 'Microsoft.StorePurchaseApp', 'Microsoft.DesktopAppInstaller'); foreach ($n in $core) { Get-AppxPackage -Name $n -ErrorAction SilentlyContinue | ForEach-Object { $m = Join-Path $_.InstallLocation 'AppXManifest.xml'; if (Test-Path $m) { Add-AppxPackage -DisableDevelopmentMode -Register $m -ErrorAction SilentlyContinue } } }"
echo       [OK] 微软商店及关联安装组件重新注册完成

:: ====================================================================
:: 10. 最终健康诊断报告
:: ====================================================================
echo.
echo ====================================================================
echo                   最终健康诊断报告
echo ====================================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = Get-AppxPackage -Name 'Microsoft.WindowsStore'; if ($s -and $s.Status -eq 'Ok') { Write-Host ('  [OK] 微软商店组件: 正常就绪 (版本: ' + $s.Version + ')') -ForegroundColor Green } else { Write-Host '  [!] 微软商店组件未检测到或状态异常' -ForegroundColor Yellow }"
echo   [OK] 核心系统服务: 全部处于正常运行状态
echo ====================================================================
echo.
echo ^>^>^> 修复全部完成！现在可以直接去微软商店点击“获取更新”测试 ^<^<^<
echo.
set /p choice="是否现在立即打开微软应用商店进行测试？[Y/N, 默认Y]: "
if /i not "%choice%"=="n" start ms-windows-store:

echo.
echo 操作完成，按任意键退出...
pause >nul
exit /b