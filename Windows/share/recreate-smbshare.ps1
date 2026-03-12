
function create-smbshare([string] $destPath, [string[]]$FullControlAccounts, [string[]]$ReadAccounts){
    
    try {
        if(-not $ReadAccounts){
            new-smbshare -Path $destPath -Name $(split-path $destPath -leaf) -Confirm:0 -FullAccess ($FullControlAccounts += ".\Administrators") -Verbose -ErrorAction Stop;
        }
        else {
            new-smbshare -Path $destPath -Name $(split-path $destPath -leaf) -Confirm:0 -FullAccess ($FullControlAccounts += ".\Administrators") -ReadAccess $ReadAccounts -Verbose -ErrorAction Stop;
        }
        write-host -f green "   share created."
        $FullControlAccounts | %{ write-host -f green "   '$_' users/groups got FullAccess" }
    }
    catch {
        write-host -f red "   failed"
        write-host -f red "   $_"
    }
}

# function set-smbpermissions([string] $destPath, [string[]]$FullControlAccounts){

#     $existingShare = get-smbshare -Name $(split-path $destPath -leaf) -ErrorAction SilentlyContinue
    
#     try {
#         if($existingShare){
#             foreach($FullControlAccount in $FullControlAccounts){ 
#                 write-host "   granting full control permissions for '$FullControlAccount'"
#                 $existingShare | Grant-SmbShareAccess -AccountName $FullControlAccount -AccessRight Full -Verbose -Confirm:0;
#             }
#         }
#         else{
#             write-host "   something wrong, smb share not found to set permissions "
#         }
#     }
#     catch {
        
#     }
# }
function recreate-smbshare([string] $destPath, [string[]]$FullControlAccounts, [string[]]$ReadAccounts){
    write-host "  checking share with name '$(split-path $destPath -leaf)'"
    $existingShare = get-smbshare -Name $(split-path $destPath -leaf) -ErrorAction SilentlyContinue

    if($existingShare){

        write-host "   share found, removing"
        $existingShare | Remove-SmbShare -Confirm:0; 
    }    

    $existingShare = get-smbshare -Name $(split-path $destPath -leaf) -ErrorAction SilentlyContinue
    if(-not $existingShare){
        # write-host "   share found, setting permissions "
        # set-smbpermissions -destPath $destPath -FullControlAccounts $FullControlAccounts

        write-host "   share not found, creating"
        create-smbshare $destPath $FullControlAccounts $ReadAccounts

    }
}
write-host -f white " Function recreate-smbshare loaded!"