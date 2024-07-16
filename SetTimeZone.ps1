$IPAddress = (Invoke-WebRequest -Uri 'https://api.ipify.org/').Content
Write-Host $IPAddress
#let's check to see if this is a valid IP address
if ($IPAddress -as [ipaddress]) {
    $GeoIP = Invoke-RestMethod -Uri "https://freegeoip.app/json/$IPAddress"
    # Write-Host $GeoIP
    $TimeZone = $GeoIP.time_zone
    Write-Host $TimeZone
}


# Id                         : Dateline Standard Time
# DisplayName                : (UTC-12:00) International Date Line West
# StandardName               : Dateline Standard Time
# DaylightName               : Dateline Daylight Time
# BaseUtcOffset              : -12:00:00
# SupportsDaylightSavingTime : False

# Id                         : UTC-11
# DisplayName                : (UTC-11:00) Coordinated Universal Time-11
# StandardName               : UTC-11
# DaylightName               : UTC-11
# BaseUtcOffset              : -11:00:00
# SupportsDaylightSavingTime : False

# Id                         : Aleutian Standard Time
# DisplayName                : (UTC-10:00) Aleutian Islands
# StandardName               : Aleutian Standard Time
# DaylightName               : Aleutian Daylight Time
# BaseUtcOffset              : -10:00:00
# SupportsDaylightSavingTime : True

# Id                         : Hawaiian Standard Time
# DisplayName                : (UTC-10:00) Hawaii
# StandardName               : Hawaiian Standard Time
# DaylightName               : Hawaiian Daylight Time
# BaseUtcOffset              : -10:00:00
# SupportsDaylightSavingTime : False

# Id                         : Marquesas Standard Time
# DisplayName                : (UTC-09:30) Marquesas Islands
# StandardName               : Marquesas Standard Time
# DaylightName               : Marquesas Daylight Time
# BaseUtcOffset              : -09:30:00
# SupportsDaylightSavingTime : False

# Id                         : Alaskan Standard Time
# DisplayName                : (UTC-09:00) Alaska
# StandardName               : Alaskan Standard Time
# DaylightName               : Alaskan Daylight Time
# BaseUtcOffset              : -09:00:00
# SupportsDaylightSavingTime : True

# Id                         : UTC-09
# DisplayName                : (UTC-09:00) Coordinated Universal Time-09
# StandardName               : UTC-09
# DaylightName               : UTC-09
# BaseUtcOffset              : -09:00:00
# SupportsDaylightSavingTime : False

# Id                         : Pacific Standard Time (Mexico)
# DisplayName                : (UTC-08:00) Baja California
# StandardName               : Pacific Standard Time (Mexico)
# DaylightName               : Pacific Daylight Time (Mexico)
# BaseUtcOffset              : -08:00:00
# SupportsDaylightSavingTime : True

# Id                         : UTC-08
# DisplayName                : (UTC-08:00) Coordinated Universal Time-08
# StandardName               : UTC-08
# DaylightName               : UTC-08
# BaseUtcOffset              : -08:00:00
# SupportsDaylightSavingTime : False

# Id                         : Pacific Standard Time
# DisplayName                : (UTC-08:00) Pacific Time (US & Canada)
# StandardName               : Pacific Standard Time
# DaylightName               : Pacific Daylight Time
# BaseUtcOffset              : -08:00:00
# SupportsDaylightSavingTime : True

# Id                         : US Mountain Standard Time
# DisplayName                : (UTC-07:00) Arizona
# StandardName               : US Mountain Standard Time
# DaylightName               : US Mountain Daylight Time
# BaseUtcOffset              : -07:00:00
# SupportsDaylightSavingTime : False

# Id                         : Mountain Standard Time (Mexico)
# DisplayName                : (UTC-07:00) La Paz, Mazatlan
# StandardName               : Mountain Standard Time (Mexico)
# DaylightName               : Mountain Daylight Time (Mexico)
# BaseUtcOffset              : -07:00:00
# SupportsDaylightSavingTime : True

# Id                         : Mountain Standard Time
# DisplayName                : (UTC-07:00) Mountain Time (US & Canada)
# StandardName               : Mountain Standard Time
# DaylightName               : Mountain Daylight Time
# BaseUtcOffset              : -07:00:00
# SupportsDaylightSavingTime : True

# Id                         : Yukon Standard Time
# DisplayName                : (UTC-07:00) Yukon
# StandardName               : Yukon Standard Time
# DaylightName               : Yukon Daylight Time
# BaseUtcOffset              : -07:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central America Standard Time
# DisplayName                : (UTC-06:00) Central America
# StandardName               : Central America Standard Time
# DaylightName               : Central America Daylight Time
# BaseUtcOffset              : -06:00:00
# SupportsDaylightSavingTime : False

