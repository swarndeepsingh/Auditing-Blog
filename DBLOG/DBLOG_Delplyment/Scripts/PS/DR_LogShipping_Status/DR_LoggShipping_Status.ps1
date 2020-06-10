function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

# [Reflection.Assembly]::LoadFile(([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo").location))


# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\100\Tools\PowerShell\Modules;C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
Import-Module sqlps

Add-PSSnapin SqlServerProviderSnapin100
add-pssnapin SqlServerCmdletSnapin100
}


Load-Modules

# Declare variables
$script:dp_usercred = ""
$script:servername = "10.18.65.11"
$script:hostname = "LAAN4DRXSQL01"
$script:server = "10.18.65.11"
$script:serverversion = ""
$script:serverversionfull = ""
$script:mi = ""
$script:OSVersion = ""
$script:sqlarray = @()
$script:sqlcred = ""
$script:LoginChoice = ""
$script:filesizes = @()
$script:isClustered = ""
$script:options=""
$script:MailProfileScript = ""
$script:dblogoptions = ""
$script:RTMServer = "10.5.20.48"

$machine="10.18.65.11"

function copyright 
{
    #clear-host
    write-host "###############################################################################################"  -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                AN4 DR LogShipping Status                                    #" -ForegroundColor DarkYellow
    write-host "#                                      GlobalSQL                                              #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "###############################################################################################" `n  -ForegroundColor DarkYellow

    
    write-host `n

}


# Initiate connection
function SDS-Set-connection($machine)
{

            read-host "`nSQL Authentication:: Hit <Enter> to provide SQL User name Password for $script:servername in the dialog box"
            $msg = "SQL Authentication:: $machine"
            $script:sqlcred = Get-Credential -Message $msg "sa"
            $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
            $smo.ConnectionContext.LoginSecure = $false
            $smo.ConnectionContext.set_Login($sqlcred.username)
            $smo.ConnectionContext.set_SecurePassword($sqlcred.Password)
            $smo.ConnectionContext.Connect()
            # Write-Host $smo
            write-host "`n"
            SDS-Print-host-information "Connection Established to $machine "
            write-host "`n"


    return $smo
}

function SDS-Options 
{
    
    write-host "####################################################################"
    write-host "#                                                                  #"
    write-host "#   Select from the following otpions:                             #"
    write-host "#                                                                  #"
    write-host "#   1. Get Active Log Shipping                                     #"
    write-host "#   2. Get Completed Log Shipping                                  #"
    write-host "#   0. EXIT program                                                #"
    write-host "#                                                                  #"
    write-host "####################################################################"
}
######################################
# Execute SP 
#####################################
function SDS-getActiveLogShipping ()
{

    Invoke-sqlcmd -ServerInstance $script:servername  -Database "DBLOGDR" -Username $script:sqlcred.UserName -Password $script:sqlcred.GetNetworkCredential().Password -Query "  
    EXEC [dbo].[usp_getActiveLogShipping]" 
}


function SDS-getCompletedLogShipping ()
{

    Invoke-sqlcmd -ServerInstance $script:servername  -Database "DBLOGDR" -Username $script:sqlcred.UserName -Password $script:sqlcred.GetNetworkCredential().Password -Query "  
    EXEC [dbo].[usp_getCompletedLogShipping]" 
}
#########################################################################
function SDS-Input_Options
{
    
    #Read-Host "`nWe must collect some information before proceeding further. Hit <Enter>"
    do{
    SDS-Options

    $result = Read-Host  "`nSelect the Action you want to perform"
    
    
    switch ($result)
    {
        1 { $script:options = "1"
            SDS-getActiveLogShipping}

        2 { $script:options = "2"
            SDS-getCompletedLogShipping           }

        0 { EXIT }
    }
    } while (100 -ne 99)
}



#########################################################################
function SDS-InitiateConection
{
            #SDS-Get-ServerInput
            # Get Authentication Mode
            #SDS-Input_WindowSQLAuth 
            #initiate connection
            $script:server = SDS-Set-connection($script:servername)  
            SDS-Print-header "Connection: $script:servername"
            #SDS-get-dp_user
            clear-host
            copyright
}


# Final call
function SDS-main
{
    clear-host
    copyright
    SDS-InitiateConection
    SDS-Input_Options
}

SDS-main;