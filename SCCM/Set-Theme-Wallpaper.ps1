# Ensure the script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "This script must be run as Administrator."
    exit
}

# Variables
$defaultThemesDir = "C:\Users\Default\AppData\Local\Microsoft\Windows\Themes"
$defaultBackgroundDir = "C:\windows\WEB\wallpaper\Windows"
$themeFile = ".\YOUR_THEME.theme"
$newWallpaper = ".\img0.jpg"
$oldWallpaper = "$defaultBackgroundDir\img0.jpg"
$4kWallpaperDestination = "C:\Windows\Web\4K\Wallpaper\Windows"
$4kWallpaper = ".\4k\*.*"

# Ensure Default Themes Directory Exists
if (-not (Test-Path $defaultThemesDir)) {
    New-Item -ItemType Directory -Path $defaultThemesDir -Force | Out-Null
}

# Replace Default Wallpaper
if (Test-Path $oldWallpaper) {
    takeown /F $oldWallpaper /A | Out-Null
    icacls $oldWallpaper /grant administrators:F /T /C | Out-Null
    Remove-Item $oldWallpaper -Force
}
Copy-Item $newWallpaper -Destination $defaultBackgroundDir -Force

# Copy Theme Files
Copy-Item $themeFile -Destination "C:\Windows\resources\themes\BalwynHS.theme" -Force
Copy-Item $themeFile -Destination "$defaultThemesDir\oem.theme" -Force

# Copy 4k Wallpaper Pack
if (Test-Path $4kWallpaperDestination) {
    takeown /F $4kWallpaperDestination /A /R /D Y | Out-Null
    icacls $4kWallpaperDestination /grant administrators:F /T /C | Out-Null
    Remove-Item "$4kWallpaperDestination\*.*" -Force -ErrorAction SilentlyContinue
}
Copy-Item $4kWallpaper -Destination $4kWallpaperDestination -Force

Write-Output "Theme and wallpaper updated successfully."
