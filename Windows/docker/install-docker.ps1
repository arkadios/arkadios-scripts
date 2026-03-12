#
# PLEASE check/use different script first 
# 
#

function Install-Docker([array] $hosts) {

    ForEach ($targetHost in $hosts) {
        write-host -f cyan "Installing docker on $targetHost"

        Invoke-Command -ComputerName $targetHost -ScriptBlock {
            write-host -f cyan "Executing docker installation on host '$($ENV:COMPUTERNAME)'";

            # get module and if not available install it 
            if ($(Get-Module DockerMsftProvider -ErrorAction SilentlyContinue) -eq $null) {
                write-host -f cyan "Installing module 'DockerMsftProvider'";
                Install-Module DockerMsftProvider -Force -Verbose;
            }

            # check if service is running, if so, stop it
            if ($(Get-Service "docker" -ErrorAction SilentlyContinue)) { Stop-Service -Name "docker" -ErrorAction SilentlyContinue -Verbose; }
            else { write-host -f cyan "Docker service not found." }

            # (re)install docker
            write-host -f cyan "Installing Docker pacakage";
            Install-Package Docker -ProviderName DockerMsftProvider -Force -Verbose;
            write-host -f cyan "Starting docker service";
            Start-Service -Name "docker" -Verbose;
            start-sleep 10;

            # restart-host
            write-host -f cyan "Restarting host."
            restart-computer -Force -Verbose;
        }
    }
}

Install-Docker -hosts localhost