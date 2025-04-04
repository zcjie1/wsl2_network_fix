#Requires -RunAsAdministrator

param(
    [string]$ServiceName = "WSL2 Network Fix Service",
    [string]$EventSource = "WSL2 Network Fix Service",
    [string]$ProjectPath = ".\"
)

# 错误处理设置
$ErrorActionPreference = "Stop"

try {
    # 规范化路径为绝对路径
    $ProjectPath = Resolve-Path $ProjectPath
    $PublishDir = Join-Path $ProjectPath "build\publish"

    # 卸载旧版本服务
    & ".\scripts\uninstall.ps1"

    Start-Sleep -Seconds 1

    if(Test-Path $PublishDir) {
        Remove-Item $PublishDir -Recurse -Force
        Write-Output "构建目录已成功删除：$PublishDir"
    }
    
    # 验证项目文件
    $csprojPath = Join-Path $ProjectPath "wsl2_network_fix.csproj"
    if (-not (Test-Path $csprojPath)) {
        throw "项目文件未找到: $csprojPath"
    }

    # 1. 编译发布项目
    Write-Host "正在编译项目..." -ForegroundColor Cyan
    dotnet publish $ProjectPath -c Release -o $PublishDir --runtime win-x64 --self-contained true /p:PublishSingleFile=true

    # 2. 创建事件日志源
    Write-Host "配置事件日志源..." -ForegroundColor Cyan
    if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
        New-EventLog -LogName Application -Source $EventSource
        Write-Host "已创建事件日志源: $EventSource" -ForegroundColor Green
    } else {
        Write-Host "事件日志源已存在: $EventSource" -ForegroundColor Yellow
    }

    # 3. 停止并删除旧服务
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "发现现有服务，正在停止并删除..." -ForegroundColor Yellow
        sc.exe stop $ServiceName
        Start-Sleep -Seconds 2
        sc.exe delete $ServiceName
    }

    # 4. 安装服务
    Write-Host "正在安装Windows服务..." -ForegroundColor Cyan
    $exePath = Join-Path $PublishDir "wsl2_network_fix.exe"
    sc.exe create $ServiceName binPath= `"$exePath`" start= auto
    sc.exe failure $ServiceName reset= 86400 actions= restart/5000
    sc.exe description $ServiceName "获取Npcap回环设备句柄，解决镜像网络中WSL2与主机无法相互访问的问题"

    # 5. 启动服务
    Write-Host "启动服务..." -ForegroundColor Cyan
    sc.exe start $ServiceName

    # 验证安装
    Start-Sleep -Seconds 2
    $service = Get-Service $ServiceName
    if ($service.Status -eq 'Running') {
        Write-Host "`n安装成功! 服务状态：" -ForegroundColor Green
        Get-Service $ServiceName | Format-List Name, Status, DisplayName, StartType
    } else {
        Write-Host "`n服务未成功启动，请检查事件日志" -ForegroundColor Red
    }

    # 显示日志查看命令
    Write-Host "`n查看日志命令：" -ForegroundColor Cyan
    Write-Host "Get-EventLog -LogName Application -Source `"$EventSource`" -Newest 10 | Format-List"
}
catch {
    Write-Host "`n安装失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
