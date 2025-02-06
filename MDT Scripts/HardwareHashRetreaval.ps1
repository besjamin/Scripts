# Enable WinRM for remote management
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Get device serial number
$serialNumber = (Get-WmiObject Win32_BIOS).SerialNumber

# Determine prefix based on serial number
# HP Elitebook x360 830 G9
if ($serialNumber -match "^5CG2") {
    $prefix = "2023"
# HP Elitebook x360 830 G10
} elseif ($serialNumber -match "^5CG3") {
    $prefix = "2024"
# Lenovo L13 Gen 5
} elseif ($serialNumber -match "^PW0") {
    $prefix = "2025"
} else {
    $prefix = "Unknown"  # Fallback if serial doesn't match expected patterns
}

# Construct the output file name
$outputDirectory = 'Z:\Hardware Hash'
$outputFile = "$outputDirectory\$prefix-$serialNumber.csv"
$autopilotScriptFile = 'Z:\Scripts\Get-WindowsAutoPilotInfo.ps1'

# Ensure the output directory exists
if (!(Test-Path -Path $outputDirectory)) {
    Write-Host "Output directory does not exist: $outputDirectory" -ForegroundColor Red
    exit 1
}

# Check if the AutoPilot script exists
if (!(Test-Path -Path $autopilotScriptFile)) {
    Write-Host "AutoPilot script not found at: $autopilotScriptFile" -ForegroundColor Red
    exit 1
}

# Run the AutoPilot script
try {
    & $autopilotScriptFile -OutputFile $outputFile
    Write-Host "Hardware hash successfully exported to: $outputFile" -ForegroundColor Green
} catch {
    Write-Host "Error running AutoPilot script: $_" -ForegroundColor Red
    exit 1
}
