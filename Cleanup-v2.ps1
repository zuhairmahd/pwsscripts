#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'Cleanup.log'
#Do not crash on errors
$ErrorActionPreference = 'SilentlyContinue'
$PackagesToRemove = @()

#Create Folder to keep logs 
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile


#Initialize variables
$AppsToRemove = @(
    'Microsoft.Xbox',
    'Microsoft.Xbox.TCUI',
    'Microsoft.Copilot',
    'Microsoft.549981C3F5F10', 
    'DropboxInc.Dropbox',
    'Microsoft.XboxGameOverlay',
    'Microsoft.BingNews',
    'Microsoft.BingWeather',
    'microsoft.windowscommunicationsapps', #Mail, Calendar, People, and Messaging
    'Microsoft.Windows.PeopleExperienceHost', #People
    'Microsoft.XboxGamingOverlay', #Xbox Game Bar
    'Microsoft.XboxIdentityProvider',
    'Microsoft.MixedReality.Portal',
    'Microsoft.WindowsTerminal',
    'Microsoft.Messaging',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.PowerAutomateDesktop',
    'Microsoft.WindowsFeedbackHub',
    'Microsoft.XboxGaming',
    'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.ZuneVideo',
    'Microsoft.People',
    'Microsoft.ZuneMusic',
    'Microsoft.XboxIdentityProvider',
    'Microsoft.OutlookForWindows',
    'Microsoft.Windows.DevHome',
    'MSTeams',
    'Microsoft.WindowsStore',
    'Microsoft.YourPhone'
    'Microsoft.Gaming',
    'Microsoft.GamingApp',
    'Spotify',
    'EclipseManager',
    'ActiproSoftwareLLC',
    'Duolingo-LearnLanguagesforFree',
    'PandoraMediaInc',
    'CandyCrush',
    'BubbleWitch3Saga',
    'Wunderlist',
    'Flipboard',
    'Twitter',
    'Facebook',
    'WhatsApp',
    'Instagram',
    'Netflix',
    'CandyCrushSodaSaga',
    'LinkedIn',
    'Spotify',
    'Minecraft',
    'Royal Revolt',
    'Disney',
    'gaming',
    'MicrosoftCorporationII.MicrosoftFamily',
    'C27EB4BA.DropboxOEM',
    'DevHome'
)

#let's see which of the above apps are acgtually provisioned 
$provisioned = Get-AppxProvisionedPackage -Online
foreach ($appxprov in $provisioned) {
    Write-Host "Checking whether $($appxprov.DisplayName) is in the list of apps to be removed"
    if ($AppsToRemove -match $appxprov.DisplayName) {
        Write-Host "$($appxprov.DisplayName) Version $($appxprov.version) will be removed"
        #add it to an array of apps to remove
        $PackagesToRemove += $appxprov
    }
    else {
        Write-Host "$($appxprov.DisplayName) version $($appxprov.version) will not be removed"
    }
}

Write-Output "$($PackagesToRemove.count) apps will be removed"

#Let's remove those packages we got from above from the image
if ($PackagesToRemove.count -gt 0) {
    foreach ($PackageToRemove in $PackagesToRemove) {
        $PackageDisplayName = $PackageToRemove.DisplayName
        $PackageName = $PackageToRemove.PackageName
        $PackageVersion = $PackageToRemove.Version
        Write-Output "Removing $PackageDisplayName Version $PackageVersion from the image"
        try {
            Remove-AppxProvisionedPackage -PackageName $PackageName -Online -ErrorAction SilentlyContinue
            Write-Host "Removed $PackageDisplayName version $PackageVersion from the image"
        }
        catch {
            Write-Host "Unable to remove $PackageDisplayName version $PackageVersion"
        }
        # Remove packages from user profiles if they are installed
        Write-Host "Checking to see if $PackageDisplayName version $PackageVersion has ever been installed in AllUsers profile"
        $InstalledPackage = Get-AppxPackage -Name $PackageDisplayName -AllUsers
        if ($InstalledPackage) {
            Write-Host "$PackageDisplayName version $PackageVersion is installed. . Removing for all users."
            try {
                $InstalledPackage | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                Write-Host "Removed $PackageDisplayName version $PackageVersion for all users."
                $InstalledPackage | Remove-AppxPackage -ErrorAction SilentlyContinue
                Write-Host "Removed $PackageDisplayName version $PackageVersion for current user."
            }
            catch {
                Write-Host "Unable to remove $PackageDisplayName version $PackageVersion for all users."
            }
        }
        else {
            Write-Host "$PackageDisplayName has not been installed in any users profile."
        }
    }
}
else {
    Write-Output 'No apps to remove'
}

