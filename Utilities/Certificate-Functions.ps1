###WARNING: The following cmdlet requires  run as administrator rights. 
# [CmdletBinding(SupportsShouldProcess=$true)] 
# param (
#     [string]$CertPath,
#     [string]$CertName = "selfsigned 5y",
#     [string]$CertPassword,
#     [securestring]$PasswordAsSecureString,
#     [string]$CompanyName
# )

write-host " Loading utilities certificate functions"

function IISInstallMyCerts() {
    param (
        [Parameter(Mandatory = $true, HelpMessage="This can be a folder with ")]
        [string]
        $CertPath,
        [Parameter(Mandatory = $true)]
        [string]
        $CertPassword
    ) 

    if (-not $CertPath) { $CertPath = read-host "> Provide certificate (containing) folder (All certificates will be imported :P)" }
    if (-not $CertPassword) { $CertPassword = read-host "> Give certificate password" }
    if (-not $PasswordAsSecureString) { $PasswordAsSecureString = ConvertTo-SecureString -String $certPassword -Force -AsPlainText }


    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("WebHosting", "LocalMachine")   
    $store.Open("ReadWrite")  

    $myCert = Get-ChildItem $certPath 
    if($myCert) {

        Write-Host "Installing following certificate in IIS '$($myCert.FullName)'" -ForegroundColor Cyan 
        try {

            $pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2  
            $pfx.Import($($myCert.FullName), $PasswordAsSecureString, "Exportable,PersistKeySet")   
            $store.Add($pfx) 
            Write-host -f green "Added."
        }
        catch {

        }

    }

    $store.Close()   
}
