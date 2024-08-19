Set-ExecutionPolicy -scope Process -ExecutionPolicy Bypass -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    #Check if the folder where the device hash file will be created exists
    if(-not (Test-Path -Path "C:\HWID")) {
        #Create the folder to store the HWID file
        New-Item -Type Directory -Path "C:\HWID" -ErrorAction Stop | Out-Null
    }
    #Change to the folder containing the device hash
    Set-Location -Path "C:\HWID" -ErrorAction Stop
    #add the Powershell scripts folder to the path
    $env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
    # Check if NuGet is installed
    $nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
    if ($null -eq $nuget) {
        # If NuGet is not installed, install it
        Install-PackageProvider -Name NuGet -Force -ErrorAction Stop | Out-Null
    }
    # Now let's see if the autopilot info script is installed
    if (-not (Test-Path -Path "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutoPilotInfo.ps1")) {
        # Set the execution policy
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -ErrorAction Stop | Out-Null
        # Install the script
        Install-Script -Name Get-WindowsAutopilotInfo -force -ErrorAction Stop | Out-Null
    }
    # Get the device hash
    Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv -ErrorAction Stop | Out-Null
    if (Test-Path -Path "C:\HWID\AutopilotHWID.csv") {
        # Copy the output file to the network share
        # Copy-Item -Path .\AutopilotHWID.csv -Destination \\raspberrypi\pi -ErrorAction Stop | Out-Null
        # Send the output file as an email using Outlook
        $Outlook = New-Object -ComObject Outlook.Application
        $Mail = $Outlook.CreateItem(0)
        $Mail.Subject = "AutopilotHWID.csv" 
        $Mail.Body = "Please find attached the AutopilotHWID.csv file."
        $Mail.Attachments.Add((Resolve-Path .\AutopilotHWID.csv).Path)
        $Mail.To = "mahmoudz@gao.gov"
        $Mail.Send()
    }

    # If all commands execute successfully, return 0
    exit 0
}
catch {
    # If any command throws an error, write the error and return a non-zero exit code
    Write-Error $_.Exception
    exit 1
}