# Id                         : Central Standard Time
# DisplayName                : (UTC-06:00) Central Time (US & Canada)
# StandardName               : Central Standard Time
# DaylightName               : Central Daylight Time
# BaseUtcOffset              : -06:00:00
# SupportsDaylightSavingTime : True

# Id                         : Easter Island Standard Time
# DisplayName                : (UTC-06:00) Easter Island
# StandardName               : Easter Island Standard Time
# DaylightName               : Easter Island Daylight Time
# BaseUtcOffset              : -06:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central Standard Time (Mexico)
# DisplayName                : (UTC-06:00) Guadalajara, Mexico City, Monterrey
# StandardName               : Central Standard Time (Mexico)
# DaylightName               : Central Daylight Time (Mexico)
# BaseUtcOffset              : -06:00:00
# SupportsDaylightSavingTime : True

# Id                         : Canada Central Standard Time
# DisplayName                : (UTC-06:00) Saskatchewan
# StandardName               : Canada Central Standard Time
# DaylightName               : Canada Central Daylight Time
# BaseUtcOffset              : -06:00:00
# SupportsDaylightSavingTime : False

# Id                         : SA Pacific Standard Time
# DisplayName                : (UTC-05:00) Bogota, Lima, Quito, Rio Branco
# StandardName               : SA Pacific Standard Time
# DaylightName               : SA Pacific Daylight Time
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : False

# Id                         : Eastern Standard Time (Mexico)
# DisplayName                : (UTC-05:00) Chetumal
# StandardName               : Eastern Standard Time (Mexico)
# DaylightName               : Eastern Daylight Time (Mexico)
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Eastern Standard Time
# DisplayName                : (UTC-05:00) Eastern Time (US & Canada)
# StandardName               : Eastern Standard Time
# DaylightName               : Eastern Daylight Time
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Haiti Standard Time
# DisplayName                : (UTC-05:00) Haiti
# StandardName               : Haiti Standard Time
# DaylightName               : Haiti Daylight Time
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Cuba Standard Time
# DisplayName                : (UTC-05:00) Havana
# StandardName               : Cuba Standard Time
# DaylightName               : Cuba Daylight Time
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : True

# Id                         : US Eastern Standard Time
# DisplayName                : (UTC-05:00) Indiana (East)
# StandardName               : US Eastern Standard Time
# DaylightName               : US Eastern Daylight Time
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Turks And Caicos Standard Time
# DisplayName                : (UTC-05:00) Turks and Caicos
# StandardName               : Turks and Caicos Standard Time
# DaylightName               : Turks and Caicos Daylight Time
# BaseUtcOffset              : -05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Paraguay Standard Time
# DisplayName                : (UTC-04:00) Asuncion
# StandardName               : Paraguay Standard Time
# DaylightName               : Paraguay Daylight Time
# BaseUtcOffset              : -04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Atlantic Standard Time
# DisplayName                : (UTC-04:00) Atlantic Time (Canada)
# StandardName               : Atlantic Standard Time
# DaylightName               : Atlantic Daylight Time
# BaseUtcOffset              : -04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Venezuela Standard Time
# DisplayName                : (UTC-04:00) Caracas
# StandardName               : Venezuela Standard Time
# DaylightName               : Venezuela Daylight Time
# BaseUtcOffset              : -04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central Brazilian Standard Time
# DisplayName                : (UTC-04:00) Cuiaba
# StandardName               : Central Brazilian Standard Time
# DaylightName               : Central Brazilian Daylight Time
# BaseUtcOffset              : -04:00:00
# SupportsDaylightSavingTime : True

# Id                         : SA Western Standard Time
# DisplayName                : (UTC-04:00) Georgetown, La Paz, Manaus, San Juan
# StandardName               : SA Western Standard Time
# DaylightName               : SA Western Daylight Time
# BaseUtcOffset              : -04:00:00
# SupportsDaylightSavingTime : False

# Id                         : Pacific SA Standard Time
# DisplayName                : (UTC-04:00) Santiago
# StandardName               : Pacific SA Standard Time
# DaylightName               : Pacific SA Daylight Time
# BaseUtcOffset              : -04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Newfoundland Standard Time
# DisplayName                : (UTC-03:30) Newfoundland
# StandardName               : Newfoundland Standard Time
# DaylightName               : Newfoundland Daylight Time
# BaseUtcOffset              : -03:30:00
# SupportsDaylightSavingTime : True

