#alternative way to change drive letter
# $cd = $NULL
# $cd = Get-WMIObject -Class Win32_CDROMDrive -ComputerName $env:COMPUTERNAME -ErrorAction Stop

# if ($cd.Drive -eq "D:")
# {
#    Write-Output "Changing CD Drive letter from D: to A:"
#    Set-WmiInstance -InputObject ( Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'd:'" ) -Arguments @{DriveLetter='a:'}
# }

# Create a DiskPart script to change the drive letter
$diskPartScript = @"
select volume D
assign letter=M
"@

# Save the DiskPart script to a temporary file
$scriptPath = "$env:TEMP\changeDriveLetter.txt"
Set-Content -Path $scriptPath -Value $diskPartScript

# Execute the DiskPart script
Start-Process -FilePath "diskpart.exe" -ArgumentList "/s $scriptPath" -Wait

# Clean up the temporary file
Remove-Item -Path $scriptPath

Write-Output "Drive letter changed to M:"