
[CmdletBinding()]
param (
    [Parameter()]
    [boolean]
    $AutoConfirm = $false
)
cls 
write-host -f cyan "- ------------- ------------ --------------- -"
write-host -f cyan "- --- FRESH/CLEAN (RE)INSTALL APPS/TOOLS --- -"
write-host -f cyan "- ------------- ------------ --------------- -"


#- manage the basics
# - AzureCLI
$continue = read-host " - (y/N) Do you want to set TLS and install/update NuGet and PowerShellGet (this cannot harm the system)?"
if ($continue -eq 'y' -or $AutoConfirm) {

    write-host -f cyan " - Setting TLS 12" 
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    write-host -f cyan " - Installing PackageProvider NuGet " 
    Install-PackageProvider -Name NuGet -Force

    write-host -f cyan " - Installing Module PowerShellGet " 
    Install-Module PowerShellGet -AllowClobber -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}


# removing stupid windows features/apps
write-host -f cyan " - removing windows features"

$pNames = @(
    "*dropbox*",
    "*disney*",
    "*spotify*",
    "*mcafee*",
    "*getstarted*",
    "*officehub*",
    "*3dbuilder*",
    "*windowscommunicationsapps*",
    "*getstarted*",
    "*skypeapp*",
    "*solitairecollection*",
    "*zunevideo*",
    "*bing*",
    "*messaging*",
    "*Zune*",
    "*people*",
    "*minecraft*"
)