###Turn off Learn about this picture
$picture = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
Write-Host "Checking the registry path for Learn About This Picture at $picture."
if (Test-Path $picture) {
    Write-Output 'Registry path exists. Checking to see if Learn about this picture is enabled'
    $LearnAboutThisPicture = Get-ItemPropertyValue -Path $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -ErrorAction SilentlyContinue
    if ($null -ne $LearnAboutThisPicture) {
        Write-Output "registry value exists at $LearnAboutThisPicture.  Checking to see if it is enabled"
        if ($LearnAboutThisPicture -eq 0) {
            Write-Output 'Learn about this picture is disabled.  No action required.'
        }
        else {
            Write-Output 'Learn about this picture is enabled.  Disabling Learn about this picture.'
            Set-ItemProperty -Path $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 0
        }
    }
    else {
        Write-Output 'Learn about this picture is not enabled.  No action required.'
    }
}
else {
    Write-Host "Registry path $picture does not exist. Creating to disable Learn About This Picture."
    New-Item -Path $LearnAboutThisPicture -Force
    Set-ItemProperty -Path $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 0
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $picture = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Write-Output "Checking the registry path for Learn About This Picture at $picture for SID $sid"
    If (Test-Path $picture) {
        Write-Output 'Registry path exists. Checking to see if Learn about this picture is enabled'
        $LearnAboutThisPicture = Get-ItemPropertyValue -Path $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -ErrorAction SilentlyContinue
        if ($null -ne $LearnAboutThisPicture) {
            Write-Output 'registry value exists.  Checking to see if it is enabled'
            if ($LearnAboutThisPicture -ne 1) {
                Write-Host "Disabling Learn about this picture for SID $sid"
                Set-ItemProperty $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 1
            }
            else {
                Write-Host "Learn about this picture is already disabled for SID $sid"
            }
        }
        else {
            Write-Host "Disabling Learn about this picture for SID $sid."
            Set-ItemProperty $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 1
        }
    }
    else {
        Write-Host "Registry path $picture for SID $sid does not exist. Creating to disable Learn About This Picture."
        New-Item -Path $picture -Force
        Set-ItemProperty $picture -Name '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' -Value 1
    }
}



##Stop personal Teams and keep it from coming back
Write-Output 'Stopping Teams from auto-installing'
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications'
If (Test-Path $registryPath) { 
    $ConfigureChatAutoInstall = Get-ItemPropertyValue -Path $registryPath -Name 'ConfigureChatAutoInstall' -ErrorAction SilentlyContinue
    if ($null -eq $ConfigureChatAutoInstall) {
        if ($ConfigureChatAutoInstall -ne 0) {
            Write-Output 'Setting ConfigureChatAutoInstall to 0'
            Set-ItemProperty -Path $registryPath -Name 'ConfigureChatAutoInstall' -Value 0
        }
        else {
            Write-Output 'ConfigureChatAutoInstall is already set to 0'
        }
    }
    else {
        Write-Output 'Setting ConfigureChatAutoInstall to 0'
        Set-ItemProperty -Path $registryPath -Name 'ConfigureChatAutoInstall' -Value 0  
    }
}
else {
    Write-Output 'Creating registry path and setting ConfigureChatAutoInstall to 0'
    New-Item -Path $registryPath -Force
    Set-ItemProperty -Path $registryPath -Name 'ConfigureChatAutoInstall' -Value 0
}


