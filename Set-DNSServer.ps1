$Servers = @{
    DNS1 = '192.168.1.252'
    DNS2 = '192.168.1.1'
}
$DHCPDNS = '192.168.1.1'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'set-dns.log'
If (Test-Path $LogFolder) {
    Write-Output "Writing entries to $LogFile."
}
else {
    Write-Output "Created the folder $LogFolder to store logs.  Logs will be stored in $LogFolder\$LogFile."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFile."
}
Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder$LogFile"

try {
    Write-Output 'Checking to see which network adapters have a DNS assigned to them'
    $dnsclient = Get-DnsClient  | Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses -contains $DHCPDNS } 
    Write-Output 'Setting DNS servers on all connected network adapters'
    foreach ($nic in $dnsclient) {
        #Set the DNS servers to the hashtable in $servers 
        Write-Output "Setting DNS servers on $($nic.InterfaceAlias) adapter with index $($nic.InterfaceIndex) to $($Servers.Values -join ', ')"
        Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses $Servers.Values -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Output "An error occurred while setting the DNS servers.  The error was $($_.Exception.Message)"
}
Stop-Transcript