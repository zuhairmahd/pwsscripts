# Enable the This PC, Documents and Network  icons on the desktop in Windows 11 and disable the Learn About This Picture
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'Desktop.log'
#Do not crash on errors
$ErrorActionPreference = 'SilentlyContinue'
$Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
$ThisPC = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
$MyDocuments = '{59031a47-3f72-44a7-89c5-5595fe6b30ee}'
$MyNetworks = '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'
$KeyFormat = 'dword'
$turnedOn = '0'
$turnedOffff = '1'

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

Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile -Force

#enable "This PC"
if (!(Test-Path $Path)) {
    New-Item -Path $Path -Force
}
if (!$ThisPC) {
    Set-Item -Path $Path -Value $turnedOn
}
else {
    Set-ItemProperty -Path $Path -Name $ThisPC -Value $turnedOn -Type $KeyFormat -Force
}

#Enable "My Documents"
if (!(Test-Path $Path)) {
    New-Item -Path $Path -Force
}
if (!$MyDocuments) {
    Set-Item -Path $Path -Value $turnedOn
}
else {
    Set-ItemProperty -Path $Path -Name $MyDocuments -Value $turnedOn -Type $KeyFormat -Force
}

#Enable "My Networks"
if (!(Test-Path $Path)) {
    New-Item -Path $Path -Force
}
if (!$MyNetworks) {
    Set-Item -Path $Path -Value $turnedOffff
}
else {
    Set-ItemProperty -Path $Path -Name $MyNetworks -Value $turnedOffff -Type $KeyFormat -Force
}


#Turn off Learn about this picture
Write-Host 'Disabling Learn about this picture'
$picture = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
If (Test-Path $picture) {
    Set-ItemProperty $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 1
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $picture = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    If (Test-Path $picture) {
        Set-ItemProperty $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 1
    }
}

#we are done.
Write-Host "Cleanup completed. Please check the log file at $LogFolder\$LogFile for more details"
Stop-Transcript