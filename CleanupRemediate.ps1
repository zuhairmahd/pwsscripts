#define variables

$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'AppRemediate.log'
$UninstallListFile = "$LogFolder\UninstallList.txt"
#Do not crash on errors
$ErrorActionPreference = 'SilentlyContinue'
$PackagesToRemove = @()

#Create Folder to keep logs 
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile

#Check to see if the uninstall list exists
If (Test-Path $UninstallListFile) {
    Write-Output "The file $UninstallListFile exists. Reading the file to get the list of apps to uninstall."
    $PackagesToRemove = Get-Content $UninstallListFile
    Write-Output "The following apps will be uninstalled: $PackagesToRemove"
    foreach ($Package in $PackagesToRemove) {
        Write-Output "Uninstalling $Package"
        # Remove-AppxPackage -Package $Package -AllUsers -ErrorAction SilentlyContinue
        Write-Output "Uninstalled $Package"
    }
}
else {
    Write-Output "The file $UninstallListFile doesn't exist. Please run the CleanupCheck.ps1 script to generate the list of apps to uninstall."
    Stop-Transcript
    exit 1
}


#we are done.
Write-Host "Cleanup completed. Please check the log file at $LogFolder\$LogFile for more details"
Stop-Transcript