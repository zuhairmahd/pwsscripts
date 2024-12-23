$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'TurnoffBitlocker-remediation.log'
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFile."
}
Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder\$LogFile"
#Output a string with the timestamp of when the script started running.
Write-Output "Script started running at $(Get-Date)"
#Check to see if bitlocker is enabled on the system
$BitlockerStatus = Get-BitLockerVolume
#process all returned volumes.
foreach ($Volume in $BitlockerStatus) {
    Write-Output "Checking BitLocker status for drive $($Volume.MountPoint)"
    #Check to see if Bitlocker is enabled
    if ($Volume.ProtectionStatus -eq 'On') {
        Write-Output "Bitlocker is enabled on $($Volume.MountPoint)"
        #Disable Bitlocker
        Disable-BitLocker -MountPoint $Volume.MountPoint
        Write-Host "Bitlocker has been disabled on $($Volume.MountPoint)"
    }
    else {
        Write-Host "Bitlocker is not enabled on $($Volume.MountPoint)"
    }
}
#we are done. Write a good-bye message.
Write-Output 'Script has completed.'
Stop-Transcript
# SIG # Begin signature block
# MII94AYJKoZIhvcNAQcCoII90TCCPc0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCEksHGIh98nQPo
# m6jSoaA25MyRrHNFp93fHDfKZ01riaCCIqYwggXMMIIDtKADAgECAhBUmNLR1FsZ
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
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbnMIIEz6ADAgECAhMzAAHgL6IT
# PVYBfL7GAAAAAeAvMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDIwHhcNMjQxMTEzMTcxNTAxWhcNMjQxMTE2
# MTcxNTAxWjBmMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExEjAQBgNV
# BAcTCUFybGluZ3RvbjEXMBUGA1UEChMOWnVoYWlyIE1haG1vdWQxFzAVBgNVBAMT
# Dlp1aGFpciBNYWhtb3VkMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
# qf+PKdW8eEmduCnp4EllC2I368jkhQC1Fb0H+p/LyJxqLe2LG6zn7GLbTgGH78/G
# TDPmEx+2ic1DCkXpvgQe8Nhb+3XXiPSltodjcwsYhWLo+obfZQh+PDSP9CHDyXUv
# 5ykeVZU5MqNGo5KGYkUTXSl+jTRTdTShZZiwTokUPa0ybutmIuh7VOYeIpL6BGUH
# L2uTbva2IH69vBbdYNzfIbaAi8wCId3rcJBB0c2gqGZsAZq1HiESocE1Ff0I99rt
# aTk5CUxAyZcO+br1OayGHyWogGzLWDakHU1w//ZSXJ4VdTXduKXWqtQSxHvtwPRh
# sr4Tc3a2ZarzG9HWDOrSUavGlWg/o4dXL5flOugBEyKiC/PBq5CPYBYdMk41Whiz
# XhkhytX1f9Qog+9Crq7Dk+ScZiPgBlxQ9X5kr8891mXJkn2zJGF9hohFfjISaXtm
# 3FkztPCvJtUqx2HoPQfLAzyryrpWNi9GQc6rGAq7vMqzNJndwZYFOMNPPTqymxnX
# AgMBAAGjggIYMIICFDAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA7BgNV
# HSUENDAyBgorBgEEAYI3YQEABggrBgEFBQcDAwYaKwYBBAGCN2GBmtGaFtje9WuB
# vfqFXPmA7xswHQYDVR0OBBYEFI+oS6Oh+lBo9qfFIsfs5ms519jlMB8GA1UdIwQY
# MBaAFCRFmaF3kCp8w8qDsG5kFoQq+CxnMGcGA1UdHwRgMF4wXKBaoFiGVmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDIuY3JsMIGlBggrBgEFBQcBAQSB
# mDCBlTBkBggrBgEFBQcwAoZYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ1MlMjBBT0MlMjBD
# QSUyMDAyLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWljcm9zb2Z0
# LmNvbS9vY3NwMGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUH
# AgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
# b3J5Lmh0bTAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBAL5iYxsCeRCFfBSc
# JBVpg6PCWdybMmBain8d83OkiPpLNLxbWHvMbB+QEnt6LqqA6Ve+qNMWnAn9tbqn
# Tf+muJ+x1wiv8r8d+WGcNfQBYYuVF79YXVsF1Yfh0RxEYeyso3H2y0vDPllsXreb
# rpwjjQWNpmsYJXPdiIM0grJEVCuYsJpxzmGUFvX/8S2sRJDuJJzKvw0tKN13DGPx
# pvr/kkn9i6gxzbXvOCL+sbGHgk/B+ft2VEPI5FWSfcasIjgZark4ijiG5DITvuZ5
# NstGgE5y7eobml9fKEyHeyIpR4YEX9VEb0ksp0gKjdgsrWhUrd3hPoewfX3ZgQyU
# wgdn2dPRT2gpdK8fjQBigriMyWyVcYrTXVmYVqf+OunhXDNG9fS8y/8+fYSo5QYv
# MG9iln3bTjOgr+rhUtPLmKrIVKsf4GU1Y//4MhOo28tTUTBMKAEzclIMx0/XgsBV
# CgCwx+8L59BkjqMBzLAeiwTgMyHUFgIwGF9+Td6iFzxFlkaDfkcGQ7Q0wxgxGWWP
# q8e0gdBficLs3v+We4FAy7hq+dP7taIRjTaFtZXVlDO021a3vrhTg3FoCW05onoc
# PsKpiEHtF9h2LFOu060vV8YSoyk9g9ny2HHIXF9lJeBHlDoYLkswtggVN8PAW0cN
# JCj67q3QADJiSvkMOnXQDaDt2iSHMIIG5zCCBM+gAwIBAgITMwAB4C+iEz1WAXy+
# xgAAAAHgLzANBgkqhkiG9w0BAQwFADBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVy
# aWZpZWQgQ1MgQU9DIENBIDAyMB4XDTI0MTExMzE3MTUwMVoXDTI0MTExNjE3MTUw
# MVowZjELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMRIwEAYDVQQHEwlB
# cmxpbmd0b24xFzAVBgNVBAoTDlp1aGFpciBNYWhtb3VkMRcwFQYDVQQDEw5adWhh
# aXIgTWFobW91ZDCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAKn/jynV
# vHhJnbgp6eBJZQtiN+vI5IUAtRW9B/qfy8icai3tixus5+xi204Bh+/Pxkwz5hMf
# tonNQwpF6b4EHvDYW/t114j0pbaHY3MLGIVi6PqG32UIfjw0j/Qhw8l1L+cpHlWV
# OTKjRqOShmJFE10pfo00U3U0oWWYsE6JFD2tMm7rZiLoe1TmHiKS+gRlBy9rk272
# tiB+vbwW3WDc3yG2gIvMAiHd63CQQdHNoKhmbAGatR4hEqHBNRX9CPfa7Wk5OQlM
# QMmXDvm69Tmshh8lqIBsy1g2pB1NcP/2UlyeFXU13bil1qrUEsR77cD0YbK+E3N2
# tmWq8xvR1gzq0lGrxpVoP6OHVy+X5TroARMiogvzwauQj2AWHTJONVoYs14ZIcrV
# 9X/UKIPvQq6uw5PknGYj4AZcUPV+ZK/PPdZlyZJ9syRhfYaIRX4yEml7ZtxZM7Tw
# rybVKsdh6D0HywM8q8q6VjYvRkHOqxgKu7zKszSZ3cGWBTjDTz06spsZ1wIDAQAB
# o4ICGDCCAhQwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwOwYDVR0lBDQw
# MgYKKwYBBAGCN2EBAAYIKwYBBQUHAwMGGisGAQQBgjdhgZrRmhbY3vVrgb36hVz5
# gO8bMB0GA1UdDgQWBBSPqEujofpQaPanxSLH7OZrOdfY5TAfBgNVHSMEGDAWgBQk
# RZmhd5AqfMPKg7BuZBaEKvgsZzBnBgNVHR8EYDBeMFygWqBYhlZodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJRCUyMFZlcmlm
# aWVkJTIwQ1MlMjBBT0MlMjBDQSUyMDAyLmNybDCBpQYIKwYBBQUHAQEEgZgwgZUw
# ZAYIKwYBBQUHMAKGWGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0ElMjAw
# Mi5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20v
# b2NzcDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQC+YmMbAnkQhXwUnCQVaYOj
# wlncmzJgWop/HfNzpIj6SzS8W1h7zGwfkBJ7ei6qgOlXvqjTFpwJ/bW6p03/prif
# sdcIr/K/HflhnDX0AWGLlRe/WF1bBdWH4dEcRGHsrKNx9stLwz5ZbF63m66cI40F
# jaZrGCVz3YiDNIKyRFQrmLCacc5hlBb1//EtrESQ7iScyr8NLSjddwxj8ab6/5JJ
# /YuoMc217zgi/rGxh4JPwfn7dlRDyORVkn3GrCI4GWq5OIo4huQyE77meTbLRoBO
# cu3qG5pfXyhMh3siKUeGBF/VRG9JLKdICo3YLK1oVK3d4T6HsH192YEMlMIHZ9nT
# 0U9oKXSvH40AYoK4jMlslXGK011ZmFan/jrp4VwzRvX0vMv/Pn2EqOUGLzBvYpZ9
# 204zoK/q4VLTy5iqyFSrH+BlNWP/+DITqNvLU1EwTCgBM3JSDMdP14LAVQoAsMfv
# C+fQZI6jAcywHosE4DMh1BYCMBhffk3eohc8RZZGg35HBkO0NMMYMRllj6vHtIHQ
# X4nC7N7/lnuBQMu4avnT+7WiEY02hbWV1ZQztNtWt764U4NxaAltOaJ6HD7CqYhB
# 7RfYdixTrtOtL1fGEqMpPYPZ8thxyFxfZSXgR5Q6GC5LMLYIFTfDwFtHDSQo+u6t
# 0AAyYkr5DDp10A2g7dokhzCCB1owggVCoAMCAQICEzMAAAAEllBL0tvuy4gAAAAA
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
# nTiOL60cPqfny+Fq8UiuZzGCGpAwghqMAgEBMHEwWjELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENTIEFPQyBDQSAwMgITMwAB4C+iEz1WAXy+xgAAAAHgLzAN
# BglghkgBZQMEAgEFAKBeMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMC8GCSqGSIb3DQEJBDEiBCD2VNTSpicICom3/dYd4A/beyua
# Unm3pw+SeQtVaadOCDANBgkqhkiG9w0BAQEFAASCAYCL3GQyPG+PsUbNJRMiiesO
# JubTqTOunwUo1YbGU1YUV/2ex9+9bQdTkVeseWjUHoaMzCdBTlVOPy4pzVJda7Kv
# d7sICerasC80TQBucQM0IrxKrk/0rWMs2c1SwFqaDUe+LjDV5Zq+wfZnBftZzr1J
# IARBg8naEOhvnvRuDw7qfQcUVZb8JBe4l85c17CouRa0e0o3TG3/mfM6mWPW7UVK
# KStg5uLriWqpf6HT0k5dw/zoXH+PhYMEo9SHfis5ybG+zQBkL2q51CoYGA+e/vBb
# jagwwTzlvRwP3qR7rO43NRsSTcOi3yJoyFOUxkEGeITUkZnZPhNd/cClbZyvP4YX
# z0pzr8dw4zt5WaN4cW0uLi5ytjqq6Xt30SGqG6ysukPun3HoZe0iTlCpp941hw3b
# ZyFw6XkcEbBXEt8KCucgfgIbzVoD9Lfqj4TMSZzQw/SStX5h4l5GIOqFy+u60lqk
# IfOT5LelAxjiZqN2KM8kafk6dLMRKEjiz9wj2BdpdbWhghgQMIIYDAYKKwYBBAGC
# NwMDATGCF/wwghf4BgkqhkiG9w0BBwKgghfpMIIX5QIBAzEPMA0GCWCGSAFlAwQC
# AQUAMIIBYQYLKoZIhvcNAQkQAQSgggFQBIIBTDCCAUgCAQEGCisGAQQBhFkKAwEw
# MTANBglghkgBZQMEAgEFAAQg+2rJTM6K46Dx7qvp5KqbBoOGv7ooeQXTX6aLuBqr
# HSECBmclIyAOXxgSMjAyNDExMTQxNjIxMjEuMTFaMASAAgH0oIHhpIHeMIHbMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNy
# b3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBF
# U046QTUwMC0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNB
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
# EzMAAAA8fxugygA3RbkAAAAAADwwDQYJKoZIhvcNAQEMBQAwYTELMAkGA1UEBhMC
# VVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWlj
# cm9zb2Z0IFB1YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwHhcNMjQwMjE1
# MjAzNjE2WhcNMjUwMjE1MjAzNjE2WjCB2zELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
# aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkE1MDAtMDVFMC1EOTQ3MTUw
# MwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0YW1waW5nIEF1dGhv
# cml0eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKcN7/+iM7DM0EHD
# 3A18oDhZ0W0H9UwcJg2uj8p3V6lw7vB3/LO7ZEjZ2cMMFoTdyzmdxAQjOowOHSzM
# akbCuzp9fUyMCpJVjssEBXM1QeVw5tc67m5nPY4V4gX53MKdjc5s+hYhM2b5bc9p
# XYrKeSxI03TAuvDEtitMyMVyMI2BbVAUKJxKe6JpQKzy/RIaoQ/XAFearh+Sp6f2
# sMxkQIFU15uqG7wkmikHQmctKk9f7YZ0EvASVmv0o3eTLfBblVZlYPT8wbYTqMVS
# myUi3kB0XEUWSPxvCk4137gzPHpbIQJaRKOdE2qcdi+AALeH3JrIgJzAPuQbB3jA
# nQ3KjEwUR9th+YmIqS3nukKBOzwsPToTRG3b5d8leqNfyPlL4lddpt8Ryrcj1jub
# 39+jx6uhFDcC9n5iYFynMSReBHmPVEpptoZktdrssb/ws+4qv6bgmXNuqOdpZBvk
# p633wSLeLgG8zORivqEM5f7grFWu2q6rmTVWF+nsybrvnmppOWIVqik3P85SvmO/
# w1xcvMEfNmWgTz0jG8Qfe3n4oMQJQ5MySZS730eys21ctp/JAWLhk8YS3GgFGB15
# jAhFxh845YNc+qxZJDCGCKmZkSGKL87ue5BqOBHn2hgxK+Hgpbci/xETc/sg9DSZ
# k1kdERLfBJjeav/bJdvCjnx0ypv3AgMBAAGjggHLMIIBxzAdBgNVHQ4EFgQU4xtz
# mjBkCmkMjTwdUzuvDcleh5UwHwYDVR0jBBgwFoAUa2koOjUvSGNAz3vYr0npPtk9
# 2yEwbAYDVR0fBGUwYzBhoF+gXYZbaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
# aW9wcy9jcmwvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5n
# JTIwQ0ElMjAyMDIwLmNybDB5BggrBgEFBQcBAQRtMGswaQYIKwYBBQUHMAKGXWh0
# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIw
# UHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0ElMjAyMDIwLmNydDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIH
# gDBmBgNVHSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0w
# CAYGZ4EMAQQCMA0GCSqGSIb3DQEBDAUAA4ICAQBiTsy8uGiW0x/1Nnbx2w1WcxyM
# YFIk4+8qPlP0NHE8cWlnUADU7aSWY77N3Mp9tUqjBpVwbN6LSJvd549BFClPkMj2
# Q3IPqH9adyORQ33wycZLFQaIRwy+0NJ5IqdfCklVVZYN0PG923ow5O12uCUf4mXW
# GteE3BOwX64nWM1GYdJlLtOKzi+MgoNCXpQS9K0vt4Ri/LZRn0dyUSkr0OzvKlpQ
# otCA85oxsbG+YykkZ5OPmi78ZaoDtCE7mbLhzTXCzNEGgEXt5HfisFTXVt1wmwfZ
# QxTojus691obDVcio7JYXxjgciQukyPkM/PSZapw4DkSGVH5kwzmS37btIBeOmJ0
# XpGAt4PGXGVJ5BxoTIi7FkrI5Qysvje+XJsCxDBGXJQuLCA9uWNrONbaqc/14Xyg
# fvvv1MdxsXOZfpRLX+3R995FpTSJfGbBV7ss3lHhLho4lIgcBCMvrp+H14mhE8A3
# koS2a/e9BsFDTvjTYNyk7STLtuiPk2ENaisonOrdymmB//RvwL/tZEbJrfQLh2Bu
# cn9kcIjJ697i2+Vo+tzMOjucB2lwIciFA3leE6bCwY8x+TmJHoiwlIWsme3uB1EG
# hMYvIQQ92SrtreQ/dCYurj/jpISz8C6uaK/d54XrNvJZWbyyB4P4wxYRfhhsMa+/
# GHlcjw9hT67VA/4mQjGCB0Mwggc/AgEBMHgwYTELMAkGA1UEBhMCVVMxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAAA8fxugygA3RbkAAAAA
# ADwwDQYJYIZIAWUDBAIBBQCgggScMBEGCyqGSIb3DQEJEAIPMQIFADAaBgkqhkiG
# 9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI0MTExNDE2MjEy
# MVowLwYJKoZIhvcNAQkEMSIEIHpttupnPJjb0xotJVIgjFJWuiypXcpXVaZM74ds
# Z7RPMIG5BgsqhkiG9w0BCRACLzGBqTCBpjCBozCBoAQgWp+niJG/SBoy5uq8YLh2
# LjZjiGwIEwwdaFGVNJKEuNswfDBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1Ymxp
# YyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAAA8fxugygA3RbkAAAAAADww
# ggNeBgsqhkiG9w0BCRACEjGCA00wggNJoYIDRTCCA0EwggIpAgEBMIIBCaGB4aSB
# 3jCB2zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UE
# CxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOkE1MDAtMDVFMC1EOTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lIFN0YW1waW5nIEF1dGhvcml0eaIjCgEBMAcGBSsOAwIaAxUA
# 0kwLSdaewMcFeEJpP3QXCMc1HyOgZzBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1
# YmxpYyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwDQYJKoZIhvcNAQELBQACBQDq
# 4BxjMCIYDzIwMjQxMTE0MDY1MTE1WhgPMjAyNDExMTUwNjUxMTVaMHQwOgYKKwYB
# BAGEWQoEATEsMCowCgIFAOrgHGMCAQAwBwIBAAICD/kwBwIBAAICE0YwCgIFAOrh
# beMCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAweh
# IKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQsFAAOCAQEAjASi290sof5c0B54fC/X
# nq8wC7V7TLeBBVP80bFAKCAIuopB7gRengfACH4jD/ZPmBPnskSppjWBF5RAXgQH
# 3bqZ9/PAPnzyV/XuameQXL76xNjV0mXJnCfhl1WA5uQ+/DcxIh7bJBd9MdZmGWHX
# 8gDgyTIP7xv/g3vNHC1Mggz8usn9AansPyYDUZsET8sKQOySAuUp/ojgFZSILIxR
# Urr++3B6qe1Y2f1XntxqGMMeVAh/y7oDAAWXXmxMjKffoy2k/ls/wRcqkxdiEBGU
# uRtwp/Bczj84gDIdQl20U3Gwx60Rse0z7KZTIerUPBo8upd+KvwRGySTri6t1ljS
# GDANBgkqhkiG9w0BAQEFAASCAgAIE0S1WgpGfAC+tZF3f+rlb75RoPcqpNVA14ia
# Y5ZXvlS4roOE6A7w6Wo/hWEohRQEYTeW8hIZ8tTk3MGedoRWm6V0aaSdweKLNnYP
# Dds1DuTImt23hp1CyBZV7z/kALuy3eRDphrZHed3fDeOhekVSn5a9Dl6iRJtm5yf
# edQzTy3BmTmy06wwXCu0d4XJuaYwzpWeSnXs7RrCBBS9kWs984gkdfm4T54La12t
# OAn976hTNkrwNBjE3GTaBc8tXYOofJthLLg7IbDA9ssLtjS7vpPNXf/MByW8M8AF
# ++nGKXNpmDXYzxHliUT9ACguFBnXAt/FNZnEj3M1SiAW9/eyv/NCNoBtzQhTxm2z
# YjT8hBCl5J+UC6gBalRq14rWKw+4Q52cP8V0TQEuYcR5mehsMOr9mrKENTzl25iB
# V5d7Mt39hFvQHB6qYN46aRHLtV76gwrvKR8cwxHbnv+xfpQIDhtaiTIXaHrTSZXO
# M1CEiYWDx7Kz4yN+HRxcMx/8h2EBq9C11jr0wQ2Gl0HT6qT5ljjfeo5faiE0MSBg
# Dci52E0UohAjQTZtepwhhJuVGr5a2sKij+fwUHcyUbmIUC4Sbxm6hxuiH376SZiJ
# PL6+GfJ6juNYD35bHFVRSDUbokJeO6NcdIO7M/BhAFsTwFy/TcSnjBuEkKjt2hwk
# 8imVsQ==
# SIG # End signature block
