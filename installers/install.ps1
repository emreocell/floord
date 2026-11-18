$ErrorActionPreference = "Stop"

# ==========================================
# CONFIGURATION
# ==========================================

$Repo = "polete-bermejo/floord"
$TaskName = "Floord"

$InstallDir = Join-Path $env:LOCALAPPDATA "Floord"
$AppExe = Join-Path $InstallDir "floord.exe"

$ConfigDir = Join-Path $env:APPDATA "floord"
$ConfigFile = Join-Path $ConfigDir "config.toml"

$AppArgs = "--config `"$ConfigFile`""

# ==========================================
# DOWNLOAD LATEST RELEASE
# ==========================================

Write-Host "Downloading latest Floord release..." -ForegroundColor Cyan

$Release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Repo/releases/latest"

$Asset = $Release.assets |
    Where-Object { $_.name -eq "floord-windows.exe" } |
    Select-Object -First 1

if (-not $Asset) {
    throw "Windows executable not found in latest GitHub Release."
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$TempExe = Join-Path $InstallDir "floord-update.tmp.exe"

Invoke-WebRequest `
    -Uri $Asset.browser_download_url `
    -OutFile $TempExe

if (!(Test-Path $TempExe)) {
    throw "Floord executable download failed."
}

Write-Host "Downloaded version: $($Release.tag_name)" -ForegroundColor Green

# ==========================================
# STOP PREVIOUS INSTANCE
# ==========================================

$ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($ExistingTask) {
    Write-Host "Stopping existing Floord task..." -ForegroundColor Cyan

    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
}

Get-Process -Name "floord" -ErrorAction SilentlyContinue |
    Stop-Process -Force

Start-Sleep -Seconds 2

# ==========================================
# INSTALL BINARY
# ==========================================

Write-Host "Installing Floord..." -ForegroundColor Cyan

Move-Item -Path $TempExe -Destination $AppExe -Force

# ==========================================
# CREATE CONFIGURATION
# ==========================================

if (!(Test-Path $ConfigFile)) {

    Write-Host "Creating Floord configuration..." -ForegroundColor Cyan

    New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

@'
# Floor Daemon configuration

# General settings
daemon = true

# ==========================================
# ORGANIZER
# ==========================================

organizer = true

# inbox = "C:/Users/user/Downloads"
delay = 300


# ==========================================
# CLEANUP
# ==========================================

cleanup = true

# Directories to clean
paths = []

# Time in days before moving files to SoonDeleted
span = 30

# Additional days before permanent deletion
grace = 7

# Allow permanent deletion
allow_deletion = false
'@ | Set-Content -Path $ConfigFile -Encoding UTF8
}

# ==========================================
# CREATE SCHEDULED TASK
# ==========================================

Write-Host "Creating Floord startup task..." -ForegroundColor Cyan

$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name

$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -Command `"Start-Process -FilePath '$AppExe' -ArgumentList '$AppArgs' -WorkingDirectory '$InstallDir' -WindowStyle Hidden`""

$Trigger = New-ScheduledTaskTrigger `
    -AtLogOn `
    -User $CurrentUser

$Settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Description "Floord background file organizer" `
    -User $CurrentUser `
    -RunLevel Limited `
    -Force | Out-Null

# ==========================================
# INITIALIZE FLOORD
# ==========================================

Write-Host "Starting Floord..." -ForegroundColor Cyan

Start-ScheduledTask -TaskName $TaskName

Start-Sleep -Seconds 2

# ==========================================
# VERIFY INSTALLATION
# ==========================================

$Task = Get-ScheduledTask -TaskName $TaskName

Write-Host ""
Write-Host "Floord installed and initialized successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Version:      $($Release.tag_name)"
Write-Host "User:         $CurrentUser"
Write-Host "Directory:    $InstallDir"
Write-Host "Config:       $ConfigFile"
Write-Host "Task:         $TaskName"
Write-Host "Task state:   $($Task.State)"
Write-Host ""
Write-Host "Floord will automatically start when you log in."