# Id                         : Tocantins Standard Time
# DisplayName                : (UTC-03:00) Araguaina
# StandardName               : Tocantins Standard Time
# DaylightName               : Tocantins Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : E. South America Standard Time
# DisplayName                : (UTC-03:00) Brasilia
# StandardName               : E. South America Standard Time
# DaylightName               : E. South America Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : SA Eastern Standard Time
# DisplayName                : (UTC-03:00) Cayenne, Fortaleza
# StandardName               : SA Eastern Standard Time
# DaylightName               : SA Eastern Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : False

# Id                         : Argentina Standard Time
# DisplayName                : (UTC-03:00) City of Buenos Aires
# StandardName               : Argentina Standard Time
# DaylightName               : Argentina Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Montevideo Standard Time
# DisplayName                : (UTC-03:00) Montevideo
# StandardName               : Montevideo Standard Time
# DaylightName               : Montevideo Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Magallanes Standard Time
# DisplayName                : (UTC-03:00) Punta Arenas
# StandardName               : Magallanes Standard Time
# DaylightName               : Magallanes Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Saint Pierre Standard Time
# DisplayName                : (UTC-03:00) Saint Pierre and Miquelon
# StandardName               : Saint Pierre Standard Time
# DaylightName               : Saint Pierre Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Bahia Standard Time
# DisplayName                : (UTC-03:00) Salvador
# StandardName               : Bahia Standard Time
# DaylightName               : Bahia Daylight Time
# BaseUtcOffset              : -03:00:00
# SupportsDaylightSavingTime : True

# Id                         : UTC-02
# DisplayName                : (UTC-02:00) Coordinated Universal Time-02
# StandardName               : UTC-02
# DaylightName               : UTC-02
# BaseUtcOffset              : -02:00:00
# SupportsDaylightSavingTime : False

# Id                         : Greenland Standard Time
# DisplayName                : (UTC-02:00) Greenland
# StandardName               : Greenland Standard Time
# DaylightName               : Greenland Daylight Time
# BaseUtcOffset              : -02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Mid-Atlantic Standard Time
# DisplayName                : (UTC-02:00) Mid-Atlantic - Old
# StandardName               : Mid-Atlantic Standard Time
# DaylightName               : Mid-Atlantic Daylight Time
# BaseUtcOffset              : -02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Azores Standard Time
# DisplayName                : (UTC-01:00) Azores
# StandardName               : Azores Standard Time
# DaylightName               : Azores Daylight Time
# BaseUtcOffset              : -01:00:00
# SupportsDaylightSavingTime : True

# Id                         : Cape Verde Standard Time
# DisplayName                : (UTC-01:00) Cabo Verde Is.
# StandardName               : Cabo Verde Standard Time
# DaylightName               : Cabo Verde Daylight Time
# BaseUtcOffset              : -01:00:00
# SupportsDaylightSavingTime : False

# Id                         : UTC
# DisplayName                : (UTC) Coordinated Universal Time
# StandardName               : Coordinated Universal Time
# DaylightName               : Coordinated Universal Time
# BaseUtcOffset              : 00:00:00
# SupportsDaylightSavingTime : False

# Id                         : GMT Standard Time
# DisplayName                : (UTC+00:00) Dublin, Edinburgh, Lisbon, London
# StandardName               : GMT Standard Time
# DaylightName               : GMT Daylight Time
# BaseUtcOffset              : 00:00:00
# SupportsDaylightSavingTime : True

# Id                         : Greenwich Standard Time
# DisplayName                : (UTC+00:00) Monrovia, Reykjavik
# StandardName               : Greenwich Standard Time
# DaylightName               : Greenwich Daylight Time
# BaseUtcOffset              : 00:00:00
# SupportsDaylightSavingTime : False

# Id                         : Sao Tome Standard Time
# DisplayName                : (UTC+00:00) Sao Tome
# StandardName               : Sao Tome Standard Time
# DaylightName               : Sao Tome Daylight Time
# BaseUtcOffset              : 00:00:00
# SupportsDaylightSavingTime : True

# Id                         : Morocco Standard Time
# DisplayName                : (UTC+01:00) Casablanca
# StandardName               : Morocco Standard Time
# DaylightName               : Morocco Daylight Time
# BaseUtcOffset              : 00:00:00
# SupportsDaylightSavingTime : True

