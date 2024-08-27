#Validate whether sysmon is installed and ‘Running’
$appPath = "c:\program files\sysmon\sysmon64.exe"
$ServiceName = "sysmon64"

try {
    if (!(Test-Path $appPath)) {
        Write-Host "files did not copy properly"
        exit 1
    }
    else {
        Write-Host "Files copied successfully"
    }
    
    #now let's check to see if the service is running
    $ServiceInfo = Get-Service -Name $ServiceName
    # $ServiceInfo.Refresh()
    
    if ($ServiceInfo.Status -ne "Running") {
        write-host "service is not running"
        write-host $ServiceInfo.Status
        exit 1
    }
    else {
        write-host "service is running"
    }
    #we made it this far, so let's return a 0
    exit 0
}

catch {
    <#Do this if a terminating exception happens#>
    Write-Host "An error occurred: $_"
    exit 1
}
