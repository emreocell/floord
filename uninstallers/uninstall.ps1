$ErrorActionPreference = "Stop"

# Floord uninstaller for Windows.
# Paths and task name match installers/install.ps1.

$TaskName = "Floord"

$InstallDir = Join-Path $env:LOCALAPPDATA "Floord"
$ConfigDir = Join-Path $env:APPDATA "floord"

# ==========================================
# STOP AND REMOVE SCHEDULED TASK
# ==========================================

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Write-Host "Stopping and removing Floord startup task..." -ForegroundColor Cyan

    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}
else {
    Write-Host "Startup task not found, skipping." -ForegroundColor Yellow
}

# ==========================================
# STOP RUNNING PROCESS
# ==========================================

$Processes = Get-Process -Name "floord" -ErrorAction SilentlyContinue

if ($Processes) {
    Write-Host "Stopping Floord process..." -ForegroundColor Cyan

    $Processes | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# ==========================================
# REMOVE BINARY AND INSTALL FOLDER
# ==========================================

if (Test-Path $InstallDir) {
    Write-Host "Removing $InstallDir..." -ForegroundColor Cyan
    Remove-Item -Path $InstallDir -Recurse -Force
}
else {
    Write-Host "Install folder not found, skipping." -ForegroundColor Yellow
}

# ==========================================
# REMOVE CONFIGURATION
# ==========================================

if (Test-Path $ConfigDir) {
    Write-Host "Removing $ConfigDir..." -ForegroundColor Cyan
    Remove-Item -Path $ConfigDir -Recurse -Force
}
else {
    Write-Host "Config folder not found, skipping." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Floord has been uninstalled." -ForegroundColor Green