# Id                         : W. Europe Standard Time
# DisplayName                : (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
# StandardName               : W. Europe Standard Time
# DaylightName               : W. Europe Daylight Time
# BaseUtcOffset              : 01:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central Europe Standard Time
# DisplayName                : (UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
# StandardName               : Central Europe Standard Time
# DaylightName               : Central Europe Daylight Time
# BaseUtcOffset              : 01:00:00
# SupportsDaylightSavingTime : True

# Id                         : Romance Standard Time
# DisplayName                : (UTC+01:00) Brussels, Copenhagen, Madrid, Paris
# StandardName               : Romance Standard Time
# DaylightName               : Romance Daylight Time
# BaseUtcOffset              : 01:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central European Standard Time
# DisplayName                : (UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb
# StandardName               : Central European Standard Time
# DaylightName               : Central European Daylight Time
# BaseUtcOffset              : 01:00:00
# SupportsDaylightSavingTime : True

# Id                         : W. Central Africa Standard Time
# DisplayName                : (UTC+01:00) West Central Africa
# StandardName               : W. Central Africa Standard Time
# DaylightName               : W. Central Africa Daylight Time
# BaseUtcOffset              : 01:00:00
# SupportsDaylightSavingTime : False

# Id                         : GTB Standard Time
# DisplayName                : (UTC+02:00) Athens, Bucharest
# StandardName               : GTB Standard Time
# DaylightName               : GTB Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Middle East Standard Time
# DisplayName                : (UTC+02:00) Beirut
# StandardName               : Middle East Standard Time
# DaylightName               : Middle East Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Egypt Standard Time
# DisplayName                : (UTC+02:00) Cairo
# StandardName               : Egypt Standard Time
# DaylightName               : Egypt Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : E. Europe Standard Time
# DisplayName                : (UTC+02:00) Chisinau
# StandardName               : E. Europe Standard Time
# DaylightName               : E. Europe Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : West Bank Standard Time
# DisplayName                : (UTC+02:00) Gaza, Hebron
# StandardName               : West Bank Gaza Standard Time
# DaylightName               : West Bank Gaza Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : South Africa Standard Time
# DisplayName                : (UTC+02:00) Harare, Pretoria
# StandardName               : South Africa Standard Time
# DaylightName               : South Africa Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : False

# Id                         : FLE Standard Time
# DisplayName                : (UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius
# StandardName               : FLE Standard Time
# DaylightName               : FLE Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Israel Standard Time
# DisplayName                : (UTC+02:00) Jerusalem
# StandardName               : Jerusalem Standard Time
# DaylightName               : Jerusalem Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : South Sudan Standard Time
# DisplayName                : (UTC+02:00) Juba
# StandardName               : South Sudan Standard Time
# DaylightName               : South Sudan Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Kaliningrad Standard Time
# DisplayName                : (UTC+02:00) Kaliningrad
# StandardName               : Russia TZ 1 Standard Time
# DaylightName               : Russia TZ 1 Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Sudan Standard Time
# DisplayName                : (UTC+02:00) Khartoum
# StandardName               : Sudan Standard Time
# DaylightName               : Sudan Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Libya Standard Time
# DisplayName                : (UTC+02:00) Tripoli
# StandardName               : Libya Standard Time
# DaylightName               : Libya Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Namibia Standard Time
# DisplayName                : (UTC+02:00) Windhoek
# StandardName               : Namibia Standard Time
# DaylightName               : Namibia Daylight Time
# BaseUtcOffset              : 02:00:00
# SupportsDaylightSavingTime : True

# Id                         : Jordan Standard Time
# DisplayName                : (UTC+03:00) Amman
# StandardName               : Jordan Standard Time
# DaylightName               : Jordan Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Arabic Standard Time
# DisplayName                : (UTC+03:00) Baghdad
# StandardName               : Arabic Standard Time
# DaylightName               : Arabic Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Syria Standard Time
# DisplayName                : (UTC+03:00) Damascus
# StandardName               : Syria Standard Time
# DaylightName               : Syria Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Turkey Standard Time
# DisplayName                : (UTC+03:00) Istanbul
# StandardName               : Turkey Standard Time
# DaylightName               : Turkey Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Arab Standard Time
# DisplayName                : (UTC+03:00) Kuwait, Riyadh
# StandardName               : Arab Standard Time
# DaylightName               : Arab Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : False

# Id                         : Belarus Standard Time
# DisplayName                : (UTC+03:00) Minsk
# StandardName               : Belarus Standard Time
# DaylightName               : Belarus Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Russian Standard Time
# DisplayName                : (UTC+03:00) Moscow, St. Petersburg
# StandardName               : Russia TZ 2 Standard Time
# DaylightName               : Russia TZ 2 Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : E. Africa Standard Time
# DisplayName                : (UTC+03:00) Nairobi
# StandardName               : E. Africa Standard Time
# DaylightName               : E. Africa Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : False

