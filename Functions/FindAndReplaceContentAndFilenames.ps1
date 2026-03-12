function FindAndReplaceContentAndFilenames(
    $FolderToProcess, 
    [Parameter(Mandatory = $true)]
    $oldValue, 
    [Parameter(Mandatory = $true)]
    $newValue, 
    $filesFilter = ("*.json", "*.xml", "*.md", "*.ps1", "*.psm1", "*.txt", "*.yml", "*.yaml", "*.order")
    ) {
    
    write-host -f DarkGray " - Location '$FolderToProcess'"
    write-host -f DarkGray " - Replacing old '$oldValue' with new '$newValue'"
    write-host -f DarkGray " - in files of type '$filesFilter'" 
    
    Push-Location $FolderToProcess

    Get-ChildItem -R -file -Include $filesFilter | ForEach-Object { 
        write-verbose "  - processing '$($_.FullName)'" ;
        if ((Get-Content -LiteralPath $_.FullName -Raw) -match $oldValue) {
            write-host -f blue "    - replacing in '$($_.FullName)'"; 
            (Get-Content -LiteralPath $_.FullName -Raw) -replace $oldValue, $newValue | set-content -LiteralPath $_.FullName -Force;
        }
        else {
            write-verbose "    - nothing found. "
        }
    } 
    
    write-host -f DarkGray "  - checking/renaming folder names"
    Get-ChildItem -R -Directory | ForEach-Object {
        write-verbose "   - processing '$($_.FullName)'";
        if ($_.Name -like "*$oldValue*") {
            write-host -f blue "    - replacing in '$($_.FullName)'"; 
            Rename-Item -LiteralPath $_.FullName -NewName $($_.Name -replace $oldValue, $newValue) 
        } }
    
    write-host -f DarkGray "  - checking/renaming file names"
    Get-ChildItem -R -File | ForEach-Object {
        write-verbose "   - processing '$($_.FullName)'";
        if ($_.Name -like "*$oldValue*") {
            write-host -f blue "    - replacing in '$($_.FullName)'"; 
            Rename-Item -LiteralPath $_.FullName -NewName $($_.Name -replace $oldValue, $newValue);
        } 
    }

    Pop-Location;
}