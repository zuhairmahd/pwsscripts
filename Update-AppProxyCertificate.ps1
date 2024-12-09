

#Read configurations from a json file.
$PfxFilePath = '.\arabictutor.pfx'
$configFile = '.\.secrets\internalConfig.json'
$Config = Get-Content -Raw -Path $configFile | ConvertFrom-Json
# Extract the variables
$clientID = $Config.clientId
$tenantID = $Config.tenantId
$thumbprint = $Config.thumbprint
$appId = $config.appId
$PfxPassword = $config.PFXPassword

Connect-MgGraph -TenantId $tenantID -ClientId $clientID -CertificateThumbprint $thumbprint -NoWelcome
Write-Output 'Connected to Microsoft Graph'

$params = @{
    onPremisesPublishing = @{
        verifiedCustomDomainKeyCredential      = @{
            type  = 'X509CertAndPassword'
            value = [convert]::ToBase64String((Get-Content -Path $PfxFilePath -AsByteStream))
        }
        verifiedCustomDomainPasswordCredential = @{ value = $PfxPassword }
    }
}

try {
    Update-MgBetaApplication -ApplicationId $appId -BodyParameter $params
    Write-Output 'Updated the SSL certificate for the application'
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Output $_.Exception.Message
}
