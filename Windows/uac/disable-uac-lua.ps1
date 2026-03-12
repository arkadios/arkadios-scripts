
get-item -path "HKLM:\\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\" 
set-itemproperty -path "HKLM:\\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\" -Name "EnableLUA" -Value 0 -Verbose #-Type DWord