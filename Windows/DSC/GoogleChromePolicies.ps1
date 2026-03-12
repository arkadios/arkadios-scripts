<#

    -- Disable 'Continue running background apps when Google Chrome is closed' --
    Description
        Chrome allows for processes started while the browser is open to remain running once the browser has been closed. It also allows for background apps and the current browsing session to remain active after the browser has been closed. Disabling this feature will stop all processes and background applications when the browser window is closed.
    Potential risk
        If this setting is enabled, vulnerable or malicious plugins, apps and processes can continue running even after Chrome has closed.

    -- Block third party cookies --
    Description
        Chrome allows cookies to be set by web page elements that are not from the domain in the user's address bar. Enabling this feature prevents third party cookies from being set.
    Potential risk
        Blocking third party cookies can help protect a user's privacy by eliminating a number of website tracking cookies.

    -- Disable 'Password Manager' --
    Description
        If this setting is enabled, Chrome will memorize passwords and automatically provide them when a user logs into a site. By disabling this feature the user will be prompted to enter their password each time they visit a website.
    Potential risk
        If not configured correctly, by using 3rd party app an intruder can dump the browser's stored passwords without having to open the browser, enter a password, or even to be identified as the attacked user.
    Personal choice == to keep this enabled because of the number of different instances I run I dont want to remember all the logins or have to look it up 
#>


$registryPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\"
if (!(test-path $registryPath)) { New-Item -Path $registryPath }
else {
    write-host -f green " Path already exists '$registryPath'"
}

$itemPropertiesWithValues = @{
    "BackgroundModeEnabled"  = 0;
    "BlockThirdPartyCookies" = 0;
    "PasswordManagerEnabled" = 1
}

foreach ($currentItemName in $itemPropertiesWithValues.Keys) {
    write-host -f cyan " Setting '$($currentItemName)' to value '$($itemPropertiesWithValues[$currentItemName])' for '$registryPath' "
        New-ItemProperty -Path $registryPath -Name $($currentItemName) -PropertyType DWORD -Value $($($itemPropertiesWithValues[$currentItemName])) -Force

}