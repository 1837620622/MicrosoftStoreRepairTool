# 微软应用商店全能修复工具 (Microsoft Store Pro Auto-Repair Tool)

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-x64%20%7C%20ARM64-brightgreen)
![Speed](https://img.shields.io/badge/Execution%20Time-10--15s-success)
![License](https://img.shields.io/badge/License-MIT-blue)

专为 Windows 10 / Windows 11 设计的专业级微软应用商店（Microsoft Store）一键式深度自适应修复工具。  
**单文件双击即修，无需重启电脑，无需等待 30 分钟，零后台常驻，全系统自适应。**

---

## 🌟 核心特性

- 🚀 **极速修复（10 ~ 15 秒）**：抛弃传统 DISM/SFC 动辄半小时的冗长扫描，针对性直击微软应用商店更新、下载与网络故障的核心病灶。
- 🖥️ **跨版本智能自适应**：自动探测 Windows 10 / Windows 11 版本（21H2、22H2、23H2、24H2 等）及硬件架构（AMD64 / ARM64），自动适配最佳修复策略。
- 🚫 **零后台常驻**：彻底清除任何遗留的后台轮询计划任务，随用随开，用完即退，绝不占用系统任何资源。
- 🛡️ **彻底杜绝 0x80073D02 冲突**：全量释放 `WinStore.App`、`winget`、`AppInstaller`、`StorePurchaseApp`、`WWAHost` 等关联安装进程锁。
- 🔓 **组策略与注册表自动解封**：自动清除第三方优化软件或域策略残留的 `RemoveWindowsStore`、`DisableStoreApps` 等策略，解决 `0x80070422` 错误。
- 🌐 **双重网络修复 + UWP 回环豁免**：
  - 重置系统底层 WinHTTP 代理为直连，刷新 DNS 缓存；
  - 强制校准现代安全协议 **TLS 1.2 / TLS 1.3**；
  - 自动通过 `CheckNetIsolation` 为微软商店注入本地网络回环豁免（Loopback Exempt），彻底根治使用代理/加速工具时出现的 `0x80131500` / `0x80072EFD`。
- 🧩 **三级智能托底重新注册**：
  - **一级**：当前用户环境精准重注册；
  - **二级**：扫描 `WindowsApps` 物理目录清单文件进行装载；
  - **三级**：自动调用系统原生 `wsreset.exe -i` 在线拉回缺失组件（即使商店被误删也能复活）。

---

## 📋 常见错误代码对照与修复原理

| 错误代码 | 常见诱因 | 本工具修复方案 |
| :--- | :--- | :--- |
| **0x80073CF0 / 0x80070002** | 下载损坏包阻塞、更新缓存异常 | 清空 `SoftwareDistribution\Download` 损坏包，释放文件锁 |
| **0x80073D02** | 部署冲突（后台进程正在占用安装器） | 彻底终止 `AppInstaller`、`WindowsPackageManagerServer` 等进程 |
| **0x803F8001** | 客户端许可证服务未启动或授权异常 | 自动校准并拉起 `ClipSVC` 许可证服务，重置商店应用包 |
| **0x80070422** | Windows Update / 商店核心服务被禁用 | 自动修正 `wuauserv`、`bits`、`InstallService` 启动类型并激活 |
| **0x80131500 / 0x80072EFD** | 本地代理冲突、UWP沙盒隔离、TLS失准 | 注入 `CheckNetIsolation` 回环豁免，重置代理并激活 TLS 1.2/1.3 |
| **0x8024402C** | DNS 污染或网络解析失败 | 自动执行系统网络协议栈复位并强行刷新 DNS 缓存 |
| **卡在 0% / 挂起** | 某个包卡在 `DeploymentInProgress` 死锁 | 探测卡阻队列并自动调用 `Reset-AppxPackage` 解锁管道 |

---

## 🚀 使用指南

### 方式一：本机使用
1. 直接双击运行桌面上或目录下的 **`一键修复微软商店.cmd`**；
2. 在弹出的“用户账户控制 (UAC)”窗口中点击**“是”**；
3. 控制台将在 **10 ~ 15 秒**内全自动完成系统检测与深度修复；
4. 修复完成后根据提示按**回车键**，将自动打开微软应用商店进行下载测试。

### 方式二：在其他受损电脑上使用（便携运行）
直接将 `一键修复微软商店.cmd` 拷贝到 U 盘或通过聊天软件发送到有问题的其他电脑上，双击运行即可，脚本会自动识别新电脑的系统并执行对应修复。

---

## ⚙️ 技术架构

- **外壳层**：采用 100% 纯 ASCII 语法编写的 `.cmd` 引导器，具备自动管理员权限检测与 UAC 自提权机制，彻底避免 `cmd.exe` 在多语言代码页环境下的编码与特殊字符转义陷阱。
- **核心引擎**：采用 Base64 打包的安全 PowerShell 逻辑，具备完善的异步异常捕获（`try-catch`）与超时防卡死设计，保证各环节在任何系统上均能顺畅退出。

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。欢迎 Star、Fork 与提 Issue！