# Id                         : Volgograd Standard Time
# DisplayName                : (UTC+03:00) Volgograd
# StandardName               : Volgograd Standard Time
# DaylightName               : Volgograd Daylight Time
# BaseUtcOffset              : 03:00:00
# SupportsDaylightSavingTime : True

# Id                         : Iran Standard Time
# DisplayName                : (UTC+03:30) Tehran
# StandardName               : Iran Standard Time
# DaylightName               : Iran Daylight Time
# BaseUtcOffset              : 03:30:00
# SupportsDaylightSavingTime : True

# Id                         : Arabian Standard Time
# DisplayName                : (UTC+04:00) Abu Dhabi, Muscat
# StandardName               : Arabian Standard Time
# DaylightName               : Arabian Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : False

# Id                         : Astrakhan Standard Time
# DisplayName                : (UTC+04:00) Astrakhan, Ulyanovsk
# StandardName               : Astrakhan Standard Time
# DaylightName               : Astrakhan Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Azerbaijan Standard Time
# DisplayName                : (UTC+04:00) Baku
# StandardName               : Azerbaijan Standard Time
# DaylightName               : Azerbaijan Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Russia Time Zone 3
# DisplayName                : (UTC+04:00) Izhevsk, Samara
# StandardName               : Russia TZ 3 Standard Time
# DaylightName               : Russia TZ 3 Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Mauritius Standard Time
# DisplayName                : (UTC+04:00) Port Louis
# StandardName               : Mauritius Standard Time
# DaylightName               : Mauritius Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Saratov Standard Time
# DisplayName                : (UTC+04:00) Saratov
# StandardName               : Saratov Standard Time
# DaylightName               : Saratov Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Georgian Standard Time
# DisplayName                : (UTC+04:00) Tbilisi
# StandardName               : Georgian Standard Time
# DaylightName               : Georgian Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : False

# Id                         : Caucasus Standard Time
# DisplayName                : (UTC+04:00) Yerevan
# StandardName               : Caucasus Standard Time
# DaylightName               : Caucasus Daylight Time
# BaseUtcOffset              : 04:00:00
# SupportsDaylightSavingTime : True

# Id                         : Afghanistan Standard Time
# DisplayName                : (UTC+04:30) Kabul
# StandardName               : Afghanistan Standard Time
# DaylightName               : Afghanistan Daylight Time
# BaseUtcOffset              : 04:30:00
# SupportsDaylightSavingTime : False

# Id                         : West Asia Standard Time
# DisplayName                : (UTC+05:00) Ashgabat, Tashkent
# StandardName               : West Asia Standard Time
# DaylightName               : West Asia Daylight Time
# BaseUtcOffset              : 05:00:00
# SupportsDaylightSavingTime : False

# Id                         : Ekaterinburg Standard Time
# DisplayName                : (UTC+05:00) Ekaterinburg
# StandardName               : Russia TZ 4 Standard Time
# DaylightName               : Russia TZ 4 Daylight Time
# BaseUtcOffset              : 05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Pakistan Standard Time
# DisplayName                : (UTC+05:00) Islamabad, Karachi
# StandardName               : Pakistan Standard Time
# DaylightName               : Pakistan Daylight Time
# BaseUtcOffset              : 05:00:00
# SupportsDaylightSavingTime : True

# Id                         : Qyzylorda Standard Time
# DisplayName                : (UTC+05:00) Qyzylorda
# StandardName               : Qyzylorda Standard Time
# DaylightName               : Qyzylorda Daylight Time
# BaseUtcOffset              : 05:00:00
# SupportsDaylightSavingTime : True

# Id                         : India Standard Time
# DisplayName                : (UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi
# StandardName               : India Standard Time
# DaylightName               : India Daylight Time
# BaseUtcOffset              : 05:30:00
# SupportsDaylightSavingTime : False

# Id                         : Sri Lanka Standard Time
# DisplayName                : (UTC+05:30) Sri Jayawardenepura
# StandardName               : Sri Lanka Standard Time
# DaylightName               : Sri Lanka Daylight Time
# BaseUtcOffset              : 05:30:00
# SupportsDaylightSavingTime : False

# Id                         : Nepal Standard Time
# DisplayName                : (UTC+05:45) Kathmandu
# StandardName               : Nepal Standard Time
# DaylightName               : Nepal Daylight Time
# BaseUtcOffset              : 05:45:00
# SupportsDaylightSavingTime : False

