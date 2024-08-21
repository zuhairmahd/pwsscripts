#a PowerShell script to create desktop shortcuts for all users


#Initialize variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'DesktopShortcuts.log'

#Create an array of a list of apps to create a shortcut for, each with the app name, app path, working directory and the shortcut name
$apps = @(
    @{AppName = 'Outlook' ; AppPath = 'C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE' ; ShortcutName = 'Outlook' ; WorkingDirectory = 'C:\Program Files\Microsoft Office\root\Office16' },
    @{AppName = 'Microsoft Teams' ; AppPath = 'C:\Users\MahmoudZ\AppData\Local\Microsoft\WindowsApps\MSTeams_8wekyb3d8bbwe\ms-teams' ; ShortcutName = 'Microsoft Teams' ; WorkingDirectory = 'C:\Users\MahmoudZ\AppData\Local\Microsoft\WindowsApps\MSTeams_8wekyb3d8bbwe' },
    @{AppName = 'Zoom Workplace' ; AppPath = 'C:\Program Files\Zoom\bin\Zoom.exe'; ShortcutName = 'Zoom Workplace' ; WorkingDirectory = 'C:\Program Files\Zoom\bin' },
    @{AppName = 'Adobe Acrobat' ; AppPath = 'C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe' ; ShortcutName = 'Adobe Acrobat' ; WorkingDirectory = 'C:\Program Files\Adobe\Acrobat DC\Acrobat' },
    @{AppName = 'Google Chrome' ; AppPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe' ; ShortcutName = 'Google Chrome' ; WorkingDirectory = 'C:\Program Files\Google\Chrome\Application' },
    @{AppName = 'Microsoft Edge' ; AppPath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' ; ShortcutName = 'Microsoft Edge' ; WorkingDirectory = 'C:\Program Files (x86)\Microsoft\Edge\Application' }
)

$InternetShortcuts = @(
    @{AppName = 'Connect to VDI' ; AppPath = 'https://workspace.gao.gov/' ; ShortcutName = 'VDI Storefront' }
)

#let's create the logs
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript -IncludeInvocationHeader -Path $LogFolder\$LogFile -Append -Force 

try {
    $WScriptShell = New-Object -ComObject WScript.Shell -ErrorAction Stop
    #Loop through each app in the array
    foreach ($app in $apps) {
        #Check if the app path exists, and if so create the shortcut
        if (-not (Test-Path $app.AppPath)) {
            Write-Host $app.AppName not found at $app.AppPath so shortcut is skipped
        }
        else {
            Write-Output "Checking to see if a shortcut to $($app.AppName) already exists"
            If ((Test-Path "$env:Public\Desktop\$($app.ShortcutName).lnk") -or (Test-Path "$env:OneDrive\Desktop\$($app.ShortcutName).lnk")) {
                Write-Output "Shortcut to $($app.AppName) already exists. Skipping."
            }
            else {
                Write-Host Creating a shortcut to $app.AppName
                $Shortcut = $WScriptShell.CreateShortcut("$env:Public\Desktop\$($app.ShortcutName).lnk")
                $Shortcut.TargetPath = $app.AppPath
                $Shortcut.WorkingDirectory = $app.WorkingDirectory
                $Shortcut.Save()
                Write-Host Shortcut to $app.AppName created
            }
        }
    }
    #now let's create the internet shortcuts
    foreach ($InternetShortcut in $InternetShortcuts) {
        Write-Host "Checking to see if a shortcut to $($InternetShortcut.AppName) exists."
        #Check if the shortcut already exists in which case skip shortcut creation
        If ((Test-Path "$env:Public\Desktop\$($InternetShortcut.ShortcutName).url") -or (Test-Path "$env:OneDrive\Desktop\$($InternetShortcut.ShortcutName).url")) {
            Write-Output "Shortcut to $($InternetShortcut.AppName) already exists. Skipping."
        }
        else {
            Write-Host Creating a shortcut to $($InternetShortcut.AppName) 
            $Shortcut = $WScriptShell.CreateShortcut("$env:Public\Desktop\$($InternetShortcut.ShortcutName).url")
            $Shortcut.TargetPath = $InternetShortcut.AppPath
            $Shortcut.Save()
            Write-Host Shortcut to $InternetShortcut.AppName created
        }
    }
    #we've made it this far, so let's celebrate
    Write-Host 'All shortcuts created successfully'
    exit 0
}

catch {
    <#Do this if a terminating exception happens#>
    Write-Host "An error occurred: $_"
    Stop-Transcript
    exit 1
} 

Stop-Transcript