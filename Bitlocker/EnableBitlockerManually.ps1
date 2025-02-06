# Stop the script if there are any errors
$ErrorActionPreference = "Stop"

#### VARIABLES SETUP ####

# Set encryption method
$encryptionMethod = "XtsAes128"

# Set the location for recovery files
$recoveryKeyDir = "C:\Windows\temp\"
$recoveryKeyFile = "$recoveryKeyDir$($env:computername)_bitlocker.txt"

# Read TPM and Veracrypt status
$isTPMEnabled = (Get-TPM).TpmReady
$isVeracryptEnabled =  "0" -ne (Resolve-Path "$env:SystemDrive\Program Files*\" | Get-ChildItem | Where-Object name -like "*VeraCrypt*").Length

# Read number of fixed drives
$drives = (Get-WmiObject win32_diskdrive | Where-Object{$_.mediatype -eq "Fixed hard disk media"} | ForEach-Object{Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  ForEach-Object{Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | ForEach-Object{$_.deviceid})

#### MAIN LOOP ####

# Execute for each fixed drive
Foreach ($currentDrive in $drives){
    if ($isVeracryptEnabled -and $currentDrive -eq $env:SystemDrive){
        # Skipping Veracrypt-enabled system drive"
    }else{ # Encrypt all drives not encrypted by Veracrypt

        # Check the Bitlocker status of the current drive, if it's not encrypted then continue
        $currentDriveBitlockerEncryptionStatus = ((Get-BitLockerVolume -MountPoint $currentDrive).volumeStatus)
        if ("FullyDecrypted" -eq $currentDriveBitlockerEncryptionStatus){
            
            # Clean the keyprotectors from failed deployments
            foreach ($keyprotector in (Get-BitLockerVolume -MountPoint $currentDrive).keyprotector) {
                Remove-BitLockerKeyProtector -MountPoint $currentDrive $keyprotector.KeyProtectorID *>null
            }
            
            # Add recovery password for unlocking the current drive
            Add-BitLockerKeyProtector -MountPoint $currentDrive -RecoveryPasswordProtector *>null
            
            # Encrypt based on whether TPM is enabled or not
            if ($isTPMEnabled){
                Enable-BitLocker -Mountpoint $currentDrive -EncryptionMethod $encryptionMethod -RecoveryKeyPath $recoveryKeyDir -RecoveryKeyProtector -SkipHardwareTest *>>$recoveryKeyFile
            }else{
                
                # If there's no TPM, halt encryption
                Write-Host "TPM is not enabled. BitLocker encryption cannot proceed without TPM."
                Break
            }
            
            # Autounlock the drive if it's not a system drive (it will be unlocked without the need to provide the password for each drive)
            if($currentDrive -ne $env:SystemDrive){
                Enable-BitLockerAutoUnlock -MountPoint $currentDrive
            }
        }
    } 
}

# Create dummy text file
New-Item -ItemType File -Path "C:\Windows\logs\bitlocker_enabled.txt" -Force

# Restore default error action preference
$ErrorActionPreference = "Continue"