# Id                         : Bangladesh Standard Time
# DisplayName                : (UTC+06:00) Dhaka
# StandardName               : Bangladesh Standard Time
# DaylightName               : Bangladesh Daylight Time
# BaseUtcOffset              : 06:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central Asia Standard Time
# DisplayName                : (UTC+06:00) Nur-Sultan
# StandardName               : Central Asia Standard Time
# DaylightName               : Central Asia Daylight Time
# BaseUtcOffset              : 06:00:00
# SupportsDaylightSavingTime : False

# Id                         : Omsk Standard Time
# DisplayName                : (UTC+06:00) Omsk
# StandardName               : Omsk Standard Time
# DaylightName               : Omsk Daylight Time
# BaseUtcOffset              : 06:00:00
# SupportsDaylightSavingTime : True

# Id                         : Myanmar Standard Time
# DisplayName                : (UTC+06:30) Yangon (Rangoon)
# StandardName               : Myanmar Standard Time
# DaylightName               : Myanmar Daylight Time
# BaseUtcOffset              : 06:30:00
# SupportsDaylightSavingTime : False

# Id                         : SE Asia Standard Time
# DisplayName                : (UTC+07:00) Bangkok, Hanoi, Jakarta
# StandardName               : SE Asia Standard Time
# DaylightName               : SE Asia Daylight Time
# BaseUtcOffset              : 07:00:00
# SupportsDaylightSavingTime : False

# Id                         : Altai Standard Time
# DisplayName                : (UTC+07:00) Barnaul, Gorno-Altaysk
# StandardName               : Altai Standard Time
# DaylightName               : Altai Daylight Time
# BaseUtcOffset              : 07:00:00
# SupportsDaylightSavingTime : True

# Id                         : W. Mongolia Standard Time
# DisplayName                : (UTC+07:00) Hovd
# StandardName               : W. Mongolia Standard Time
# DaylightName               : W. Mongolia Daylight Time
# BaseUtcOffset              : 07:00:00
# SupportsDaylightSavingTime : True

# Id                         : North Asia Standard Time
# DisplayName                : (UTC+07:00) Krasnoyarsk
# StandardName               : Russia TZ 6 Standard Time
# DaylightName               : Russia TZ 6 Daylight Time
# BaseUtcOffset              : 07:00:00
# SupportsDaylightSavingTime : True

# Id                         : N. Central Asia Standard Time
# DisplayName                : (UTC+07:00) Novosibirsk
# StandardName               : Novosibirsk Standard Time
# DaylightName               : Novosibirsk Daylight Time
# BaseUtcOffset              : 07:00:00
# SupportsDaylightSavingTime : True

# Id                         : Tomsk Standard Time
# DisplayName                : (UTC+07:00) Tomsk
# StandardName               : Tomsk Standard Time
# DaylightName               : Tomsk Daylight Time
# BaseUtcOffset              : 07:00:00
# SupportsDaylightSavingTime : True

# Id                         : China Standard Time
# DisplayName                : (UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi
# StandardName               : China Standard Time
# DaylightName               : China Daylight Time
# BaseUtcOffset              : 08:00:00
# SupportsDaylightSavingTime : False

# Id                         : North Asia East Standard Time
# DisplayName                : (UTC+08:00) Irkutsk
# StandardName               : Russia TZ 7 Standard Time
# DaylightName               : Russia TZ 7 Daylight Time
# BaseUtcOffset              : 08:00:00
# SupportsDaylightSavingTime : True

# Id                         : Singapore Standard Time
# DisplayName                : (UTC+08:00) Kuala Lumpur, Singapore
# StandardName               : Malay Peninsula Standard Time
# DaylightName               : Malay Peninsula Daylight Time
# BaseUtcOffset              : 08:00:00
# SupportsDaylightSavingTime : False

# Id                         : W. Australia Standard Time
# DisplayName                : (UTC+08:00) Perth
# StandardName               : W. Australia Standard Time
# DaylightName               : W. Australia Daylight Time
# BaseUtcOffset              : 08:00:00
# SupportsDaylightSavingTime : True

# Id                         : Taipei Standard Time
# DisplayName                : (UTC+08:00) Taipei
# StandardName               : Taipei Standard Time
# DaylightName               : Taipei Daylight Time
# BaseUtcOffset              : 08:00:00
# SupportsDaylightSavingTime : False

