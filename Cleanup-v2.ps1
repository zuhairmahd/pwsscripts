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
    'Microsoft.Cortana',
    'DropboxInc.Dropbox',
    'Microsoft.XboxGameOverlay',
    'Microsoft.BingNews',
    'Microsoft.BingWeather',
    'Microsoft.Windows.PeopleExperienceHost',
    'Microsoft.XboxGamingOverlay',
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
    # Write-Host "Checking whether $($appxprov.DisplayName) is in the list of apps to be removed"
    if ($AppsToRemove -match $appxprov.DisplayName) {
        Write-Host "$($appxprov.DisplayName) Version $($appxprov.version) will be removed"
        #add it to an array of apps to remove
        $PackagesToRemove += $appxprov
    }
    else {
        Write-Host "$($appxprov.DisplayName) version $($appxprov.version) will not be removed"
    }
}

#Let's remove those packages we got from above from the image
foreach ($PackageToRemove in $PackagesToRemove) {
    $PackageDisplayName = $PackageToRemove.DisplayName
    $PackageName = $PackageToRemove.PackageName
    $PackageVersion = $PackageToRemove.Version
    Write-Host "Removing $PackageDisplayName Version $PackageVersion from the image"
    try {
        Remove-AppxProvisionedPackage -PackageName $PackageName -Online -ErrorAction SilentlyContinue
        Write-Host "Removed $PackageDisplayName version $PackageVersion from the image"
    }
    catch {
        Write-Host "Unable to remove $PackageDisplayName version $PackageVersion"
    }
    # If it is installed in any user profile, remove it for all users
    # Write-Host "Checking to see if $PackageDisplayName version $PackageVersion has ever been installed in a users profile"
    # $InstalledPackage = Get-AppxPackage -Name $PackageDisplayName -AllUsers
    # if ($InstalledPackage) {
    # Write-Host "$PackageDisplayName version $PackageVersion is installed. . Removing for all users."
    # try {
    # $InstalledPackage | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    # Write-Host "Removed $PackageDisplayName version $PackageVersion for all users."
    # }
    # catch {
    # Write-Host "Unable to remove $PackageDisplayName version $PackageVersion for all users."
    # }
    # }
    # else {
    # Write-Host "$PackageDisplayName has not been installed in any users profile."
    # }
}

#we are done.
Write-Host "Cleanup completed. Please check the log file at $LogFolder\$LogFile for more details"
Stop-Transcript