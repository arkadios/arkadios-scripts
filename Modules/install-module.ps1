$myModuleFolder = $PSScriptRoot + ""; 

$envVarTarget = ""

write-host -f cyan " - INSTALLING MODULES -"
Write-Host -f cyan " - Checking if this folder is in path env var."

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    $envVarTarget = "Machine";
}
else{
    $envVarTarget = "User";
}

$envVarName = "PSModulePath";
$currentPSModulePathValue = [System.Environment]::GetEnvironmentVariable($envVarName, $envVarTarget); 

$envVarCollection = $currentPSModulePathValue.Split(';',[System.StringSplitOptions]::RemoveEmptyEntries)

if($envVarCollection -notcontains $myModuleFolder){
    $envVarCollection += $myModuleFolder
    Write-Host -f cyan " - Module folder = '$myModuleFolder'"
    Write-Host -f cyan " - Adding module folder as part of '$envVarName', scope/target '$envVarTarget'"
    try {
        [System.Environment]::SetEnvironmentVariable("PSModulePath", $($envVarCollection -join ';'), $envVarTarget);
        write-host -f green " - added."
    }
    catch {
        write-error -Message "Something went wrong with installation of the module"
    }
    write-host -f yellow " - To use this module:"
    write-host -f cyan " -  Restart Powershell to be able to use this module!"
    write-host -f cyan " -  import-module arkadios.core; "
}
else{
    write-host -f green " - This scripts folder already in '$envVarName' "
}
