$inputFile = 'updateOS.ps1'
$OutputFile = New-Item -ItemType File -Path 'UpdateOS-processed.ps1' -Force


Get-Content $inputFile | ForEach-Object {
    $object = '"' + $_ + '",'
    Write-Host $object
    Out-File -Encoding ascii -FilePath $OutputFile -Append -InputObject $object
    $object
} 







# $myScript = @(
#     '[CmdletBinding()]',
#     'Param(',
#     "[Parameter(Mandatory = $False)] [ValidateSet('Soft', 'Hard', 'None', 'Delayed')] [String] $Reboot = 'Soft',"
# )

# $TaskTrigger = New-ScheduledTaskTrigger -AtLogOn
# $TaskAction = New-ScheduledTaskAction -Execute 'test.ps1'
# Register-ScheduledTask Update -Trigger $TaskTrigger -Action $TaskAction -User 'NT AUTHORITY\SYSTEM' -RunLevel Highest -Force

