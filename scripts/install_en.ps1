#Requires -RunAsAdministrator

param(
    [string]$ServiceName = "WSL2 Network Fix Service",
    [string]$EventSource = "WSL2 Network Fix Service",
    [string]$ProjectPath = ".\"
)

# Error handling settings
$ErrorActionPreference = "Stop"

try {
    # Normalize path to absolute path
    $ProjectPath = Resolve-Path $ProjectPath
    $PublishDir = Join-Path $ProjectPath "build\publish"

    # Uninstall old version of the service
    & ".\scripts\uninstall.ps1"

    Start-Sleep -Seconds 1

    if (Test-Path $PublishDir) {
        Remove-Item $PublishDir -Recurse -Force
        Write-Output "Build directory successfully deleted: $PublishDir"
    }
    
    # Validate project file
    $csprojPath = Join-Path $ProjectPath "wsl2_network_fix.csproj"
    if (-not (Test-Path $csprojPath)) {
        throw "Project file not found: $csprojPath"
    }

    # 1. Build and publish the project
    Write-Host "Building the project..." -ForegroundColor Cyan
    dotnet publish $ProjectPath -c Release -o $PublishDir --runtime win-x64 --self-contained true /p:PublishSingleFile=true

    # 2. Create event log source
    Write-Host "Configuring event log source..." -ForegroundColor Cyan
    if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
        New-EventLog -LogName Application -Source $EventSource
        Write-Host "Event log source created: $EventSource" -ForegroundColor Green
    } else {
        Write-Host "Event log source already exists: $EventSource" -ForegroundColor Yellow
    }

    # 3. Stop and delete the old service
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Existing service detected, stopping and deleting..." -ForegroundColor Yellow
        sc.exe stop $ServiceName
        Start-Sleep -Seconds 2
        sc.exe delete $ServiceName
    }

    # 4. Install the service
    Write-Host "Installing Windows service..." -ForegroundColor Cyan
    $exePath = Join-Path $PublishDir "wsl2_network_fix.exe"
    sc.exe create $ServiceName binPath= `"$exePath`" start= auto
    sc.exe failure $ServiceName reset= 86400 actions= restart/5000
    sc.exe description $ServiceName "Obtain Npcap loopback device handle to resolve WSL2 host mutual access issues in mirrored networks."

    # 5. Start the service
    Write-Host "Starting the service..." -ForegroundColor Cyan
    sc.exe start $ServiceName

    # Verify installation
    Start-Sleep -Seconds 2
    $service = Get-Service $ServiceName
    if ($service.Status -eq 'Running') {
        Write-Host "`nInstallation successful! Service status:" -ForegroundColor Green
        Get-Service $ServiceName | Format-List Name, Status, DisplayName, StartType
    } else {
        Write-Host "`nService failed to start, please check the event logs" -ForegroundColor Red
    }

    # Display the command to view logs
    Write-Host "`nCommand to view logs:" -ForegroundColor Cyan
    Write-Host "Get-EventLog -LogName Application -Source `"$EventSource`" -Newest 10 | Format-List"
}
catch {
    Write-Host "`nInstallation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}