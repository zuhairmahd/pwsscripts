
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
            Write-Host "Checking $accessGroupName Access for user $($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`)."
            #Is the user already in the group?
            if ($_ -in $ADGroup) {
                Write-Output "User $($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`) already has access to $accessGroupName."
                $ADExcludedUsers += $user
                $excludedUsers += "$($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`), "
            }
            else {
                $ADUsers += $user
                $Users += "$($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`), "
                Write-Output "User $($user.GivenName) $($user.surname) `($($user.UserPrincipalName)`) will be given access to $accessGroupName."
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
    Write-Host "The following users will be provided with $accessGroupName access:"
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
# MII94wYJKoZIhvcNAQcCoII91DCCPdACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDWSlH3Z6xoQypi
# +fhk0U9lExWpuVj+AWQmuwRNkoDzUKCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# nTiOL60cPqfny+Fq8UiuZzGCGpMwghqPAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMQITMwAB5QvzJ/O6YLp6nAAAAAHlCzAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCDZaVojMW5X/eEPeAuKBMvllIy7
# NBWFI9W86YJAoDxpOjANBgkqhkiG9w0BAQEFAASCAYADSRH4hFRonGUrF5q4ObOz
# QqpBg5pj38yDmhLj+m1NWSojPff13s2WzTvivxBH+lOj+J70ByCt6MCrElrjAw+c
# fMFlJvkmI6+jfSG5o+ug+ytwiHvZH5apOVqz5r/9QKHVs3BzumoVykiLJSwdy3ku
# 0IrOh+ICDgISVHAqRATBaLftzJhRVy1XPRvT4r83V/bI/TvCC/+wotZYhjTP/Bs3
# Huq4KpiRBRDmOzWt8H18H/sQftMzHyJSvz00DoEgUAKL+LPKdTiEP7J8EGcjwDQB
# +3wlvc8EAuqEX1RJVuBjXlVwSjE7YXuhnwCRZdiPO0ZaFJjv8MHtnep1C3SzHWfs
# 28Na74qq6/Pml4DAmbnAhAMEelWeaSwN65qMXSPYlzHqzIUiTTcSCGjDpHGuBaWa
# FbMBGw5aJ2ZGA9SkEO/B0YfNbYduczlKRPKh4l29tAUoQNoC8tASrkhvP25fd42p
# rxoOgxaeZZxr8WV2ZEOO/in6iRTUxA3oOLQooyz6D5GhghgTMIIYDwYKKwYBBAGC
# NwMDATGCF/8wghf7BgkqhkiG9w0BBwKgghfsMIIX6AIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYgYLKoZIhvcNAQkQAQSgggFRBIIBTTCCAUkCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQgfcPjCmx14xkaDXBUH6KXA7wC4RvB5OQ3oUaTxbmZ
# CCwCBmc8jp8NyhgTMjAyNDExMTkxNzI4MDEuOTgxWjAEgAIB9KCB4aSB3jCB2zEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWlj
# cm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1Mg
# RVNOOjc4MDAtMDVFMC1EOTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJT
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
# AhMzAAAAO4ppWb4UBWRxAAAAAAA7MA0GCSqGSIb3DQEBDAUAMGExCzAJBgNVBAYT
# AlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1p
# Y3Jvc29mdCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMB4XDTI0MDIx
# NTIwMzYxMloXDTI1MDIxNTIwMzYxMlowgdsxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJh
# dGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo3ODAwLTA1RTAtRDk0NzE1
# MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRo
# b3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCoN2tZV70ADgeA
# rSKowvN7sD1Wj9d2dKDzNsSpQZSD3kwUftP9qC4o/eDvvzx/AzPtJpkW5JpDqYKG
# Ik3NSyyWFlY12loL6mhkRO8K3lLLgZ9wAr68z+1W0NLs0Bd48QUtLfckAiToeknd
# sqKFP28jZOKBU43nW2SiLEL1Wo2JUHFW5Crw16Bkms3b8U9etQKcErNDgTbUnxFb
# c73Dr47el6ppsy6ZMFK7aWzryjKZZfJwS1EmgT2CTQ4XY9qj2Fd9y3gSWNlP+XrG
# yCiPQ3oQ5cdr9Ms59najNa0WxHbR7B8DPIxXRDxCmdQxHw3HL9N8SC017cvwA4hE
# uBMfix2gC7xiDyM+pTkl28BZ1ANnBznEMZs9rbHtKQpyz2bsNO0RYRP+xrIZtWdu
# vwCWEB6k2H5UHSYErMUTm2T4VOQeGsjPRFco+t/5spFqPBsUr/774i4Z+fAfD91D
# 1DFgiK5CVZggk1StKFVDfQSKU5YRXI/TaM4bVocAW3S9rVgpQXCcWI/WJEBxYZn6
# SJ5dE45VlCwyC7HEZvCOrtM02rELlCcXbGdICL3FltPh9A2ZsDw0HA6/7NXF3mhy
# Z37yQ3sprS/Mglb5ddY3/KL7nyCfehVuQDjFD2S/h7FCkM1tFFOJnHrn+UHaBsWS
# /LjyKdBLSK26D/C6RPbM6m5MqeJQIwIDAQABo4IByzCCAccwHQYDVR0OBBYEFBmD
# kSnO3Ykx3QWs933wkNmnHPEVMB8GA1UdIwQYMBaAFGtpKDo1L0hjQM972K9J6T7Z
# PdshMGwGA1UdHwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2lvcHMvY3JsL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGlu
# ZyUyMENBJTIwMjAyMC5jcmwweQYIKwYBBQUHAQEEbTBrMGkGCCsGAQUFBzAChl1o
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUy
# MFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwZgYDVR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRt
# MAgGBmeBDAEEAjANBgkqhkiG9w0BAQwFAAOCAgEAKrAu6dFJYu6BKhLMdAxnEMze
# KzJOMunyOeCMX9VC/meVFudURy3RKZMYUq0YFqQ0BsmfufswGszwfSnqaq116/fo
# miYokxBDQU/r2u8sXod6NfSaD8/xx/pAFSU28YFYJh46+wdlR30wgf+8uJJMlpZ9
# 0fGiZ2crTw0KZJWWSg53MlXTalBP7ZepnoVp9NmcRD9CDw+3IdkjzH1yCnfjbWp0
# HfBJdv7WJVlcnRM45MYqUX1x+5LCeeDnBw2pTj3cDKPNNtNhb8BHRcTJSH84tjVR
# TtpCtc1XZE5u+u0g1tCzLSm7AmR+SZjoClyzinuQuqk/8kx6YRow7Y8wBiZjP5Lf
# riRreaDGpm97efzhkwVKcsZsKnw007GhPRQWz52fSgMsRzg6rWx6MRBv3c+kBcef
# gLVVEI3ggugej9NwDXUnmH+DC6ir5NTQ3ZVLhwA2Fjbn+rctcXeozP5g/CS9Qx4C
# 8RpkvyZGvBEBDyNFdU9r2HyMvFP/NaUCI0xC7oLde5FONeRFI01itSXk1N7R80JU
# W7jqRKvy7Ueqg6T6PwWfAd/R+vh7oQXhLH98dPJMODz3cdCtw5MeAnfcfUDEE8b6
# mzJK5iLJbnKYIQ+o9T/AcS0A1yCiClaBZBTociaFT5JStvCe7CDzvUWVBY375ezQ
# +l6M3tTzy63GpBDohSMxggdFMIIHQQIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAO4ppWb4UBWRxAAAA
# AAA7MA0GCWCGSAFlAwQCAQUAoIIEnjARBgsqhkiG9w0BCRACDzECBQAwGgYJKoZI
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yNDExMTkxNzI4
# MDFaMC8GCSqGSIb3DQEJBDEiBCB6tKpuEVzEZhfWYIYh23njBnavW6mcaec5Zmy0
# Jluh1zCBuQYLKoZIhvcNAQkQAi8xgakwgaYwgaMwgaAEIJPbJzLEniYkzwpcwDrQ
# SswJJ/yvXnr91KPiO2/Blq7cMHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAO4ppWb4UBWRxAAAAAAA7
# MIIDYAYLKoZIhvcNAQkQAhIxggNPMIIDS6GCA0cwggNDMIICKwIBATCCAQmhgeGk
# gd4wgdsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNV
# BAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGll
# bGQgVFNTIEVTTjo3ODAwLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHmiIwoBATAHBgUrDgMCGgMV
# AClO3IQMdSPcu/l/uN44JqTQiG/3oGcwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMA0GCSqGSIb3DQEBCwUAAgUA
# 6ucNIjAiGA8yMDI0MTExOTEzMTIwMloYDzIwMjQxMTIwMTMxMjAyWjB2MDwGCisG
# AQQBhFkKBAExLjAsMAoCBQDq5w0iAgEAMAkCAQACAR8CAf8wBwIBAAICEQkwCgIF
# AOroXqICAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQAC
# AwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQsFAAOCAQEAIyKDUEH3fZ/XC5EF
# cFeRgYiroo/1GbnwSKNtDARXc91YEihqtVJc+szUjIZkTRkfU9KTm9Edx1u/mSvk
# gHTV0mED3aDVHzGEjfr5SmYFfRTldiTuunWxcSv5glMP1SKQxumq+vHPr/g0rZzp
# aKXmd82PTI2CwCkosrvPlgRG1UolwfVhwFISht8RavgdAqB5jNbyQsKZ3AAGRO3n
# BCKy9vuN2wpWEoRuSOrMEtOeWEayg/RB/y1z2OF5qw1USBkMIHEJfEqJ+FxxN3lA
# 8etJGj+A8N77tiSiGZVA4pnSnoT02bDh54YwfsM1tr/baZIXEYz5BM4SM0B1aF7k
# D0SNnTANBgkqhkiG9w0BAQEFAASCAgByNU7KzdqH2KUuno6NyUgWbwuGAZmWzDBS
# wklBUk9JHUtJ9al6Ug3YeowppRS7ntZFfTcfTsGvRuHJ6aGJ1FOO9xhvsnW+utQs
# iIzjQzYpM6GZ22YnNmjz5/CcN9pLyRXCjhGjaCKPRWOXLdV3etbc5bauSKfw1vZ5
# sj5q9q4MdCX/t7hXN6WHQ6WGM1cUtRsLXre5uo/yWmQwaxrHE/ofHlnQ+nIJBNr5
# wF3Y0dwhMOqk2BXNfNWKNuV0JXZyFQ3FFf+26HyQITaOByyuQIkCJLTe3oc/9vl9
# ecpqOYna8WjcM2DgS0SC+j8qE/0kN1hfAYYQMIZVsxq9RRJSeKRhKeaNOl/vH0HJ
# YynGeXFPIQ+wsO/OhwCpC3DDqPXyZnGa1JqjgJQPwyBFYUCL7o6abCJWgNIcrs21
# AQnNePybVb34Yg0DQbG9pSMCL3XgKbhkNHFnD3BAGgn9l69+FmFFlbvhAyLckSV4
# 1M76O3tshNR6pII+28I0XJ4M4CBDBmhBSt0K4DXiSNkEXxqCS4qfcpZ8ygfkaddU
# zttOEm+8ZS0lv8V4MBaPihBg/HTVJLw+PM99cvUCcwm8thNEK+6RMdSwXrOB0bTm
# UngmPePq4438sKIiDhcPt6OlhwbhuXOTEyBbCuo3FiM/vCb51TOQTO6yHYSTDHoK
# HYetpYn6sA==
# SIG # End signature block
