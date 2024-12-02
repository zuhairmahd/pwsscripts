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
# SIG # Begin signature block
# MII95AYJKoZIhvcNAQcCoII91TCCPdECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBUOMT76J3EMVzd
# ppH/JHnMzmEBV/CdHQcBBlBX1nfTHaCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
# lUgTecgRwIeZMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVu
# dGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAy
# MDAeFw0yMDA0MTYxODM2MTZaFw00NTA0MTYxODQ0NDBaMHcxCzAJBgNVBAYTAlVT
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jv
# c29mdCBJZGVudGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
# b3JpdHkgMjAyMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALORKgeD
# Bmf9np3gx8C3pOZCBH8Ppttf+9Va10Wg+3cL8IDzpm1aTXlT2KCGhFdFIMeiVPvH
# or+Kx24186IVxC9O40qFlkkN/76Z2BT2vCcH7kKbK/ULkgbk/WkTZaiRcvKYhOuD
# PQ7k13ESSCHLDe32R0m3m/nJxxe2hE//uKya13NnSYXjhr03QNAlhtTetcJtYmrV
# qXi8LW9J+eVsFBT9FMfTZRY33stuvF4pjf1imxUs1gXmuYkyM6Nix9fWUmcIxC70
# ViueC4fM7Ke0pqrrBc0ZV6U6CwQnHJFnni1iLS8evtrAIMsEGcoz+4m+mOJyoHI1
# vnnhnINv5G0Xb5DzPQCGdTiO0OBJmrvb0/gwytVXiGhNctO/bX9x2P29Da6SZEi3
# W295JrXNm5UhhNHvDzI9e1eM80UHTHzgXhgONXaLbZ7LNnSrBfjgc10yVpRnlyUK
# xjU9lJfnwUSLgP3B+PR0GeUw9gb7IVc+BhyLaxWGJ0l7gpPKWeh1R+g/OPTHU3mg
# trTiXFHvvV84wRPmeAyVWi7FQFkozA8kwOy6CXcjmTimthzax7ogttc32H83rwjj
# O3HbbnMbfZlysOSGM1l0tRYAe1BtxoYT2v3EOYI9JACaYNq6lMAFUSw0rFCZE4e7
# swWAsk0wAly4JoNdtGNz764jlU9gKL431VulAgMBAAGjVDBSMA4GA1UdDwEB/wQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTIftJqhSobyhmYBAcnz1AQ
# T2ioojAQBgkrBgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEAr2rd5hnn
# LZRDGU7L6VCVZKUDkQKL4jaAOxWiUsIWGbZqWl10QzD0m/9gdAmxIR6QFm3FJI9c
# Zohj9E/MffISTEAQiwGf2qnIrvKVG8+dBetJPnSgaFvlVixlHIJ+U9pW2UYXeZJF
# xBA2CFIpF8svpvJ+1Gkkih6PsHMNzBxKq7Kq7aeRYwFkIqgyuH4yKLNncy2RtNwx
# AQv3Rwqm8ddK7VZgxCwIo3tAsLx0J1KH1r6I3TeKiW5niB31yV2g/rarOoDXGpc8
# FzYiQR6sTdWD5jw4vU8w6VSp07YEwzJ2YbuwGMUrGLPAgNW3lbBeUU0i/OxYqujY
# lLSlLu2S3ucYfCFX3VVj979tzR/SpncocMfiWzpbCNJbTsgAlrPhgzavhgplXHT2
# 6ux6anSg8Evu75SjrFDyh+3XOjCDyft9V77l4/hByuVkrrOj7FjshZrM77nq81YY
# uVxzmq/FdxeDWds3GhhyVKVB0rYjdaNDmuV3fJZ5t0GNv+zcgKCf0Xd1WF81E+Al
# GmcLfc4l+gcK5GEh2NQc5QfGNpn0ltDGFf5Ozdeui53bFv0ExpK91IjmqaOqu/dk
# ODtfzAzQNb50GQOmxapMomE2gj4d8yu8l13bS3g7LfU772Aj6PXsCyM2la+YZr9T
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAIBlSPc
# Ehbp17sSAAAAAgGVMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDIwHhcNMjQxMjAxMTU0MjI3WhcNMjQxMjA0
# MTU0MjI3WjBmMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExEjAQBgNV
# BAcTCUFybGluZ3RvbjEXMBUGA1UEChMOWnVoYWlyIE1haG1vdWQxFzAVBgNVBAMT
# Dlp1aGFpciBNYWhtb3VkMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# i/qzA2P0v8a0x7uIiesDJQWI8CRLp8hYXsfp7Mlz6n1S8dfPTFFsEFAZxnZlJRO9
# giW/PLqPS1ba+bKYtVnTEeUxjpvh4ag2/YHDXLTaZpsZcRTGa8wQeSZ05lgXz2ps
# 1F/Lqz1HtaED2DylBNOb6w/rcyD/PkjtnU72Itjwftq9tugskyGSpI631vXwa/KP
# 8unr2YDwJzr4nJV06Ftsfcmpla36wdxZ2dUxK4vnDIKaIah9XmUwI8dnUaKZ67YC
# 2lvLxNURfCmBnYEEcESZOdp+7dOq2gK36JFpHFmQ69kwrmwUBhb/zUafUCCw6nCW
# pmSjuR4RcTNL+hQUz3m0uuJQFMS0ok4ORtwUg8BW1MRlf3k0VKH43h5XBT9aX+bM
# qQ3htRuM6fAzefch1GlpCjS14lxiErU+grXiW/9e2zah6DRPM+OneyihFiSZG+Ng
# 9QnWl1g7lxtD/VBPL0gRx2gXRMSVtTe+B0/2GUGIP7Da4z97A9rAKNSiBT3RlCwn
# AgMBAAGjggIYMIICFDAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA7BgNV
# HSUENDAyBgorBgEEAYI3YQEABggrBgEFBQcDAwYaKwYBBAGCN2GBmtGaFtje9WuB
# vfqFXPmA7xswHQYDVR0OBBYEFPyXHIvJPg+mpZCSLg//WhcSyxK6MB8GA1UdIwQY
# MBaAFCRFmaF3kCp8w8qDsG5kFoQq+CxnMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDIuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAyLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBADO75o5rKgAPCJ+w
# uz3jBzL5YqavehNiMGc3CJL9YrK0zfgYnqmDvDzNNXNVzZaGmi84wUYbnf7qHHkE
# ARqOvrrq34ZkAbUqU7IR4a7MkcIPnF91fHg/hgBsFlL0MBp43w+L8jr19K6+3jIj
# A29xelvAil46H8HHJMY7MLJWDNPUMF6XL233zBMK57Ly3/S3Fp/5Dm+LT7ke4jXY
# W7yG3FsRuZjNPuncngFKVZ9NtFPCUlkCwxEDzm26+FTx0sMItxiTcenJopl/nk7G
# ODh8/Gsm9sV09OcNMIsSXe+FK8i2nacp59/tW3Qf52Huvqkb+3OQ6ynv3N3zm6Pu
# elhM/rQLdquBtjMwMx1CKApGDAMlgFjqNJ49kK+XEOdicYGO5APCEeQIUQwEJOB8
# pPwr9E0OALH1dVTqpnhm7h15VrBW1E6ZcKm8urTVicnXET+Q4aJnfFgK3E09yatL
# HUSMbodS6M5+i8xCHiGZ4pQKLxPgCif/EnGyseqd31Pgk3+C+HosQA2/kipTfjWV
# XZ2CWPmxj7j21kPXtkwAxEEg/vhr89N5LNI+M0pG9BMSweNXI2//HrgG+NbS06VV
# cdX2bD1f1U7NzzX/Fr84iNm+U9eRUy0+1L/rBbs533Wn5L/AJ++kdiQNoq/UrnAY
# ZWO723Se7Lge2irX0/Ao/1b0yo/kMIIG5zCCBM+gAwIBAgITMwACAZUj3BIW6de7
# EgAAAAIBlTANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAyMB4XDTI0MTIwMTE1NDIyN1oXDTI0MTIwNDE1NDIy
# N1owZjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMRIwEAYDVQQHEwlB
# cmxpbmd0b24xFzAVBgNVBAoTDlp1aGFpciBNYWhtb3VkMRcwFQYDVQQDEw5adWhh
# aXIgTWFobW91ZDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAIv6swNj
# 9L/GtMe7iInrAyUFiPAkS6fIWF7H6ezJc+p9UvHXz0xRbBBQGcZ2ZSUTvYIlvzy6
# j0tW2vmymLVZ0xHlMY6b4eGoNv2Bw1y02mabGXEUxmvMEHkmdOZYF89qbNRfy6s9
# R7WhA9g8pQTTm+sP63Mg/z5I7Z1O9iLY8H7avbboLJMhkqSOt9b18Gvyj/Lp69mA
# 8Cc6+JyVdOhbbH3JqZWt+sHcWdnVMSuL5wyCmiGofV5lMCPHZ1Gimeu2Atpby8TV
# EXwpgZ2BBHBEmTnafu3TqtoCt+iRaRxZkOvZMK5sFAYW/81Gn1AgsOpwlqZko7ke
# EXEzS/oUFM95tLriUBTEtKJODkbcFIPAVtTEZX95NFSh+N4eVwU/Wl/mzKkN4bUb
# jOnwM3n3IdRpaQo0teJcYhK1PoK14lv/Xts2oeg0TzPjp3sooRYkmRvjYPUJ1pdY
# O5cbQ/1QTy9IEcdoF0TElbU3vgdP9hlBiD+w2uM/ewPawCjUogU90ZQsJwIDAQAB
# o4ICGDCCAhQwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOwYDVR0lBDQw
# MgYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGisGAQQBgjdhgZrRmhbY3vVrgb36hVz5
# gO8bMB0GA1UdDgQWBBT8lxyLyT4PpqWQki4P/1oXEssSujAfBgNVHSMEGDAWgBQk
# RZmhd5AqfMPKg7BuZBaEKvgsZzBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAyLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# Mi5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQAzu+aOayoADwifsLs94wcy
# +WKmr3oTYjBnNwiS/WKytM34GJ6pg7w8zTVzVc2WhpovOMFGG53+6hx5BAEajr66
# 6t+GZAG1KlOyEeGuzJHCD5xfdXx4P4YAbBZS9DAaeN8Pi/I69fSuvt4yIwNvcXpb
# wIpeOh/BxyTGOzCyVgzT1DBely9t98wTCuey8t/0txaf+Q5vi0+5HuI12Fu8htxb
# EbmYzT7p3J4BSlWfTbRTwlJZAsMRA85tuvhU8dLDCLcYk3HpyaKZf55Oxjg4fPxr
# JvbFdPTnDTCLEl3vhSvItp2nKeff7Vt0H+dh7r6pG/tzkOsp79zd85uj7npYTP60
# C3argbYzMDMdQigKRgwDJYBY6jSePZCvlxDnYnGBjuQDwhHkCFEMBCTgfKT8K/RN
# DgCx9XVU6qZ4Zu4deVawVtROmXCpvLq01YnJ1xE/kOGiZ3xYCtxNPcmrSx1EjG6H
# UujOfovMQh4hmeKUCi8T4Aon/xJxsrHqnd9T4JN/gvh6LEANv5IqU341lV2dglj5
# sY+49tZD17ZMAMRBIP74a/PTeSzSPjNKRvQTEsHjVyNv/x64BvjW0tOlVXHV9mw9
# X9VOzc81/xa/OIjZvlPXkVMtPtS/6wW7Od91p+S/wCfvpHYkDaKv1K5wGGVju9t0
# nuy4Htoq19PwKP9W9MqP5DCCB1owggVCoAMCAQICEzMAAAAEllBL0tvuy4gAAAAA
# AAQwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTJaFw0yNjA0MTMx
# NzMxNTJaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0Eg
# MDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDhzqDoM6JjpsA7AI9s
# GVAXa2OjdyRRm5pvlmisydGnis6bBkOJNsinMWRn+TyTiK8ElXXDn9v+jKQj55cC
# pprEx3IA7Qyh2cRbsid9D6tOTKQTMfFFsI2DooOxOdhz9h0vsgiImWLyTnW6locs
# vsJib1g1zRIVi+VoWPY7QeM73L81GZxY2NqZk6VGPFbZxaBSxR1rNIeBEJ6TztXZ
# sz/Xtv6jxZdRb3UimCBFqyaJnrlYQUdcpvKGbYtuEErplaZCgV4T4ZaspYIYr+r/
# hGJNow2Edda9a/7/8jnxS07FWLcNorV9DpgvIggYfMPgKa1ysaK/G6mr9yuse6cY
# 0Hv/9Ca6XZk/0dw6Zj9qm2BSfBP7bSD8DfuIN+65XDrJLYujT+Sn+Nv4ny8TgUyo
# iLDEYHIvjzY8xUELep381sVBrwyaPp6exT4cSq/1qv4BtwrC6ZtmokkqZCsZpI11
# Z+TY2h2BxY6aruPKFvHBk6OcuPT9vCexQ1w0B7T2/6qKjPJBB6zwDdRc9xFBvwb5
# zTJo7YgKJ9ZMrvJK7JQnzyTWa03bYI1+1uOK2IB5p+hn1WaGflF9v5L8rlqtW9Nw
# u6S3k91MNDGXnnsQgToD7pcUGl2yM7OQvN0SHsQuTw9U8yNB88KAq0nzhzXt93YL
# 36nEXWURBQVdj9i0Iv42az1xZQIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBQkRZmhd5AqfMPKg7BuZBaEKvgs
# ZzBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAGct
# OF2Vsw0iiR0q3NJryKj6kQ73kJzdU7Jj+FCwghx0zKTaEk7Mu38zVZd9DISUOT9C
# 3IvNfrdN05vkn6c7y3SnPPCLtli8yI2oq8BA7nSww4mfdPeEI+mnE02GgYVXHPZT
# KJDhva86tywsr1M4QVdZtQwk5tH08zTBmwAEiG7iTpVUvEQN7QZJ5Bf9kTs8d9OD
# jgu5+3ggqpiae/UK6iyneCUVixV6AucxZlRnxS070XxAKICi4liEvk6UKSyANv29
# 78dCEsWd6V+Dp1C5sgWyoH0iUKidgoln8doxm9i0DvL0Q5ErhzGW9N60JcAdrKJJ
# cfS54T9P3bBUbRyy/lV1TKPrJWubba+UpgCRcg0q8M4Hz6ziH5OBKGVRrYAK7YVa
# fsnOVNJumTQgTxES5iaS7IT8FOST3dYMzHs/Auefgn7l+S9uONDTw57B+kyGHxK4
# 91AqqZnjQjhbZTIkowxNt63XokWKZKoMKGCcIHqXCWl7SB9uj3tTumult8EqnoHa
# TZ/tj5ONatBg3451w87JAB3EYY8HAlJokbeiF2SULGAAnlqcLF5iXtKNDkS5rpq2
# Mh5WE3Qp88sU+ljPkJBT4kLYfv3Hh387pg4VH1ph7nj8Ia6nt1FQh8tK/X+PQM9z
# oSV/djJbGWhaPzJ5jeQetkVoCVEzCEBfI9DesRf3MIIHnjCCBYagAwIBAgITMwAA
# AAeHozSje6WOHAAAAAAABzANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQGEwJVUzEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9NaWNyb3Nv
# ZnQgSWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
# aXR5IDIwMjAwHhcNMjEwNDAxMjAwNTIwWhcNMzYwNDAxMjAxNTIwWjBjMQswCQYD
# VQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTQwMgYDVQQD
# EytNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ29kZSBTaWduaW5nIFBDQSAyMDIxMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsvDArxmIKOLdVHpMSWxpCFUJ
# tFL/ekr4weslKPdnF3cpTeuV8veqtmKVgok2rO0D05BpyvUDCg1wdsoEtuxACEGc
# gHfjPF/nZsOkg7c0mV8hpMT/GvB4uhDvWXMIeQPsDgCzUGzTvoi76YDpxDOxhgf8
# JuXWJzBDoLrmtThX01CE1TCCvH2sZD/+Hz3RDwl2MsvDSdX5rJDYVuR3bjaj2Qfz
# ZFmwfccTKqMAHlrz4B7ac8g9zyxlTpkTuJGtFnLBGasoOnn5NyYlf0xF9/bjVRo4
# Gzg2Yc7KR7yhTVNiuTGH5h4eB9ajm1OCShIyhrKqgOkc4smz6obxO+HxKeJ9bYmP
# f6KLXVNLz8UaeARo0BatvJ82sLr2gqlFBdj1sYfqOf00Qm/3B4XGFPDK/H04kteZ
# EZsBRc3VT2d/iVd7OTLpSH9yCORV3oIZQB/Qr4nD4YT/lWkhVtw2v2s0TnRJubL/
# hFMIQa86rcaGMhNsJrhysLNNMeBhiMezU1s5zpusf54qlYu2v5sZ5zL0KvBDLHtL
# 8F9gn6jOy3v7Jm0bbBHjrW5yQW7S36ALAt03QDpwW1JG1Hxu/FUXJbBO2AwwVG4F
# re+ZQ5Od8ouwt59FpBxVOBGfN4vN2m3fZx1gqn52GvaiBz6ozorgIEjn+PhUXILh
# AV5Q/ZgCJ0u2+ldFGjcCAwEAAaOCAjUwggIxMA4GA1UdDwEB/wQEAwIBhjAQBgkr
# BgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU2UEpsA8PY2zvadf1zSmepEhqMOYwVAYD
# VR0gBE0wSzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3FAIE
# DB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFMh+0mqF
# KhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmgd6B1hnNodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJZGVudGl0eSUyMFZl
# cmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhvcml0eSUyMDIw
# MjAuY3JsMIHDBggrBgEFBQcBAQSBtjCBszCBgQYIKwYBBQUHMAKGdWh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwSWRlbnRp
# dHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3Jp
# dHklMjAyMDIwLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9z
# b2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQB/JSqe/tSr6t1mCttXI0y6
# XmyQ41uGWzl9xw+WYhvOL47BV09Dgfnm/tU4ieeZ7NAR5bguorTCNr58HOcA1tcs
# HQqt0wJsdClsu8bpQD9e/al+lUgTUJEV80Xhco7xdgRrehbyhUf4pkeAhBEjABvI
# UpD2LKPho5Z4DPCT5/0TlK02nlPwUbv9URREhVYCtsDM+31OFU3fDV8BmQXv5hT2
# RurVsJHZgP4y26dJDVF+3pcbtvh7R6NEDuYHYihfmE2HdQRq5jRvLE1Eb59PYwIS
# FCX2DaLZ+zpU4bX0I16ntKq4poGOFaaKtjIA1vRElItaOKcwtc04CBrXSfyL2Op6
# mvNIxTk4OaswIkTXbFL81ZKGD+24uMCwo/pLNhn7VHLfnxlMVzHQVL+bHa9KhTyz
# wdG/L6uderJQn0cGpLQMStUuNDArxW2wF16QGZ1NtBWgKA8Kqv48M8HfFqNifN6+
# zt6J0GwzvU8g0rYGgTZR8zDEIJfeZxwWDHpSxB5FJ1VVU1LIAtB7o9PXbjXzGifa
# IMYTzU4YKt4vMNwwBmetQDHhdAtTPplOXrnI9SI6HeTtjDD3iUN/7ygbahmYOHk7
# VB7fwT4ze+ErCbMh6gHV1UuXPiLciloNxH6K4aMfZN1oLVk6YFeIJEokuPgNPa6E
# nTiOL60cPqfny+Fq8UiuZzGCGpQwghqQAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMgITMwACAZUj3BIW6de7EgAAAAIBlTAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCAskNpEU4FwoFs+6McJnkBxnyFa
# LsEYoZsNLSKtAr1TgDANBgkqhkiG9w0BAQEFAASCAYBajwZb8opQHbAvJx7ClLbN
# 0GRXN+FOy35H1mkXOpbRUIezwlwHXu4TMjdXjIyJMRlRKJLJJ5b3kxWR/p9uU6Kw
# Z7NwrxdCp9uHlAE2AtbMrPHSojK0yNhWzLF9a00ZoRgjyD3kcWieOT1qQOu8fiS4
# cuNsGkTDSNSSe9mMXAL5E8kOtBiv9kCYV1y4o+s63uWn/A0dOJ8+rXd72c0x8WGN
# aNrrhkCshFC7Yw0YexNO9Z8bLhnv51fZzdzcejItTRpA/9FfRJvKW8iBfUiZnFPz
# 0PNTxv0M+rtZKFYR05F91wu48wn1KPrBCBj7savvP2kwNHUtqqOArq99b32uD2pD
# eELBOPH4atZv/no1JJSVChps3a8L4UdlIxVY3H3qzSVRAuY/zVbrQy5W2vfRDGov
# SA4ooDNXj4QA3CaCTcg+fITg7WyFrErJPiSBrpmzOaS02WAIR3TuYQsnFKU18HoE
# cKX8vmedM5KaceCIYa3fOBz5LPqrzIuUrv9yiLwxxNOhghgUMIIYEAYKKwYBBAGC
# NwMDATGCGAAwghf8BgkqhkiG9w0BBwKgghftMIIX6QIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYgYLKoZIhvcNAQkQAQSgggFRBIIBTTCCAUkCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQg9KfzhDTc3N+G/NExT5O2PefmWoN/NPGcHEqYJnea
# JyICBmdEXClnUBgTMjAyNDEyMDEyMzEyNTMuODE5WjAEgAIB9KCB4aSB3jCB2zEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWlj
# cm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1Mg
# RVNOOkE1MDAtMDVFMC1EOTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJT
# QSBUaW1lIFN0YW1waW5nIEF1dGhvcml0eaCCDyEwggeCMIIFaqADAgECAhMzAAAA
# BeXPD/9mLsmHAAAAAAAFMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29m
# dCBJZGVudGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3Jp
# dHkgMjAyMDAeFw0yMDExMTkyMDMyMzFaFw0zNTExMTkyMDQyMzFaMGExCzAJBgNV
# BAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
# KU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnnznUmP94MWfBX1jtQYioxwe1+eX
# M9ETBb1lRkd3kcFdcG9/sqtDlwxKoVIcaqDb+omFio5DHC4RBcbyQHjXCwMk/l3T
# OYtgoBjxnG/eViS4sOx8y4gSq8Zg49REAf5huXhIkQRKe3Qxs8Sgp02KHAznEa/S
# sah8nWo5hJM1xznkRsFPu6rfDHeZeG1Wa1wISvlkpOQooTULFm809Z0ZYlQ8Lp7i
# 5F9YciFlyAKwn6yjN/kR4fkquUWfGmMopNq/B8U/pdoZkZZQbxNlqJOiBGgCWpx6
# 9uKqKhTPVi3gVErnc/qi+dR8A2MiAz0kN0nh7SqINGbmw5OIRC0EsZ31WF3Uxp3G
# gZwetEKxLms73KG/Z+MkeuaVDQQheangOEMGJ4pQZH55ngI0Tdy1bi69INBV5Kn2
# HVJo9XxRYR/JPGAaM6xGl57Ei95HUw9NV/uC3yFjrhc087qLJQawSC3xzY/EXzsT
# 4I7sDbxOmM2rl4uKK6eEpurRduOQ2hTkmG1hSuWYBunFGNv21Kt4N20AKmbeuSnG
# nsBCd2cjRKG79+TX+sTehawOoxfeOO/jR7wo3liwkGdzPJYHgnJ54UxbckF914Aq
# HOiEV7xTnD1a69w/UTxwjEugpIPMIIE67SFZ2PMo27xjlLAHWW3l1CEAFjLNHd3E
# Q79PUr8FUXetXr0CAwEAAaOCAhswggIXMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEE
# AYI3FQEEAwIBADAdBgNVHQ4EFgQUa2koOjUvSGNAz3vYr0npPtk92yEwVAYDVR0g
# BE0wSzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEF
# BQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFMh+0mqFKhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmg
# d6B1hnNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3Nv
# ZnQlMjBJZGVudGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0
# ZSUyMEF1dGhvcml0eSUyMDIwMjAuY3JsMIGUBggrBgEFBQcBAQSBhzCBhDCBgQYI
# KwYBBQUHMAKGdWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMv
# TWljcm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2Vy
# dGlmaWNhdGUlMjBBdXRob3JpdHklMjAyMDIwLmNydDANBgkqhkiG9w0BAQwFAAOC
# AgEAX4h2x35ttVoVdedMeGj6TuHYRJklFaW4sTQ5r+k77iB79cSLNe+GzRjv4pVj
# JviceW6AF6ycWoEYR0LYhaa0ozJLU5Yi+LCmcrdovkl53DNt4EXs87KDogYb9eGE
# ndSpZ5ZM74LNvVzY0/nPISHz0Xva71QjD4h+8z2XMOZzY7YQ0Psw+etyNZ1Cesuf
# U211rLslLKsO8F2aBs2cIo1k+aHOhrw9xw6JCWONNboZ497mwYW5EfN0W3zL5s3a
# d4Xtm7yFM7Ujrhc0aqy3xL7D5FR2J7x9cLWMq7eb0oYioXhqV2tgFqbKHeDick+P
# 8tHYIFovIP7YG4ZkJWag1H91KlELGWi3SLv10o4KGag42pswjybTi4toQcC/irAo
# dDW8HNtX+cbz0sMptFJK+KObAnDFHEsukxD+7jFfEV9Hh/+CSxKRsmnuiovCWIOb
# +H7DRon9TlxydiFhvu88o0w35JkNbJxTk4MhF/KgaXn0GxdH8elEa2Imq45gaa8D
# +mTm8LWVydt4ytxYP/bqjN49D9NZ81coE6aQWm88TwIf4R4YZbOpMKN0CyejaPNN
# 41LGXHeCUMYmBx3PkP8ADHD1J2Cr/6tjuOOCztfp+o9Nc+ZoIAkpUcA/X2gSMkgH
# APUvIdtoSAHEUKiBhI6JQivRepyvWcl+JYbYbBh7pmgAXVswggeXMIIFf6ADAgEC
# AhMzAAAAPH8boMoAN0W5AAAAAAA8MA0GCSqGSIb3DQEBDAUAMGExCzAJBgNVBAYT
# AlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1p
# Y3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMB4XDTI0MDIx
# NTIwMzYxNloXDTI1MDIxNTIwMzYxNlowgdsxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJh
# dGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpBNTAwLTA1RTAtRDk0NzE1
# MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRo
# b3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCnDe//ojOwzNBB
# w9wNfKA4WdFtB/VMHCYNro/Kd1epcO7wd/yzu2RI2dnDDBaE3cs5ncQEIzqMDh0s
# zGpGwrs6fX1MjAqSVY7LBAVzNUHlcObXOu5uZz2OFeIF+dzCnY3ObPoWITNm+W3P
# aV2KynksSNN0wLrwxLYrTMjFcjCNgW1QFCicSnuiaUCs8v0SGqEP1wBXmq4fkqen
# 9rDMZECBVNebqhu8JJopB0JnLSpPX+2GdBLwElZr9KN3ky3wW5VWZWD0/MG2E6jF
# UpslIt5AdFxFFkj8bwpONd+4Mzx6WyECWkSjnRNqnHYvgAC3h9yayICcwD7kGwd4
# wJ0NyoxMFEfbYfmJiKkt57pCgTs8LD06E0Rt2+XfJXqjX8j5S+JXXabfEcq3I9Y7
# m9/fo8eroRQ3AvZ+YmBcpzEkXgR5j1RKabaGZLXa7LG/8LPuKr+m4JlzbqjnaWQb
# 5Ket98Ei3i4BvMzkYr6hDOX+4KxVrtquq5k1Vhfp7Mm6755qaTliFaopNz/OUr5j
# v8NcXLzBHzZloE89IxvEH3t5+KDECUOTMkmUu99HsrNtXLafyQFi4ZPGEtxoBRgd
# eYwIRcYfOOWDXPqsWSQwhgipmZEhii/O7nuQajgR59oYMSvh4KW3Iv8RE3P7IPQ0
# mZNZHRES3wSY3mr/2yXbwo58dMqb9wIDAQABo4IByzCCAccwHQYDVR0OBBYEFOMb
# c5owZAppDI08HVM7rw3JXoeVMB8GA1UdIwQYMBaAFGtpKDo1L0hjQM972K9J6T7Z
# PdshMGwGA1UdHwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2lvcHMvY3JsL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGlu
# ZyUyMENBJTIwMjAyMC5jcmwweQYIKwYBBQUHAQEEbTBrMGkGCCsGAQUFBzAChl1o
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUy
# MFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwZgYDVR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRt
# MAgGBmeBDAEEAjANBgkqhkiG9w0BAQwFAAOCAgEAYk7MvLholtMf9TZ28dsNVnMc
# jGBSJOPvKj5T9DRxPHFpZ1AA1O2klmO+zdzKfbVKowaVcGzei0ib3eePQRQpT5DI
# 9kNyD6h/WncjkUN98MnGSxUGiEcMvtDSeSKnXwpJVVWWDdDxvdt6MOTtdrglH+Jl
# 1hrXhNwTsF+uJ1jNRmHSZS7Tis4vjIKDQl6UEvStL7eEYvy2UZ9HclEpK9Ds7ypa
# UKLQgPOaMbGxvmMpJGeTj5ou/GWqA7QhO5my4c01wszRBoBF7eR34rBU11bdcJsH
# 2UMU6I7rOvdaGw1XIqOyWF8Y4HIkLpMj5DPz0mWqcOA5EhlR+ZMM5kt+27SAXjpi
# dF6RgLeDxlxlSeQcaEyIuxZKyOUMrL43vlybAsQwRlyULiwgPbljazjW2qnP9eF8
# oH7779THcbFzmX6US1/t0ffeRaU0iXxmwVe7LN5R4S4aOJSIHAQjL66fh9eJoRPA
# N5KEtmv3vQbBQ07402DcpO0ky7boj5NhDWorKJzq3cppgf/0b8C/7WRGya30C4dg
# bnJ/ZHCIyeve4tvlaPrczDo7nAdpcCHIhQN5XhOmwsGPMfk5iR6IsJSFrJnt7gdR
# BoTGLyEEPdkq7a3kP3QmLq4/46SEs/Aurmiv3eeF6zbyWVm8sgeD+MMWEX4YbDGv
# vxh5XI8PYU+u1QP+JkIxggdGMIIHQgIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAPH8boMoAN0W5AAAA
# AAA8MA0GCWCGSAFlAwQCAQUAoIIEnzARBgsqhkiG9w0BCRACDzECBQAwGgYJKoZI
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yNDEyMDEyMzEy
# NTNaMC8GCSqGSIb3DQEJBDEiBCCSHmmXmHBw3Qy0zxvR2KQzrx79sepcOSefAJG3
# E6QHmTCBuQYLKoZIhvcNAQkQAi8xgakwgaYwgaMwgaAEIFqfp4iRv0gaMubqvGC4
# di42Y4hsCBMMHWhRlTSShLjbMHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAPH8boMoAN0W5AAAAAAA8
# MIIDYQYLKoZIhvcNAQkQAhIxggNQMIIDTKGCA0gwggNEMIICLAIBATCCAQmhgeGk
# gd4wgdsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNV
# BAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGll
# bGQgVFNTIEVTTjpBNTAwLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHmiIwoBATAHBgUrDgMCGgMV
# ANJMC0nWnsDHBXhCaT90FwjHNR8joGcwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMA0GCSqGSIb3DQEBCwUAAgUA
# 6vbDrjAiGA8yMDI0MTIwMTExMTQ1NFoYDzIwMjQxMjAyMTExNDU0WjB3MD0GCisG
# AQQBhFkKBAExLzAtMAoCBQDq9sOuAgEAMAoCAQACAglCAgH/MAcCAQACAhKeMAoC
# BQDq+BUuAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEA
# AgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAFuZ9Bs5dxFT1WVx
# vXO3OLX+KBaeTae3eCodFg8Cu316M6EuWk/cJ3biKsjx3Bx+9lUBi/9Jcq5Hkmmm
# F3RmV3blafW68n0QwB9c9fuzk33hYuypAEpVdL0DMTfYIsiVgM7THF+0ZdVfE1Jg
# vQ2hbQH224J7MXXfs3+XCnP/5INT7HPxneoyRgkay0EsbiycFu+fQnFWtHbFn6OQ
# Jw+mT/RAE9hiXcqVAjSXxOMBwawq80B2Zfd7jENvx0TLzGdsg/tuLDsRVLLQC5oN
# VXqWt1NzhBZjMsdp+A1ZXSlo4d/MX9CuqvBBvpUaJ/DfpQkeCdXfGYerKE16XF8q
# xyYWqcUwDQYJKoZIhvcNAQEBBQAEggIAmT9sGl4NQaRzhxASrqxVl7VH92ycr5yO
# +sDhEciaJT4oAIsjgCEreBqm4a4T3JSyKQpKARBDJ7ULOeQbL7pzB8+vSLvYOXJt
# qxx/DDooD6RhcPA8uE67QNHKPfG/u1BuDmOiiDywAEUerGZ/XxqGZq6BXTi/W2HQ
# 9TDpaClfi4aXR+wmPcAC2EHVKlsOVzOoadtjdeU42swO3MvZqRuzgRzqUWCrUb8w
# zNZdEEaKEJWihOih7dE+ZS3+Qg5f+rNnI3JpgjMDTuOvYunJnN0S++vWBGqCwBNf
# CckhgfJtDhV4iaob7MHyHe069Ixxb2JlXjegVg8/NHgE66BZB16P5R6OXF4AkJ8i
# iOOeOXogVGOQAsqslqL6g3s4bhKN+6W0n9/HMRY6BxoKrEGhsGCplFKsG21ivZSx
# tHSZIoVWzIVW3YBXBdtqE0EctIbtIi9/gHqvBPpi7jBzZzkZVPurKzSzBVI81NgO
# BpvejGFuD7242wc+GfkFqd0lAkxP8e9LOxZCTuAaKwHux4c632wGmV1mVJAJ4PfY
# 0Er3RXqNsdYxgYEDh+Sm8+8YcJhAliSGoNL2kEQVkrOLkSPaQ7GNIf4ivwGPBCzW
# 9HCufIEkoSOwbrMuOULrPzkQLFYeAZwFzZLIs0/4PCikSOANINTXpR+HUnYfZuqJ
# 2TcWt0KgH10=
# SIG # End signature block
