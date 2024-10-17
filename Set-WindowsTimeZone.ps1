#define variables
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'TimeZone.log'
#Do not crash on errors
$ErrorActionPreference = 'SilentlyContinue'

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

#Check if the ActiveDirectory powershell module is installed, if not, install it.
$ADModule = Get-Module -ListAvailable -Name ActiveDirectory
if ($ADModule) {
    Write-Output 'Active Directory module is already installed.'
}
else {
    Write-Output 'Active Directory module is not installed. Installing now.'
    Install-Module -Name ActiveDirectory -Force
    Import-Module ActiveDirectory
    Write-Output 'Active Directory module has been installed.'
}

function Get-TimeZoneFromCity {
    param (
        [string]$CityName
    )
    $tz = switch ($CityName) {
        { 
            'Atlanta', 'Boston', 'Virginia Beach', 'Washington' -contains $_
        } {
            'Eastern Standard Time' 
        }
        {
            'Los Angeles', 'Oakland', 'Seattle' -contains $_
        } {
            'Pacific Standard Time' 
        }
        {
            'Denver' -contains $_
        } {
            'Mountain Standard Time'
        }
        {
            'Huntsville', 'Dallas' -contains $_
        } {
            'Central Standard Time' 
        }
        default {
            $null 
        }
    }
    return $tz
}


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

