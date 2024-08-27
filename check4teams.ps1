$MSTeams = 'MSTeams'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'Teams-detection.log'
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
    $TeamsWinApp = Get-AppxPackage -Name $MSTeams -AllUsers  -ErrorAction SilentlyContinue
    $TeamsPrrovisionedApp = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $MSTeams }
    if ($TeamsWinApp.Name -eq 'MSTeams') {
        Write-Host 'Built-in Teams Chat App Detected'
        Stop-Transcript
        Exit 1
    }
    elseif ($TeamsPrrovisionedApp.DisplayName -eq $MSTeams) {
        Write-Host 'Built-in Teams Chat App Detected in image'
        Stop-Transcript
        Exit 1
    }
    ELSE {
        Write-Host 'Built-in Teams Chat App Not Detected'
        Exit  0
    }
}
catch {
    $errMsg = $_.Exception.Message
    return $errMsg
    Exit 1
}

Stop-Transcript