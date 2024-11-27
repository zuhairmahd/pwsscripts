#A shell script to turn on Zscaler Strict Enforcement on Windows 11 by running a Windows repair

#Let's define some variables here
$ZscalerFolder = 'C:\Program Files\Zscaler'
$ZscalerInstallerFolder = "$ZscalerFolder\RevertZcc"
$ZscalerRegPath = 'HKLM:\SOFTWARE\Zscaler Inc.\Zscaler'
$ZscalerRegKey = 'Enforce'
$StrictEnforcementDisabled = 99
$tmp = [System.IO.Path]::GetTempPath()
$RepairCommandline = '--mode unattended --cloudName zscalerten --hideAppUIOnLaunch 1 --userDomain gao.gov --strictEnforcement 0 --policyToken 3334373A333A65333833326434642D626165622D346462372D626236362D663437373133623563653035'
$ZscalerServices = @('ZSAService', 'ZSATrayManager', 'ZSATunnel', 'ZSAUpm')
$ZscalerSubFolders = @('Common', 'RevertZcc', 'ThirdParty', 'Updater', 'ZEPInstaller', 'ZSACli', 'ZSACredentialProviders', 'ZSAFilterDriver', 'ZSAHelper', 'ZSAInstaller', 'ZSAService', 'ZSATray', 'ZSATrayManager', 'ZSATunnel', 'ZSAUpdater', 'ZSAUpm', 'ZSAWFPDriver')
$TimeStamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'ZSCStrictEnforcement-disabled.log'
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
#Now let us check the Zscaler registry keys
Write-Host "" Checking Zscaler registry keys"
If (Test-Path $ZscalerRegPath) {
    Write-Output "" The registry key $ZscalerRegPath exists. Checking for the $ZscalerRegKey value."
    $RegValue = (Get-ItemProperty -Path $ZscalerRegPath -Name $ZscalerRegKey).Enforce
    Write-Output "" The value of $ZscalerRegKey is $RegValue"
    If ($RegValue -eq $StrictEnforcementDisabled) {
        Write-Output ""  Strict enforcement appears to already be disabled.  Nothing to do"
        Stop-Transcript
        Exit 0
    }
    Else {
        Write-Output "" $RegKey is set to $RegValue, so Strict Enforcement is enabled.  Continuing."
    }
}
Else {
    Write-Output "" The registry key $ZscalerRegPath doesn't exist. Check your Zscaler installation. Exitting."
    Stop-Transcript
    Exit 1
}

#first make sure all subfolders of the Zscaler folder exist
Write-Host "" Checking Zscaler folder structure under $ZscalerFolder"
ForEach ($SubFolder in $ZscalerSubFolders) {
    $Folder = Join-Path -Path $ZscalerFolder -ChildPath $SubFolder
    Write-Host ""  Checking for $Folder"
    If (Test-Path $Folder) {
        Write-Output "" The folder $Folder exists. Continuing."
    }
    Else {
        Write-Output "" The folder $Folder doesn't exist. Exitting."
        Stop-Transcript
        Exit 1
    }
}
Write-Host "" All Zscaler folders under $ZscalerFolder appear to be intact"

# Now check to make sure all Zscaler services are up and running
Write-Host "" Checking the status of Zscaler services."
ForEach ($Service in $ZscalerServices) {
    $ServiceStatus = Get-Service -Name $Service
    Write-Output "" Checking the status of the $Service service."
    If ($ServiceStatus.Status -eq 'Running') {
        Write-Output "" The $Service service is running. Continuing."
    }
    Else {
        Write-Output "" The $Service service is stopped. Check your Zscaler installation. Exitting."
        Stop-Transcript
        Exit 1
    }
}
Write-Host "" All Zscaler services are running."

