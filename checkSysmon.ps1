#Validate whether sysmon is installed and ‘Running’
$appPath = 'c:\program files\sysmon\sysmon64.exe'
$ServiceName = 'sysmon64'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'Sysmon.log'
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFile."
}
Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder$LogFile" -Force
try {
    if (!(Test-Path $appPath)) {
        Write-Host 'files did not copy properly'
        Stop-Transcript
        exit 1
    }
    else {
        Write-Host 'Files copied successfully'
    }
    
    #now let's check to see if the service is running
    $ServiceInfo = Get-Service -Name $ServiceName
    # $ServiceInfo.Refresh()
    
    if ($ServiceInfo.Status -ne 'Running') {
        Write-Host 'service is not running'
        Write-Host $ServiceInfo.Status
        Stop-Transcript
        exit 1
    }
    else {
        Write-Host 'service is running'
    }
    #we made it this far, so let's return a 0
    exit 0
}

catch {
    <#Do this if a terminating exception happens#>
    Write-Host "An error occurred: $_"
    exit 1
}
Stop-Transcript
