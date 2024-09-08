$DNSServers = @{
    DNS1 = '192.168.1.252'
    DNS2 = '192.168.1.1'
    DNS3 = '192.168.1.226'
    DNS4 = '192.168.1.213'
}
$DHCPAddress = '192.168.1.1'
$LogFolder = 'C:\ProgramData\PWSLogs'
$LogFile = 'DNS.log'
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists.  Creating/appending to $LogFile."
}
else {
    Write-Output "The folder $LogFolder doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path $LogFolder -ItemType Directory | Out-Null
    Write-Output "The folder $LogFolder was successfully created. Files will be written to $LogFile."
}
Start-Transcript -Append -IncludeInvocationHeader -Path "$LogFolder$LogFile"
#Check to see if the DHCPDns server is in the dnsservers table
$dnsclient = Get-DnsClient  | Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses -contains $DNSServers.DNS1 }
if ($DNSServers.Values -contains $dnsclient) {
    Write-Output "The DHCP server address $DHCPAddress is in the DNS servers table. This is not allowed. Exiting script."
    Stop-Transcript
    Exit
}
else {
    Write-Output "The DHCP server address $DHCPAddress is not in the DNS servers table. Continuing script."
}


#Check to see if the DNS servers we want have already been assigned
$DNSAddress1 = $DNSServers.DNS1
$dnsclient = Get-DnsClient  | Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses -contains $DNSAddress1 }
Write-Output $dnsclient
if ($null -eq $dnsclient) {
    Write-Output "The DNS servers have not been set to the desired values. Setting DNS servers to $DNSAddress1, $DNSAddress2, $DNSAddress3, and $DNSAddress4."
    $dnsclient = Get-DnsClient  | Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses -contains $DHCPAddress }
    foreach ($nic in $dnsclient) {
        # Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses ($DNSAddress1, $DNSAddress2, $DNSAddress3, $DNSAddress4) -Verbose
        Write-Output "DNS servers have been set on $nic"
    }
    Write-Output 'DNS servers have been set to the desired values.'
}
else {
    Write-Output 'The DNS servers have already been set to the desired values. Exiting script.'
}
Stop-Transcript