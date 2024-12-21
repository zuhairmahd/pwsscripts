Param(
    [Parameter(Mandatory = $false)]
    [string]$TenantID,
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
$thumbPrint = $Configs.thumbprint

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
Write-Host "Found group: $($group.DisplayName) with Id: $($group.Id)"

try
{
    # Get Device Configuration Profiles assigned to the group
    Write-Host 'Device Configuration Profiles:'
    $deviceConfigurationAssignments = Get-MgGroupDeviceConfigurationAssignment -GroupId $GroupId
    if ($deviceConfigurationAssignments)
    {
        foreach ($assignment in $deviceConfigurationAssignments)
        {
            $devProfile = Get-MgDeviceManagementDeviceCompliancePolicy -DeviceCompliancePolicyId $assignment.Target.DeviceAndAppManagementAssignmentTarget.TargetId
            Write-Host "- $($devProfile.DisplayName) (ID: $($DevProfile.Id))"
        }
    }
    else
    {
        Write-Host 'No device configuration profiles assigned to this group.'
    }
    Write-Host '' # Add a newline for better readability
    # Get Mobile Apps (Applications) assigned to the group. This gets all types of apps.
    Write-Host 'Mobile Applications:'
    $mobileAppAssignments = Get-MgGroupMobileAppConfigurationAssignment -GroupId $GroupId
    if ($mobileAppAssignments)
    {
        foreach ($assignment in $mobileAppAssignments)
        {
            try
            {
                $appId = $assignment.Target.DeviceAndAppManagementAssignmentTarget.TargetId
                $app = Get-MgMobileApp -MobileAppId $appId
                Write-Host "- $($app.DisplayName) (ID: $($app.Id)) - App Type: $($app.OdataType)"
            }
            catch
            {
                Write-Warning "Could not retrieve details for app ID $($assignment.Target.DeviceAndAppManagementAssignmentTarget.TargetId). This may be due to the app being deleted or permissions issues. Error: $($_.Exception.Message)"
            }
        }
    }
    else
    {
        Write-Host 'No mobile apps assigned to this group.'
    }

}
catch
{
    Write-Error "An error occurred: $($_.Exception.Message)"
}