##Unpin it
$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
Write-Output "Checking registry key at $registryPath to see if Teams Chat is pinned"
If (Test-Path $registryPath) { 
    Write-Output "found registry key at $registryPath.  Checking to see if Teams Chat is pinned"    
    $ChatIcon = Get-ItemPropertyValue -Path $registryPath -Name 'ChatIcon' -ErrorAction SilentlyContinue
    if ($null -ne $ChatIcon) {
        if ($ChatIcon -ne 2) {
            Write-Host 'Unpinning Teams Chat'
            Set-ItemProperty $registryPath 'ChatIcon' -Value 2
        }
        else {
            Write-Host 'Teams Chat is already unpinned.'
        }
    }
    else {
        Write-Host 'Unpinning Teams Chat'
        Set-ItemProperty $registryPath 'ChatIcon' -Value 2
    }
}
else {
    Write-Output "creating registry key at $registryPath to unpin Teams Chat"
    New-Item -Path $registryPath -Force
    Set-ItemProperty $registryPath 'ChatIcon' -Value 2
}



###Cleaning up Windows 11 start menu
Write-Host 'Cleaning up start menu'
Write-Host 'Removing Current Layout'
If (Test-Path 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml') {
    Remove-Item 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml'
}
$blankjson = @'
{
    "pinnedList": [
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Microsoft Edge.lnk"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Word.lnk"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Excel.lnk"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\PowerPoint.lnk"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Outlook.lnk"
        },
        {
            "packagedAppId": "MSTeams_8wekyb3d8bbwe!MSTeams"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\OneNote.lnk"
        },
        {
            "packagedAppId": "Microsoft.Todos_8wekyb3d8bbwe!App"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\OneDrive.lnk"
        },
        {
            "packagedAppId": "Mozilla.Firefox_n80bbvh6b1yt2!App"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Google Chrome.lnk"
        },
        {
            "packagedAppId": "Microsoft.CompanyPortal_8wekyb3d8bbwe!App"
        },
        {
            "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Adobe Acrobat.lnk"
        },
        {
            "packagedAppId": "MicrosoftCorporationII.AzureVirtualDesktopClient_8wekyb3d8bbwe!MsrdcwForwarder"
        },
        {
            "packagedAppId": "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"
        },
        {
            "packagedAppId": "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"
        },
        {
            "packagedAppId": "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe!App"
        },
        {
            "desktopAppLink": "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\File Explorer.lnk"
        },
        {
            "packagedAppId": "Microsoft.Getstarted_8wekyb3d8bbwe!App"
        }
    ]
}
'@
$blankjson | Out-File 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml' -Encoding utf8 -Force

#                                        Disable Edge Surf Game                                            #
$surf = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge'
Write-Host 'Disabling Edge Surf Game'
If (Test-Path $surf) {
    Write-Output "Found registry key $surf"
    $AllowSurfGame = Get-ItemPropertyValue -Path $surf -Name 'AllowSurfGame' -ErrorAction SilentlyContinue
    #If the value is set to anything other than 0, then change it to 0 to disable the surf game.
    if ($null -ne $AllowSurfGame) {
        Write-Output "The value of $surf is set to $AllowSurfGame."
        if ($AllowSurfGame -ne 0) {
            Write-Output 'Disabling Edge Surf Game'
            Set-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0
        }
        else {
            Write-Host 'AllowSurfGame is already disabled.'
        }
    }    
    else {
        Write-Host 'Disabling Edge Surf Game'
        Set-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0
    }
}
else {
    Write-Host 'Disabling Edge Surf Game'
    New-Item -Path $surf -Force
    Set-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0 -PropertyType DWord
}


