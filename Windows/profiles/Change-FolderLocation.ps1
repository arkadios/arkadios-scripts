
.\Change-UserProfilePathAndMoveFiles.ps1
.\Set-KnownFolderPath.ps1

$username = read-host "Username/name of the user folder,1 for folder move"
$destinationLocRoot= read-host "like d:\users"

MoveUserFiles -ACCOUNT $username -NEWPATH $destinationLocRoot


Set-KnownFolderPath -KnownFolder 'Contacts' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Desktop' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Documents' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Downloads' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Favorites' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Links' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Music' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'My Safes' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Pictures' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Saved Games' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Searches' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Tracing' -Path $destinationLocRoot -UserName $username
Set-KnownFolderPath -KnownFolder 'Videos' -Path $destinationLocRoot -UserName $username

#LocalAppData
#RoanubgAppData
