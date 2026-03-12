

New-PSDrive -Name Z -PSProvider FileSystem -Root $(read-host "Please provide path to the share like '\\server\share'") -Persist

# zip local folder and split into 1GB files
# move all zips to share
