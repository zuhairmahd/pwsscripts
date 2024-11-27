
Write-Host 'Windows 11 Detected'
Write-Host 'Removing Current Layout'
If (Test-Path 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml') {
    Remove-Item 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml'
}
$blankjson = @'
{ 
    "pinnedList": [ 
      { "desktopAppId": "MSEdge" }, 
      { "packagedAppId": "Microsoft.WindowsStore_8wekyb3d8bbwe!App" }, 
      { "packagedAppId": "desktopAppId":"Microsoft.Windows.Explorer" } 
    ] 
  }
'@

$blankjson | Out-File 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml' -Encoding utf8 -Force


#                                        Disable Edge Surf Game                                            #
$surf = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge'
If (!(Test-Path $surf)) {
    New-Item $surf
}
New-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0 -PropertyType DWord

#                                              Remove Xbox Gaming                                          #
New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\xbgm' -Name 'Start' -PropertyType DWORD -Value 4 -Force
Set-Service -Name XblAuthManager -StartupType Disabled
Set-Service -Name XblGameSave -StartupType Disabled
Set-Service -Name XboxGipSvc -StartupType Disabled
Set-Service -Name XboxNetApiSvc -StartupType Disabled
$task = Get-ScheduledTask -TaskName 'Microsoft\XblGameSave\XblGameSaveTask' -ErrorAction SilentlyContinue
if ($null -ne $task) {
    Set-ScheduledTask -TaskPath $task.TaskPath -Enabled $false
}
##Check if GamePresenceWriter.exe exists
if (Test-Path "$env:WinDir\System32\GameBarPresenceWriter.exe") {
    Write-Host 'GamePresenceWriter.exe exists'
    #Take-Ownership -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
    $NewAcl = Get-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
    # Set properties
    $identity = "$builtin\Administrators"
    $fileSystemRights = 'FullControl'
    $type = 'Allow'
    # Create new rule
    $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    # Apply new rule
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe" -AclObject $NewAcl
    Stop-Process -Name 'GameBarPresenceWriter.exe' -Force
    Remove-Item "$env:WinDir\System32\GameBarPresenceWriter.exe" -Force -Confirm:$false
}
else {
    Write-Host 'GamePresenceWriter.exe does not exist'
}
New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\GameDVR' -Name 'AllowgameDVR' -PropertyType DWORD -Value 0 -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'SettingsPageVisibility' -PropertyType String -Value 'hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking' -Force
