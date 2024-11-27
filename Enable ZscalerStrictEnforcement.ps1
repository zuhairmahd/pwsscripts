#A shell script to turn on Zscaler Strict Enforcement on Windows 11 by running a Windows repair

#Let's define some variables here
$ZscalerFolder = 'C:\Program Files\Zscaler'
$ZscalerInstallerFolder = "$ZscalerFolder\RevertZcc"
$SemaphorePath = '.zscaler'
$SemaphoreString = 'StrictEnforcementEnabled'
$ZscalerRegPath = 'HKLM:\SOFTWARE\Zscaler Inc.\Zscaler'
$ZscalerRegKey = 'Enforce'
$StrictEnforcementDisabled = 99
$tmp = [System.IO.Path]::GetTempPath()
$RepairCommandline = '--mode unattended --cloudName zscalerten --hideAppUIOnLaunch 1 --userDomain gao.gov --strictEnforcement 1 --policyToken 3334373A333A65333833326434642D626165622D346462372D626236362D663437373133623563653035'
$ZscalerServices = @('ZSAService', 'ZSATrayManager', 'ZSATunnel', 'ZSAUpm')
$ZscalerSubFolders = @('Common', 'RevertZcc', 'ThirdParty', 'Updater', 'ZEPInstaller', 'ZSACli', 'ZSACredentialProviders', 'ZSAFilterDriver', 'ZSAHelper', 'ZSAInstaller', 'ZSAService', 'ZSATray', 'ZSATrayManager', 'ZSATunnel', 'ZSAUpdater', 'ZSAUpm', 'ZSAWFPDriver')
$TimeStamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'ZSCStrictEnforcement-enabled.log'
#Set up logging for the script
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Logs will be appended to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFolder\$LogFile."
}

Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder\$LogFile" -Force

#First, check if the script has run before using its semaphore file.
if (Test-Path $LogFolder\$SemaphorePath) {
    Write-Output "The semaphore file $LogFolder\$SemaphorePath exists. Checking for the semaphore string."
    $SemaphoreContent = Get-Content -Path $LogFolder\$SemaphorePath
    If ($SemaphoreContent -eq $SemaphoreString) {
        Write-Output "Semaphore string match. The script has already run before. Exiting."
        Stop-Transcript
        Exit 0
    }
    Else {
        Write-Output "Semaphore string mismatch. The script has not run before. Continuing."
    }
}
Else {
    Write-Output "Semaphore file not found. The script has not run before. Continuing."
}

#Now let us check the Zscaler registry keys
Write-Host " Checking Zscaler registry keys"
If (Test-Path $ZscalerRegPath) {
    Write-Output " The registry key $ZscalerRegPath exists. Checking for the $ZscalerRegKey value."
    $RegValue = (Get-ItemProperty -Path $ZscalerRegPath -Name $ZscalerRegKey).Enforce
    Write-Output " The value of $ZscalerRegKey is $RegValue"
    If ($RegValue -ne $StrictEnforcementDisabled) {
        Write-Output "  Strict enforcement appears to already be enabled.  Nothing to do"
        New-Item -Path $LogFolder -Name $Semaphore -ItemType File -ErrorAction SilentlyContinue | Out-Null
        Set-Content -Path $LogFolder\$SemaphorePath -Value $SemaphoreString
        Stop-Transcript
        Exit 0
    }
    Else {
        Write-Output " $RegKey is set to $StrictEnforcementDisabled, so Strict Enforcement is disabled.  Continuing."
    }
}
Else {
    Write-Output " The registry key $ZscalerRegPath doesn't exist. Check your Zscaler installation. Exitting."
    Stop-Transcript
    Exit 1
}

#first make sure all subfolders of the Zscaler folder exist
Write-Host " Checking Zscaler folder structure under $ZscalerFolder"
ForEach ($SubFolder in $ZscalerSubFolders) {
    $Folder = Join-Path -Path $ZscalerFolder -ChildPath $SubFolder
    Write-Host "  Checking for $Folder"
    If (Test-Path $Folder) {
        Write-Output " The folder $Folder exists. Continuing."
    }
    Else {
        Write-Output " The folder $Folder doesn't exist. Exitting."
        Stop-Transcript
        Exit 1
    }
}
Write-Host " All Zscaler folders under $ZscalerFolder appear to be intact"

