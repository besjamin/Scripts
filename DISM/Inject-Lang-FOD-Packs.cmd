@echo off
setlocal


rem Set paths using environment variables
set "wimFile=%USERPROFILE%\Desktop\24H2\install.wim"
set "mountDir=%USERPROFILE%\Desktop\24H2\mount"
set "languagePackagesDir=%USERPROFILE%\Desktop\24H2\lang"
set "fodPackagesDir=%USERPROFILE%\Desktop\24H2\fod"
set "updatePackagesDir=%USERPROFILE%\Desktop\24H2\updates"


rem Mount the WIM file
dism /Mount-Wim /WimFile:"%wimFile%" /Index:6 /MountDir:"%mountDir%"

if %errorlevel% neq 0 (
    echo Error: Failed to mount WIM file.
    exit /b %errorlevel%
)

rem Inject language packages
echo Injecting language packages from: %languagePackagesDir%
for %%i in ("%languagePackagesDir%\*.cab") do (
    echo Injecting language package: %%i
    dism /Image:"%mountDir%" /Add-Package /PackagePath:"%%i"
    if errorlevel 1 (
        echo Error: Failed to inject language package: %%i
        exit /b %errorlevel%
    )
)

rem Inject Feature on Demand (FoD) packages
echo Injecting FoD packages from: %fodPackagesDir%
for %%i in ("%fodPackagesDir%\*.cab") do (
    echo Injecting FoD package: %%i
    dism /Image:"%mountDir%" /Add-Package /PackagePath:"%%i"
    if errorlevel 1 (
        echo Error: Failed to inject FoD package: %%i
        exit /b %errorlevel%
    )
)

rem Inject Windows updates
echo Injecting Windows updates from: %updatePackagesDir%
for %%i in ("%updatePackagesDir%\*.msu") do (
    echo Injecting update package: %%i
    dism /Image:"%mountDir%" /Add-Package /PackagePath:"%%i" /LogPath:C:\Users\bmasri\Desktop\24H2\dism.log
    if errorlevel 1 (
        echo Error: Failed to inject update package: %%i
        exit /b %errorlevel%
    )
)

rem Set international settings
echo Setting international settings...
DISM.exe /Image:"%mountDir%" /Set-UILang:en-GB
if errorlevel 1 (
    echo Error: Failed to set UI language.
    exit /b %errorlevel%
)

DISM.exe /Image:"%mountDir%" /Set-SysLocale:en-AU
if errorlevel 1 (
    echo Error: Failed to set system locale.
    exit /b %errorlevel%
)

DISM.exe /Image:"%mountDir%" /Set-UserLocale:en-AU
if errorlevel 1 (
    echo Error: Failed to set user locale.
    exit /b %errorlevel%
)

DISM.exe /Image:"%mountDir%" /Set-InputLocale:0C09:00000409
if errorlevel 1 (
    echo Error: Failed to set input locale.
    exit /b %errorlevel%
)

DISM.exe /Image:"%mountDir%" /Set-Timezone:"AUS Eastern Standard Time"
if errorlevel 1 (
    echo Error: Failed to set timezone.
    exit /b %errorlevel%
)

rem Unmount the WIM file
dism /Unmount-Wim /MountDir:"%mountDir%" /Commit

if %errorlevel% neq 0 (
    echo Error: Failed to unmount WIM file.
    exit /b %errorlevel%
)

echo Process completed successfully.
exit /b 0
