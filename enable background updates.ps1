#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'regUpdate.log'
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

try {
    if (!(Test-Path $registryPath)) {
        Write-Host $registryPath does not exist.  Creating.
        New-Item -Path $registryPath -Force | Out-Null
    }
    if (!(Get-ItemProperty -Path $registryPath -Name $name -ErrorAction SilentlyContinue)) {
        Write-Host the key $name in $registryPath does not exist.  Creating.
        New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
    }
    else {
        Write-Host Found $name in $registryPath. Setting value to $value.
        Set-ItemProperty -Path $registryPath -Name $name -Value $value
    }
}

catch {
    Write-Host 'An error occurred.  Please check the log file for more information.'
}

Stop-Transcript