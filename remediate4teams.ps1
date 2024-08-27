$MSTeams = 'MSTeams'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'Teams-remediation.log'
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

Try {
    $WinPackage = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $MSTeams }
    $ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage }
    If ($null -ne $WinPackage) {
        Remove-AppxPackage  -Package $WinPackage.PackageFullName -AllUsers
    } 
    If ($null -ne $ProvisionedPackage) {
        Remove-AppxProvisionedPackage -Online -PackageName $ProvisionedPackage.Packagename -AllUsers
    }
    Write-Host 'Built-In Teams Chat app uninstalled'
    #Stop it coming back
    $registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications'
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath ConfigureChatAutoInstall -Value 0
    #Unpin it
    $registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath 'ChatIcon' -Value 2
    Write-Host 'Removed Teams Chat'
}


catch {
    $errMsg = $_.Exception.Message
    return $errMsg
    Exit 1
}

Stop-Transcript