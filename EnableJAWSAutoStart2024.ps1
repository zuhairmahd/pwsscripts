# Enable JAWS to auto start on login
#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'JAWS2024.log'
$machinePath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility'
$JAWSFilePath = 'C:\Program Files\Freedom Scientific\JAWS\2024\jfw.exe'
$JAWSRegistryPath = 'HKLM:\SOFTWARE\Freedom Scientific\JAWS\2024'
$keyName = 'Configuration'
$keyValue = 'FreedomScientific_JAWS_v2024'
$JAWSUserRunPath = 'HKCU:\SOFTWARE\Freedom Scientific\JAWS'
$JAWSRunKeyName = 'Run'
$AlwaysRun = 1
$NeverRun = 0
$AllUsersRunKeyName = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
# $CurrentUserRunKeyName = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$JAWSTargetVersion = '2024.2409.2.400'


#Create Folder to keep logs 
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile -Force

try {
    #Let's see if JAWS is installed by checking for the presence of the jaws executable
    if (!(Test-Path $JAWSFilePath)) {
        Write-Host 'JAWS executable not found'
        Stop-Transcript
        exit 1
    }
    else {
        Write-Host 'JAWS executable found'
    }
    #now let's check for the path in the registry
    if (!(Test-Path $JAWSRegistryPath)) {
        Write-Host 'JAWS registry key not found'
        Stop-Transcript
        exit 1
    }
    else {
        Write-Host 'JAWS registry key found'
    }
    #Check the executable file for the right version of JAWS
    $jawsVersion = (Get-Command $JAWSFilePath).FileVersionInfo.ProductVersion
    if ($jawsVersion -ne $JAWSTargetVersion) {
        Write-Host "JAWS version is $jawsVersion.  The target version is $JAWSTargetVersion.  Versions do not match. Exiting."
        Stop-Transcript
        exit 1
    }
    else {
        Write-Host "JAWS version is $jawsVersion.  The target version is $JAWSTargetVersion. Versions match"
    }
    #now that we know JAWS is installed, let's proceed to enable it for auto start
    $key = Get-ItemProperty -Path $machinePath -Name $keyName -Verbose -ErrorAction SilentlyContinue
    #Check to see if JAWS is already enabled to autostart 
    if ($key.Configuration -eq $keyValue) {
        Write-Host 'JAWS auto start before signing in is already enabled'
    }
    else {
        if (!(Test-Path $machinePath)) {
            Set-Item -Path $machinePath -Value $keyValue
        }
        else {
            Set-ItemProperty -Path $machinePath -Name $keyName -Value $keyValue -Force 
        }
        Write-Host 'Enabled JAWS auto start before signing in'
    }
    #Enable for AllUser start
    $key = Get-ItemProperty -Path $JAWSRegistryPath -Name $JAWSRunKeyName -ErrorAction SilentlyContinue
    if ($key.Run -eq $alwaysRun) {
        Write-Host 'JAWS auto start after signing in is already enabled'
    }
    else {
        if (!(Test-Path $JAWSRegistryPath)) {
            Set-Item -Path $JAWSRegistryPath -Value $alwaysRun
        }
        else {
            Set-ItemProperty -Path $JAWSRegistryPath -Name $JAWSRunKeyName -Value $alwaysRun -Force
        }
        Write-Host 'Enabled JAWS auto start after signing in for all users.'
    }
    #Enable for CurrentUser start
    $key = Get-ItemProperty -Path $JAWSUserRunPath -Name $JAWSRunKeyName -ErrorAction SilentlyContinue
    if (($key.Run -eq $alwaysRun) -or ($key.run -eq $NeverRun)) {
        Remove-ItemProperty -Path $JAWSUserRunPath -Name $JAWSRunKeyName -Force -ErrorAction SilentlyContinue
        Write-Host 'Setting autostart to use all user settings'    
    }
    else {
        Write-Host 'JAWS is already set to use all user settings'
        # if (!(Test-Path $JAWSUserRunPath)) {
        # Set-Item -Path $JAWSUserRunPath -Value $alwaysRun
        # }
        # else {
        # Set-ItemProperty -Path $JAWSUserRunPath -Name $JAWSRunKeyName -Value $alwaysRun -Force
        # }
        # Write-Host 'Enabled JAWS auto start after signing in for current user.'
    }
    $key = Get-ItemProperty -Path $AllUsersRunKeyName -Name 'JAWS' -ErrorAction SilentlyContinue
    if ($null -eq $key) {
        New-ItemProperty -Path $AllUsersRunKeyName -Name 'JAWS' -Value "`"$JAWSFilePath`" /run" -PropertyType String -Force 
        Write-Host 'JAWS added to all users run registry'
    }
    else {
        Write-Host 'JAWS already added to all users run registry'
    }
}

catch {
    Write-Host 'Failed to enable JAWS auto start before signing in'
    Write-Host $_exception.Message $key
    exit 1
}

Stop-Transcript
# SIG # Begin signature block
# MII94QYJKoZIhvcNAQcCoII90jCCPc4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCX6eITSK2OcskL
# 2RaAmw5wnBw/q8Rt3JfN7UxHkiEQfaCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAADfIqDl
# w+kBJM3oAAAAAN8iMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBFT0MgQ0EgMDEwHhcNMjQxMDE3MTk0ODI4WhcNMjQxMDIw
# MTk0ODI4WjBmMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExEjAQBgNV
# BAcTCUFybGluZ3RvbjEXMBUGA1UEChMOWnVoYWlyIE1haG1vdWQxFzAVBgNVBAMT
# Dlp1aGFpciBNYWhtb3VkMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# siAdi6HIeHTm8Gr0ddJE/kpOyfUfNopUPU/y2l21YYv2OFDFvXeWjmjlmxIMUfwM
# 8tvQH/U/XphHC5LrxzH6kS6M0ZpG8REa7QOGTPB3urAVBZpUYK0lTwsrDQpFBiHc
# iD+VlV49LrfytLcFDwZd3Jh8UK4v2haZJ8wBPRgBpZSVxnDBtTWu7W3WkIpphsxA
# wXl3WGL5tO2iURgctbHOJBaupXEPuEbaGXgziKq39JFI40ZXVCPtnCnZRDtLhFSX
# 5yrZADb8ZSSqJJegXAYXaIoN4xqRHqRCtd1W6499YvhO5oDPKGztx35SYhIYe9wr
# Lr0ZOvwDZg8w0IluAt69bt2wcuuNHWa6ntUhjU9EM92SyiziNrq56vH2Ujva9Ixv
# hmi1wWcm1BaioOpLVwvn/OqWvDhx4VOR7e8MrwvZUc4vOGuX/9IvtkcA2bQPmF23
# 5iIGE7singPel/LYbxWe8ZB5pfZKTVmKebutyQ2DT5qiIhLyjJo0qr7IONY7Kecj
# AgMBAAGjggIYMIICFDAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA7BgNV
# HSUENDAyBgorBgEEAYI3YQEABggrBgEFBQcDAwYaKwYBBAGCN2GBmtGaFtje9WuB
# vfqFXPmA7xswHQYDVR0OBBYEFEeQIi6UJwehCG31SSsq7lxPYco/MB8GA1UdIwQY
# MBaAFHacNnQT0ZB9YV+zAuuA9JlLpT6FMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEVPQyUyMENBJTIwMDEuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBFT0MlMjBD
# QSUyMDAxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBAMKGMZZgyMbBTxpw
# vya19RChLaigi0uRrcfB3PVTHbA78rVkuU8ndu+HPW9+GDn6ddwXmGrmJQBwF8Fa
# yrLyOrH0ll4K5w8LKhSW12ayyn8G4bZvAapi2cHy9V7hMmot9p5KWLOgwsea40A1
# yg0MDzMhnqA6wuOYwrEIvbGBbJayZVHZQ7N4QWk5k0AGj8iMik/+21OX24QxQy7f
# zQsPTCgx8nfP0JmyyvS1FchJsGOocMlRyTMbY3Gk2YqS26XhSdYe9RySAKHeetch
# LydyvFPtkW/9nErPzf00Z9Sv3qSSi+tHhVJJQo36Km2qqQLw5jXCHBSu8rXux0BR
# SuQOUjYilONi5DIvIj5QLKEh2YaRKpzUKM4VSFoAeg1b6CtVj8dEouC/5Q0cWnPb
# hYRLZdrjBDk4KYqi8tJaSeLy9k9SUMEWYWxZBjFVfeERXSSGHsyyawc7x5+B9G0y
# S4wIsn/agfevN81RYNg1uqr8/rUP7REar16juVP6HT31lsd1NfynvOr1J0B58U8x
# XzSwPFV6VPDzR0140P9/raESqmoCCC7+/rjAezIf8diTZAylPIel7bKICNR5Xh9o
# Xq/5SATeBZfZa3MhXUFlmWE40CbRcvh1/QWqOaOJDvHJdxRncHkFPoILJaRF4zLM
# VQ2TfGVwPy4tNI/ZiBHTFCTKSZxMMIIG5zCCBM+gAwIBAgITMwAA3yKg5cPpASTN
# 6AAAAADfIjANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgRU9DIENBIDAxMB4XDTI0MTAxNzE5NDgyOFoXDTI0MTAyMDE5NDgy
# OFowZjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMRIwEAYDVQQHEwlB
# cmxpbmd0b24xFzAVBgNVBAoTDlp1aGFpciBNYWhtb3VkMRcwFQYDVQQDEw5adWhh
# aXIgTWFobW91ZDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBALIgHYuh
# yHh05vBq9HXSRP5KTsn1HzaKVD1P8tpdtWGL9jhQxb13lo5o5ZsSDFH8DPLb0B/1
# P16YRwuS68cx+pEujNGaRvERGu0Dhkzwd7qwFQWaVGCtJU8LKw0KRQYh3Ig/lZVe
# PS638rS3BQ8GXdyYfFCuL9oWmSfMAT0YAaWUlcZwwbU1ru1t1pCKaYbMQMF5d1hi
# +bTtolEYHLWxziQWrqVxD7hG2hl4M4iqt/SRSONGV1Qj7Zwp2UQ7S4RUl+cq2QA2
# /GUkqiSXoFwGF2iKDeMakR6kQrXdVuuPfWL4TuaAzyhs7cd+UmISGHvcKy69GTr8
# A2YPMNCJbgLevW7dsHLrjR1mup7VIY1PRDPdksos4ja6uerx9lI72vSMb4ZotcFn
# JtQWoqDqS1cL5/zqlrw4ceFTke3vDK8L2VHOLzhrl//SL7ZHANm0D5hdt+YiBhO7
# Ip4D3pfy2G8VnvGQeaX2Sk1Zinm7rckNg0+aoiIS8oyaNKq+yDjWOynnIwIDAQAB
# o4ICGDCCAhQwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOwYDVR0lBDQw
# MgYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGisGAQQBgjdhgZrRmhbY3vVrgb36hVz5
# gO8bMB0GA1UdDgQWBBRHkCIulCcHoQht9UkrKu5cT2HKPzAfBgNVHSMEGDAWgBR2
# nDZ0E9GQfWFfswLrgPSZS6U+hTBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBFT0MlMjBDQSUyMDAxLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwRU9DJTIwQ0ElMjAw
# MS5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQDChjGWYMjGwU8acL8mtfUQ
# oS2ooItLka3Hwdz1Ux2wO/K1ZLlPJ3bvhz1vfhg5+nXcF5hq5iUAcBfBWsqy8jqx
# 9JZeCucPCyoUltdmssp/BuG2bwGqYtnB8vVe4TJqLfaeSlizoMLHmuNANcoNDA8z
# IZ6gOsLjmMKxCL2xgWyWsmVR2UOzeEFpOZNABo/IjIpP/ttTl9uEMUMu380LD0wo
# MfJ3z9CZssr0tRXISbBjqHDJUckzG2NxpNmKktul4UnWHvUckgCh3nrXIS8ncrxT
# 7ZFv/ZxKz839NGfUr96kkovrR4VSSUKN+iptqqkC8OY1whwUrvK17sdAUUrkDlI2
# IpTjYuQyLyI+UCyhIdmGkSqc1CjOFUhaAHoNW+grVY/HRKLgv+UNHFpz24WES2Xa
# 4wQ5OCmKovLSWkni8vZPUlDBFmFsWQYxVX3hEV0khh7MsmsHO8efgfRtMkuMCLJ/
# 2oH3rzfNUWDYNbqq/P61D+0RGq9eo7lT+h099ZbHdTX8p7zq9SdAefFPMV80sDxV
# elTw80dNeND/f62hEqpqAggu/v64wHsyH/HYk2QMpTyHpe2yiAjUeV4faF6v+UgE
# 3gWX2WtzIV1BZZlhONAm0XL4df0FqjmjiQ7xyXcUZ3B5BT6CCyWkReMyzFUNk3xl
# cD8uLTSP2YgR0xQkykmcTDCCB1owggVCoAMCAQICEzMAAAAGShr6zwVhanQAAAAA
# AAYwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTRaFw0yNjA0MTMx
# NzMxNTRaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBFT0MgQ0Eg
# MDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDH48g/9CHdxhnAu8XL
# q64nh9OneWfsaqzuzyVNXJ+A4lY/VoAHCTb+jF1WN9IdSrgxM9eKUvnuqL98ftid
# 0Qrgqd3e7lx50XCvZodJOnq+X88vV0Av2x+gO82l0bQ39HzgCFg2kFBOGk7j8GrG
# YKCXeIhF+GHagVU66JOINVa9cGDvptyOcecQS1fO8BbAm7RsFTuhFGpB53hVcm0g
# JW35mgpRKOpjnBSWEB3AeH7fUGekE8LMW0pWIunrMS1HI7FF6BqAVT7IuBe++Z3T
# sgM3RLZMti6JmNPD6Rxg62g2AqvuTQLoT1Z/cfiMdq+TYzGoWm2B8vSAv7NtJv5U
# E0qJVPSarNckgmZaarDQr4Pcwp+YJ6vd7cJus/4XlG0JvRdoTS5Fwk9kmNbByIMH
# EEhuQ0XgYvXaGXm/J2AUybNBw26h0rJf//eUsnWrbaugdVLVyC2wuCmNZhmUGWEJ
# Nxcl5nfG5om9dkH2twsJfXk6BcvbW1RTAkIsTbtXkAZnGQ7eLniaBIKzC06ZZTgA
# p38H97cq1e/pcFREq4C157PUSmCWhpnBB6P2Xl031SHxbX0FmD0iUuX7EdFfi8OI
# xYBR//sA17gyhL3wXjmvvogYnSELTYQy4xnEASvBmPSWfRovncTOUxrkkKJE5tvR
# Sgsd8ZJ00mwyDS6PcMBAN1VZMQIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBR2nDZ0E9GQfWFfswLrgPSZS6U+
# hTBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAGov
# CZ/YsHVCNSBrQbvMWRsZ3w0FAsc/Qo4UFY0kVmJO0p+k7RtnZZ+zq/m+ogqMTfZD
# ozz0bhmRVy9a4QAD52+MtOFLLz1jT/+b9ZNIrBi2JHUTCfvHWTD8WD3fBCmzYLVZ
# SP7TT/q42sX53gxUnFXUegEgP73lkhbQqSpmimc4DjDm8/hPlwGmtlACU/+8wbIH
# Qf36kc2jSNP1DyB8ok3MdL2LUOAGaa58Z1b1MHK6ejwYCLMUyEuUizTxvmWKUiQT
# nPcUwBQCv5eAgjUU1mdvjc4jpB3bM6KNuNh+6uxdQI0cL5FLAkablQvM/KZiCCcn
# 6SEk6ruhKWo8aluvvSEYF4/D8nv+aZKqnuFOC3SY+KRLWLhqnzH4/fJ6ZhKGcWuB
# XXvnZMj4Czr0t+Au2GQhO9/tsUcHy+YiFp1kI5LS9MLHcH785VwQws07ZsnQ72KR
# zUmpHQW+rHucDAxFKHcVWqiyDMFtadWRAmruhYXAxV8Uhifos9Fky3jy7qIxQIUF
# I912w8D/qTzmYS/7TxTlYJDvJ2PUpVXZMet7/yYseJ6b3B/8LOiGpGe3EzYT/H40
# fLpMEydI9BGqGE1+46BQMBYRiaUz9kcZo8hvvE699XItD/uXph+iBPd6m3CngY4Z
# GMfnP6Ab2SkEjHxCtGXo6KWeXFETGiSYx+UvuXXZMIIHnjCCBYagAwIBAgITMwAA
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
# nTiOL60cPqfny+Fq8UiuZzGCGpEwghqNAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEVPQyBDQSAwMQITMwAA3yKg5cPpASTN6AAAAADfIjAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCDqirQk/1zK4CLDgJ3zMt9HxpL0
# nXOW5V1HZUEMQRJsODANBgkqhkiG9w0BAQEFAASCAYBHAm/2b90qx1Z0CwmfQK88
# d6WGaREj0o0X4JhcKjgM1bxVrBZN6hVF295HcJsJgd/oFjpIO8WW3o3En5f8k0jR
# km+oYvu+hyu4LuGAx87+6adfnyXD4/QG+ZsIolkrp49F8xqLvn5JhtP0Meyx55V9
# DrMv3N1+JO4wxyys1zUZiu3j2nDj7vPghs3oD06FMVMHHzo4YJOysKRUR5RSwCmu
# 1duV9k110I5WXDqxcuMlzvp67C0Y+T/4WlKgiK32YmS2lfW4cEyZjPS8g0GbyisK
# wZ9tHVBzRDwFD8/40hj4MhwEJpcOUvIHwkNz91VTcP9VjZ7byMZVcj/Oi8qNpuqb
# waCBGLI2B+DwPcpvS9J5dz+m0PqiovWo3etk6JWjZU0Votd+cEDLvT++09BoJy8E
# WPB9x/cSIBM7wvXZICrqPzSOmbQn5OA1QYb9bmFJEgopkCw0YFrTD2u0/YOhWpkh
# eHk1uZk3eXpaFqfI/LQ++Kfh/498NxuggZUNcu+XqSuhghgRMIIYDQYKKwYBBAGC
# NwMDATGCF/0wghf5BgkqhkiG9w0BBwKgghfqMIIX5gIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYgYLKoZIhvcNAQkQAQSgggFRBIIBTTCCAUkCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgK9MtfjK6H7y2eXRQp3XQKsrU2esTE5SpNpweVsiL
# HloCBmcNCHSqjxgTMjAyNDEwMTcyMjA4MzcuNjg0WjAEgAIB9KCB4aSB3jCB2zEL
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
# vxh5XI8PYU+u1QP+JkIxggdDMIIHPwIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAPH8boMoAN0W5AAAA
# AAA8MA0GCWCGSAFlAwQCAQUAoIIEnDARBgsqhkiG9w0BCRACDzECBQAwGgYJKoZI
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yNDEwMTcyMjA4
# MzdaMC8GCSqGSIb3DQEJBDEiBCAOmKDcs/0MyTmmJKAfoGvJz3ZeZ722ic9duY1G
# fTOkvjCBuQYLKoZIhvcNAQkQAi8xgakwgaYwgaMwgaAEIFqfp4iRv0gaMubqvGC4
# di42Y4hsCBMMHWhRlTSShLjbMHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAPH8boMoAN0W5AAAAAAA8
# MIIDXgYLKoZIhvcNAQkQAhIxggNNMIIDSaGCA0UwggNBMIICKQIBATCCAQmhgeGk
# gd4wgdsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNV
# BAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGll
# bGQgVFNTIEVTTjpBNTAwLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHmiIwoBATAHBgUrDgMCGgMV
# ANJMC0nWnsDHBXhCaT90FwjHNR8joGcwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMA0GCSqGSIb3DQEBCwUAAgUA
# 6rt7eTAiGA8yMDI0MTAxNzEyMDMwNVoYDzIwMjQxMDE4MTIwMzA1WjB0MDoGCisG
# AQQBhFkKBAExLDAqMAoCBQDqu3t5AgEAMAcCAQACAjfFMAcCAQACAhPLMAoCBQDq
# vMz5AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMH
# oSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAB6N3MCPbwYcDalOz63G
# 77pCAvH0q2kL0zVHty/DbWN3yWxNYNNmps+mZn5xMuvGvRMe0ia2z979Zw24nrFj
# hc+iMhQlOs8Ucxlc9WIoiFBvb4ncilgL5MFGi1skaSwHWDEkH265yjl3u95Z+kta
# uX/YA2S/u3PAcwAYJyBEtJncYzB/uOIAY4FwPcqYgxA8EFz5k4Eijve3VHQVB/rW
# gNa3YgpHWR/8IVHMWj+9O+bZwAYmmmr3yV6CeNkIKbq9WX1XTVWfSk3nBr+fFFS+
# XDNq/+6Bg97tN5HhmGjhJchQK76mphmKqB/C7BIfUgpn8TO2azU+iE4xB63Tnb+p
# RxIwDQYJKoZIhvcNAQEBBQAEggIALwl/7Yv3yjHnQMul/xCOLlojEkkqEiTapyed
# fDKkp3IIIqBbrXEvBTjXSpIJwvPOih0tSSsykvqyZ+vOgDMHFRBS8HwmcfxhIVrq
# mZj28FS/mjOxYXYqi6+JJbbKqQ6Xe8NmL32/VboFAY/lr0Kd+zrxM7/N2tUF6Ruu
# OobERGfy7w4bijK9pOKF35PW4rXXcGb0Z9Fm09MaGiGdiRBUHnmr5poHloYFhdA+
# 46KGz72KZSA3DMCp8r1HWd96xgMBJV6roCKE64kdDUCJVsKF1vsLZttACHC24V0j
# vx8BxL29Sw7tX3M0M5zAGEY+8hw1Xnqf+xUKiSdfyt35fmt+Fa0+sMv6BTjzxWuv
# xJiqDGinlIeWqNnXZpddsvZ2yKuuu2xH8MJ2zfxoIyGtjqfgJJc8TYXdo4yxqsWQ
# gv74BsGgsj/OUtWQobHQdml86UOGX5cMJsZ6P7/51X1wInL47wC6JaiTytQDhr5M
# AeuoSGaa6ZlwMkJH8vAc1jHWqmNcLBNPtHYj7mCaXckANWYJIWDjZGWh8aCM33Te
# 8DNgpsQ8ZM/gCUFsAivVPVHy5DWKBF6yGqJzpK4ovnGzeU9Tw/aBmahqCfpWVIQK
# 7bV62sZr1Ly/VCVF1ZUn1sZreW4bgoMCodB2Se3oGCGYQcFTQtInvDwh0rQVh6tD
# 2Fcm5e0=
# SIG # End signature block
