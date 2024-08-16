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
    $IPAddress = (Invoke-WebRequest -Uri 'https://api.ipify.org/').Content
    Write-Host Your detected public IP address is $IPAddress
    #See if we can get the time zone, assuming an IP address was returned
    if ($IPAddress -as [ipaddress]) {
        $GeoIP = Invoke-RestMethod -Uri "https://freegeoip.app/json/$IPAddress"
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

$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'TimeZone.log'
#Create Folder to keep logs 
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}
Start-Transcript -Append -IncludeInvocationHeader -Path $LogFolder\$LogFile
$MyCity = 'Washinton'
$WindowsTimezone = Get-TimeZoneFromCity -CityName $MyCity
if (-not ($WindowsTimezone )) {
    $UnixTimezone = get-UnixTimeZoneFromIP
    if ($UnixTimezone ) {
        $WindowsTimeZone = Convert-TimeZone -UnixTimeZone $UnixTimezone
    }
    else {
        Write-Host 'Failed to get timezone'
        exit 1
    }
}
Write-Host "Time zone detected as $WindowsTimeZone"
$CurrentTimeZone = Get-TimeZone
if ($CurrentTimeZone.Id -eq $WindowsTimeZone) {
    Write-Host "Time zone is already set to $WindowsTimeZone"
    exit 0
}
else {
    Write-Host "Time zone is currently set to $($CurrentTimeZone.Id)"
    # Set the time zone
    Set-TimeZone -Id $WindowsTimeZone
    Write-Host "Time zone set to $WindowsTimeZone"
}
Stop-Transcript
