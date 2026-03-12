$moduleRoot = $PSScriptRoot
# $logFolder = "d:\logs\scripts"

# if(-not $(test-path $logFolder)){new-item -ItemType Directory -Path $logFolder}

# THIS ONE is based on personal preference. Do you want to pull latest version from git every time you import this module?
# Write-Progress -Activity "Update" -Status "Pulling latest changes from git...";
# GIT -C $moduleRoot pull origin --progress;
# Write-Progress -Activity "Update" -Completed;


# loading classes - DISABLED for now as there are no classes available
#"$moduleRoot\..\..\classes\*.ps1" | Get-Childitem | ForEach-Object { 
#    ."$($_.Fullname)" ;
#    write-host -ForegroundColor DarkYellow " - Class / objecttype loaded: '[$($_.Basename)]'";
#}


# loading functions
"$moduleRoot\..\..\functions\*.ps1", "$moduleRoot\..\..\wrappers\*.ps1" | Get-Childitem | ForEach-Object { 
    .$_.Fullname ;
    Export-ModuleMember -Function $($_.Basename);
    write-host -ForegroundColor DarkYellow " - Function loaded: '$($_.Basename)'"
}

