# WSL Network Fix Service

## English Version

### Introduction
Windows Service for automatically fixing WSL2 network connectivity issues.  
Reference: [microsoft/WSL#11600](https://github.com/microsoft/WSL/issues/11600), [microsoft/WSL#12399](https://github.com/microsoft/WSL/issues/12399), [microsoft/WSL#12303](https://github.com/microsoft/WSL/issues/12303)

### How It Works
Maintains WSL2 network by acquiring Npcap device handles (no actual data processing)

### Installation 

- Requires [NPcap](https://npcap.com/) installed  
- With .NET runtime → Run `.\scripts\install.ps1`
- Without .NET → Run `.\scripts\no_compile_install.ps1` (pre-built x86_64 version)

#### Tips
1. Do not execute scripts from within the scripts directory
2. All operations require PowerShell with Administrator privileges

### Script Reference
| Script | Function |
|--------|----------|
| install.ps1 | Standard installation (.NET required) |
| no_compile_install.ps1 | Pre-compiled installation |
| uninstall.ps1 | Uninstall service |
| install_en.ps1 | English version installer |
| uninstall_en.ps1 | English version uninstaller |

---

## 中文版

### 简介
Windows 服务程序，用于自动修复 WSL2 网络连接问题。  
参考：[microsoft/WSL#11600](https://github.com/microsoft/WSL/issues/11600), [microsoft/WSL#12399](https://github.com/microsoft/WSL/issues/12399), [microsoft/WSL#12303](https://github.com/microsoft/WSL/issues/12303)

### 工作原理
通过获取 Npcap 设备句柄信息来维持 WSL2 网络连接（无实际数据操作）

### 安装指南

- 需要预先安装 [NPcap](https://npcap.com/)
- 已安装 .NET 运行时环境 → 运行 `.\scripts\install.ps1`
- 无 .NET 环境 → 运行 `.\scripts\no_compile_install.ps1`（使用预编译x86_64版本）

#### Tips
1. 请勿进入 scripts 目录内执行脚本
2. 所有操作需在管理员权限的 PowerShell 中完成

### 脚本说明
| 脚本文件 | 功能 |
|---------|------|
| install.ps1 | 标准安装（需.NET环境） |
| no_compile_install.ps1 | 免编译安装（预编译版） |
| uninstall.ps1 | 卸载服务 |
| install_en.ps1 | 英文版安装脚本 |
| uninstall_en.ps1 | 英文版卸载脚本 |