#Now get the content of the zscaler folder to find the installer
$ZscalerFolder = Get-ChildItem -Path $ZscalerInstallerFolder
#Find the latest executable file in the folder
$ZscalerInstaller = $ZscalerFolder | Where-Object { $_.Extension -eq '.exe' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
#Create a folder under tmp and copy the installation file to it.
New-Item -Path "$tmp\zscaler" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
Write-Host "" Copying the installer file to the $tmp\zscaler folder"
Copy-Item -Path $ZscalerInstaller.FullName -Destination $tmp\zscaler -Force
$tmpFolder = Get-ChildItem -Path $tmp\zscaler
$ZscalerInstaller = $tmpFolder | Where-Object { $_.Extension -eq '.exe' }
#Run the executable file
Write-Output "" Running the Zscaler installer executable file $($ZscalerInstaller.FullName) with the argument $RepairCommandline"
Start-Process -FilePath $ZscalerInstaller.FullName -ArgumentList $RepairCommandline -Wait
Write-Output "" The Zscaler installer has completed. The exit code is $LastExitCode"
#Check to see if the repair was successful
If (($null -eq $LastExitCode) -or ($LastExitCode -eq 0)) {
    Write-Output 'Zscaler Strict Enforcement has been disabled. Please restart your computer to apply the changes.'
    #delete the file from the temporary folder
    Remove-Item -Path $tmp\zscaler -Recurse -Force -ErrorAction SilentlyContinue
}
Else {
    Write-Output 'An error occurred while disabling Zscaler Strict Enforcement. Please check the logs for more information.'
}

Stop-Transcript
# SIG # Begin signature block
# MII6cAYJKoZIhvcNAQcCoII6YTCCOl0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD26+ON1wWIyFBn
# Dnq3SuDoOlrpVgz7/fVNjEg202/Nd6CCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# nTiOL60cPqfny+Fq8UiuZzGCFyAwghccAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMQITMwAB5QvzJ/O6YLp6nAAAAAHlCzAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCAFUIjtB6GKPpS3IT5AM/te8X0h
# D48qBpiMRCeunG6TYzANBgkqhkiG9w0BAQEFAASCAYBEVpSbiHpWFsF8+0YtjxI+
# NAdif/FrRSijXhMcTiwzA5wWpSLv5TzT44txqYc9yp+oLJcjkyTByS4A0LdRYhIe
# r4uXRtM++XnSbcPFJeRdqRY+JV02QWn8E+D/LGC8MO8YP63bIBytxVA0jFQ5AFvU
# aUx7Eok516O2lRU7WKiLwwgV9p9UuvrKj7S3qmSYNo5jfD2hI8zPushPczdtoN5d
# fiGXhJ8yi1wnVV+VG4sZUNkeKO7eOXolslNjGvDEfVZ9c9mitGQSY4b/IMYOkKnE
# GEZohxYJNpBGjdhBa51O2Qzu3WWw9gkGPGySTOeIMSXfH6iXQ3iBkufbXBgAeqps
# LS8IjEo2khYmDl+4Vk2Izt8zHDQvx3QxaDAiYcsoSYCq2gGg+3lAqwd46/GW5xNs
# Bk4XNS4Z9kZyTFjxq5MjptCqd5Wjt6Por1PL6mpC5eYQNVTe7leBrr90hee/QSzG
# 6m7G85KldUwA2xHBLY/hs3+IwWudwKA0VMITnFL1dqWhghSgMIIUnAYKKwYBBAGC
# NwMDATGCFIwwghSIBgkqhkiG9w0BBwKgghR5MIIUdQIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYQYLKoZIhvcNAQkQAQSgggFQBIIBTDCCAUgCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQg/d/Aeph2EGY2GqkaztfjCOLgtAmsVL83FnvPWSmi
# DpMCBmc7x8luPhgTMjAyNDExMjAxNjAyMzIuNTEyWjAEgAIB9KCB4KSB3TCB2jEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWlj
# cm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBF
# U046M0RBNS05NjNCLUUxRjQxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNB
# IFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5oIIPIDCCB4IwggVqoAMCAQICEzMAAAAF
# 5c8P/2YuyYcAAAAAAAUwDQYJKoZIhvcNAQEMBQAwdzELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/TWljcm9zb2Z0
# IElkZW50aXR5IFZlcmlmaWNhdGlvbiBSb290IENlcnRpZmljYXRlIEF1dGhvcml0
# eSAyMDIwMB4XDTIwMTExOTIwMzIzMVoXDTM1MTExOTIwNDIzMVowYTELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMp
# TWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCefOdSY/3gxZ8FfWO1BiKjHB7X55cz
# 0RMFvWVGR3eRwV1wb3+yq0OXDEqhUhxqoNv6iYWKjkMcLhEFxvJAeNcLAyT+XdM5
# i2CgGPGcb95WJLiw7HzLiBKrxmDj1EQB/mG5eEiRBEp7dDGzxKCnTYocDOcRr9Kx
# qHydajmEkzXHOeRGwU+7qt8Md5l4bVZrXAhK+WSk5CihNQsWbzT1nRliVDwunuLk
# X1hyIWXIArCfrKM3+RHh+Sq5RZ8aYyik2r8HxT+l2hmRllBvE2Wok6IEaAJanHr2
# 4qoqFM9WLeBUSudz+qL51HwDYyIDPSQ3SeHtKog0ZubDk4hELQSxnfVYXdTGncaB
# nB60QrEuazvcob9n4yR65pUNBCF5qeA4QwYnilBkfnmeAjRN3LVuLr0g0FXkqfYd
# Umj1fFFhH8k8YBozrEaXnsSL3kdTD01X+4LfIWOuFzTzuoslBrBILfHNj8RfOxPg
# juwNvE6YzauXi4orp4Sm6tF245DaFOSYbWFK5ZgG6cUY2/bUq3g3bQAqZt65Kcae
# wEJ3ZyNEobv35Nf6xN6FrA6jF9447+NHvCjeWLCQZ3M8lgeCcnnhTFtyQX3XgCoc
# 6IRXvFOcPVrr3D9RPHCMS6Ckg8wggTrtIVnY8yjbvGOUsAdZbeXUIQAWMs0d3cRD
# v09SvwVRd61evQIDAQABo4ICGzCCAhcwDgYDVR0PAQH/BAQDAgGGMBAGCSsGAQQB
# gjcVAQQDAgEAMB0GA1UdDgQWBBRraSg6NS9IY0DPe9ivSek+2T3bITBUBgNVHSAE
# TTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUF
# BwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMA8GA1UdEwEB/wQFMAMBAf8w
# HwYDVR0jBBgwFoAUyH7SaoUqG8oZmAQHJ89QEE9oqKIwgYQGA1UdHwR9MHsweaB3
# oHWGc2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29m
# dCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRpZmljYXRl
# JTIwQXV0aG9yaXR5JTIwMjAyMC5jcmwwgZQGCCsGAQUFBwEBBIGHMIGEMIGBBggr
# BgEFBQcwAoZ1aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9N
# aWNyb3NvZnQlMjBJZGVudGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0
# aWZpY2F0ZSUyMEF1dGhvcml0eSUyMDIwMjAuY3J0MA0GCSqGSIb3DQEBDAUAA4IC
# AQBfiHbHfm21WhV150x4aPpO4dhEmSUVpbixNDmv6TvuIHv1xIs174bNGO/ilWMm
# +Jx5boAXrJxagRhHQtiFprSjMktTliL4sKZyt2i+SXncM23gRezzsoOiBhv14YSd
# 1Klnlkzvgs29XNjT+c8hIfPRe9rvVCMPiH7zPZcw5nNjthDQ+zD563I1nUJ6y59T
# bXWsuyUsqw7wXZoGzZwijWT5oc6GvD3HDokJY401uhnj3ubBhbkR83RbfMvmzdp3
# he2bvIUztSOuFzRqrLfEvsPkVHYnvH1wtYyrt5vShiKheGpXa2AWpsod4OJyT4/y
# 0dggWi8g/tgbhmQlZqDUf3UqUQsZaLdIu/XSjgoZqDjamzCPJtOLi2hBwL+KsCh0
# Nbwc21f5xvPSwym0Ukr4o5sCcMUcSy6TEP7uMV8RX0eH/4JLEpGyae6Ki8JYg5v4
# fsNGif1OXHJ2IWG+7zyjTDfkmQ1snFOTgyEX8qBpefQbF0fx6URrYiarjmBprwP6
# ZObwtZXJ23jK3Fg/9uqM3j0P01nzVygTppBabzxPAh/hHhhls6kwo3QLJ6No803j
# UsZcd4JQxiYHHc+Q/wAMcPUnYKv/q2O444LO1+n6j01z5mggCSlRwD9faBIySAcA
# 9S8h22hIAcRQqIGEjolCK9F6nK9ZyX4lhthsGHumaABdWzCCB5YwggV+oAMCAQIC
# EzMAAAA6MyjtFSmYogQAAAAAADowDQYJKoZIhvcNAQEMBQAwYTELMAkGA1UEBhMC
# VVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWlj
# cm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwHhcNMjQwMjE1
# MjAzNjA5WhcNMjUwMjE1MjAzNjA5WjCB2jELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
# aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046M0RBNS05NjNCLUUxRjQxNTAz
# BgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9y
# aXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvKaYhzQ6FZ/GGFB4
# yCEikAGZmdUqpUNhYYq0nPCNoGpLlWt1q/QAokRT9fa+WmBzlwvUU4x1MaLHQqDp
# zSu6YWEM5z+lDReW5GZYskOrmrq0whdkOsppKgpcWCbgvo4wt4jjtFr9YgePSn0Y
# 74/chMnmYhob3LlPIsgr+33U+O+bpn1xopRcAP3P+NSHegIlFmViD7PAkR2y6oVF
# 4BoEVthhg8FrYQs+UWsMtFKT+yw9arLm/hKYSRZmWZHjvMHWC9GDvUHTFaIVyKhC
# gMD7bJMk3RIzIgA8f1knHIseebUI3gFnhd2UnZWdCtX1xvUCO7JT2vHzFr3hyH3W
# g7S6RW/NAdr0gHKVtJNfE24z0hpccrHJtXC0rgPRNyKOX5/lqYO6nba0ivrSTC4p
# 5tLz0h/QYCts244HYNW5xAWSDmdR2BBq19ymSHT8y/XAx3OqBNq+3JUhP+M+owOP
# OewUFU5oAqiRDdu8ag4ndv5+9xVWGyT6h0OX57Cd0Z14baszFJc9qyclKG67GmAB
# TwdM1qg/Z/DhGjPRVkN+eDYnTb1BzVuVo6BYA2LfmjWsmBEC1CFl49aEKOhSxuYU
# sspiPjrix7l7aqnH2QkOZi93bieih2zCXn62RmV6FDWNMf7B3ElWQoq4ofMQRsJb
# RXADpGBnDqT+YYr8B6hoX8KZ+MsCAwEAAaOCAcswggHHMB0GA1UdDgQWBBSFZTsR
# yjPodArmkyF8WRMJnSwACTAfBgNVHSMEGDAWgBRraSg6NS9IY0DPe9ivSek+2T3b
# ITBsBgNVHR8EZTBjMGGgX6BdhltodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2NybC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmcl
# MjBDQSUyMDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0wazBpBggrBgEFBQcwAoZdaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBQ
# dWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3J0MAwGA1Ud
# EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeA
# MGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAI
# BgZngQwBBAIwDQYJKoZIhvcNAQEMBQADggIBAEibNvWCdyE0QfF0qtqPiMJPl8Cn
# UkvPY5S5TuIWor55M30EGb8557hhQQ65yyXX6wKSzkEZDJDolK0K3w0eknCD3v3Z
# vBcmS3ehxb/jB4XmwaUqZ5JPQKUEM94kk9NmRGaX9cIBjV8yXHGIDiTvF6nxxz0p
# QyS/btGgdGcbQPAIaXlgfEIgc/FyI4lfGTJL+1oW8O7UrQ0tK6VfVQ6M0F0sUrpP
# aAznV8udyfUqXhCcdgO4QIM48OEAKcBSf2t6Gf9aS3ARJALf/Rj/255+hhlq/1Qk
# n6B2aLlTK/ApvqBtMtb8omB/j+3Hlvamtk2MLalKM3wkFoE+iMRd71xLfGKY/h8m
# 0h/guB+Hwm8fi8sRsmk80a0/3oCuhrGNR2Kdcqxmiks6cF+WyKObI2lkGQKXKh3v
# yX42BYHnr+ZFZWSf1G4xfdHqFZHUuoZ0zRz4RvCDOBt/zf12olGKDTDwPLazAV+x
# +8yZqNyHXnHVz6i4+Js9PYWeB6vOaibpfVDOCS/EHS7+j2LER6uKTneDyFU3UJhB
# 6hmenAKR/SOrdBhosoS4UI5jlEt9wYSu2xNxw7aKlK6lnMFXCVMCeEa8GhpD22U5
# qNRfIfhVohwz0bw3DZ84/f8J1y4scH/5aiAkfgxn7RhzY6T3tC8A74k6fvWBjpOm
# ej+byPlnS4tt/cRiMYID1DCCA9ACAQEweDBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAADozKO0VKZiiBAAAAAAA
# OjANBglghkgBZQMEAgEFAKCCAS0wGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCCalgMaEJOo+v6rkpzo8wqrBpYUqPy5He4nd2NZXamz
# fzCB3QYLKoZIhvcNAQkQAi8xgc0wgcowgccwgaAEIOiTtrG2N3h52cHQpFIpCBET
# WiSpNJnTzdC8HVfcp+A2MHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMg
# UlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAOjMo7RUpmKIEAAAAAAA6MCIE
# IMOlNKoXQj5f2l23u29mtxbF047vOikm1cm2jZVbS06ZMA0GCSqGSIb3DQEBCwUA
# BIICAEQR3E9264UQ4Xe4skb8zdVksV5fEbtKvJm+E0mU2sQk37fAuiE30SIoTUEH
# peqqrdJefxDpTx5HAbITw+KGPpgvIwNNtdycfmawXjZ6ODQr3zG5yt969Obi58N3
# n3FLQQc8Z1j3EiyNTdTUgrBsuVc2sYNmEqbMEqgv/SwQ87JOFJR9E4StcSKvXBfK
# i3xkGVj2fA2Jgi+HbKNKbah9ciJp/uOZrMRDdT0IrVdzD54mE6bbx+/IutTpPIjG
# bWpC5u+zkJytf8C3eTRammLYEwwpVWwPRgT+pM9IYK8hy1UD4oa1or7F6QvZKh9+
# PAa3FtVC9CqkpNshbneyctice7iAGDs4piVo4m6XOJCNGbNGNEQk6laE/IP/Ar4Y
# z+MY20nO6VSRmKwLQRwJQs+DmY4phHVfkHWJPxxfJtnmuvfjMyxz+ks7XpMnfpt2
# dlcWjM1tGimDZeQWsxx6KvMfOR/4g2yrGgeibAascpENKgfzp/ua1W0cGn01w4Of
# C8xJkMvQysL8amHtWu6trNPWMJzygqrv3Nbffgg5iIK2FnUPuuOyQuRymoCH6t3K
# gVE6RiOS1cgLkt5PZp663S40lIVMMSZLdasHUCusOSfdGCUkDspCsG7mzkCpA/dp
# rYi/ihJe3rXFKQ9duTJnSY10JY5V3pjPyzp9CYKoMkVlDbV5
# SIG # End signature block
