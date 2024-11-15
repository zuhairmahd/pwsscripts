
param(
    [string]$desiredGroupName,
    [string]$inputFile,
    [string]$outputFile
)

if (-not $inputFile) {
    $inputFile = Read-Host -Prompt 'Enter the path to the input file. Press Enter to use users.txt in the current folder'
    #if the user enters nothing, inputFile becomes user.txt.
    if (-not $inputFile) {
        $inputFile = 'users.txt'
    }
    #Check to see if the file exists, if not, prompt for a different name.  
    if (-not (Test-Path $inputFile)) {
        do {
            $inputFile = Read-Host -Prompt 'File not found. Enter the path to the input file. If you did not enter a filename, insure that the file users.txt is in the current folder'
            if (-not $inputFile) {
                $inputFile = 'users.txt'
            }
        } while (-not (Test-Path $inputFile))
    }
}

if (-not $outputFile) {
    $outputFile = Read-Host -Prompt 'Enter the path to the output file. Press Enter to use AddedUsers.csv in the current folder'
    #if the user enters nothing, outputFile becomes AddedUsers.csv.
    if (-not $outputFile) {
        $outputFile = 'AddedUsers.csv'
    }
    #Check to see if the file exists, if so, ask the user if they want to overwrite it. If no, prompt for a different name.
    if (Test-Path $outputFile) {
        do {
            $overwrite = Read-Host -Prompt 'The file already exists. Do you want to overwrite it? (Y/N)'
            if ($overwrite -eq 'N') {
                $outputFile = Read-Host -Prompt 'Enter the path to the output file. Press Enter to use AddedUsers.csv in the current folder'
                if (-not $outputFile) {
                    $outputFile = 'AddedUsers.csv'
                }
            }
        } while ((Test-Path $outputFile) -and ($overwrite -eq 'N'))
    }
}

if (-not $desiredGroupName) {
    Write-Output 'Which AVD group do you want the users to be added to?'
    do {
        switch (Read-Host -Prompt 'Enter V for VCA, D for DTA, Q to quit') {
            V {
                $desiredGroupName = 'MAC-SBAVD-SG-VCA-Dskt-Pool-Users' 
                $accessGroupName = 'VCA'
            }
            D {
                $desiredGroupName = 'MAC-SBAVD-SG-DTA-Dskt-Pool-Users' 
                $accessGroupName = 'DTA'
            }
            Q {
                Write-Output 'Exiting.'; exit 0 
            }
            default {
                Write-Output 'Invalid selection. Try again!'
                #sound a beep
                [console]::beep(500, 300)
            }
        }
    } while (-not $desiredGroupName)
}

# Define the path to the file with the list of users
$csvFilePath = $outputFile
$file = $inputFile
# Define the names of the Active Directory groups we will work with
$ADGroup = (Get-ADGroupMember -Identity $desiredGroupName).name 
#define an array to hold the list of users to be added
$ADUsers = @()
#and another for the users to be excluded
$ADExcludedUsers = @()
# Check if the file $file exists
if (Test-Path $file) {
    #define the RegEx pattern to find the usernames
    $pattern = '(?<=<)([^@]+)'
    #Read the raw file content into a string variable
    $rawContent = Get-Content -Path $file
    #let's extract the list of users into a string
    $userHandle = [regex]::Matches($rawContent, $pattern)
    #Now let's extract and join the matches into a comma-delimited string
    $outputString = $userHandle.ForEach({ $_.Groups[1].Value }) -join ','
    #Now let's split this into stringlets so we can process them one at a time
    $inputString = $outputString -split ',' 
    $inputString | ForEach-Object {
        $user = Get-ADUser -Identity $_ -properties *
        if ($user) {
            #Get their identity
            Write-Host "Checking$accessGroupName Access for user $($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`)."
            #Is the user already in the group?
            if ($_ -in $ADGroup) {
                Write-Output "User $($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`) already has access to $accessGroupName."
                $ADExcludedUsers += $user
                $excludedUsers += "$($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`), "
            }
            else {
                $ADUsers += $user
                $Users += "$($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`), "
            }
        }
        else {                
            Write-Host User $_ not found
        }
    }
}
else {
    Write-Host file $file not found
    exit 1
}

