$myModuleFolder = $PSScriptRoot + "";

write-host -f cyan " - INSTALLING MODULES -"
Write-Host -f cyan " - Checking if this folder is in path env var."

$envVarName = "PSModulePath";
$onWindows = $PSVersionTable.PSEdition -eq "Desktop" -or $IsWindows

if ($onWindows) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $envVarTarget = [System.EnvironmentVariableTarget]::Machine
    } else {
        $envVarTarget = [System.EnvironmentVariableTarget]::User
    }
    $currentPSModulePathValue = [System.Environment]::GetEnvironmentVariable($envVarName, $envVarTarget)
    $pathSeparator = ';'
} else {
    $envVarTarget = $null
    $currentPSModulePathValue = $env:PSModulePath
    $pathSeparator = ':'
}

$envVarCollection = $currentPSModulePathValue.Split($pathSeparator, [System.StringSplitOptions]::RemoveEmptyEntries)

if ($envVarCollection -notcontains $myModuleFolder) {
    $envVarCollection += $myModuleFolder
    Write-Host -f cyan " - Module folder = '$myModuleFolder'"
    Write-Host -f cyan " - Adding module folder as part of '$envVarName'"
    try {
        $newValue = $envVarCollection -join $pathSeparator
        if ($onWindows) {
            [System.Environment]::SetEnvironmentVariable($envVarName, $newValue, $envVarTarget)
        } else {
            # Persist to PowerShell profile on Linux/macOS
            $profileDir = Split-Path $PROFILE.CurrentUserAllHosts -Parent
            if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
            $profilePath = $PROFILE.CurrentUserAllHosts
            $exportLine = "`$env:PSModulePath = `"$myModuleFolder`$([System.IO.Path]::PathSeparator)`$env:PSModulePath`""
            if (-not (Test-Path $profilePath) -or -not (Select-String -Path $profilePath -SimpleMatch $myModuleFolder -Quiet)) {
                Add-Content -Path $profilePath -Value $exportLine
            }
            # Also set for current session
            $env:PSModulePath = $newValue
        }
        write-host -f green " - added."
    }
    catch {
        write-error -Message "Something went wrong with installation of the module"
    }
    write-host -f yellow " - To use this module:"
    write-host -f cyan " -  Restart Powershell to be able to use this module!"
    write-host -f cyan " -  import-module arkadios.core; "
} else {
    write-host -f green " - This scripts folder already in '$envVarName' "
}
