Param(
    [Parameter(Mandatory = $false)]
    [string]$TenantID,
    [Parameter(Mandatory = $false)]
    [string]$thumbprint,
    [Parameter(Mandatory = $false)]
    [string]$ClientID,
    [Parameter(Mandatory = $false)]
    [string]$ClientSecret,
    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

$configFile = '.\.secrets\config.json'
$Configs = Get-Content -Raw -Path $configFile | ConvertFrom-Json
if (-not $TenantID)
{
    $TenantID = $Configs.TenantID 
}
if (-not $ClientID)
{
    $ClientID = $Configs.ClientID 
}
if (-not $ClientSecret)
{
    $ClientSecret = $Configs.ClientSecret 
}
if (-not $thumbprint)
{
    $thumbprint = $Configs.thumbprint 
}

# Stop on any error
$ErrorActionPreference = 'Stop'

try
{
    #Authenticate to MGGraph
    Connect-MgGraph -TenantId $tenantID -ClientId $clientID -CertificateThumbprint $thumbprint -NoWelcome
    Write-Output 'Connected to Microsoft Graph'
}
catch
{
    Write-Output 'Error connecting to Microsoft Graph'
    Write-Output $_.Exception.Message
    exit
}
Write-Output "Retrieving properties for group $GroupName"
$group = Get-MgGroup -Filter "displayName eq '$GroupName'"

if (-not $group)
{
    Write-Host "Group '$($groupName)' not found."
    return
}
# Write-Host "Found group: $($group.DisplayName) with Id: $($group.Id)"

#Read all device configurations into a variable.
$deviceConfigurations = Get-MgDeviceManagementDeviceConfiguration
foreach ($deviceConfiguration in $deviceConfigurations)
{
    Write-Output "Retrieving assignments for$($deviceConfiguration.DisplayName)"
    $assignments = Get-MgDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $deviceConfiguration.Id -All
    Write-Output "Number of targets is $($assignments.Target.Count)"
    if ($assignments.Target.Count -gt 0)
    {
        Write-Output "Targets are $($assignments.Target)"
    }
    if ($assignments.AdditionalProperties.Count -gt 0)
    {
        Write-Output "Additional propperties are $($assignments.AdditionalProperties)"
    }



    Write-Output "Assignment ID is $($assignments.Id)"
    Write-Output "Assignment keys $($assignments.AdditionalProperties.Keys)"
    Write-Output "Values are $($assignments.AdditionalProperties.Values)"
    foreach ($assignment in $assignments)
    {
        if ($assignment.Target.Id -eq $group.Id)
        {
            Write-Host "Device Configuration $($deviceConfiguration.DisplayName) is assigned to group $($group.DisplayName)"
        }
    }
}
