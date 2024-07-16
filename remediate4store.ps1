#define variables
$path = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$key = "RequirePrivateStoreOnly"
$KeyFormat = "dword"
$value = 1

try {
    if(!(Test-Path $Path)) {New-Item -Path $Path -Force -ErrorAction SilentlyContinue}
    if(!$key){Set-Item -Path $Path -Value $value -ErrorAction SilentlyContinue
    }else{Set-ItemProperty -Path $Path -Name $key -Value $value -Type $KeyFormat -Force -ErrorAction SilentlyContinue}
    exit 0
}

catch {
    exit 1
}
