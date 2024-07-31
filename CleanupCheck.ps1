#define variables

$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'AppCheck.log'
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
    'Microsoft.Xbox', #Xbox
    'Microsoft.Xbox.TCUI', #Xbox Console Companion
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


#Let's see if any of the apps above are installed
$InstalledApps = Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
ForEach ($App in $InstalledApps) {
    If ($AppsToRemove -contains $App.Name) {
        Write-Output "Found $($App.Name) in the blacklist.  Marking for removal."
        $PackagesToRemove += $App.PackageFullName
    }
    else {
        Write-Output "$($App.Name) is not in the black list.  Keeping."
    }
}



#If there are any apps to be uninstalled, write them to a text file and return exit 1
If ($PackagesToRemove) {
    Write-Output "The following apps will be removed: $($PackagesToRemove)"
    $PackagesToRemove | Out-File -FilePath $LogFolder\UninstallList.txt
    Write-Output "Uninstall list written to $LogFolder\UninstallList.txt"
    Write-Output 'Exiting with code 1'
    Exit 1
}
Else {
    Write-Output 'No apps to remove.  Exiting with code 0'
    Exit 0
}

#we are done.
Write-Host "Cleanup completed. Please check the log file at $LogFolder\$LogFile for more details"
Stop-Transcript