#                                              Remove Xbox Gaming                                          #
$XboxGamingServices = @(
    'XblAuthManager',
    'XblGameSave',
    'XboxGipSvc',
    'XboxNetApiSvc'
)
foreach ($service in $XboxGamingServices) {
    Write-Output "checking whether $service exists"
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Write-Output "$service exists.  Getting status."
        $serviceSstatus = (Get-Service -Name $service).Status
        $serviceStartType = (Get-Service -Name $service).StartType
        if ($serviceStartType -ne 'Disabled') {
            Write-Output "$service is $serviceSstatus with a startup type of $serviceStartType.  Disabling."
            Set-Service -Name $service -StartupType Disabled
        }
        else {
            Write-Output "$service is already $serviceStartType."
        }
    }
    else {
        Write-Output "$service is not installed."
    }
}

$task = Get-ScheduledTask -TaskName 'Microsoft\XblGameSave\XblGameSaveTask' -ErrorAction SilentlyContinue
Write-Output 'Checking the status of the XblGameSaveTask'
if ($null -ne $task) {
    Write-Output 'XblGameSaveTask exists.  Disabling.'
    Set-ScheduledTask -TaskPath $task.TaskPath -Enabled $false
}
else {
    Write-Output 'XblGameSaveTask does not exist.'
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
#Check if the following registery values are set.  If not, set them.
$GameDVR = 'HKLM:\Software\Policies\Microsoft\Windows\GameDVR'
If (!(Test-Path $GameDVR)) {
    New-Item $GameDVR
}
$AllowgameDVR = Get-ItemPropertyValue -Path $GameDVR -Name 'AllowgameDVR' -ErrorAction SilentlyContinue
if ($null -ne $AllowgameDVR) {
    if ($AllowgameDVR -ne 0) {
        Write-Host 'Disabling GameDVR'
        Set-ItemProperty -Path $GameDVR -Name 'AllowgameDVR' -Value 0
    }
    else {
        Write-Host 'GameDVR is already disabled.'
    }
}
else {
    Write-Host 'Disabling GameDVR'
    New-ItemProperty -Path $GameDVR -Name 'AllowgameDVR' -Value 0 -PropertyType DWord
}
#same for the next one.
$gameBarItemsToHide = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'SettingsPageVisibility' -ErrorAction SilentlyContinue
if ($null -ne $gameBarItemsToHide) {
    if ($gameBarItemsToHide -ne 'hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking') {
        Write-Host 'Hiding Game Bar Items'
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'SettingsPageVisibility' -Value 'hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking'
    }
    else {
        Write-Host 'Game Bar Items are already hidden.'
    }
}
else {
    Write-Host 'Hiding Game Bar Items'
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'SettingsPageVisibility' -PropertyType String -Value 'hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking' -Force
}

$xdgm = 'HKLM:\System\CurrentControlSet\Services\xbgm' 
if (Test-Path $xdgm) { 
    Write-Output "found registry path $xdgm.  Checking value."
    $value = Get-ItemPropertyValue -Path $xdgm -Name 'Start'
    if ($null -ne $value) {
        Write-Output "Value for $xdgm is set to $value"
        if ($value -ne 4) {
            Write-Output "Value found.  Value is $($value.Start).  Changing to 4."
            Set-ItemProperty -Path $xdgm -Name 'Start' -Value 4
        } 
        else {
            Write-Output "Value found.  Value is already $($value.Start)"
        }
    }
    else {
        Write-Output 'Value not found.  Creating value with value 4.'
        Set-ItemProperty -Path $xdgm -Name 'Start' -Value 4
    }
}
else {
    Write-Output 'Registry path not found.  Creating registry path and value with value 4.'
    New-Item -Path $xdgm -Force
    Set-ItemProperty -Path $xdgm -Name 'Start' -Value 4
}

#we are done.
Write-Host "Cleanup completed. Please check the log file at $LogFolder\$LogFile for more details"
Stop-Transcript