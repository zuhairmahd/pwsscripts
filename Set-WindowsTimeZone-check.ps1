#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'TimeZone-check.log'

#Create Folder to keep logs 
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/Appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile

#Write a timestamp noting when the script started to the log.
Write-Host "Script started at $(Get-Date -DisplayHint DateTime)"
function Get-UnixTimeZoneFromIP {
    #First let's get the IP address
    $IPAddress = (Invoke-WebRequest -UseBasicParsing -Uri 'https://api.ipify.org/').Content 
    Write-Host Your detected public IP address is $IPAddress
    #See if we can get the time zone, assuming an IP address was returned
    if ($IPAddress -as [ipaddress]) {
        $GeoIP = Invoke-RestMethod -UseBasicParsing -Uri "https://freegeoip.app/json/$IPAddress"
        $UnixTimeZone = $GeoIP.time_zone
    }
    if ($UnixTimeZone) {
        return $UnixTimeZone
    }
    else {
        Write-Host "Could not find a time zone for IP address $IPAddress"
        return $null
    }
}

function Convert-TimeZone {
    param (
        [string]$UnixTimeZone
    )
    $map = switch ($UnixTimeZone) {
        { 
            'America/Anchorage', 'America/Juneau', 'America/Metlakatla', 'America/Nome', 'America/Sitka', 
            'America/Yakutat', 'us/Alaska' -contains $_ 
        } {
            'Alaskan Standard Time' 
        }
        { 
            'America/Adak', 'us/Aleutian' -contains $_ 
        } {
            'Aleutian Standard Time' 
        }
        { 
            'America/Winnipeg', 'America/Rainy_River', 'America/Rankin_Inlet', 'America/Resolute', 'America/Matamoros', 
            'America/Chicago', 'America/Indiana/Knox', 'America/Indiana/Tell_City', 'America/Menominee', 
            'America/North_Dakota/Beulah', 'America/North_Dakota/Center', 'America/North_Dakota/New_Salem', 
            'us/Indiana-Starke', 'us/Central' -contains $_ 
        } {
            'Central Standard Time' 
        }
        { 
            'America/New_York', 'America/Nassau', 'America/Toronto', 'America/Iqaluit', 'America/Nipigon', 
            'America/Pangnirtung', 'America/Thunder_Bay', 'America/Detroit', 'America/Indiana/Petersburg', 
            'America/Indiana/Vincennes', 'America/Indiana/Winamac', 'America/Kentucky/Monticello', 
            'America/Kentucky/Louisville', 'us/Michigan', 'us/Eastern' -contains $_ 
        } {
            'Eastern Standard Time' 
        }
        { 
            'Pacific/Honolulu', 'Pacific/Rarotonga', 'Pacific/Tahiti', 'us/Hawaii' -contains $_ 
        } {
            'Hawaiian Standard Time' 
        }
        { 
            'America/Denver', 'America/Edmonton', 'America/Cambridge_Bay', 'America/Inuvik', 'America/Yellowknife', 
            'America/Ojinaga', 'America/Boise', 'us/Mountain' -contains $_ 
        } {
            'Mountain Standard Time' 
        }
        { 
            'America/Los_Angeles', 'America/Vancouver', 'America/Dawson', 'America/Whitehorse', 'America/Tijuana', 
            'us/Pacific' -contains $_ 
        } {
            'Pacific Standard Time' 
        }
        { 
            'Pacific/Apia', 'us/Samoa' -contains $_ 
        } {
            'Samoa Standard Time' 
        }
        { 
            'America/Indiana/Indianapolis', 'America/Indiana/Marengo', 'America/Indiana/Vevay', 'us/East-Indiana' -contains $_ 
        } {
            'US Eastern Standard Time' 
        }
        { 
            'America/Phoenix', 'America/Dawson_Creek', 'America/Creston', 'America/Fort_Nelson', 'America/Hermosillo', 
            'us/Arizona' -contains $_ 
        } {
            'US Mountain Standard Time' 
        }
        default {
            $null 
        }
    }
    return $map
}

