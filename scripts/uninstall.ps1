#Requires -RunAsAdministrator

param(
    [string]$ServiceName = "WSL2 Network Fix Service",
    [string]$EventSource = "WSL2 Network Fix Service"
)

try {
    # 停止并删除服务
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "正在停止并删除服务..." -ForegroundColor Cyan
        sc.exe stop $ServiceName
        sc.exe delete $ServiceName
    }

    # 删除事件日志源
    if ([System.Diagnostics.EventLog]::SourceExists($EventSource)) {
        Write-Host "正在移除事件日志源..." -ForegroundColor Cyan
        [System.Diagnostics.EventLog]::DeleteEventSource($EventSource)
    }

    Write-Host "`n卸载完成" -ForegroundColor Green
}
catch {
    Write-Host "`n卸载失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
