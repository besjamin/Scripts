# Set the KMS key
$KmsKey = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"

# Install the KMS key
Write-Output "Installing the KMS key..."
cscript /nologo slmgr.vbs /ipk $KmsKey

# Set KMS address to URL
cscript /nologo slmgr.vbs /skms kms.education.wan

# Activate Windows
Write-Output "Activating Windows..."
cscript /nologo slmgr.vbs /ato

Write-Output "Windows activation complete."
