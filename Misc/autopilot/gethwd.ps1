Set-ExecutionPolicy Bypass
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    #Create the folder to store the HWID file
    New-Item -Type Directory -Path "C:\HWID" -ErrorAction Stop
    #Change to the folder containing the device hash
    Set-Location -Path "C:\HWID" -ErrorAction Stop
    #add the scripts folder to the path
    $env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
    #install a couple of necessary modules and scripts
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -ErrorAction Stop
    Install-PackageProvider -Name NuGet -Force -ErrorAction Stop
    Install-Script -Name Get-WindowsAutopilotInfo -force -ErrorAction Stop
    #now get the device hash
    Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv -ErrorAction Stop
    # Copy the output file to the specified network location
    #Copy-Item -Path .\AutopilotHWID.csv -Destination \\prod.gao.gov\info\publishing -ErrorAction Stop
    # If all commands execute successfully, return 0
    exit 0
}
catch {
    # If any command throws an error, write the error and return a non-zero exit code
    Write-Error $_.Exception
    exit 1
}