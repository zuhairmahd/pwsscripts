#A script to take a file from the commandline and sign it.
#Usage: sign-script.ps1 <file>
#Example: sign-script.ps1 c:\temp\test.ps1

param(
    [string]$file
)
#how long to wait for a response from a timestamp server
$timeout = 1000
#The algorithm to use for signatures
$alg = 'SHA256'
#A list of valid time stamp servers
$TimeStampServers = @(
    'http://timestamp.comodoca.com',
    'http://timestamp.verisign.com/scripts/timstamp.dll',
    'http://timestamp.digicert.com',
    'http://timestamp.globalsign.com/tsa/r6advanced1',
    'http://rfc3161timestamp.globalsign.com/advanced',
    'http://timestamp.sectigo.com',
    'http://timestamp.apple.com/ts01',
    'http://tsa.mesign.com',
    'http://time.certum.pl',
    'https://freetsa.org',
    'http://tsa.startssl.com/rfc3161',
    'http://dse200.ncipher.com/TSS/HttpTspServer',
    'http://zeitstempel.dfn.de',
    'https://ca.signfiles.com/tsa/get.aspx',
    'http://services.globaltrustfinder.com/adss/tsa',
    'https://tsp.iaik.tugraz.at/tsp/TspRequest',
    'http://timestamp.entrust.net/TSS/RFC3161sha2TS',
    'http://timestamp.acs.microsoft.com'
)

#If no file provided, prompt the user.
if (-not $file) {
    $file = Read-Host -Prompt 'Enter the path of the file to sign'
}
#If the file doesn't exist, exit.
if (-not (Test-Path $file)) {
    Write-Output "File $file not found. Exiting."
    exit
}
Write-Output "Looking for a valid certificate to sign the file $file"
$certs = Get-ChildItem cert: -Recurse -CodeSigningCert | Where-Object { $_.NotAfter -gt (Get-Date) }
$invalidCerts = Get-ChildItem cert: -Recurse -CodeSigningCert | Where-Object { $_.NotAfter -lt (Get-Date) }
if (($null -eq $invalidCerts) -and ($null -eq $certs)) {
    Write-Output 'No code signing certificates found.'
    exit
}
elseif (($null -ne $invalidCerts) -and ($null -eq $certs)) {
    Write-Output 'You have no valid code signing certificates, but you have the following expired certificates.'
    #show the expired certificates 
    for ($i = 0; $i -lt $invalidCerts.Count; $i++) {
        Write-Output "$($invalidCerts[$i].Subject) - Issuer: $($invalidCerts[$i].Issuer) - Valid from: $($invalidCerts[$i].NotBefore) Valid to: $($invalidCerts[$i].NotAfter)"
    }
    Write-Output 'Please renew your certificates and try again.'
    exit 1
}
elseif (($null -ne $invalidCerts) -and ($null -ne $certs)) {
    Write-Output 'Certificates found, and you also have expired certificates (this is only informational)'
    for ($i = 0; $i -lt $invalidCerts.Count; $i++) {
        Write-Output "$($invalidCerts[$i].Subject) - Issuer: $($invalidCerts[$i].Issuer) - Valid from: $($invalidCerts[$i].NotBefore) Valid to: $($invalidCerts[$i].NotAfter)"
    }
}
# Present the user with a list of certificates to choose from
Write-Output '-------------------------------'
Write-Output "The following is a list of valid code signing certificates you can choose from. Please choose the certificate you would like to use to sign the file $file"
do {
    for ($i = 0; $i -lt $certs.Count; $i++) {
        Write-Output "${i}: $($certs[$i].Subject) - Issuer: $($certs[$i].Issuer) - Valid from: $($certs[$i].NotBefore) Valid to: $($certs[$i].NotAfter)"
    }

    $selection = Read-Host 'Enter the number of the certificate you want to use (or type Q to quit)'
    
    if ($selection -eq 'Q') {
        Write-Output 'Exiting.'
        exit
    }
    
    if ($selection -match '^\d+$' -and $selection -ge 0 -and $selection -lt $certs.Count) {
        $cert = $certs[$selection]
        Write-Output "Using certificate $($cert.Subject)"
        break
    }
    else {
        Write-Output 'Invalid selection. Please try again.'
    }
} while ($true)
try {
    Write-Output 'Finding a functioning timestamp server'
    foreach ($TimeStampServer in $TimeStampServers) {
        #Check to see if the server is up.
        Write-Output "Checking $TimeStampServer"
        $request = [System.Net.WebRequest]::Create($TimeStampServer)
        $request.Timeout = $timeout
        try {
            $response = $request.GetResponse()
            $response.Close()
            Write-Host "Timestamp server $TimeStampServer is up. Continuing."
            $server = $TimeStampServer
            break
        }
        catch {
            Write-Host "Timestamp server $TimeStampServer is down. Trying the next one"
        }
    }
    #If no valid timestamp server found, exit.
    if ($null -eq $server) {
        Write-Output 'No timestamp server found. Exiting.'
        exit 2
    }
    Write-Output "Signing file $file using certificate $($cert.Subject) using timestamp server $server"
    Set-AuthenticodeSignature -Certificate $cert -FilePath $file -TimestampServer $server -IncludeChain All -HashAlgorithm $alg
}
catch {
    Write-Output "Error signing file $file"
    Write-Output $_.Exception.Message
    exit 1
}

