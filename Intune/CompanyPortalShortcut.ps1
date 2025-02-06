# Specify the display name for the shortcut
$shortcutName = "Company Portal"

# Specify the URL for the icon
$iconUrl = "SPECIFY_URL_PATH"

# Specify the local path to save the icon
$localIconPath = "$env:TEMP\CompanyPortalApp.ico"

# Download the icon
Invoke-WebRequest -Uri $iconUrl -OutFile $localIconPath

# Create a WScript Shell object
$wshShell = New-Object -ComObject WScript.Shell

# Create a shortcut object
$shortcut = $wshShell.CreateShortcut("$env:userprofile\desktop\$shortcutName.lnk")

# Set the target path for the shortcut
$shortcut.TargetPath = "shell:AppsFolder\Microsoft.CompanyPortal_8wekyb3d8bbwe!App"

# Set the icon location
$shortcut.IconLocation = "$localIconPath,0"

# Save the shortcut
$shortcut.Save()
