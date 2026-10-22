@echo off
chcp 65001 >nul
title 发布微软商城修复工具到 GitHub
cd /d "%~dp0"

echo ====================================================================
echo             微软应用商店修复工具 - 一键发布到 GitHub
echo ====================================================================
echo.

"C:\Program Files\GitHub CLI\bin\gh.exe" auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 检测到您尚未登录 GitHub 账号。
    echo 正在调起浏览器进行网页一键授权登录，请在弹出的浏览器中确认登录...
    echo.
    "C:\Program Files\GitHub CLI\bin\gh.exe" auth login -w -p https
)

echo.
echo [1/2] 正在 GitHub 上创建公开仓库并关联远程源...
"C:\Program Files\GitHub CLI\bin\gh.exe" repo create MicrosoftStoreRepairTool --public --source=. --remote=origin --push

if %errorlevel% equ 0 (
    echo.
    echo ====================================================================
    echo   [√] 恭喜！项目已成功发布并推送到您的 GitHub！
    echo ====================================================================
) else (
    echo.
    echo [提示] 若仓库已存在，正在尝试直接推送到 origin master...
    git push -u origin master
)

echo.
echo 按任意键退出...
pause >nul