# Enable the This PC, Documents and Network  icons on the desktop in Windows 10
$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$ThisPC = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$MyDocuments = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
$MyNetworks = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
$KeyFormat = "dword"
$turnedOn = "0"
$turnedOffff = "1"
#enable "This PC"
if(!(Test-Path $Path)) {New-Item -Path $Path -Force}
if(!$ThisPC){Set-Item -Path $Path -Value $turnedOn
}else{Set-ItemProperty -Path $Path -Name $ThisPC -Value $turnedOn -Type $KeyFormat -Force}

#Enable "My Documents"
if(!(Test-Path $Path)) {New-Item -Path $Path -Force}
if(!$MyDocuments){Set-Item -Path $Path -Value $turnedOn
}else{Set-ItemProperty -Path $Path -Name $MyDocuments -Value $turnedOn -Type $KeyFormat -Force}

#Enable "My Networks"
if(!(Test-Path $Path)) {New-Item -Path $Path -Force}
if(!$MyNetworks){Set-Item -Path $Path -Value $turnedOffff
}else{Set-ItemProperty -Path $Path -Name $MyNetworks -Value $turnedOffff -Type $KeyFormat -Force}

