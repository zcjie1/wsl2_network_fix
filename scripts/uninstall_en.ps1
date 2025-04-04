#Requires -RunAsAdministrator

param(
    [string]$ServiceName = "WSL2 Network Fix Service",
    [string]$EventSource = "WSL2 Network Fix Service"
)

try {
    # Stop and delete the service
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Stopping and deleting the service..." -ForegroundColor Cyan
        sc.exe stop $ServiceName
        sc.exe delete $ServiceName
    }

    # Delete the event log source
    if ([System.Diagnostics.EventLog]::SourceExists($EventSource)) {
        Write-Host "Removing the event log source..." -ForegroundColor Cyan
        [System.Diagnostics.EventLog]::DeleteEventSource($EventSource)
    }

    Write-Host "`nUninstallation completed" -ForegroundColor Green
}
catch {
    Write-Host "`nUninstallation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}