# now that we have a list of AD users, lets move them.
if ($excludedUsers) {
    Write-Output 'The following users already have $accessGroupName access:'
    Write-Output "$excludedUsers"
}
if ($users) {
    Write-Host 'The following users will be provided with $accessGroupName access:'
    Write-Output "$Users."
    Add-ADGroupMember -Identity $desiredGroupName -Members $ADUsers -Confirm
    #now let's write a list of the objects converted into a .csv file
    $exportData = @()
    # Iterate through each user object and extract required properties
    foreach ($user in $ADUsers) {
        $userData = [PSCustomObject]@{
            FirstName   = $user.GivenName
            LastName    = $user.Surname
            DisplayName = $user.DisplayName
            Email       = $user.EmailAddress
            UserID      = $user.SamAccountName
        }
        $exportData += $userData
    }
    # Export the data to the CSV file
    $exportData | Export-Csv -Path $csvFilePath -NoTypeInformation
    Write-Host "CSV file exported to: $csvFilePath"
}

# SIG # Begin signature block
# MII6cAYJKoZIhvcNAQcCoII6YTCCOl0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBs9nyZoi8JmIXG
# E8sml7CmcPuUBsN7J6YGrFdY4oAHMqCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAHhub5n
# bUXQgyyiAAAAAeG5MA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDIwHhcNMjQxMTE1MTcwNDAwWhcNMjQxMTE4
# MTcwNDAwWjBmMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExEjAQBgNV
# BAcTCUFybGluZ3RvbjEXMBUGA1UEChMOWnVoYWlyIE1haG1vdWQxFzAVBgNVBAMT
# Dlp1aGFpciBNYWhtb3VkMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# uRwUFqTSN7wHJHPKss+q1zEWnQ4THaaDFL3LQqirvWwCw3EIU+gOtox0mm2kzoSP
# W8LB4bVLRAeKpLXS/GAhZdDUFe5dUqsDb5zRdi0yA9CqRHjktJzLtXK3B7ETDgSr
# 6CUtgB9idsIW4danBc9nNNw0J1lOKm8UN0oGrOvucBuez7p0Jvn7im/M0a1uS8pP
# DWWQAeL1piW6VnSKm9JN9WWS66TZm2uz75dM+wJcltIgRB5tWatGoCPNtYN8A9Ak
# omg0fJDAPbNmh9bw8mPSMnvEmrzSyi6tR8NUC3CnvAjBqz8gyDJ34cZFMlR9LwTt
# RjdmIJLxV11FRkQy38iCNjAlaYsW9DU6f0wV/DCKJnUu4+iZiTAJJP3Oj/GNZbUQ
# WdLx022s7Ntln1rOSZ+0nqqmqtNmoJb1efhap39C388dx+0nJNVNuizaqWnJvr5Y
# QIbBjHM3Dt/EgkjqBOkjuZV2h7KmcD+61NXRbECK5Dl/X5GloUvFhaWXiqkFskkz
# AgMBAAGjggIYMIICFDAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA7BgNV
# HSUENDAyBgorBgEEAYI3YQEABggrBgEFBQcDAwYaKwYBBAGCN2GBmtGaFtje9WuB
# vfqFXPmA7xswHQYDVR0OBBYEFNW76alcu9D/0mDWLVzYHaZ5ldrkMB8GA1UdIwQY
# MBaAFCRFmaF3kCp8w8qDsG5kFoQq+CxnMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDIuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAyLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBAK+DVlGeC0NZfDqx
# Eqwl3X3p3lX/dfPH307b0FzdvkDLI8RPf9any3qfpPDNQO8WLlv9G7Y5OQRfBiK8
# hVm294a7ggekjkhdtc5XqrgDCHRDWoPS6d2MoeYV/QRZfsHhmQgMhi9Nknug6xs2
# 4IaF0JVlSejfIt1AuXj0sRePUoxHJl/oA9fjqm5B6d6PCqvkJ/1OrD1o4fl/dIU+
# vKhQm6zFtsMB38bdAKZJCBv4EKfm8BQtGJv3M2rsz9nIMIaTVOyYVgH8LPM08e8d
# ihJ5A2J3KrV9tFSnEJZP5GH1wy3kS0c21e7JrWyyY2mfztk5EQpai0VgDegfQJJG
# hChU/Ij1sdBHTTZknXnYEZsVOJ2XW2H+cLSolWWb2EXZjRN9fG37b5L1LdkKu53k
# DzF79gPUoo/vBHRF2h7vl7M8YBYRWGoLBlqH5NDpTKfBCoXZxvsoUYmK0G8TM7Ha
# ZtUE8iJqbXlSF/9v/z8p4Iymvh2DsdXaU9klwPyLxkpXVBUoe1HdG5nfh9YKM4Zo
# xMAk3NVdbrIvwgmXg99WxocPCeQAcjRvz0mw7hHseeJrINDSioE3efXtnlAPOOtm
# nEpYn0wwn53rZ6v+8tH69zFoxQbAYlXjKSS2OxOAjYmkgal4YTPIFrte8dHUT462
# RDlhj1x8QbuT0IsFxgHBG9d9D7cUMIIG5zCCBM+gAwIBAgITMwAB4bm+Z21F0IMs
# ogAAAAHhuTANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAyMB4XDTI0MTExNTE3MDQwMFoXDTI0MTExODE3MDQw
# MFowZjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMRIwEAYDVQQHEwlB
# cmxpbmd0b24xFzAVBgNVBAoTDlp1aGFpciBNYWhtb3VkMRcwFQYDVQQDEw5adWhh
# aXIgTWFobW91ZDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBALkcFBak
# 0je8ByRzyrLPqtcxFp0OEx2mgxS9y0Koq71sAsNxCFPoDraMdJptpM6Ej1vCweG1
# S0QHiqS10vxgIWXQ1BXuXVKrA2+c0XYtMgPQqkR45LScy7VytwexEw4Eq+glLYAf
# YnbCFuHWpwXPZzTcNCdZTipvFDdKBqzr7nAbns+6dCb5+4pvzNGtbkvKTw1lkAHi
# 9aYlulZ0ipvSTfVlkuuk2Ztrs++XTPsCXJbSIEQebVmrRqAjzbWDfAPQJKJoNHyQ
# wD2zZofW8PJj0jJ7xJq80sourUfDVAtwp7wIwas/IMgyd+HGRTJUfS8E7UY3ZiCS
# 8VddRUZEMt/IgjYwJWmLFvQ1On9MFfwwiiZ1LuPomYkwCST9zo/xjWW1EFnS8dNt
# rOzbZZ9azkmftJ6qpqrTZqCW9Xn4Wqd/Qt/PHcftJyTVTbos2qlpyb6+WECGwYxz
# Nw7fxIJI6gTpI7mVdoeypnA/utTV0WxAiuQ5f1+RpaFLxYWll4qpBbJJMwIDAQAB
# o4ICGDCCAhQwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOwYDVR0lBDQw
# MgYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGisGAQQBgjdhgZrRmhbY3vVrgb36hVz5
# gO8bMB0GA1UdDgQWBBTVu+mpXLvQ/9Jg1i1c2B2meZXa5DAfBgNVHSMEGDAWgBQk
# RZmhd5AqfMPKg7BuZBaEKvgsZzBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAyLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# Mi5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQCvg1ZRngtDWXw6sRKsJd19
# 6d5V/3Xzx99O29Bc3b5AyyPET3/Wp8t6n6TwzUDvFi5b/Ru2OTkEXwYivIVZtveG
# u4IHpI5IXbXOV6q4Awh0Q1qD0undjKHmFf0EWX7B4ZkIDIYvTZJ7oOsbNuCGhdCV
# ZUno3yLdQLl49LEXj1KMRyZf6APX46puQenejwqr5Cf9Tqw9aOH5f3SFPryoUJus
# xbbDAd/G3QCmSQgb+BCn5vAULRib9zNq7M/ZyDCGk1TsmFYB/CzzNPHvHYoSeQNi
# dyq1fbRUpxCWT+Rh9cMt5EtHNtXuya1ssmNpn87ZOREKWotFYA3oH0CSRoQoVPyI
# 9bHQR002ZJ152BGbFTidl1th/nC0qJVlm9hF2Y0TfXxt+2+S9S3ZCrud5A8xe/YD
# 1KKP7wR0Rdoe75ezPGAWEVhqCwZah+TQ6UynwQqF2cb7KFGJitBvEzOx2mbVBPIi
# am15Uhf/b/8/KeCMpr4dg7HV2lPZJcD8i8ZKV1QVKHtR3RuZ34fWCjOGaMTAJNzV
# XW6yL8IJl4PfVsaHDwnkAHI0b89JsO4R7HniayDQ0oqBN3n17Z5QDzjrZpxKWJ9M
# MJ+d62er/vLR+vcxaMUGwGJV4ykktjsTgI2JpIGpeGEzyBa7XvHR1E+OtkQ5YY9c
# fEG7k9CLBcYBwRvXfQ+3FDCCB1owggVCoAMCAQICEzMAAAAEllBL0tvuy4gAAAAA
# AAQwDQYJKoZIhvcNAQEMBQAwYzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0IElEIFZlcmlmaWVk
# IENvZGUgU2lnbmluZyBQQ0EgMjAyMTAeFw0yMTA0MTMxNzMxNTJaFw0yNjA0MTMx
# NzMxNTJaMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0Eg
# MDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDhzqDoM6JjpsA7AI9s
# GVAXa2OjdyRRm5pvlmisydGnis6bBkOJNsinMWRn+TyTiK8ElXXDn9v+jKQj55cC
# pprEx3IA7Qyh2cRbsid9D6tOTKQTMfFFsI2DooOxOdhz9h0vsgiImWLyTnW6locs
# vsJib1g1zRIVi+VoWPY7QeM73L81GZxY2NqZk6VGPFbZxaBSxR1rNIeBEJ6TztXZ
# sz/Xtv6jxZdRb3UimCBFqyaJnrlYQUdcpvKGbYtuEErplaZCgV4T4ZaspYIYr+r/
# hGJNow2Edda9a/7/8jnxS07FWLcNorV9DpgvIggYfMPgKa1ysaK/G6mr9yuse6cY
# 0Hv/9Ca6XZk/0dw6Zj9qm2BSfBP7bSD8DfuIN+65XDrJLYujT+Sn+Nv4ny8TgUyo
# iLDEYHIvjzY8xUELep381sVBrwyaPp6exT4cSq/1qv4BtwrC6ZtmokkqZCsZpI11
# Z+TY2h2BxY6aruPKFvHBk6OcuPT9vCexQ1w0B7T2/6qKjPJBB6zwDdRc9xFBvwb5
# zTJo7YgKJ9ZMrvJK7JQnzyTWa03bYI1+1uOK2IB5p+hn1WaGflF9v5L8rlqtW9Nw
# u6S3k91MNDGXnnsQgToD7pcUGl2yM7OQvN0SHsQuTw9U8yNB88KAq0nzhzXt93YL
# 36nEXWURBQVdj9i0Iv42az1xZQIDAQABo4ICDjCCAgowDgYDVR0PAQH/BAQDAgGG
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBQkRZmhd5AqfMPKg7BuZBaEKvgs
# ZzBUBgNVHSAETTBLMEkGBFUdIAAwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgw
# FoAU2UEpsA8PY2zvadf1zSmepEhqMOYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBW
# ZXJpZmllZCUyMENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyMS5jcmwwga4GCCsG
# AQUFBwEBBIGhMIGeMG0GCCsGAQUFBzAChmFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDb2Rl
# JTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8v
# b25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwDQYJKoZIhvcNAQEMBQADggIBAGct
# OF2Vsw0iiR0q3NJryKj6kQ73kJzdU7Jj+FCwghx0zKTaEk7Mu38zVZd9DISUOT9C
# 3IvNfrdN05vkn6c7y3SnPPCLtli8yI2oq8BA7nSww4mfdPeEI+mnE02GgYVXHPZT
# KJDhva86tywsr1M4QVdZtQwk5tH08zTBmwAEiG7iTpVUvEQN7QZJ5Bf9kTs8d9OD
# jgu5+3ggqpiae/UK6iyneCUVixV6AucxZlRnxS070XxAKICi4liEvk6UKSyANv29
# 78dCEsWd6V+Dp1C5sgWyoH0iUKidgoln8doxm9i0DvL0Q5ErhzGW9N60JcAdrKJJ
# cfS54T9P3bBUbRyy/lV1TKPrJWubba+UpgCRcg0q8M4Hz6ziH5OBKGVRrYAK7YVa
# fsnOVNJumTQgTxES5iaS7IT8FOST3dYMzHs/Auefgn7l+S9uONDTw57B+kyGHxK4
# 91AqqZnjQjhbZTIkowxNt63XokWKZKoMKGCcIHqXCWl7SB9uj3tTumult8EqnoHa
# TZ/tj5ONatBg3451w87JAB3EYY8HAlJokbeiF2SULGAAnlqcLF5iXtKNDkS5rpq2
# Mh5WE3Qp88sU+ljPkJBT4kLYfv3Hh387pg4VH1ph7nj8Ia6nt1FQh8tK/X+PQM9z
# oSV/djJbGWhaPzJ5jeQetkVoCVEzCEBfI9DesRf3MIIHnjCCBYagAwIBAgITMwAA
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
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMgITMwAB4bm+Z21F0IMsogAAAAHhuTAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCAWVMpfic7dj//FFjfygjPt1Zzm
# 15EH8AKKnLNkIylbJDANBgkqhkiG9w0BAQEFAASCAYBUU8U9rFOQXzA18OyZ2+wj
# Lgk013i5n4hC2EOv+nDxvrUU+dOgXDhoaoSvKCulXB4o3Elaq0ZUEc8e47uVCUIH
# wq8xp36Rj9DDjIYuBZXv8hmnWNBPxji+/k5CbXnqZ6o8ZgsvptoLLdRngEcurErw
# zOa1t5DhgUo02wOhhK8n0QB5DRotIgrRM48DvzASUG9Lijmk9hMlvtktgbIrE/02
# E7pCB/4iTwj4jfIS5V8Fkv8Y/IJkVmOSzMYvOjkbvGo4tW4hbetJLPCfDIFMtw71
# qt+PUZAtcGpw8oew0y0pHxMyN6Dt8eyz7x7QNxQceMGBkp54UiJ0T7hL9ypark7C
# Jo3K4ZZc6uLyPKyzxdZuPUs3/yG00gXmr/M7SwWgmTI1MAZeGwytcIGIwcVSuGOy
# NYoeqcEzscs/CRmrEaL2i0qg6q62h690BjAsANXU5EdDwBJmZD2DxjjXDDbW/osv
# FOQ2cYX9vmxNd0LtI4+bxEz5bd5jMObqHKWtqevjizihghSgMIIUnAYKKwYBBAGC
# NwMDATGCFIwwghSIBgkqhkiG9w0BBwKgghR5MIIUdQIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYQYLKoZIhvcNAQkQAQSgggFQBIIBTDCCAUgCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgcDWqQc/pVERyUskmX+yx21aRc1jAYYER1AgIxCDH
# vOYCBmc2ZOpCPxgTMjAyNDExMTUyMjU1NTIuMzQ5WjAEgAIB9KCB4KSB3TCB2jEL
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
# MC8GCSqGSIb3DQEJBDEiBCBAbS2ToCPlK2Bb8E94dhJG1ma+k0dk3G4zPnsBeA2M
# uTCB3QYLKoZIhvcNAQkQAi8xgc0wgcowgccwgaAEIOiTtrG2N3h52cHQpFIpCBET
# WiSpNJnTzdC8HVfcp+A2MHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMg
# UlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAOjMo7RUpmKIEAAAAAAA6MCIE
# IDCJEePd0na/cJdQ3uDFKHdbmGB5CjPFDFWBznq9L38WMA0GCSqGSIb3DQEBCwUA
# BIICAIf9cde7dYkIJnVovZ/Y9DW9O3wveWdZx0pL5gxhYptWwg1SBAhpQZ5RVK1w
# 7f1ITHVm1sCIWJDyWuwV7dfKZ9lSosxA2XQWh6O0ugOEpaKy7ycrGgttwj1O+xm7
# 4+rbx8qZkti8gf0gkpMoNPwMcz9DtnBhIA4mLdJ109UcScLNpvYKEp1axW7cgmdx
# ba99dfEdtJTWTkaSStwU798UFinshPxnFA3EmX1Y6DlUw+v6mUAPCyo5/c88RZLs
# AgQWhvYN6ANWuHRlmXIn4N7Ram272+E90HfBtKjgz61JSNTFkZHyQHirlVFCsp5t
# LsvjxsKlukwHJowhdDjIFkSKcmHcv+lbkS+OyB0dz/3MJCyatfnEviEIIF+fc1gw
# Fwm1Y3PjjZl5aB+fi8DNPx/SXtrOpeofYw65Sg2h1WcOfolgDzwZtuAIC9FfSIPa
# 7E8S32+GMN54z/HX928JIhl7HH8oE9w02gi2AMJWEPmkY9JpnElqCwwpr/yaJ5sA
# vlcPCPGGvA25Ppgl1CYXTolYteCJsL700IitwaWqMGi2OT+/5kgDffzoe/IcR6Md
# F0GgQqwHzCgz9EEshB/9XLAVWD4JkrF87dzfMoz1H4FQsJ2i42RccvJBGTlU+gjK
# 5XeM2H2tEL5dDijyd2W21q4Xjq15OChsTwiPsPLdHHUY4tVE
# SIG # End signature block
