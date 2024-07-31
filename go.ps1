#Powershell script to extract and modify multiple windows 11 images

$range = 4..11
$MountFolder = 'C:\Users\zuhai\Downloads\win\amd64\mount'
$wimFile = 'C:\Users\zuhai\Downloads\win\Win11_23H2_English_x64v2\sources\install.wim'
$CopyToFolder = 'C:\Users\zuhai\Downloads\win\amd64\mount\Windows\Provisioning\Autopilot'
$FileToCopy = 'C:\Users\zuhai\Downloads\win\AutopilotConfigurationFile.json'
$MakeMediaCommand = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\MakeWinPEMedia.cmd'
$IsoFileName = 'Win11_23H2_English_x64v2-modified.iso'
$IsoFolder = 'C:\Users\zuhai\Downloads\win\amd64'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'ImmageModification.log'
#Do not crash on errors
$ErrorActionPreference = 'SilentlyContinue'
#define a hashtable to hold the image information
$imageInfo = @{
    1  = @{
        Name        = 'Windows 11 Home'
        Description = 'Windows 11 Home'
        Size        = 18638211254
    }
    2  = @{
        Name        = 'Windows 11 Home N'
        Description = 'Windows 11 Home N'
        Size        = 17934599136
    }
    3  = @{
        Name        = 'Windows 11 Home Single Language'
        Description = 'Windows 11 Home Single Language'
        Size        = 18601483355
    }
    4  = @{
        Name        = 'Windows 11 Education'
        Description = 'Windows 11 Education'
        Size        = 18903797223
    }
    5  = @{
        Name        = 'Windows 11 Education N'
        Description = 'Windows 11 Education N'
        Size        = 18240856138
    }
    6  = @{
        Name        = 'Windows 11 Pro'
        Description = 'Windows 11 Pro'
        Size        = 18936584427
    }
    7  = @{
        Name        = 'Windows 11 Pro N'
        Description = 'Windows 11 Pro N'
        Size        = 18259385629
    }
    8  = @{
        Name        = 'Windows 11 Pro Education'
        Description = 'Windows 11 Pro Education'
        Size        = 18903747433
    }
    9  = @{
        Name        = 'Windows 11 Pro Education N'
        Description = 'Windows 11 Pro Education N'
        Size        = 18240805448
    }
    10 = @{
        Name        = 'Windows 11 Pro for Workstations'
        Description = 'Windows 11 Pro for Workstations'
        Size        = 18903772328
    }
    11 = @{
        Name        = 'Windows 11 Pro N for Workstations'
        Description = 'Windows 11 Pro N for Workstations'
        Size        = 18240830793
    }
}

#Create Folder to keep logs
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Appending to $LogFolder\$LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript $LogFolder\$LogFile -Append -IncludeInvocationHeader

#loop through the range, extract, copy then repack
foreach ($i in $range) {
    $index = $i
    if ($imageInfo[$index].name -eq 'Windows 11 Pro') {
        Write-Host "Mounting image $_.name"
        Mount-WindowsImage -ImagePath $wimFile -Index $index -Path $MountFolder -ErrorAction $ErrorActionPreference
        try {
            Write-Host "Copying $FileToCopy to $CopyToFolder in image $_.name"
            Copy-Item $FileToCopy -Destination $CopyToFolder -Force -ErrorAction $ErrorActionPreference
        }
        catch {
            Write-Host an error has occurred
            Write-Host "Error: $_.Exception.Message" | Out-File -Append $LogFolder\$LogFile
            Write-Host "Error: $_.Exception.Message"
            exit 1
        }
        #now let's commit the image
        Write-Host "Committing image $_.name""
        Write-Host "Now unmounting image $_.name"
        Dismount-WindowsImage -Path $mountFolder -Save -CheckIntegrity -ErrorAction $ErrorActionPreference
    }
}

Write-Host 'Creating ISO'
& $MakeMediaCommand /ISO /f $IsoFolder $IsoFileName
Write-Host 'done'
Stop-Transcript
