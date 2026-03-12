#
# For working powershell PSGallery
#

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default -Verbose
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
# Install-Script -Name New-OnPremiseHybridWorker
