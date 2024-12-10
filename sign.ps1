#This script should take a filename or a folder path for input.  If those are not supplied, it should prompt the user.

param (
    [string]$Path
)
#Get the name to the current folder.

if (-not $Path) {
    $Path = Read-Host "Please enter a filename or folder path or press enter for the current folder, ($(Get-Item -Path '.\'))"
}

$files = Get-ChildItem -Path $Path -Filter *.ps1
#Build a list of unsigned scripts or scripts with an invalid signature.
$unsignedFiles = @()
foreach ($file in $files) {
    $signature = Get-AuthenticodeSignature -FilePath $file.FullName -ErrorAction SilentlyContinue
    if ($signature.Status -ne 'Valid') {
        $unsignedFiles += $file.FullName
    }
}
#List all files that are unsigned or have an invalid signature.
if ($unsignedFiles.Count -gt 0) {
    Write-Host 'The following files are unsigned or have an invalid signature:'
    foreach ($file in $unsignedFiles) {
        #trim the path, leaving only the filename.
        $file = $file -replace '^.*\\'
        Write-Host $file
    }
    #Ask the user if they want to proceed with signing the files.
    $proceed = Read-Host 'Do you want to proceed with signing these files? (Y/N)'
    if ($proceed -ne 'Y') {
        Write-Host 'Operation cancelled.'
        return
    }
}
else {
    Write-Host 'No files to sign.'
    exit 0
}
#Transform the unsigned files list into a comma separated string.
$unsignedFiles = $unsignedFiles -join ','

$params = @{
    Endpoint               = 'https://eus.codesigning.azure.net/'
    CodeSigningAccountName = 'zuhairmahd'
    CertificateProfileName = 'Cert1'
    Files                  = "$unsignedFiles"
    # FilesFolder            = $Path
    FileDigest             = 'SHA256'
    TimestampRfc3161       = 'http://timestamp.acs.microsoft.com'
    TimestampDigest        = 'SHA256'
}
Invoke-TrustedSigning @params
