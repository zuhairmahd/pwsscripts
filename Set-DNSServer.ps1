$dnsclient = Get-DnsClient  | Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses -contains '192.168.1.1' }
foreach ($nic in $dnsclient) {
    Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses ('192.168.1.252', '192.168.1.1')
}

