#Modified to write logs to the PWSLogs folder to aid in troubleshooting.
#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'Enable-tls1-0.log'
$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$regKey = 'SecureProtocols'
$regType = 'DWord'
$regValue = '0x00002aa0'
#Create Folder to keep logs 
If (Test-Path $LogFolder) {
    Write-Output "Logs will be appended to $LogFolder\$LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created."
    Write-Output "Logs will be written to $LogFolder\$LogFile."
}

Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile

Write-Output "Checking to see if the registry path $regPath exists."
if (!(Test-Path $regPath)) {
    Write-Output "Registry path $regPath does not exist.  Creating."
    New-Item -Path $regPath -Force
}
Write-Output "Found registry path $regPath."
Write-Output "Checking for the key $regKey"
if (!$regKey) {
    Write-Output "the registry key $regKey was not found.  Creating."
    Set-Item -Path $regPath -Value $regKey
}
else {
    Write-Output "Found registry key $regKey at $regPath."
    #get the current value.
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regKey).$regKey
    #if the values are different then update the value.
    if ($currentValue -ne $regValue) {
        Write-Output "$regKey value is set to $currentValue"
        Write-Output "Updating $regKey to $regValue"
        try {
            Set-ItemProperty -Path $regPath -Name $regKey -Value $regValue -Type $regType -Force
            Write-Output "Successfully Updated $regKey to $regValue"
        }
        catch {
            Write-Output "Error updating $regKey to $regValue"
            exit 1
        }
    }
    else {
        Write-Output "$regKey is already set to $regValue. Nothing to do."
    }
}


Stop-Transcript