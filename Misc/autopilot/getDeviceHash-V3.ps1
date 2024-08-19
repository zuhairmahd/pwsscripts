[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    #Check if the folder where the device hash file will be created exists
    if(-not (Test-Path -Path "C:\HWID")) {
        #Create the folder to store the HWID file
        New-Item -Type Directory -Path "C:\HWID" -ErrorAction Stop | Out-Null
    }
    # Get the device hash
    .\Get-WindowsAutopilotInfo -OutputFile C:\hwid\AutopilotHWID.csv -ErrorAction Stop | Out-Null
    if (Test-Path -Path "C:\HWID\AutopilotHWID.csv") {
        # Copy the output file to the network share
        # Copy-Item -Path .\AutopilotHWID.csv -Destination \\raspberrypi\pi -ErrorAction Stop | Out-Null
        # Send the output file as an email using Outlook
        # $Outlook = New-Object -ComObject Outlook.Application
        # $Mail = $Outlook.CreateItem(0)
        # $Mail.Subject = "AutopilotHWID.csv" 
        # $Mail.Body = "Please find attached the AutopilotHWID.csv file."
        # $Mail.Attachments.Add((Resolve-Path .\AutopilotHWID.csv).Path)
        # $Mail.To = "mahmoudz@gao.gov"
        # $Mail.Send()
    }

    # If all commands execute successfully, return 0
    exit 0
}
catch {
    # If any command throws an error, write the error and return a non-zero exit code
    Write-Error $_.Exception
    exit 1
}
