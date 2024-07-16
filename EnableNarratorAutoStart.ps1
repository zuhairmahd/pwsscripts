# Enable Narrator auto start before and after signing in
$userPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Accessibility"
$machinePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility"
$keyName = "Configuration"
$keyValue = "Narrator"
try {
    #Enable for user start 
    if (!$keyName) {
        Set-Item -Path $userPath -Value $keyValue
    }
    else { Set-ItemProperty -Path $userPath -Name $keyName -Value $keyValue -Force }

    #Enable for machine start
    $value = Get-ItemProperty -Path $machinePath -name $keyName
    if ($value.$keyName -eq "") {
        if (!$keyName) {
            Set-Item -Path $machinePath -Value $keyValue
        }
        else { Set-ItemProperty -Path $machinePath -Name $keyName -Value $keyValue -Force }
    else { 
        Write-Host "No value found" 
    }
    $returnCode = 1
}
exit $returnCode
}

catch {
    Write-Host "Failed to enable Narrator auto start before and after signing in"
    exit 1
}