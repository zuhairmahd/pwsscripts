#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'update.log'
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator'
$Name = 'ScanBeforeInitialLogonAllowed'
$value = '1'
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/Appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created."
}
Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile


if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}
if (!(Get-ItemProperty -Path $registryPath -Name $name -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}
else {
    Set-ItemProperty -Path $registryPath -Name $name -Value $value
}

Stop-Transcript