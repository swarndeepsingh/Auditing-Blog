function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules"
# Add Connection Assembly
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo.dll")
Import-Module sqlps
}

Load-Modules

$smo = ""


function Set-connection($machine)
{
    $cred = Get-Credential
    $user = $cred.UserName -replace("\\","")

    try
    {

        $serverConnection = new-object Microsoft.SqlServer.Management.Common.ServerConnection($machine)
        $serverconnection.LoginSecure = $True
        $serverConnection.ConnectAsUser = $true
        $serverConnection.ConnectAsUsername = $user
        $serverConnection.ConnectAsUserPassword = $cred.Password
        $smo = new-object Microsoft.SqlServer.Management.Smo.Server($serverconnection)



        return $smo


    }
    
    catch
    {
        $ErrorMessage = $_.Exception.Message
        print-host-error "Error Establishing connection to " $machine
        print-host-error $ErrorMessage
    }

    #return $smo
}



Set-connection 192.168.173.152


$smo.Information.Properties | Where-Object {$_.name -eq "VersionString"}