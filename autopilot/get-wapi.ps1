try {
	$bad = $false
	$session = New-CimSession
	$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
	$product = ""
	# Get the hash (if available)
	$devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
	if ($devDetail -and (-not $Force)) {
		$hash = $devDetail.DeviceHardwareData
	}
	else {
		$bad = $true
		$hash = ""
	}

	if (-not ($bad)) {
		write-host "Serial: $serial", "Hash: $hash", "Product: $product"
		$File = "c:\HWID\autopilot.txt"
		new-item -ItemType File $file -force -ErrorAction Stop | Out-Null
		write-host "File created: $file"
		add-content -Path $file -Value "Serial Number: $serial"
		add-content -Path $file -Value "Product: $product"
		add-content -Path $file -Value "Hash: $hash"
	}
	else {
		write-host "No hash found"
		add-content -Path $file -Value "No hash found"
		exit 1
	}
	
	exit 0 
}

catch {
	#do this if an error occurs
	Write-Error "An error occurred: $_"
	exit 1
}
