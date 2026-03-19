function FindAndReplaceContentAndFilenames(
    $FolderToProcess,
    [Parameter(Mandatory = $true)]
    $oldValue,
    [Parameter(Mandatory = $true)]
    $newValue,
    $filesFilter = ("*.json", "*.xml", "*.md", "*.ps1", "*.psm1", "*.txt", "*.yml", "*.yaml", "*.order")
    ) {
<#
.SYNOPSIS
    Finds and replaces a value in file contents, folder names, and file names.

.DESCRIPTION
    Performs a three-pass replacement within a folder:
    1. Replaces occurrences of oldValue with newValue inside file contents (filtered by type).
    2. Renames folders containing oldValue in their name.
    3. Renames files containing oldValue in their name.

.PARAMETER FolderToProcess
    The root folder to process.

.PARAMETER oldValue
    The string or pattern to find.

.PARAMETER newValue
    The replacement string.

.PARAMETER filesFilter
    File extensions to include when replacing content. Defaults to common config/script types.

.EXAMPLE
    FindAndReplaceContentAndFilenames -FolderToProcess "C:\Project" -oldValue "OldName" -newValue "NewName"
#>
    
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