foreach ($pName in $pNames) {
    write-host -f cyan " - Removing $pName ..." -NoNewLine 
    try {
        write-verbose "Get-AppPackage `"$pName`" -AllUsers | Remove-AppPackage -ErrorAction Stop;"
        Get-AppPackage "$pName" -AllUsers | Remove-AppPackage -ErrorAction Stop; 
        write-host -f green "  removed!"
    }
    catch {
        write-host -f red ' - failed to remove. Error: $_'
    }
}

$continue = read-host " - (y/N) Enable windows features Hyper-V?"
if ($continue -eq 'y' -or $AutoConfirm) {

    # enable windows features
    write-host -f cyan " - enbling windows features"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose
}

$continue = read-host " - (y/N) Enable windows features IIS?"
if ($continue -eq 'y' -or $AutoConfirm) {

    write-host -f cyan " - installing/enabing IIS"
    $Error.Clear();
    try {
        Get-WindowsOptionalFeature -Online | ? { $_.FeatureName -like 'IIS-*' -and $_.state -eq "Disabled" } | % { write-host " Installing '$($_.FeatureName)'"; Enable-WindowsOptionalFeature -FeatureName $_.FeatureName -Online -ErrorAction SilentlyContinue; }
    }
    catch {}
	
    if ($Error.Count -gt 0) {
        write-host -f yellow "We are going to run same command again to install features with dependencies, see if there will be some errors. "
        Get-WindowsOptionalFeature -Online | ? { $_.FeatureName -like 'IIS-*' -and $_.state -eq "Disabled" } | % { write-host " Installing '$($_.FeatureName)'"; Enable-WindowsOptionalFeature -FeatureName $_.FeatureName -Online; }
    }

    write-host -f green " - Done installing IIS. "
}


# Installing tools 
$toolsToInstall = @(
    "vscode",
    "git", 
    "googlechrome",
    "putty",
    "openssl",
    "firefox",
    "keepassxc",
    "telegram"
)

write-host " - About to install following tools and applications:"
write-host $toolsToInstall 

$continue = read-host " - (y/N) Install tools and applications?"
if ($continue -eq 'y' -or $AutoConfirm) {
    # install choco 
    $hasChoco = Get-Command choco
    if ($null -eq $hasChoco) {
        write-host -f cyan " - installing choco"
        
        $cmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
        write-host -f DarkGray $cmd
        invoke-expression -Command $cmd

        write-host "Time to restart this shell and script."
        read-host "Close this window or press enter to continue"
    }

    $toolsToInstall | ForEach-Object { 
        $command = "choco install $_ -yes";
        write-host -f cyan " - Executing '$command'";
        invoke-expression $command -ErrorAction Stop
    }

    # Connect-MsolService 
    $testAppExistence = ""; try { $testAppExistence = get-command "Connect-MsolService" } catch { }
    if (-not $testAppExistence) {
        write-host -f yellow " - Installing MSOnline modules"
        Invoke-Expression -Command "Install-Module MSOnline -confirm:0" 
    }
    else {
        write-host -f green " - MSOnline modules seems to be installed! Yay!"
    }

}
else {
    # write-host -f yellow "skipping tools install"
}

#- PnP Powershell
$continue = read-host " - (y/N) Install PnP Powershell?"
if ($continue -eq 'y' -or $AutoConfirm) {

    # install PnP PowerShell
    Install-Module PnP.PowerShell -Scope CurrentUser;

}

#- SPO Management Shell
$continue = read-host " - (y/N) SPO Management Shell?"
if ($continue -eq 'y' -or $AutoConfirm) {
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -RequiredVersion 16.0.21213.12000 
}

$pages2Open = @(
    "https://nmap.org/download.html",
    "https://my.kaspersky.com/"
)

write-host -f DarkGray $($pages2Open -join ', ')
$continue = read-host " - (y/N) Open web pages for apps that could be auto installed?"

if ($continue -eq 'y' -or $AutoConfirm) {

    
    write-host " - Opening pages for other software to download and install"

    $pages2Open | ForEach-Object { 
        $command = "start $_; sleep 2;";
        write-host -f cyan " - Executing '$command'";
        invoke-expression $command -ErrorAction Stop
    }

}


$folders = (
    "dev", "logs", "_temp"
)
$continue = read-host " - (y/N) Create default folders on d-drive ($($folders -join ', '))?"
if ($continue -eq 'y' -or $AutoConfirm) {



    $folders | % { mkdir "D:\$_" }
}


# winget install --id  --source winget

$wingetInstalls = @(
    "Microsoft.Powershell",
    "Microsoft.PowerToys",
    "Postman.Postman",
    "Microsoft.AzureCLI",
    "WhatsApp.WhatsApp",
    "Discord.Discord",
    "OpenWhisperSystems.Signal",
    "nextcloud.nextclouddesktop",
    "ProtonTechnologies.ProtonVPN",
    "pnpm.pnpm",
    "7zip.7zip",
    "Microsoft.DotNet.SDK.9",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.SQLServerManagementStudio"
)

foreach ($wgInstallation in $wingetInstalls) {
    $continue = read-host " - (y/N) Install ' $wgInstallation ' via winget?"

    if ($continue -eq 'y' -or $AutoConfirm) {
        winget install --id "$wgInstallation" --source winget;  
    }
}




# Performance Optimization
$continue = read-host " - (y/N) optimize performance?"
if ($continue -eq 'y' -or $AutoConfirm) {
    write-host -f cyan " - Set power plan to High Performance"
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    write-host -f cyan " - Enable TRIM for SSDs"
    fsutil behavior set DisableDeleteNotify 0
    write-host -f cyan " - Disable hibernation (reclaims disk space)"
    powercfg -h off
}

# Windows Services Optimization

$continue = read-host " - (y/N) optimize performance?"
if ($continue -eq 'y' -or $AutoConfirm) {

    write-host -f cyan " - Disable unnecessary services"
    Stop-Service -Name "DiagTrack" -Force
    Set-Service -Name "DiagTrack" -StartupType Disabled
    # Stop-Service -Name "dmwappushservice" -Force # Device Management Wireless Application Protocol (WAP) Push message Routing Service. It is a critical service in Windows operating systems
    # Set-Service -Name "dmwappushservice" -StartupType Disabled
    Stop-Service -Name "lfsvc" -Force # location services
    Set-Service -Name "lfsvc" -StartupType Disabled

}



$continue = read-host " - (y/N) Restart computer?"
if ($continue -eq 'y' -or $AutoConfirm) {
    Restart-Computer -Force; 
}