# Now check to make sure all Zscaler services are up and running
Write-Host " Checking the status of Zscaler services."
ForEach ($Service in $ZscalerServices) {
    $ServiceStatus = Get-Service -Name $Service
    Write-Output " Checking the status of the $Service service."
    If ($ServiceStatus.Status -eq 'Running') {
        Write-Output " The $Service service is running. Continuing."
    }
    Else {
        Write-Output " The $Service service is stopped. Check your Zscaler installation. Exitting."
        Stop-Transcript
        Exit 1
    }
}
Write-Host " All Zscaler services are running."

#Now get the content of the zscaler folder to find the installer
$ZscalerFolder = Get-ChildItem -Path $ZscalerInstallerFolder
#Find the latest executable file in the folder
$ZscalerInstaller = $ZscalerFolder | Where-Object { $_.Extension -eq '.exe' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
#Create a folder under tmp and copy the installation file to it.
New-Item -Path "$tmp\zscaler" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
Write-Host " Copying the installer file to the $tmp\zscaler folder"
Copy-Item -Path $ZscalerInstaller.FullName -Destination $tmp\zscaler -Force
$tmpFolder = Get-ChildItem -Path $tmp\zscaler
$ZscalerInstaller = $tmpFolder | Where-Object { $_.Extension -eq '.exe' }
#Run the executable file
Write-Output " Running the Zscaler installer executable file $($ZscalerInstaller.FullName) with the argument $RepairCommandline"
Start-Process -FilePath $ZscalerInstaller.FullName -ArgumentList $RepairCommandline -Wait
Write-Output " The Zscaler installer has completed. The exit code is $LastExitCode"
#Check to see if the repair was successful
If (($null -eq $LastExitCode) -or ($LastExitCode -eq 0)) {
    Write-Output 'Zscaler Strict Enforcement has been enabled. Please restart your computer to apply the changes.'
    #delete the file from the temporary folder
    Remove-Item -Path $tmp\zscaler -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $LogFolder -Name $Semaphore -ItemType File -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $LogFolder\$SemaphorePath -Value $SemaphoreString -ErrorAction SilentlyContinue
}
Else {
    Write-Output 'An error occurred while enabling Zscaler Strict Enforcement. Please check the logs for more information.'
}

Stop-Transcript
# SIG # Begin signature block
# MII6bwYJKoZIhvcNAQcCoII6YDCCOlwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB70Ytz85JNxtmo
# CjFMadpy+de+R/XFz4gdIJNPhNM5jaCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAHlC/Mn
# 87pgunqcAAAAAeULMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjQxMTE5MTY0MTMxWhcNMjQxMTIy
# MTY0MTMxWjBmMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExEjAQBgNV
# BAcTCUFybGluZ3RvbjEXMBUGA1UEChMOWnVoYWlyIE1haG1vdWQxFzAVBgNVBAMT
# Dlp1aGFpciBNYWhtb3VkMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# h6b9risV06FhJnmuKdpRQs6/CVAlDX6DN4GYNtWspF1pGd+a4WXa1j3i/1/o6en2
# nIQL7XYC8gZyBIi0mW5cqodRhri+GWFnF0u23tAurB2XNjJWjXIYKNw9cA5CwQRs
# jucMlnI6JGLTeR1Jh44bdlw8IEXJBYSn4DQmjGAlm9F801jb9SzmEMceiy6hP4jh
# 2cc2HrD6iWc8UfcFjeT4QVTbEZIqWnC0RF46ceGTJ+GwSG+AtBPOJ2RWUdNOiVfQ
# PHempAHAqIK5NXs/rIaoTWM6jLgfTCZiepaJTAWqUJwsUI3LoTS3yFO/cDLzkJP+
# f2MsxAMD7np/F9L1qw6bUuC2eutBJCwcyPZsBn7wyYrZC22SyJ0gc4RG156pwGns
# Zf6CcerrI0SYtqm8olnt3OYbb1VgfT702iFnJNGxAw/DJAF8DYdWVEtwTzUJQe4J
# ySDSqAChCYJu+WXT520tP/ZH0wsRGe0FsEw0cgV5B+Eojq2iAmGGSDaXVdi5sPg3
# AgMBAAGjggIYMIICFDAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA7BgNV
# HSUENDAyBgorBgEEAYI3YQEABggrBgEFBQcDAwYaKwYBBAGCN2GBmtGaFtje9WuB
# vfqFXPmA7xswHQYDVR0OBBYEFJHCLmwWFc0/5lyam3KO9uK4jV7IMB8GA1UdIwQY
# MBaAFOiDxDPX3J8MnHaaCqbU34emXljuMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBAAofMNWKvxUfGVVy
# IsG76jrmzT5Y6cwgEXS7Gas6DCZBaLpbhFdaFoKRQwUdUCZUc20kTsnrvITpkz0Y
# wKUTdQZWGnNCjDt9aQQf/F3ZCBYmr9SDumrWqjICXiq5Io0knSpAU8jb3OQNiu2u
# 9/Ty1SwdS8AZ7eJDI8b1gaW+ideyT7LJc3XmiXFy/YEbibfBlVwd2ofGln7tAp9+
# sw/d3RUES9du83hzfFImQXvzJRJ5XmSQ6PffX8dqQTy8ogG4h5tCpF8d8+tThIbX
# rH5qWSisaYGZB0rORHPMeQEcpy1Qr274kcqw+6IRdF3PAtrACps/GURBQgtDc/oI
# khD1y/roYellwYC+NXM8M5BBU4Q7yz0+2jsYfnoB3i+uTQOSZJVqRJe7FS71UIK9
# AJXw/jae8teTlUFztyObDzNI1L189uhZZ6ug4fLCa4JtMfvw3rdQWKuyekFqyA2O
# uFHwcAy0lnjmOWU0jVQev7Hw/UNVWTuH/IoRncYmxIeesO6CFD68PK2JWnHU/QDs
# FunGoTSYuvTUpRk/ZoTwujnY4CoYdx2WHr45R1YSFTKu/C3a9avcHgSsYLkfOno4
# i09KFBKP2wI9YyWyPkJQ85YqHVNstkehSZr0fRqAXYwch8Og8KGvGsB0v+nIus4E
# LFd54VbLIJHkvMpdxMjIYkwM1a3KMIIG5zCCBM+gAwIBAgITMwAB5QvzJ/O6YLp6
# nAAAAAHlCzANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAxMB4XDTI0MTExOTE2NDEzMVoXDTI0MTEyMjE2NDEz
# MVowZjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMRIwEAYDVQQHEwlB
# cmxpbmd0b24xFzAVBgNVBAoTDlp1aGFpciBNYWhtb3VkMRcwFQYDVQQDEw5adWhh
# aXIgTWFobW91ZDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAIem/a4r
# FdOhYSZ5rinaUULOvwlQJQ1+gzeBmDbVrKRdaRnfmuFl2tY94v9f6Onp9pyEC+12
# AvIGcgSItJluXKqHUYa4vhlhZxdLtt7QLqwdlzYyVo1yGCjcPXAOQsEEbI7nDJZy
# OiRi03kdSYeOG3ZcPCBFyQWEp+A0JoxgJZvRfNNY2/Us5hDHHosuoT+I4dnHNh6w
# +olnPFH3BY3k+EFU2xGSKlpwtEReOnHhkyfhsEhvgLQTzidkVlHTTolX0Dx3pqQB
# wKiCuTV7P6yGqE1jOoy4H0wmYnqWiUwFqlCcLFCNy6E0t8hTv3Ay85CT/n9jLMQD
# A+56fxfS9asOm1LgtnrrQSQsHMj2bAZ+8MmK2QttksidIHOERteeqcBp7GX+gnHq
# 6yNEmLapvKJZ7dzmG29VYH0+9NohZyTRsQMPwyQBfA2HVlRLcE81CUHuCckg0qgA
# oQmCbvll0+dtLT/2R9MLERntBbBMNHIFeQfhKI6togJhhkg2l1XYubD4NwIDAQAB
# o4ICGDCCAhQwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOwYDVR0lBDQw
# MgYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGisGAQQBgjdhgZrRmhbY3vVrgb36hVz5
# gO8bMB0GA1UdDgQWBBSRwi5sFhXNP+ZcmptyjvbiuI1eyDAfBgNVHSMEGDAWgBTo
# g8Qz19yfDJx2mgqm1N+Hpl5Y7jBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAxLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# MS5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQAKHzDVir8VHxlVciLBu+o6
# 5s0+WOnMIBF0uxmrOgwmQWi6W4RXWhaCkUMFHVAmVHNtJE7J67yE6ZM9GMClE3UG
# VhpzQow7fWkEH/xd2QgWJq/Ug7pq1qoyAl4quSKNJJ0qQFPI29zkDYrtrvf08tUs
# HUvAGe3iQyPG9YGlvonXsk+yyXN15olxcv2BG4m3wZVcHdqHxpZ+7QKffrMP3d0V
# BEvXbvN4c3xSJkF78yUSeV5kkOj331/HakE8vKIBuIebQqRfHfPrU4SG16x+alko
# rGmBmQdKzkRzzHkBHKctUK9u+JHKsPuiEXRdzwLawAqbPxlEQUILQ3P6CJIQ9cv6
# 6GHpZcGAvjVzPDOQQVOEO8s9Pto7GH56Ad4vrk0DkmSVakSXuxUu9VCCvQCV8P42
# nvLXk5VBc7cjmw8zSNS9fPboWWeroOHywmuCbTH78N63UFirsnpBasgNjrhR8HAM
# tJZ45jllNI1UHr+x8P1DVVk7h/yKEZ3GJsSHnrDughQ+vDytiVpx1P0A7BbpxqE0
# mLr01KUZP2aE8Lo52OAqGHcdlh6+OUdWEhUyrvwt2vWr3B4ErGC5Hzp6OItPShQS
# j9sCPWMlsj5CUPOWKh1TbLZHoUma9H0agF2MHIfDoPChrxrAdL/pyLrOBCxXeeFW
# yyCR5LzKXcTIyGJMDNWtyjCCB1owggVCoAMCAQICEzMAAAAHN4xbodlbjNQAAAAA
# AAcwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTRaFw0yNjA0MTMx
# NzMxNTRaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0Eg
# MDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC398ADKAfFuj6PEDTi
# E0jxvP4Spta9K711GABrCMJlq7VjnghBqXkCuklaLxwiPRYD6anCLHyJNGC6r0kQ
# tm9MyjZnVToC0TVOfea+rebLBn1J7FV36s85Ov651roZWDAsDzQuFF/zYC+tLDGZ
# mkIf+VpPTx2fv4a3RxdhU0ok5GbWFKsCOMNCJnUmKr9KqIOgc3o8aZPmFcqzbYTv
# 0x4VZgHjLRSU2pbRnYs825ryTStsRF2I1L6dM//GwRJlSetubJdloe9zIQpgrzlY
# HPdKvoS3xWVt2J3+mMGlwcj4fK2hpQAYTqtJaqaHv9oRl4MNSTP24wo4ZqwiBid6
# dSTkTRvZT/9tCoO/ep2GP1QlhYAM1gL/eLeLFxbVUQtpT7BOpdPEsAV6UKL+VEdK
# NpaKkN4T9NsFvTNMKIudz2eY6Nk8qW60w2Gj3XDGjiK1wmgiTZs+i3234BX5TA1o
# NEhtwRpBoHJyX2lxjBaZ/RsnggWf8KZgxUbV6QIHEHLJE2QWQea4xctfo8xdy94T
# jqMyv2zILczwkdF11HjNWN38XEGdLkc6ujemDpK24Q+yGunsj8qTVxMbzI5aXxqp
# /o4l4BXIbiXIn1X5nEKViZpTnK+0pgqTUUsGcQF8NbD5QDNBXS9wunoBXHYVzyfS
# +mjK52vdLBmZyQm7PtH5Lv0HMwIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTog8Qz19yfDJx2mgqm1N+Hpl5Y
# 7jBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAHf+
# 60si2TAtOng1+H32+tulKwvw3A8iPb5MGdkYvcLx61MZiz4dlTE0b6s15lr5HO72
# gRwBkkOIaMRbK3Mxq8PoGKHecRYWwhbhoaHiAHif+lE955WsriLUsbuMneQ8tGE0
# 4dmItRC2asXhXojG1QWO8GeKNpn2gjGxJJA/yIcyM/3amNCscEVYcYNuSbH7I7oh
# qfdA3diZt197DNK+dCYpuSJOJsmBwnUvRNnsHCawO+b7RdGw858WCfOEtWpl0TJb
# DDXRt+U54EqqRvdJoI1BPPyeyFpRmGvFVTmo2BiNpoNBCb4/ZISkEXtGiUQLeWWV
# +4vgA4YK2g1085avH28FlNcBV1MTavQgOTz7nLWQsZMsrOY0WfqRUJzkF10zvGgN
# ZDhpSgJFdywF5GGxyWTuRVc/7MkY85fCNQlufPYq32IX/wHoUM7huUa4auiAynJe
# S7AILZnhdx/IyM8OGplgA8YZNQg0y0Vtq7lG0YbUM5YT150JqG248wOAHJ8+LG+H
# LeyfvNQeAgL9iw5MzFW4xCL9uBqZ6aj9U0pmuxlpLSfOY7EqmD2oN5+Pl8n2Agdd
# ynYXQ4dxXB7cqcRdrySrMwN+tGX/DAqs1IWfenuDRvjgB3U40OZa3rUwtC8Xngsb
# raLp9+FMJ6gVP1n2ltSjaDGXJMWDsGbR+A6WdF8YMIIHnjCCBYagAwIBAgITMwAA
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
# nTiOL60cPqfny+Fq8UiuZzGCFx8wghcbAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMQITMwAB5QvzJ/O6YLp6nAAAAAHlCzAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCCaLleGaSZW/58xemAtzFXdp2DT
# JPPeFuSi+ViHkg8xIjANBgkqhkiG9w0BAQEFAASCAYAtYtTESkwwnbkS6CD9gsp3
# WDxt2fCoCM4L1RPfmAw7lwuj5BL/5Ovau53dtujIobiDjNdDt3QDL3dpSOB5xQdH
# sSDsJAdtBdsPI0NqVtlf+B5AXw5Cpl9epSJz3MaZVc+7Beu9SxMFSydI6AdN6s+B
# c0F0bCKny2kGmAcbdvF/x+2CoV56YKRwThQWmZq5puSuXBO2kN+tlGL/zEi/3TXX
# jlJWnnyTFDmT6L9K2C+R1kt102HB/Rn7bGtv5p26CPPjSxgk+k6zAbG3NCqTWdo0
# D3IN3WcmF381JS0lBrsbD0cIqp/+6zdD30kAl1LeXBj2p8COx6fqIaizOu6rktQs
# 1haqZQ24BKwY04bQLDLtPk4gZrdYhRKLnY0yS7FyZ4Nhz0iqVx+ZSJwXolPY2Poj
# 0SgGnwWXAHOlQGFnsR/zfm6tqxxhKuCI+A+bg348VnxeLxJB4B4EEaF7GY8j2/Os
# WPxQWsHKlZf6EIa9jjaJqoo3I2ZJ8bT49dBuiGNB0+KhghSfMIIUmwYKKwYBBAGC
# NwMDATGCFIswghSHBgkqhkiG9w0BBwKgghR4MIIUdAIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYAYLKoZIhvcNAQkQAQSgggFPBIIBSzCCAUcCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgwaNTHKswtyMJHFT8puimzxTKpvoPdxxYDXZwO+y4
# vzsCBmc7x8luQRgSMjAyNDExMjAxNjAyMzMuOTNaMASAAgH0oIHgpIHdMIHaMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNy
# b3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVT
# TjozREE1LTk2M0ItRTFGNDE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0Eg
# VGltZSBTdGFtcGluZyBBdXRob3JpdHmggg8gMIIHgjCCBWqgAwIBAgITMwAAAAXl
# zw//Zi7JhwAAAAAABTANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQGEwJVUzEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9NaWNyb3NvZnQg
# SWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMjAwHhcNMjAxMTE5MjAzMjMxWhcNMzUxMTE5MjA0MjMxWjBhMQswCQYDVQQG
# EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylN
# aWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJ5851Jj/eDFnwV9Y7UGIqMcHtfnlzPR
# EwW9ZUZHd5HBXXBvf7KrQ5cMSqFSHGqg2/qJhYqOQxwuEQXG8kB41wsDJP5d0zmL
# YKAY8Zxv3lYkuLDsfMuIEqvGYOPURAH+Ybl4SJEESnt0MbPEoKdNihwM5xGv0rGo
# fJ1qOYSTNcc55EbBT7uq3wx3mXhtVmtcCEr5ZKTkKKE1CxZvNPWdGWJUPC6e4uRf
# WHIhZcgCsJ+sozf5EeH5KrlFnxpjKKTavwfFP6XaGZGWUG8TZaiTogRoAlqcevbi
# qioUz1Yt4FRK53P6ovnUfANjIgM9JDdJ4e0qiDRm5sOTiEQtBLGd9Vhd1MadxoGc
# HrRCsS5rO9yhv2fjJHrmlQ0EIXmp4DhDBieKUGR+eZ4CNE3ctW4uvSDQVeSp9h1S
# aPV8UWEfyTxgGjOsRpeexIveR1MPTVf7gt8hY64XNPO6iyUGsEgt8c2PxF87E+CO
# 7A28TpjNq5eLiiunhKbq0XbjkNoU5JhtYUrlmAbpxRjb9tSreDdtACpm3rkpxp7A
# QndnI0Shu/fk1/rE3oWsDqMX3jjv40e8KN5YsJBnczyWB4JyeeFMW3JBfdeAKhzo
# hFe8U5w9WuvcP1E8cIxLoKSDzCCBOu0hWdjzKNu8Y5SwB1lt5dQhABYyzR3dxEO/
# T1K/BVF3rV69AgMBAAGjggIbMIICFzAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYBBAGC
# NxUBBAMCAQAwHQYDVR0OBBYEFGtpKDo1L0hjQM972K9J6T7ZPdshMFQGA1UdIARN
# MEswSQYEVR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwDwYDVR0TAQH/BAUwAwEB/zAf
# BgNVHSMEGDAWgBTIftJqhSobyhmYBAcnz1AQT2ioojCBhAYDVR0fBH0wezB5oHeg
# dYZzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0
# JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUl
# MjBBdXRob3JpdHklMjAyMDIwLmNybDCBlAYIKwYBBQUHAQEEgYcwgYQwgYEGCCsG
# AQUFBzAChnVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01p
# Y3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRp
# ZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcnQwDQYJKoZIhvcNAQEMBQADggIB
# AF+Idsd+bbVaFXXnTHho+k7h2ESZJRWluLE0Oa/pO+4ge/XEizXvhs0Y7+KVYyb4
# nHlugBesnFqBGEdC2IWmtKMyS1OWIviwpnK3aL5JedwzbeBF7POyg6IGG/XhhJ3U
# qWeWTO+Czb1c2NP5zyEh89F72u9UIw+IfvM9lzDmc2O2END7MPnrcjWdQnrLn1Nt
# day7JSyrDvBdmgbNnCKNZPmhzoa8PccOiQljjTW6GePe5sGFuRHzdFt8y+bN2neF
# 7Zu8hTO1I64XNGqst8S+w+RUdie8fXC1jKu3m9KGIqF4aldrYBamyh3g4nJPj/LR
# 2CBaLyD+2BuGZCVmoNR/dSpRCxlot0i79dKOChmoONqbMI8m04uLaEHAv4qwKHQ1
# vBzbV/nG89LDKbRSSvijmwJwxRxLLpMQ/u4xXxFfR4f/gksSkbJp7oqLwliDm/h+
# w0aJ/U5ccnYhYb7vPKNMN+SZDWycU5ODIRfyoGl59BsXR/HpRGtiJquOYGmvA/pk
# 5vC1lcnbeMrcWD/26ozePQ/TWfNXKBOmkFpvPE8CH+EeGGWzqTCjdAsno2jzTeNS
# xlx3glDGJgcdz5D/AAxw9Sdgq/+rY7jjgs7X6fqPTXPmaCAJKVHAP19oEjJIBwD1
# LyHbaEgBxFCogYSOiUIr0Xqcr1nJfiWG2GwYe6ZoAF1bMIIHljCCBX6gAwIBAgIT
# MwAAADozKO0VKZiiBAAAAAAAOjANBgkqhkiG9w0BAQwFADBhMQswCQYDVQQGEwJV
# UzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNy
# b3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDAeFw0yNDAyMTUy
# MDM2MDlaFw0yNTAyMTUyMDM2MDlaMIHaMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRp
# b25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjozREE1LTk2M0ItRTFGNDE1MDMG
# A1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3Jp
# dHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC8ppiHNDoVn8YYUHjI
# ISKQAZmZ1SqlQ2FhirSc8I2gakuVa3Wr9ACiRFP19r5aYHOXC9RTjHUxosdCoOnN
# K7phYQznP6UNF5bkZliyQ6uaurTCF2Q6ymkqClxYJuC+jjC3iOO0Wv1iB49KfRjv
# j9yEyeZiGhvcuU8iyCv7fdT475umfXGilFwA/c/41Id6AiUWZWIPs8CRHbLqhUXg
# GgRW2GGDwWthCz5Rawy0UpP7LD1qsub+EphJFmZZkeO8wdYL0YO9QdMVohXIqEKA
# wPtskyTdEjMiADx/WSccix55tQjeAWeF3ZSdlZ0K1fXG9QI7slPa8fMWveHIfdaD
# tLpFb80B2vSAcpW0k18TbjPSGlxyscm1cLSuA9E3Io5fn+Wpg7qdtrSK+tJMLinm
# 0vPSH9BgK2zbjgdg1bnEBZIOZ1HYEGrX3KZIdPzL9cDHc6oE2r7clSE/4z6jA485
# 7BQVTmgCqJEN27xqDid2/n73FVYbJPqHQ5fnsJ3RnXhtqzMUlz2rJyUobrsaYAFP
# B0zWqD9n8OEaM9FWQ354NidNvUHNW5WjoFgDYt+aNayYEQLUIWXj1oQo6FLG5hSy
# ymI+OuLHuXtqqcfZCQ5mL3duJ6KHbMJefrZGZXoUNY0x/sHcSVZCirih8xBGwltF
# cAOkYGcOpP5hivwHqGhfwpn4ywIDAQABo4IByzCCAccwHQYDVR0OBBYEFIVlOxHK
# M+h0CuaTIXxZEwmdLAAJMB8GA1UdIwQYMBaAFGtpKDo1L0hjQM972K9J6T7ZPdsh
# MGwGA1UdHwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
# cHMvY3JsL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUy
# MENBJTIwMjAyMC5jcmwweQYIKwYBBQUHAQEEbTBrMGkGCCsGAQUFBzAChl1odHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFB1
# YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcnQwDAYDVR0T
# AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4Aw
# ZgYDVR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgG
# BmeBDAEEAjANBgkqhkiG9w0BAQwFAAOCAgEASJs29YJ3ITRB8XSq2o+Iwk+XwKdS
# S89jlLlO4haivnkzfQQZvznnuGFBDrnLJdfrApLOQRkMkOiUrQrfDR6ScIPe/dm8
# FyZLd6HFv+MHhebBpSpnkk9ApQQz3iST02ZEZpf1wgGNXzJccYgOJO8XqfHHPSlD
# JL9u0aB0ZxtA8AhpeWB8QiBz8XIjiV8ZMkv7Whbw7tStDS0rpV9VDozQXSxSuk9o
# DOdXy53J9SpeEJx2A7hAgzjw4QApwFJ/a3oZ/1pLcBEkAt/9GP/bnn6GGWr/VCSf
# oHZouVMr8Cm+oG0y1vyiYH+P7ceW9qa2TYwtqUozfCQWgT6IxF3vXEt8Ypj+HybS
# H+C4H4fCbx+LyxGyaTzRrT/egK6GsY1HYp1yrGaKSzpwX5bIo5sjaWQZApcqHe/J
# fjYFgeev5kVlZJ/UbjF90eoVkdS6hnTNHPhG8IM4G3/N/XaiUYoNMPA8trMBX7H7
# zJmo3IdecdXPqLj4mz09hZ4Hq85qJul9UM4JL8QdLv6PYsRHq4pOd4PIVTdQmEHq
# GZ6cApH9I6t0GGiyhLhQjmOUS33BhK7bE3HDtoqUrqWcwVcJUwJ4RrwaGkPbZTmo
# 1F8h+FWiHDPRvDcNnzj9/wnXLixwf/lqICR+DGftGHNjpPe0LwDviTp+9YGOk6Z6
# P5vI+WdLi239xGIxggPUMIID0AIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAOjMo7RUpmKIEAAAAAAA6
# MA0GCWCGSAFlAwQCAQUAoIIBLTAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQw
# LwYJKoZIhvcNAQkEMSIEIPWYkBKEJbEK+eHVbPtRZ1mXva2J5tghoAUidAa1vOnD
# MIHdBgsqhkiG9w0BCRACLzGBzTCByjCBxzCBoAQg6JO2sbY3eHnZwdCkUikIERNa
# JKk0mdPN0LwdV9yn4DYwfDBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBS
# U0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAAA6MyjtFSmYogQAAAAAADowIgQg
# w6U0qhdCPl/aXbe7b2a3FsXTju86KSbVybaNlVtLTpkwDQYJKoZIhvcNAQELBQAE
# ggIABRm23Wm3XMGHHn7ZwB7xZcZ5UY8hdfbcz/xQKgOfimdHtim8pU+HwSFTPjsA
# aMUDZxvgRBIX6KKaszp6oSTBmx0BXlkrxBCGSePboFVjasonZ6g2FTtBdIbEuqZa
# YzBNvYMS5RbHM8OrfcnJ8flGTWCcczbs0nwFRB8bCUfNvAmv6wcNZn2mpivioVs1
# FHX7T1Y6MKB6vfYHRDWUY4UaVxI39bas9jY+y9lrxLdOFl076zMiIF+cq8hWsocI
# pxqz5rww92yL4Qaa05kuO5SUbYk8oGZrvJ7e0t+0nEK15fBiXabf34W2Dh42jXP7
# JUZS+LIk+PURrpYURQNT7mxJkFWBjRCWoWvwupt3LyC6BL7Ev9UlHsiUOXuaZ2Ia
# aZOQBFtRrztmtrqCADx+en1vvWiS/+I0l5SKw2aLS++vqM3QHu75e8anG7aadGrU
# TXms0dwpdqadKVdAuLO//ReV5nVkdp1GKtgXiUTAlFtgyCBd6ysxebsAhOCFuIGy
# 37ZTOvGB2bGulCkhPt6yyhgcY3gRmu9I4XxbN25xllyeGfblSezj0WEzL/uGRZnj
# lEckZrk741dVmg/9YJWPV7qu/vii7g6RFIioIIf5N2W7Ki4xX8vZNNxUK+OduBC8
# yQNJDxdb7fNUK9IxLgtjIKPDV+pqEeTl340Xi6rqjNZbFuY=
# SIG # End signature block
