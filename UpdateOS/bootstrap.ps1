$ScriptName = 'UpdateOS.ps1'
$ScriptsFolder = 'C:\ProgramData\IntuneScripts'
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
Copy-Item $ScriptName $ScriptsFolder


try {
    $TaskTrigger = New-ScheduledTaskTrigger -AtLogOn
    # $TaskTrigger = New-ScheduledTaskTrigger -Once
    # $TaskUser = 'NT AUTHORITY\LOCALSERVICE'
    $TaskAction = New-ScheduledTaskAction -Execute $PWSCommand -Argument "-executionPolicy Bypass $ScriptsFolder\$ScriptName -reboot 'None'" -WorkingDirectory $ScriptsFolder 
    $TaskName = 'UpdateOS'
    #Check to see if the task is already registered 
    $TaskCheck = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    If ($TaskCheck) {
        Write-Output "The task $TaskName already exists. Updating the task."
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Register-ScheduledTask -TaskName $TaskName -Description "Run the shell script in $ScriptName to download system updates" -Trigger $TaskTrigger -Action $TaskAction -RunLevel Highest -Force
    }
    else {
        Write-Output "Creating the task $TaskName."
        Register-ScheduledTask -TaskName $TaskName -Description "Run the shell script in $ScriptName to download system updates" -Trigger $TaskTrigger -Action $TaskAction -RunLevel Highest -Force
    }
}
#'-User 'NT AUTHORITY\SYSTEM''
catch {
    Write-Output "An error occurred while creating the scheduled task. The error was: $_"
}

Stop-Transcript