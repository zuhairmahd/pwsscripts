# Enable JAWS to auto start on login
$machinePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility"
$JAWSFilePath = "C:\Program Files\Freedom Scientific\JAWS\2023\jfw.exe"
$JAWSRegistryPath = "HKLM:\SOFTWARE\Freedom Scientific\JAWS\2023"
$keyName = "Configuration"
$keyValue = "FreedomScientific_JAWS_v2023"

try {
    #Let's see if JAWS is installed by checking for the presence of the jaws executable
    if (!(Test-Path $JAWSFilePath)) {
        Write-Host "JAWS executable not found"
        exit 1
    }else {
        Write-Host "JAWS executable found"
    }
    #now let's check for the path in the registry
    if (!(Test-Path $JAWSRegistryPath)) {
        Write-Host "JAWS registry key not found"
        exit 1
    }else {
        Write-Host "JAWS registry key found"
    }
    #now that we know JAWS is installed, let's proceed to enable it for auto start
    $key = Get-ItemProperty -Path $machinePath -Name $keyName -ErrorAction SilentlyContinue

    #Enable for machine start
    if (!$keyName) {
        Set-Item -Path $machinePath -Value $keyValue
    }
    else { Set-ItemProperty -Path $machinePath -Name $keyName -Value $keyValue -Force }
    write-host "Enabled JAWS auto start before signing in"
    exit 0
}

catch {
    Write-Host "Failed to enable JAWS auto start before signing in"
    write-host $_exception.Message
    exit 1
}