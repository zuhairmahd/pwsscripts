# Read configuration from a JSON file containing the tenant id, client id, and client secret.

$configFile = '.\.secrets\config.json'
$Config = Get-Content -Raw -Path $configFile | ConvertFrom-Json

# Extract the variables
$clientID = $Config.clientId
$tenantID = $Config.tenantId
$clientSecret = $Config.clientSecret
$thumbprint = $Config.thumbprint
#Add the client id and secret into a credentials variable.
# $credentials = New-Object System.Management.Automation.PSCredential ($clientID, (ConvertTo-SecureString $clientSecret -AsPlainText -Force))

#Authenticate using the credentials above
try {
    # Connect-MgGraph -TenantId $tenantID -ClientId $clientID -ClientSecret $clientSecret -NoWelcome
    Connect-MgGraph -TenantId $tenantID -ClientId $clientID -CertificateThumbprint $thumbprint -NoWelcome
    Write-Output 'Successfully connected to Microsoft Graph API'
}
catch {
    Write-Host "Error connecting to Microsoft Graph API: $_"
}


