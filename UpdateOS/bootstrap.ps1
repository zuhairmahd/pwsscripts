$ScriptName = 'UpdateOS.ps1'
$ScriptsFolder = 'C:\ProgramData\IntuneScripts'
$ScriptArguments = "-reboot 'delayed' 30"
$LogFolder = 'C:\ProgramData\PWSLogs\UpdateOS'
$LogFile = 'UpdateOS-bootstrap.log'
$PWSCommand = 'C:\windows\system32\WindowsPowerShell\v1.0\PowerShell.exe'

If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFile."
}

Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder\$LogFile"

#Now let's copy the script
If (Test-Path $ScriptsFolder) {
    Write-Output "$ScriptsFolder exists.  Copying the script."
}
else {
    Write-Output "The folder $ScriptsFolder doesn't exist. Creating now."
    Start-Sleep 1
    New-Item -Path $ScriptsFolder -ItemType Directory | Out-Null
    Write-Output "The folder $ScriptsFolder was successfully created. Copying the script."
}
Copy-Item $ScriptName $ScriptsFolder -Force

#Let's ad an entry to the user's registry to run the script at logon
$RegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$RegName = 'UpdateOS'
$RegValue = "`"$PWSCommand -ExecutionPolicy Bypass -File $ScriptsFolder\$ScriptName`" $ScriptArguments"
If (Test-Path $RegKey) {
    Write-Output 'Adding registry entry to run the script at logon.'
    New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -PropertyType String -Force | Out-Null
}
else {
    Write-Output "The registry key $RegKey doesn't exist. Creating now."
    New-Item -Path $RegKey -Force | Out-Null
    Write-Output 'Adding registry entry to run the script at logon.'
    New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -PropertyType String -Force | Out-Null
}

Stop-Transcript
