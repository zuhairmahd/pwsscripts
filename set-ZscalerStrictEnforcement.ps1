#A shell script to turn on Zscaler Strict Enforcement on Windows 11
$RegistryPath = 'HKLM:\SOFTWARE\Zscaler Inc.\Zscaler'
$RegistryName = 'Enforce'
$RegistryValue = 99
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'ZSCStrictEnforcement.log'
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFolder\$LogFile."
}


Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder\$LogFile" -Force

# Check if the registry key exists
If (Test-Path $RegistryPath) {
    Write-Output "The registry key $RegistryPath exists."
    $RegistryValue = (Get-ItemProperty -Path $RegistryPath -Name $RegistryName).$RegistryName
    If ($RegistryValue -eq 99) {
        Write-Output 'Zscaler Strict Enforcement is already enabled'
    }
    else {
        Write-Output "The registry key $RegistryName is set to $RegistryValue. Changing to $RegistryValue to enable Strict Enforcement."
        Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue
        Write-Output 'Strict Enforcement has been enabled.'
    }
}
else {
    Write-Output "The registry key $RegistryPath doesn't exist. Creating now."
    New-Item -Path $RegistryPath -Force | Out-Null
    Write-Output "The registry key $RegistryPath has been created."
    Write-Output 'Enabling Strict Enforcement.'
    New-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -PropertyType DWORD -Force | Out-Null
    Write-Output 'Strict enforcement has been enabled.'
}

Stop-Transcript