# Id                         : Ulaanbaatar Standard Time
# DisplayName                : (UTC+08:00) Ulaanbaatar
# StandardName               : Ulaanbaatar Standard Time
# DaylightName               : Ulaanbaatar Daylight Time
# BaseUtcOffset              : 08:00:00
# SupportsDaylightSavingTime : True

# Id                         : Aus Central W. Standard Time
# DisplayName                : (UTC+08:45) Eucla
# StandardName               : Aus Central W. Standard Time
# DaylightName               : Aus Central W. Daylight Time
# BaseUtcOffset              : 08:45:00
# SupportsDaylightSavingTime : False

# Id                         : Transbaikal Standard Time
# DisplayName                : (UTC+09:00) Chita
# StandardName               : Transbaikal Standard Time
# DaylightName               : Transbaikal Daylight Time
# BaseUtcOffset              : 09:00:00
# SupportsDaylightSavingTime : True

# Id                         : Tokyo Standard Time
# DisplayName                : (UTC+09:00) Osaka, Sapporo, Tokyo
# StandardName               : Tokyo Standard Time
# DaylightName               : Tokyo Daylight Time
# BaseUtcOffset              : 09:00:00
# SupportsDaylightSavingTime : False

# Id                         : North Korea Standard Time
# DisplayName                : (UTC+09:00) Pyongyang
# StandardName               : North Korea Standard Time
# DaylightName               : North Korea Daylight Time
# BaseUtcOffset              : 09:00:00
# SupportsDaylightSavingTime : True

# Id                         : Korea Standard Time
# DisplayName                : (UTC+09:00) Seoul
# StandardName               : Korea Standard Time
# DaylightName               : Korea Daylight Time
# BaseUtcOffset              : 09:00:00
# SupportsDaylightSavingTime : False

# Id                         : Yakutsk Standard Time
# DisplayName                : (UTC+09:00) Yakutsk
# StandardName               : Russia TZ 8 Standard Time
# DaylightName               : Russia TZ 8 Daylight Time
# BaseUtcOffset              : 09:00:00
# SupportsDaylightSavingTime : True

# Id                         : Cen. Australia Standard Time
# DisplayName                : (UTC+09:30) Adelaide
# StandardName               : Cen. Australia Standard Time
# DaylightName               : Cen. Australia Daylight Time
# BaseUtcOffset              : 09:30:00
# SupportsDaylightSavingTime : True

# Id                         : AUS Central Standard Time
# DisplayName                : (UTC+09:30) Darwin
# StandardName               : AUS Central Standard Time
# DaylightName               : AUS Central Daylight Time
# BaseUtcOffset              : 09:30:00
# SupportsDaylightSavingTime : False

# Id                         : E. Australia Standard Time
# DisplayName                : (UTC+10:00) Brisbane
# StandardName               : E. Australia Standard Time
# DaylightName               : E. Australia Daylight Time
# BaseUtcOffset              : 10:00:00
# SupportsDaylightSavingTime : False

# Id                         : AUS Eastern Standard Time
# DisplayName                : (UTC+10:00) Canberra, Melbourne, Sydney
# StandardName               : AUS Eastern Standard Time
# DaylightName               : AUS Eastern Daylight Time
# BaseUtcOffset              : 10:00:00
# SupportsDaylightSavingTime : True

# Id                         : West Pacific Standard Time
# DisplayName                : (UTC+10:00) Guam, Port Moresby
# StandardName               : West Pacific Standard Time
# DaylightName               : West Pacific Daylight Time
# BaseUtcOffset              : 10:00:00
# SupportsDaylightSavingTime : False

# Id                         : Tasmania Standard Time
# DisplayName                : (UTC+10:00) Hobart
# StandardName               : Tasmania Standard Time
# DaylightName               : Tasmania Daylight Time
# BaseUtcOffset              : 10:00:00
# SupportsDaylightSavingTime : True

# Id                         : Vladivostok Standard Time
# DisplayName                : (UTC+10:00) Vladivostok
# StandardName               : Russia TZ 9 Standard Time
# DaylightName               : Russia TZ 9 Daylight Time
# BaseUtcOffset              : 10:00:00
# SupportsDaylightSavingTime : True

# Id                         : Lord Howe Standard Time
# DisplayName                : (UTC+10:30) Lord Howe Island
# StandardName               : Lord Howe Standard Time
# DaylightName               : Lord Howe Daylight Time
# BaseUtcOffset              : 10:30:00
# SupportsDaylightSavingTime : True

# Id                         : Bougainville Standard Time
# DisplayName                : (UTC+11:00) Bougainville Island
# StandardName               : Bougainville Standard Time
# DaylightName               : Bougainville Daylight Time
# BaseUtcOffset              : 11:00:00
# SupportsDaylightSavingTime : True

