function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules;C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
Import-Module sqlps
}

Load-Modules

# Declare variables
$script:dp_usercred = ""




#Get user input
function SDS-Get-ServerInput
{

    $script:servername = Read-Host "Please enter sql server instance name or hit <ENTER> to abort"

    write-host "Server Name you entered $script:servername"

    if ($script:servername -eq "")
    {
        EXIT
    }

    $script:hostname = $script:servername

    if ($script:servername.indexof("\") -ne "-1")
    {
    $script:hostname = $script:servername.Substring(0, $script:servername.indexof("\"))
    
    }    
}


function SDS-Print-header ($header)
{
  
    # $secondline = "################ " -NoNewline; write-host "Connection: $script:mi" -BackgroundColor DarkRed -ForegroundColor Yellow -NoNewline; Write-Host " ####################"
    $secondline = "################## $header ##################"
    $secondlinecount = SDS-Get-Length($secondline)
    $emptyline = " " * $secondlinecount
    $firstline ="#" * $secondlinecount
    $thirdline = "#" * $secondlinecount
    write-host $firstline
    write-host $secondline
    write-host $thirdline
    write-host $emptyline
    
     
}



function SDS-LoginChoice #Login Choice
{
    clear-host
    write-host "####################################################################"
    write-host "#                                                                  #"
    write-host "#   Select from the following otpions:                             #"
    write-host "#                                                                  #"
    write-host "#   1. Windows Authentication Mode                                 #"
    write-host "#   2. SQL Authentication Mode                                     #"
    write-host "#   0. EXIT program                                                #"
    write-host "#                                                                  #"
    write-host "####################################################################"
}

function copyright 
{
    clear-host
    write-host "###############################################################################################"  -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                              DCU                                            #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                DBLOG Configuration Utility                                  #" -ForegroundColor DarkYellow
    write-host "#                                      globalsql@ebix.com                                     #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "###############################################################################################" `n  -ForegroundColor DarkYellow

    SDS-Print-header "Connection: $script:servername"
    write-host `n

}





# Get Windows or SQL Authentication
function SDS-Input_WindowSQLAuth
{
    SDS-LoginChoice

    $title = "Enter your Choice to connect to SQL Server"
    $one = New-Object System.Management.Automation.Host.ChoiceDescription "&1", "1. Windows Authentication Mode"
    $two = New-Object System.Management.Automation.Host.ChoiceDescription "&2", "2. SQL Authentication Mode"
    $zero = New-Object System.Management.Automation.Host.ChoiceDescription "&0", "0. Exit"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $zero)

    $result = $host.UI.PromptForChoice($title, $title, $options, 2)

    switch ($result)
    {
        0 { $script:LoginChoice = "W"
            write-host $script:LoginChoice}
        1 { $script:LoginChoice = "S"
            write-host $script:LoginChoice}
        2 { EXIT }
    }
}





# Get dp_user credentials and save in variable

function SDS-get-dp_user
{

    $msg = "Enter user name and password to configre new server"
    $script:dp_usercred = Get-Credential -Message $msg "dp_user"

    write-host $script:dp_usercred.username
    Write-Host $script:dp_usercred.Password

}




function SDS-main
{
    clear-host
    SDS-Get-ServerInput

    write-host "Server Name you entered in SDS-main $script:servername"

    # Get Authentication Mode
    SDS-Input_WindowSQLAuth 


    SDS-get-dp_user
}



SDS-main

