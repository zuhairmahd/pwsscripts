# Enable JAWS to auto start on login
$machinePath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility'
$JAWSFilePath = 'C:\Program Files\Freedom Scientific\JAWS\2023\jfw.exe'
$JAWSRegistryPath = 'HKLM:\SOFTWARE\Freedom Scientific\JAWS\2023'
$keyName = 'Configuration'
$keyValue = 'FreedomScientific_JAWS_v2023'
$JAWSUserRunPath = 'HKCU:\SOFTWARE\Freedom Scientific\JAWS'
$JAWSRunKeyName = 'Run'
$AlwaysRun = 1
$NeverRun = 0
$AllUsersRunKeyName = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
# $CurrentUserRunKeyName = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'JAWS2023.log'
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFile."
}
Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder$LogFile"

try {
    #Let's see if JAWS is installed by checking for the presence of the jaws executable
    if (!(Test-Path $JAWSFilePath)) {
        Write-Host 'JAWS executable not found'
        exit 1
    }
    else {
        Write-Host 'JAWS executable found. Proceeding to check for registry key'
    }
    #now let's check for the path in the registry
    if (!(Test-Path $JAWSRegistryPath)) {
        Write-Host 'JAWS registry key not found'
        exit 1
    }
    else {
        Write-Host 'JAWS registry key found. Proceeding to set autostart'
    }
    #now that we know JAWS is installed, let's proceed to enable it for auto start
    $key = Get-ItemProperty -Path $machinePath -Name $keyName -Verbose -ErrorAction SilentlyContinue
    #Check to see if JAWS is already enabled to autostart 
    if ($key.Configuration -eq $keyValue) {
        Write-Host 'JAWS auto start before signing in is already enabled'
    }
    else {
        if (!(Test-Path $machinePath)) {
            Set-Item -Path $machinePath -Value $keyValue
        }
        else {
            Set-ItemProperty -Path $machinePath -Name $keyName -Value $keyValue -Force 
        }
        Write-Host 'Enabled JAWS auto start before signing in'
    }
    #Enable for AllUser start
    $key = Get-ItemProperty -Path $JAWSRegistryPath -Name $JAWSRunKeyName -ErrorAction SilentlyContinue
    if ($key.Run -eq $alwaysRun) {
        Write-Host 'JAWS auto start after signing in is already enabled'
    }
    else {
        if (!(Test-Path $JAWSRegistryPath)) {
            Set-Item -Path $JAWSRegistryPath -Value $alwaysRun
        }
        else {
            Set-ItemProperty -Path $JAWSRegistryPath -Name $JAWSRunKeyName -Value $alwaysRun -Force
        }
        Write-Host 'Enabled JAWS auto start after signing in for all users.'
    }
    #Enable for CurrentUser start
    $key = Get-ItemProperty -Path $JAWSUserRunPath -Name $JAWSRunKeyName -ErrorAction SilentlyContinue
    if (($key.Run -eq $alwaysRun) -or ($key.run -eq $NeverRun)) {
        Remove-ItemProperty -Path $JAWSUserRunPath -Name $JAWSRunKeyName -Force -ErrorAction SilentlyContinue
        Write-Host 'Setting autostart to use all user settings'    
    }
    else {
        Write-Host 'JAWS is already set to use all user settings'
        # if (!(Test-Path $JAWSUserRunPath)) {
        # Set-Item -Path $JAWSUserRunPath -Value $alwaysRun
        # }
        # else {
        # Set-ItemProperty -Path $JAWSUserRunPath -Name $JAWSRunKeyName -Value $alwaysRun -Force
        # }
        # Write-Host 'Enabled JAWS auto start after signing in for current user.'
    }
    $key = Get-ItemProperty -Path $AllUsersRunKeyName -Name 'JAWS' -ErrorAction SilentlyContinue
    if ($null -eq $key) {
        New-ItemProperty -Path $AllUsersRunKeyName -Name 'JAWS' -Value "`"$JAWSFilePath`" /run" -PropertyType String -Force 
        Write-Host 'JAWS added to all users run registry'
    }
    else {
        Write-Host 'JAWS already added to all users run registry'
    }
}

catch {
    Write-Host 'Failed to enable JAWS auto start before signing in'
    Write-Host $_exception.Message $key
    exit 1
}
Stop-Transcript