# Id                         : Russia Time Zone 10
# DisplayName                : (UTC+11:00) Chokurdakh
# StandardName               : Russia TZ 10 Standard Time
# DaylightName               : Russia TZ 10 Daylight Time
# BaseUtcOffset              : 11:00:00
# SupportsDaylightSavingTime : True

# Id                         : Magadan Standard Time
# DisplayName                : (UTC+11:00) Magadan
# StandardName               : Magadan Standard Time
# DaylightName               : Magadan Daylight Time
# BaseUtcOffset              : 11:00:00
# SupportsDaylightSavingTime : True

# Id                         : Norfolk Standard Time
# DisplayName                : (UTC+11:00) Norfolk Island
# StandardName               : Norfolk Standard Time
# DaylightName               : Norfolk Daylight Time
# BaseUtcOffset              : 11:00:00
# SupportsDaylightSavingTime : True

# Id                         : Sakhalin Standard Time
# DisplayName                : (UTC+11:00) Sakhalin
# StandardName               : Sakhalin Standard Time
# DaylightName               : Sakhalin Daylight Time
# BaseUtcOffset              : 11:00:00
# SupportsDaylightSavingTime : True

# Id                         : Central Pacific Standard Time
# DisplayName                : (UTC+11:00) Solomon Is., New Caledonia
# StandardName               : Central Pacific Standard Time
# DaylightName               : Central Pacific Daylight Time
# BaseUtcOffset              : 11:00:00
# SupportsDaylightSavingTime : False

# Id                         : Russia Time Zone 11
# DisplayName                : (UTC+12:00) Anadyr, Petropavlovsk-Kamchatsky
# StandardName               : Russia TZ 11 Standard Time
# DaylightName               : Russia TZ 11 Daylight Time
# BaseUtcOffset              : 12:00:00
# SupportsDaylightSavingTime : True

# Id                         : New Zealand Standard Time
# DisplayName                : (UTC+12:00) Auckland, Wellington
# StandardName               : New Zealand Standard Time
# DaylightName               : New Zealand Daylight Time
# BaseUtcOffset              : 12:00:00
# SupportsDaylightSavingTime : True

# Id                         : UTC+12
# DisplayName                : (UTC+12:00) Coordinated Universal Time+12
# StandardName               : UTC+12
# DaylightName               : UTC+12
# BaseUtcOffset              : 12:00:00
# SupportsDaylightSavingTime : False

# Id                         : Fiji Standard Time
# DisplayName                : (UTC+12:00) Fiji
# StandardName               : Fiji Standard Time
# DaylightName               : Fiji Daylight Time
# BaseUtcOffset              : 12:00:00
# SupportsDaylightSavingTime : True

# Id                         : Kamchatka Standard Time
# DisplayName                : (UTC+12:00) Petropavlovsk-Kamchatsky - Old
# StandardName               : Kamchatka Standard Time
# DaylightName               : Kamchatka Daylight Time
# BaseUtcOffset              : 12:00:00
# SupportsDaylightSavingTime : True

# Id                         : Chatham Islands Standard Time
# DisplayName                : (UTC+12:45) Chatham Islands
# StandardName               : Chatham Islands Standard Time
# DaylightName               : Chatham Islands Daylight Time
# BaseUtcOffset              : 12:45:00
# SupportsDaylightSavingTime : True

# Id                         : UTC+13
# DisplayName                : (UTC+13:00) Coordinated Universal Time+13
# StandardName               : UTC+13
# DaylightName               : UTC+13
# BaseUtcOffset              : 13:00:00
# SupportsDaylightSavingTime : False

# Id                         : Tonga Standard Time
# DisplayName                : (UTC+13:00) Nuku'alofa
# StandardName               : Tonga Standard Time
# DaylightName               : Tonga Daylight Time
# BaseUtcOffset              : 13:00:00
# SupportsDaylightSavingTime : True

# Id                         : Samoa Standard Time
# DisplayName                : (UTC+13:00) Samoa
# StandardName               : Samoa Standard Time
# DaylightName               : Samoa Daylight Time
# BaseUtcOffset              : 13:00:00
# SupportsDaylightSavingTime : True

# Id                         : Line Islands Standard Time
# DisplayName                : (UTC+14:00) Kiritimati Island
# StandardName               : Line Islands Standard Time
# DaylightName               : Line Islands Daylight Time
# BaseUtcOffset              : 14:00:00
# SupportsDaylightSavingTime : False
