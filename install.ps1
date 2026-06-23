# HongiLauncher installer
# irm https://raw.githubusercontent.com/lightsound23-hongi/hongi-launcher/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$InstallDir = "$env:LOCALAPPDATA\Programs\HongiLauncher"
$ExePath = "$InstallDir\HongiLauncher.exe"

Write-Host "Stopping existing HongiLauncher processes..."
Get-Process -Name "HongiLauncher" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 500

Write-Host "Removing old installation..."
if (Test-Path $InstallDir) { Remove-Item -Recurse -Force $InstallDir }

$StartMenuShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\HongiLauncher.lnk"
$DesktopShortcut   = "$env:USERPROFILE\Desktop\HongiLauncher.lnk"
if (Test-Path $StartMenuShortcut) { Remove-Item -Force $StartMenuShortcut }
if (Test-Path $DesktopShortcut)   { Remove-Item -Force $DesktopShortcut }

Write-Host "Installing HongiLauncher..."

# Get latest release URL
$api = "https://api.github.com/repos/lightsound23-hongi/hongi-launcher/releases/latest"
$release = Invoke-RestMethod -Uri $api -UseBasicParsing
$asset = $release.assets | Where-Object { $_.name -eq "HongiLauncher.exe" } | Select-Object -First 1

if (-not $asset) {
    Write-Host "ERROR: Could not find HongiLauncher.exe in latest release"
    exit 1
}

# Download
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Write-Host "Downloading from $($asset.browser_download_url)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $ExePath -UseBasicParsing

# Create Start Menu shortcut with Ctrl+Alt+H hotkey
$ShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\HongiLauncher.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $ExePath
$Shortcut.HotKey = "Ctrl+Alt+H"
$Shortcut.Description = "HONGI SSH Launcher"
$Shortcut.Save()

# Also create Desktop shortcut
$DesktopShortcut = "$env:USERPROFILE\Desktop\HongiLauncher.lnk"
$DS = $WshShell.CreateShortcut($DesktopShortcut)
$DS.TargetPath = $ExePath
$DS.HotKey = "Ctrl+Alt+H"
$DS.Description = "HONGI SSH Launcher"
$DS.Save()

Write-Host "Done. HongiLauncher installed at $ExePath"
Write-Host "Shortcut: Ctrl+Alt+H (Start Menu shortcut)"
Write-Host "Run now? (Press Enter to launch)"
$null = Read-Host
Start-Process $ExePath
