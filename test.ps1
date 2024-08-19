[CmdletBinding()]
Param(
[Parameter(Mandatory = False)] [ValidateSet('Soft', 'Hard', 'None', 'Delayed')] [String]  = 'Soft',
