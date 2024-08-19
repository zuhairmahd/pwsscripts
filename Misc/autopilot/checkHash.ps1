# Define the file path
$File = "c:\HWID\autopilot.txt"

# Use try-catch block to handle errors
try {
    # Check if the file exists
    if (Test-Path $File) {
        Write-Output "The file $file exists."
        exit 0
    } else {
        Write-Output "The file $file is not found."
        exit 1
    }
} catch {
    write-output $exception.Message
    exit 1
}