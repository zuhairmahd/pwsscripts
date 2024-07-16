# Print the value of the key at the specified path
$userPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Accessibility"
$machinePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility"
$keyName = "Configuration"
# $keyValue = "Narrator"

$value = Get-ItemProperty -Path $machinePath -name $keyName 
#If value is not empty, print its value
if ($value.$keyName -ne "") {
    Write-Host "Machine value: " $value.$keyName
} else {
    Write-Host "No machine value found"
}

$value = Get-ItemProperty -Path $userPath -name $keyName 
#If value is not empty, print its value
if ($value.$keyName -ne "") {
    Write-Host "User value: " $value.$keyName
} else {
    Write-Host "No user value found"
}