#Let's try getting the user's time zone from the Active Directory account
#first, get the name of the current logged in user
$loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
$usernameOnly = $loggedInUser.Split('\')[-1]
$MyCity = (Get-ADUser $usernameOnly -Property City).City
if ($MyCity) {
    $WindowsTimezone = Get-TimeZoneFromCity -CityName $MyCity
    Write-Host "According to AD, user is in $MyCity which belongs to the $WindowsTimezone"
}
else {
    Write-Host failed to get time zone info from AD.  Trying with IP address.
    $UnixTimezone = get-UnixTimeZoneFromIP
    if ($UnixTimezone ) {
        $WindowsTimeZone = Convert-TimeZone -UnixTimeZone $UnixTimezone
        Write-Host Got the time zone from IP address.
    }
    else {
        Write-Host Failed to get timezone.  Giving up.
        Stop-Transcript
        exit 1
    }
}

if ($WindowsTimezone) {
    Write-Host "Time zone detected as $WindowsTimeZone"
    # Set the time zone
    Set-TimeZone -Id $WindowsTimeZone
    Write-Host "Time zone set to $WindowsTimeZone"
}
else {
    Write-Host Could not set time zone
}

#we are done here
Stop-Transcript
# SIG # Begin signature block
# MII94AYJKoZIhvcNAQcCoII90TCCPc0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAK0L6x6Fa18eCv
# 4N5oLX0OzFQZYHLVYw64CligyZfszaCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# nTiOL60cPqfny+Fq8UiuZzGCGpAwghqMAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEVPQyBDQSAwMQITMwAA3yKg5cPpASTN6AAAAADfIjAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCCuROaI5a3GOHcPWj6NTW/16akV
# tQ1FIUlINj/GhSg21DANBgkqhkiG9w0BAQEFAASCAYAs7Dpk44eTjxFoNM+vfwa0
# RTMwc5fF80UjmeaVCNrhAUZDYIsNC+XZ4/F4EQPjVcqocWnyILR0aurztNYZ6oyy
# SKBoQC5gAvCS4xtirMxiiu5bYLjWUCW6uRlny2cwrmi/MQ7mHPxBydqBa1/mAd5x
# yCBF1t4fYh6vU6J51Ilsab/VATr7P9C2yLeto8x85KUxD8Me864ye8Z9XEAuNUfx
# Dno4Pcu9BEE0u1fv3QmIRLZ17RnBAKLmfcV2tUZP0syBE2gkunRnXcd/7QfI5q/q
# yKHB/3iPOM1CWjkc8qaqNXEq4+5ZlURmhbFNzzzovv0+HAOWbh9+LwTUC1s+9/dU
# vJsW3jQUOTMgPiJ/QZz6fDatMtV7i3V6p9gJDwO7ddcqhviXeeoqHKM9w0mgqya8
# 5lQDNv6kfSquzN/0X3vLtoeQzBnGen+nI0w8jjEiXcy+2Mi0bOelvhiaLMwankIO
# 74A8rB9tDQanUGbjGFwZIBco8n5zb7aEPCsvwPbXhVGhghgQMIIYDAYKKwYBBAGC
# NwMDATGCF/wwghf4BgkqhkiG9w0BBwKgghfpMIIX5QIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYQYLKoZIhvcNAQkQAQSgggFQBIIBTDCCAUgCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgH9hOhI/gbPSDhez4pEZhKqenvqNUYtonGoWm3g0t
# b5ECBmcNFqqnghgSMjAyNDEwMTcyMjA4NDkuODlaMASAAgH0oIHhpIHeMIHbMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNy
# b3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBF
# U046N0QwMC0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNB
# IFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5oIIPITCCB4IwggVqoAMCAQICEzMAAAAF
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
# 9S8h22hIAcRQqIGEjolCK9F6nK9ZyX4lhthsGHumaABdWzCCB5cwggV/oAMCAQIC
# EzMAAAA1CQW1sueE7wwAAAAAADUwDQYJKoZIhvcNAQEMBQAwYTELMAkGA1UEBhMC
# VVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWlj
# cm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwHhcNMjQwMjE1
# MjAzNTUyWhcNMjUwMjE1MjAzNTUyWjCB2zELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
# aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjdEMDAtMDVFMC1EOTQ3MTUw
# MwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0YW1waW5nIEF1dGhv
# cml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALHXp6cZkkZDuBow
# lOGOhdz/LJNL/jXC8z4NlE+9ErrVHHzCuKqXeNr4OavHpFIQRCz2KOiCeI2R+PIE
# svsd0JsVnytXK5rolBmi876LBdLoFL468EdKIfjll7zzQj/NqLZM0NAZoWBWuD3D
# 5TtXuXuVejJ2rzaOpk1A3W8jJ8ARq4V06FS3zNBCoVhY4CAz22Ka8dmnALrvKvdT
# 4fUYK6fee/dUT0/m9JnVkZlxP5tUXfWv1TmEU0yFVApCZPJbtwAnc9jTh5MKX//P
# Ax8jkLRmxZ+0Haz/6xIt6GsMYsasyUBv+Cayk+IOi5sXHDKFlPD6j7W0jYMuWgbS
# K7ePDtqI0FSj//JCc9zHHsrSvbKLHEgBLocVD4ogSdBcGgo6R58AUN8Lpyy/gOCy
# tnwnR0d/7kpZ6Q6k8GvwGG1F9A5ly2cqOzp7q0qM26QIMQMglB9qnURxo7xen8PT
# cXrRmRHe2L+NRqXLRgEjNJWXc/U79SwBN486lpogIYXrht5wzdiF1BaK55kJEHV7
# KcfKJ7Ec8gK050Zia8FtLCAa1OeOQEMFmZhGYFlDug70eljq4DOp6Xi//HYz2HF1
# HnwLG1HrtZrX0bswhceuNY5b0/9L0tYfEKa/ysFgf9cnqA7QswbXLtFU19VrvixO
# QV3Detdg6oiAArc/9EBWyX6cmRQ5AgMBAAGjggHLMIIBxzAdBgNVHQ4EFgQULQwf
# CKM6WDEYsVidR//Uq8UhPCswHwYDVR0jBBgwFoAUa2koOjUvSGNAz3vYr0npPtk9
# 2yEwbAYDVR0fBGUwYzBhoF+gXYZbaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
# aW9wcy9jcmwvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5n
# JTIwQ0ElMjAyMDIwLmNybDB5BggrBgEFBQcBAQRtMGswaQYIKwYBBQUHMAKGXWh0
# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIw
# UHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0ElMjAyMDIwLmNydDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIH
# gDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0w
# CAYGZ4EMAQQCMA0GCSqGSIb3DQEBDAUAA4ICAQAkMvAbkQg3nYOXI77dSaxnzRBL
# mQ/hxZbkOC4Mb4TX7NM/1gmb7M2t4QsaLo3DL/BFRLFcvUE3cgVDtphzWIA7ShoS
# 2ZHtYereMGQgvHoGeVDUGFcd85xJei0lAAdY7czSnetVXjKpUt/H5BY9QoJFBe+F
# 0rZR08qKf2YEuWGW9Iu0ykZYfJOExGVLDUsfYhU0bBX8Hshg89pDw4ySHLXn8iue
# cqkzruWOklR3QgLpbXtBeebjcBKqnavj1UTpxZnmTu2gEun7smFvEG52F7B3zNmH
# S5mg5hmpTDxf+167Gzbuzg1rhjrY3fujb0SUT5i5JAcQujP694GSboCtKnY4jYFa
# L36+asVGCyLvJBJMkUkoA4jn9r8OTiC3YueUWdMwIKhTDBE+nHJd7mKOYacwscu7
# QLiU51GCHyYTF+dxkyywxdJ+GZ/ee0cZahjpezgbWFKXAyx1/H87ik6PlIosAJMr
# UVbZwQF6VgDCSLn3fwGdHghSNcbyNfxnR8ASg9g5BJEN5gYrTPogE+YIit8J+Ty6
# XM3dt26trbLA85Q5Hv1II9CEEMWy9RCxmGhlwQZCOQL/gC+wKocmkM6n+bxLJ1ZP
# OeOXjsLN0mDf+h+woMzPNg6bs71fHwtDoIKZiM0b5qNHIDh+bvHJLq0wwaQizjNZ
# iAXHNfPEx6vQl0L/ojGCB0Mwggc/AgEBMHgwYTELMAkGA1UEBhMCVVMxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAAA1CQW1sueE7wwAAAAA
# ADUwDQYJYIZIAWUDBAIBBQCgggScMBEGCyqGSIb3DQEJEAIPMQIFADAaBgkqhkiG
# 9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MTAxNzIyMDg0
# OVowLwYJKoZIhvcNAQkEMSIEIA7trlBWHLVGgWq0kaGrreIIVFlOjQCJeCqQpWFk
# vo2RMIG5BgsqhkiG9w0BCRACLzGBqTCBpjCBozCBoAQgfFMAYSZahMI8zp94ry1x
# BugYhwhSXfP6W2MOJnVX6oAwfDBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1Ymxp
# YyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAAA1CQW1sueE7wwAAAAAADUw
# ggNeBgsqhkiG9w0BCRACEjGCA00wggNJoYIDRTCCA0EwggIpAgEBMIIBCaGB4aSB
# 3jCB2zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UE
# CxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjdEMDAtMDVFMC1EOTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lIFN0YW1waW5nIEF1dGhvcml0eaIjCgEBMAcGBSsOAwIaAxUA
# L+y7hpIIGre1luiKo6DnFwDLYtmgZzBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwDQYJKoZIhvcNAQELBQACBQDq
# u4mvMCIYDzIwMjQxMDE3MTMwMzQzWhgPMjAyNDEwMTgxMzAzNDNaMHQwOgYKKwYB
# BAGEWQoEATEsMCowCgIFAOq7ia8CAQAwBwIBAAICLVIwBwIBAAICE3QwCgIFAOq8
# 2y8CAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAweh
# IKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQsFAAOCAQEAq6hlMLDboNteNNXEz0Sz
# zdsaxTJ5X5UvYz2+3Jd/aGzwDFLjm8gsm773kEEqxtpgjsPFzvib1S4V2mCqN98r
# b80CH2d2d14ZEf0gaMB29Zqyw0W3cw+2EdkiUOUqY87Hsyw7InTeQYmInZBO63wO
# YSa3I53qBMJ+7zw5KcQx+DN98GGlQB2SVKogyg0YCSp3psEb4ll+ISx6iXWNH7Ty
# 7xssH3A2/44ZNd9g3x8WhYICwop+J9FGbJqG6cSIPlDPNgdtFLTgtMcsG83C52er
# ksf1U20jpJRact6nD1XsuMUMMRIewJjtY5+sys1/SdY8QTLWDNQUPE0Lwnu1p+7c
# TjANBgkqhkiG9w0BAQEFAASCAgB03BTS9flupCytD82pglk5GrPEXMpAf1pP4qH9
# VwNdnOIEPi4hJjq9/JUORAolgBxJetogCDbUFkLShj/IYYKIXZtd2Um1iGYu7zu7
# 2f9WMHKuMVTu7XSJEEYIEv8YGgPL3Rd7bYNNURrhJGLFEV52W1ULzW9gY1fSI+fb
# kXoSPMBMmw+tgc5u88aQmWehTjGeeGK1BowRlBbA9VXOdtxH1VUlP3exZtK0J90O
# MaxR9R0CzLiip3A+TwV2I+UQcDvrHAuyP3PAGrrJBHUFfX38lGvDoLJ3+uSmywB2
# zzzxwtZJ0lnbliCesX58zsJ39W9m5/XBzNHandXlT/9K75fgVOVsjp0w9PCcXsGk
# xKSZyRW7yPV2Whc9efrtcNoH0E/xyoyxU0ZHeuK6m2DmMgJh1UR5jvQzkhEZeHjb
# toPUxbljHC8c8AJOc9n1SV1uxNRPqTO1Kbp0DqeBH/VV49UVgl3YM5PutTxBQaA3
# 1REuQU3JJHjBELZyX2DtW8YV/y/COxPAZpePa7+Sb0kTzfaLOpdRoCfHpY/yUQ1Y
# E1u+Urne8BY1S8pk615xmmJZhazNpSUe3yUQUS0STcKfYmigvMc3O1j99lnjK0f5
# j55D86SRGKnJ19Vkj+Bn3URyAgrRC/DE004rgrCQAwPi1N0duSBm+nQCyBEHPHzS
# GjgAmg==
# SIG # End signature block
