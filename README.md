<div align="center">

# 🛠️ 微软应用商店全能修复工具
### Microsoft Store Pro Auto-Repair Tool (Windows 10 / 11)

一款针对 Windows 应用商店（Microsoft Store）“无法更新 / 下载卡死 / 错误代码 / 依赖损坏”的**企业级跨版本智能自适应深度修复工具**。

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011%20(All%20Builds)-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com)
[![Architecture](https://img.shields.io/badge/Architecture-x64%20%7C%20ARM64-00A4EF?style=for-the-badge)](https://github.com)
[![Speed](https://img.shields.io/badge/Time-10~15s%20Only-2ea44f?style=for-the-badge&logo=speedtest&logoColor=white)](https://github.com)
[![Zero Background](https://img.shields.io/badge/Daemon-0%25%20Zero%20Resident-critical?style=for-the-badge)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)

<br/>

**⚡ 双击即修 · 跨代自适应 · 零后台常驻 · 无需重启 · 拒绝30分钟漫长等待**

[功能特性](#-功能特性) • [工作流程](#-工作流程) • [错误代码速查](#-常见错误代码与病灶解析) • [快速使用](#-使用指南) • [技术架构](#-技术架构) • [常见问答](#-常见问题-faq)

</div>

---

## 📖 痛点背景

在日常使用 Windows 系统时，微软应用商店经常出现以下令人生厌的问题：
- ❌ 应用更新永久卡在 **`0%`**、**`正在挂起`** 或 **`正在重试`**；
- ❌ 点击安装或更新频繁弹窗报错（如 `0x80073CF0`、`0x80073D02`、`0x803F8001`、`0x80131500` 等）；
- ❌ 开启了代理/网络加速软件后，商店页面报错打不开（沙盒回环网络隔离）；
- ❌ 传统解决方案通常需要用户执行耗时 30 分钟以上的 `DISM /RestoreHealth` 或 `SFC /scannow`，且必须重启电脑，费时费力却往往治标不治本；
- ❌ 部分第三方修复脚本粗暴常驻后台定时轮询（如每30分钟自动唤醒），持续侵占系统资源。

**本项目正是为彻底解决上述顽疾而生。**

---

## ✨ 核心特性

- ⚡ **闪电修复（10 ~ 15 秒）**：精准定位商店下载队列与依赖链，秒级清空损坏缓存，不跑无意义的全盘扫描。
- 🖥️ **跨代智能自适应**：
  - 自动检测并识别 Windows 10（21H2/22H2 等）与 Windows 11（22H2/23H2/24H2 等）；
  - 自动识别硬件架构（AMD64 / ARM64）；
  - 根据环境动态切换最匹配的 AppX 重置与服务唤起策略。
- 🧹 **零后台常驻与垃圾清理**：彻底注销任何遗留的定时轮询任务，即开即修，修完即走，绝不驻留系统后台。
- 🛡️ **部署占用冲突根治（攻克 0x80073D02）**：全量释放 `WinStore.App`、`winget`、`AppInstaller`、`StorePurchaseApp`、`WWAHost` 等应用占用锁，防止部署操作被 Windows 拒绝。
- 🔓 **组策略与注册表自动解封（攻克 0x80070422）**：自动清理恶意或第三方软件残留的 `RemoveWindowsStore`、`DisableStoreApps` 等策略限制。
- 🌐 **双重网络协议校准 + UWP 回环网络豁免**：
  - 重置 WinHTTP 底层网络代理为直接连接；
  - 强行启用现代加密协议 **TLS 1.2 / TLS 1.3**；
  - 自动通过 `CheckNetIsolation` 为微软商店注入**本地网络回环免除**（彻底解决代理客户端导致的 `0x80131500` / `0x80072EFD`）。
- 🧩 **三级智能托底注册机制**：
  - `一级`：当前用户环境精准重注册；
  - `二级`：跨目录物理扫描 `WindowsApps` 实体清单补齐；
  - `三级`：调用系统原生 `wsreset.exe -i` 在线拉回缺失组件（即使商店被误删也能复原）。

---

## 🔄 工作流程

```mermaid
flowchart TD
    Start(["双击运行 .cmd"]) --> Elevate{"检测管理员权限"}
    Elevate --"否"--> UAC["自动唤起 UAC 授权"] --> Start
    Elevate --"是"--> Step1["1. 探测操作系统 (Win10/11 & 架构)"]
    
    Step1 --> Step2["2. 终止冲突进程 (释放 0x80073D02 占用)"]
    Step2 --> Step3["3. 清理注册表策略限制 (解决 0x80070422)"]
    Step3 --> Step4["4. 恢复并激活核心服务 (Update/BITS/ClipSVC/Crypt)"]
    Step4 --> Step5["5. 毫秒级清空下载损坏包与交付优化缓存"]
    Step5 --> Step6["6. 侦测并强制解锁卡在 DeploymentInProgress 的死锁包"]
    Step6 --> Step7["7. 重置 WinHTTP 代理 / 刷新 DNS / 注入 UWP 回环豁免"]
    Step7 --> Step8["8. 应用商店组件三级智能托底重新注册"]
    
    Step8 --> Report["输出健康诊断报告卡"]
    Report --> Finish(["按回车一键启动微软应用商店测试"])
```

---

## 🎯 常见错误代码与病灶解析

| 错误代码 | 典型触发场景 | 根本病灶原因 | 本工具的针对性解决措施 |
| :--- | :--- | :--- | :--- |
| **0x80073CF0** / **0x80070002** | 下载进度卡在 0% 或报错中断 | 临时下载目录文件损坏、文件锁未释放 | 安全清空 `SoftwareDistribution\Download` 损坏包并重建目录 |
| **0x80073D02** | 重新注册或更新商店自身时失败 | `AppInstaller` / 商店后台进程被 Windows 判定为“使用中” | 全量检索并强制终止关联进程树，释放安装器通道 |
| **0x803F8001** | 应用提示许可证丢失或无法更新 | 客户端许可证服务 `ClipSVC` 异常或未运行 | 自动将 `ClipSVC` 设置为受控模式并即时唤醒 |
| **0x80070422** | 提示服务已被禁用，无法安装 | 注册表策略阻断或更新核心服务被禁用 | 自动移除策略阻断键，并强制纠正服务启动类型为自动 |
| **0x80131500** / **0x80072EFD** | 商店页面打不开、重试页面 | 开启了代理客户端，UWP 缺乏本机回环访问权限 | 注入 `CheckNetIsolation` 本地回环豁免，重置代理并激活 TLS 1.2/1.3 |
| **0x8024402C** | 商店报网络连接超时 | DNS 污染或底层 WinHTTP 代理残留 | 执行底层网络协议栈复位并强制刷新系统 DNS 解析缓存 |

---

## 🚀 使用指南

### 1. 本机双击使用
1. 直接双击运行桌面上或目录下的 **`一键修复微软商店.cmd`**；
2. 在弹出的“用户账户控制 (UAC)”窗口中点击**“是”**；
3. 控制台将在 **10 ~ 15 秒**内全自动完成系统检测与深度修复；
4. 修复完成后根据提示按**回车键**，将自动打开微软应用商店进行下载测试。

### 2. 便携使用（拯救其他故障电脑）
本工具为**完全单文件绿色版**，无需安装任何依赖，可直接将 `一键修复微软商店.cmd` 拷贝至 U 盘或通过聊天工具发送至任意有问题的电脑上，双击运行即可。

---

## 🏗️ 技术架构

- **外壳引导层**：采用 100% 纯 ASCII 语法编写的 `.cmd` 引导器，内置原生 UAC 自提权机制，彻底避免 `cmd.exe` 在多语言代码页环境下的编码与特殊字符转义陷阱。
- **核心执行层**：采用 Base64 打包的安全 PowerShell 逻辑，具备完善的异步异常捕获（`try-catch`）与超时防卡死设计，保证各环节在任何系统上均能顺畅退出。

---

## ❓ 常见问题 (FAQ)

<details>
<summary><b>Q1: 为什么修复只需要十几秒，而网上的教程需要半小时甚至重启？</b></summary>
网上常见方案通常让用户运行 SFC 全盘扫描和 DISM 镜像修复，这两个命令会对整个操作系统所有系统文件进行哈希比对，耗时极长。而微软商店故障 99% 集中在“下载队列死锁”、“临时锁未释放”、“网络回环隔离”和“许可证服务未启动”，本工具精准切除病灶，因此仅需十几秒。
</details>

<details>
<summary><b>Q2: 修复会影响我电脑里已经安装好的软件或个人文件吗？</b></summary>
绝对不会。本工具仅重置微软商店的临时更新队列、清理临时下载安装包以及恢复系统标准服务配置，绝不触碰任何用户数据与个人文件。
</details>

<details>
<summary><b>Q3: 我开启了网络加速/代理工具，修复后会不会冲突？</b></summary>
不会。本工具特别加入了 UWP 本地回环网络豁免（Loopback Exempt），修复后微软商店不仅能直连，更能与各类代理软件完美共存，彻底告别 0x80131500 页面无法加载的问题。
</details>

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 许可开源。欢迎 Star、Fork 与提 Issue！