#Let's try getting the user's time zone from their logged in IP address
$UnixTimezone = get-UnixTimeZoneFromIP
if ($UnixTimezone ) {
    $WindowsTimeZone = Convert-TimeZone -UnixTimeZone $UnixTimezone
    Write-Host Got the time zone from IP address.
}
else {
    Write-Host 'Failed to get timezone.  Giving up as there is nothing to do. Will not be calling remediation script.'
    Stop-Transcript
    exit 0
}

if ($WindowsTimezone) {
    Write-Host "Time zone detected as $WindowsTimeZone"
    #Check to see if the time zone is already set to the detected time zone
    $CurrentTimeZone = Get-TimeZone
    if ($CurrentTimeZone.Id -eq $WindowsTimeZone) {
        Write-Host "Time zone is already set to $WindowsTimeZone"
        Stop-Transcript
        exit 0
    }
    else {
        Write-Host "Time zone is not set to $WindowsTimeZone.  Returning exit code 1 so remediation script to run"
        Stop-Transcript
        exit 1
    }
}
else {
    Write-Host 'Could not detect time zone'
}

#we are done here
Stop-Transcript
# SIG # Begin signature block
# MII9YAYJKoZIhvcNAQcCoII9UTCCPU0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCZXwY6m1muLUc3
# zZX3+/zItq4eN0lapv+J8Hxf3joopaCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAHMQn7F
# SA+l8eEvAAAAAcxCMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjQxMTA0MTgwNjAyWhcNMjQxMTA3
# MTgwNjAyWjBmMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExEjAQBgNV
# BAcTCUFybGluZ3RvbjEXMBUGA1UEChMOWnVoYWlyIE1haG1vdWQxFzAVBgNVBAMT
# Dlp1aGFpciBNYWhtb3VkMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# pvaGJWIdgDqTQpFzirPjD7fsLJOELrsBL5npG5cxEw7zESEIhqxZd2ldigQH+H7l
# fz8VqgMBSd1IYpNI36EOvfWQ1KF/w9EvVj17f3cE3ia1bDQnrU4j6eiXN+96fhDl
# X4NQRfoG+pJmDSByxppnuhs31kT1YhON5cSNXKTVgYUQFJgp9QxRgmSKdRQUjDAT
# l4JIz/ju3jMpf4Z2aIEwVzMee19GfHfzvcAnjwLfTD2s+KZ+Xv6IBoQXKazQ7XFT
# AXVHf1cJXJeoRY7XmGyvw9OovQNwu7jRtvd6mfoCjI1Rla1Yy+N6uNdf1o5uqQoK
# CM9JVMEuZhH8mzv6/Wsrt5RL4gTKttg+iikI2HEPEgyzCtLBAYzYCSdTA0Sp801i
# Ul3+3CEGU1uumxb0IC7BtFRKHHqRlJbVA/XkoGQU501YlZqjo303DYYpIOCIOhws
# s2wIj3v0ssbBUFPEO+UCjt4RSayYxcK3UwcL/dCeL3Ku07AU2IYucj9TiXvgWFrh
# AgMBAAGjggIYMIICFDAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA7BgNV
# HSUENDAyBgorBgEEAYI3YQEABggrBgEFBQcDAwYaKwYBBAGCN2GBmtGaFtje9WuB
# vfqFXPmA7xswHQYDVR0OBBYEFGi+Zv96dYPp5T4oJzHgKo5WLomVMB8GA1UdIwQY
# MBaAFOiDxDPX3J8MnHaaCqbU34emXljuMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBALVfKtdTZ8R5ZAY7
# s6u0iMwlq8FCLtUAhZ7N79OHycufMngQKUoWPIScIQpWWQRypgYudRjNsV76oiYE
# KNMwUJuu+/sahPZJhoxZqFxqPr9BpUeiYy6PpKZ7DGNo1KcfxB2LlhBPohYlVaiz
# vCEZ9Rugf3q7hepQC+hziLooy5E06Kkjw+MJfIEhqiQczIP8RnkIPJ5HTs37xoNx
# TNUpe3g2FlWF6ncX/8ZfXDHSrjlvVM++DrdLhgvovxLtbu7SH+FkHyqJe0hqYsXw
# m+4a2wL0tp2J1Q7GHby+996+BOzvyvb6jH9bApceK97Dp1dBalMxJdHzKhPU7t7+
# H77VUXIfgYIWNaI15Mqd/UjD+qWi2zQt+y3OTYgrvTkJ3XI+5h3X5Tkj4/5/DI8o
# wkb9Q/cKrnzmvzEI9RExQSmuZk/62+lkOp6l+Ws3AEIhZVXO45iR17is1jHHtSec
# 3WKXGsuH0gL4CuuWrJhLOqo5OfDABE6tgjfaELaaLm8oEBBDk4PgU1dCanurQQpC
# AODh8H8T0ocemvJfbLhWk9a4VyHsSzc9k87EIMbMEOmGQgU5/pNXK7SdaQyZzbOQ
# dgPN2ekV1ZooQ6lG1yLajxkmtdQYCgRpTOl5mT0vV8/BcMeIpfLhYeMzAkUI+2uL
# JDGT6al8vt/HOcgxdBMdBxQ7armRMIIG5zCCBM+gAwIBAgITMwABzEJ+xUgPpfHh
# LwAAAAHMQjANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAxMB4XDTI0MTEwNDE4MDYwMloXDTI0MTEwNzE4MDYw
# MlowZjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMRIwEAYDVQQHEwlB
# cmxpbmd0b24xFzAVBgNVBAoTDlp1aGFpciBNYWhtb3VkMRcwFQYDVQQDEw5adWhh
# aXIgTWFobW91ZDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAKb2hiVi
# HYA6k0KRc4qz4w+37CyThC67AS+Z6RuXMRMO8xEhCIasWXdpXYoEB/h+5X8/FaoD
# AUndSGKTSN+hDr31kNShf8PRL1Y9e393BN4mtWw0J61OI+nolzfven4Q5V+DUEX6
# BvqSZg0gcsaaZ7obN9ZE9WITjeXEjVyk1YGFEBSYKfUMUYJkinUUFIwwE5eCSM/4
# 7t4zKX+GdmiBMFczHntfRnx3873AJ48C30w9rPimfl7+iAaEFyms0O1xUwF1R39X
# CVyXqEWO15hsr8PTqL0DcLu40bb3epn6AoyNUZWtWMvjerjXX9aObqkKCgjPSVTB
# LmYR/Js7+v1rK7eUS+IEyrbYPoopCNhxDxIMswrSwQGM2AknUwNEqfNNYlJd/twh
# BlNbrpsW9CAuwbRUShx6kZSW1QP15KBkFOdNWJWao6N9Nw2GKSDgiDocLLNsCI97
# 9LLGwVBTxDvlAo7eEUmsmMXCt1MHC/3Qni9yrtOwFNiGLnI/U4l74Fha4QIDAQAB
# o4ICGDCCAhQwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOwYDVR0lBDQw
# MgYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGisGAQQBgjdhgZrRmhbY3vVrgb36hVz5
# gO8bMB0GA1UdDgQWBBRovmb/enWD6eU+KCcx4CqOVi6JlTAfBgNVHSMEGDAWgBTo
# g8Qz19yfDJx2mgqm1N+Hpl5Y7jBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAxLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# MS5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQC1XyrXU2fEeWQGO7OrtIjM
# JavBQi7VAIWeze/Th8nLnzJ4EClKFjyEnCEKVlkEcqYGLnUYzbFe+qImBCjTMFCb
# rvv7GoT2SYaMWahcaj6/QaVHomMuj6SmewxjaNSnH8Qdi5YQT6IWJVWos7whGfUb
# oH96u4XqUAvoc4i6KMuRNOipI8PjCXyBIaokHMyD/EZ5CDyeR07N+8aDcUzVKXt4
# NhZVhep3F//GX1wx0q45b1TPvg63S4YL6L8S7W7u0h/hZB8qiXtIamLF8JvuGtsC
# 9LadidUOxh28vvfevgTs78r2+ox/WwKXHivew6dXQWpTMSXR8yoT1O7e/h++1VFy
# H4GCFjWiNeTKnf1Iw/qlots0Lfstzk2IK705Cd1yPuYd1+U5I+P+fwyPKMJG/UP3
# Cq585r8xCPURMUEprmZP+tvpZDqepflrNwBCIWVVzuOYkde4rNYxx7UnnN1ilxrL
# h9IC+ArrlqyYSzqqOTnwwAROrYI32hC2mi5vKBAQQ5OD4FNXQmp7q0EKQgDg4fB/
# E9KHHpryX2y4VpPWuFch7Es3PZPOxCDGzBDphkIFOf6TVyu0nWkMmc2zkHYDzdnp
# FdWaKEOpRtci2o8ZJrXUGAoEaUzpeZk9L1fPwXDHiKXy4WHjMwJFCPtriyQxk+mp
# fL7fxznIMXQTHQcUO2q5kTCCB1owggVCoAMCAQICEzMAAAAHN4xbodlbjNQAAAAA
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
# nTiOL60cPqfny+Fq8UiuZzGCGhAwghoMAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMQITMwABzEJ+xUgPpfHhLwAAAAHMQjAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCBYz6Z3+R9KgusEH89kV78mx7NR
# Bv5Bnz5Xlx1P1+W0fjANBgkqhkiG9w0BAQEFAASCAYARaparItgIgwQgH/dtPb3P
# zXph+9zcrJ/kL1jj2uVGR7ar7MzD8zq6wuDjMxAsgbpSU6n4snwF+kOfLXvVHY25
# DfN8Au8GJzZ45J+wqDU7O5nIExk2z+qa9/u3BevrBEl/S6KI8TCXifZa3gFbQhts
# gQmavj611lwIa6SsC7BgO2QGUWsa20yyd/mIsXiai1+Apa5O1oy/aX7rY00H23f+
# /Fg2itGsYdoNrBJ0kp2LmiDoqCvTZ6ZaG4lZfDua2L7vZgz4vbGBQx/TkXSgKHD4
# G+aTOKFY9X95mQN5kWI2dWYSIC1dIt7YxbvdAxr7VWX1NB3GQv4dgr50/jsVu0J4
# /2BbuLwYTsnzPVH50FxxFFPTi9Iqf4XewRN78zgD1oigJYFeV2UrzkoxArqEbdbJ
# IIXeHFufBtWF96pDKKQvR5tyXr+1aKQ5VZKOAb5H2ZzDpJn+l1BJBsZbeVbFU0QM
# xBwr1JjB8FPUbEidQhBL+kxJMCELInaAeXIhVtERFxKhgheQMIIXjAYKKwYBBAGC
# NwMDATGCF3wwghd4BgkqhkiG9w0BBwKgghdpMIIXZQIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYQYLKoZIhvcNAQkQAQSgggFQBIIBTDCCAUgCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgXrgKbQidrA9xFf1Q8It9JnSBhW38/jbNcckgspAz
# kjUCBmclIlF76hgTMjAyNDExMDUwNTE3MjguODc0WjAEgAIB9KCB4KSB3TCB2jEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWlj
# cm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBF
# U046NDVENi05NkM1LTVFNjMxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNB
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
# EzMAAAA22TYciQoua4EAAAAAADYwDQYJKoZIhvcNAQEMBQAwYTELMAkGA1UEBhMC
# VVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWlj
# cm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwHhcNMjQwMjE1
# MjAzNTU2WhcNMjUwMjE1MjAzNTU2WjCB2jELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
# aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046NDVENi05NkM1LTVFNjMxNTAz
# BgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9y
# aXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxVGM6rg/DX9dyRIk
# a0Ig8p8HG9/F215K2yhLSZg0jdRr1LhoU/gjuh2leV0KNbLbTzSkuTWh6JJbyYqK
# xt0KIH3mbMqd4MKtD1DsGaaMxjpgKZyBarnsjHeymAzPaNYSUGkwmPQpnzTRMXSE
# gwBXsgbNUrWr3cbA7Jcn0Sk5LlbszBEIDj4TqGlAr2p1MvRHshdvm1Yzg2UFE1j9
# QN5rSQ8H1u6ce5cbEaspYfWQ5f+I9MT6ZSbzbIg10nyafFWrn0zRbY+TGiw3HXTe
# DWYsWSvBKyyx5G/N61wQVJkwtEJb5wZ8oo96MMjBAGLV2S3El3bJoZRn/XixNaI5
# 6NnVtIjQ4kjPam6xcQl00g1ngAl5oqOm+GZJfvmVf+9A/pxKOi79k/E6vM3Rb6RF
# KT5LCY/egpLKD546APtmMLSfj0X/lfmmhEzlJA52dSi0z3gHklWvymuNX9Hq6HX7
# pwMJWu9GIIXWuMcwNl6IpMu2sONXgoq+4I2yJGsLOSVKPqWJmCqLp9Q4LbJs7leZ
# KI75moUReAMS+hHfy7tm/h16iKLZRL+9KZfAbj4MNtv/JuoH1Qdtb0zWcb5rmd+5
# +C9Tok0Vj063Nabt9pSr+rB4CQHIGrkdp3hAXwewruDtypeMRgl1oLey4Rj+gfR1
# mT89AjnkwA3M41PkBYScDDxQ56UCAwEAAaOCAcswggHHMB0GA1UdDgQWBBRG/cU8
# X14PwTOoC53+lgy//OuPwzAfBgNVHSMEGDAWgBRraSg6NS9IY0DPe9ivSek+2T3b
# ITBsBgNVHR8EZTBjMGGgX6BdhltodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2NybC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmcl
# MjBDQSUyMDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0wazBpBggrBgEFBQcwAoZdaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBQ
# dWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3J0MAwGA1Ud
# EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeA
# MGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAI
# BgZngQwBBAIwDQYJKoZIhvcNAQEMBQADggIBAI01A1c8TLWSO28Ttt7o3NoWEVcC
# j7SKJqWaojEZnZJLloy4c5dlHT19XHWoVwrb7HGN3XcT1CuwwKTYutvnmbP4+h6Y
# cJzBDD9ibxkhKstsa45+EM7YzURlQr+4HoP1056xNVdb9cG7G50H5B3htEPT+7jM
# OWTBCpgsD3n55eJmhdIchJhZ+i6YgDiOsFOKJn8n4yYF1RYb9RKIDn+ynfXiCxir
# Y3j5mbiR2OpwpFy3gCbFsFjH7mOEsLxAXD+qBwrDKUhLOrqYkEI6jLJRDaWLHTNe
# U7Ydwkovan6zTeQmIHMOzBMsdEz/zYwaSoIWAYmtVs8MmwgxvJTAAlw9lX9JvJe7
# nD97QisHuqcOewzFlC/fSFjnMJg02Cbp+JJJPM1qN6oJSnsJ6ayBIY5Y2vnKbPYJ
# K97Pn72as3ZzDnia+1lAW2/0HYhIMontYNE5k8ZMmeRmeVhkK2M+2Pfl3Tq1rs6s
# 6JDnaQAdhtcCKde3k9qIx8xgQEFnHn8UNUUXGETEgIC/ZWsPly0DiUbnyhexNI1K
# 28j7zG6nvkKkk3nK3pSJEbdNJDbz/1Q/LWgrDmbmTEpgc+isJHYjSwaXfyL0+KOM
# Q0VquAoXoFYg4KvH0uDMAvQWMyNw7D9PSASTUd376r6R2j/kcZsmn4yHT5cqg5MA
# 49dM4c/SUD1Y/Vz6MYIGxDCCBsACAQEweDBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAADbZNhyJCi5rgQAAAAAA
# NjANBglghkgBZQMEAgEFAKCCBB0wEQYLKoZIhvcNAQkQAg8xAgUAMBoGCSqGSIb3
# DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQxMTA1MDUxNzI4
# WjAvBgkqhkiG9w0BCQQxIgQgpVXOnmpvrMtFyfp5dlzJCjGzg7HRnJm5k4Fvr9Kk
# 9cQwgbkGCyqGSIb3DQEJEAIvMYGpMIGmMIGjMIGgBCA0A9dQAtIuK4xJqKETlX2e
# siXJAblGg3/WH/POMsUfZTB8MGWkYzBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGlj
# IFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAADbZNhyJCi5rgQAAAAAANjCC
# At8GCyqGSIb3DQEJEAISMYICzjCCAsqhggLGMIICwjCCAisCAQEwggEIoYHgpIHd
# MIHaMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo0NUQ2LTk2QzUtNUU2MzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1Ymxp
# YyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHmiIwoBATAHBgUrDgMCGgMVAKGl
# Gj0uE0nZGLtLqW80zysO5wzSoGcwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMA0GCSqGSIb3DQEBBQUAAgUA6tOV
# UTAiGA8yMDI0MTEwNDE4NDc0NVoYDzIwMjQxMTA1MTg0NzQ1WjB3MD0GCisGAQQB
# hFkKBAExLzAtMAoCBQDq05VRAgEAMAoCAQACAgzDAgH/MAcCAQACAhF8MAoCBQDq
# 1ObRAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMH
# oSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAI/9aeiyOxpL7yiPRcaE+
# chCaM0B+IJS0RmDpJuUi/eL2yeI9Bv0ypqUais51zsmKJc0fPHNcAb9ZiJYl6VkB
# PDZUpnbTYI0KJh/bjdlfW6HIhgs45aaLdAbZJsR9qVZ8S4CsHPZo9Xv7bQdL3MBq
# rcFDpneqdEZlu0OK9hRsN6EwDQYJKoZIhvcNAQEBBQAEggIAcctCZdZnZcGTgyqV
# colw64Xyr+tudMPTKtgX3svV7/nPXmPkJ7EHGMcdlCfp1WHpkCPJsa0O56lU7LBc
# dBGQcC8dUfo0HJpfLd6E73cVQeEunBaj5vRwuldj6hBSgAgmARBFiroeEMm3Z4uC
# Gmu+wzwq6boE5GXDt4OPKQs23tRx9/7tqTbuCV4KlD1GdPV/mj1MTE7uwNz/u1GN
# 8pesRxi70qv9czLnUhWJnHfycfzpFo19g32xHM6kONk4aIzI21BGMSvwFxO6QXLn
# awE0/4DMqyrKnnXD0G4cEqosRWJttDfvBI9hRSFX+p69yq5RASWVupRbnx+sKL6F
# 50cbipOBjWZFQ61qTpX7thwiN6la2F1V6/QJphebjEb1KjJv1XBL6JzRfOVkWu9t
# 9HcCnNk4ZPksx0TrsKw37K8vk1vVkpgF8Ek0mVrlPGPL9PCw71MnW/51a88r6okW
# 6DbqU/9rm5VqWw5OH62KM+14gRCTFBeMo8luzRB9AxmYzAJ/RA2zqNL0WDsOko+F
# DX26tQrCQHFWJRLZ/CWQTYlcRt7meum6BxB67rQ3z0+KMeyHwH3xm9TXt6TM1eAp
# Sq42ERxaN+qNJ8cZ/33utmnwthN7na/vrF8o3B0OHdm2iKLvlaprYS+cB/ocpPIX
# 1bYaE5BRZkx6hfRArjd+E4MmQyM=
# SIG # End signature block
