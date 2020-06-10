

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

$script:servername = ""
$script:hostname = ""
$script:server = ""
$script:serverversion = ""
$script:serverversionfull = ""
$script:mi = ""
$script:OSVersion = ""
$script:sqlarray = @()
$script:sqlcred = ""
$script:loginchoice = ""
$script:filesizes = @()
$script:isClustered = ""



function Print-header ($header)
{
  
    # $secondline = "################ " -NoNewline; write-host "Connection: $script:mi" -BackgroundColor DarkRed -ForegroundColor Yellow -NoNewline; Write-Host " ####################"
    $secondline = "################## $header ##################"
    $secondlinecount = Get-Length($secondline)
    $emptyline = " " * $secondlinecount
    $firstline ="#" * $secondlinecount
    $thirdline = "#" * $secondlinecount
    write-host $firstline
    write-host $secondline
    write-host $thirdline
    write-host $emptyline
    
     
}

function Print-host-information ( $text)
{    
    #write-host $header  -NoNewline
    write-host $text -BackgroundColor white -ForegroundColor black     
}


function Print-host-error ($text)
{   
    write-host $text -BackgroundColor red -ForegroundColor yellow
}


function Print-host-warning ($text)
{    

    write-host $text -BackgroundColor darkyellow -ForegroundColor DarkBlue       
}





function Get-ActiveNodes
{

    $script:isClustered = $script:server.properties.Item("IsClustered")

    if ($script:isClustered.value -eq $true)
    {
        
        write-host "SQL Server instance $script:servername is clustered"
        write-host `n
        # connection
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        if ($script:loginchoice -eq "w")
        {
            $sqlConnection.ConnectionString = "Server=$script:servername;Database=master;Integrated Security=True"
            
        }
        elseif ($script:loginchoice -eq "s")
        {
            $user = $script:sqlcred.username
            # $pwd = $script:sqlcred.password | ConvertFrom-SecureString
            $pwd = $script:sqlcred.GetNetworkCredential().password

            $sqlConnection.ConnectionString = "Server=$script:servername;Database=master;UID=$user;password=$pwd"
        }
        $sqlConnection.Open()

        # command A - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select NodeName as Nodes from sys.dm_os_cluster_nodes"
        $data = $sqlcmd.ExecuteReader()
    
        $tabledata = @()

        while ($data.read())
        {
            $tabledata += $data["Nodes"]
        }

        print-host-information "The SQL Cluster nodes are:"

        $tabledata | Format-Table -AutoSize
        write-host `n

        $data.Close()

        $sqlCmd.CommandText = "SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as ActiveNode"
        $data = $sqlcmd.ExecuteReader()
    
        $tabledata = @()

        while ($data.read())
        {
            $tabledata += $data["ActiveNode"]
        }

        print-host-information "The Current Active Node is:"

        $tabledata | Format-Table -AutoSize
        $data.Close()
        $sqlconnection.close()

        
       
        

    }
        if ($script:isClustered.value -ne $true)
    {
        
        write-host "SQL Server $script:servername is not clustered"
        
    }


}




#Get user input
function Get-ServerInput
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


function SplashScreen_I #Login Choice
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

function SplashScreen_intro #intro screen
{
    clear-host
    write-host "###############################################################################################"  -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                                DCU                                          #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                     DBLOG Configuration Utility                             #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "###############################################################################################" `n  -ForegroundColor DarkYellow

    print-header "Connection: $script:servername"
    write-host `n

}



# Get Windows or SQL Authentication
function Input_WindowSQLAuth
{
    SplashScreen_I

    $title = "Enter your Choice to connect to SQL Server"
    $one = New-Object System.Management.Automation.Host.ChoiceDescription "&1", "1. Windows Authentication Mode"
    $two = New-Object System.Management.Automation.Host.ChoiceDescription "&2", "2. SQL Authentication Mode"
    $zero = New-Object System.Management.Automation.Host.ChoiceDescription "&0", "0. Exit"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $zero)

    $result = $host.UI.PromptForChoice($title, $title, $options, 2)

    switch ($result)
    {
        0 { $script:loginchoice = "W"
            write-host $script:loginchoice}
        1 { $script:loginchoice = "S"
            write-host $script:loginchoice}
        2 { EXIT }
    }
}

# Get SQL Version
function Get-SQLSubVersion ($version)
{
    switch($version)
    {
        "13" {$ver = "SQL Server 2016 - $script:serverversionfull"; break}
        "12" {$ver = "SQL Server 2014 - $script:serverversionfull"; break}
        "11" {$ver = "SQL Server 2012 - $script:serverversionfull"; break}
        "10" {$ver = "SQL Server 2008 - $script:serverversionfull"; break}
        "9" {$ver = "SQL Server 2005 - $script:serverversionfull"; break}
    }
    return $ver
}




#Get SQL Credentials



# Initiate connection
function Set-connection($machine)
{
    try
    {

        if ($loginchoice -eq "S")
        {
            $msg = "Enter User name and password for $machine"
            $script:sqlcred = Get-Credential -Message $msg
            $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
            $smo.ConnectionContext.LoginSecure = $false
            $smo.ConnectionContext.set_Login($sqlcred.username)
            $smo.ConnectionContext.set_SecurePassword($sqlcred.Password)
            $smo.ConnectionContext.Connect()
       }

       elseif ($loginchoice -eq "W")
       {
            $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
            $smo.ConnectionContext.LoginSecure = $true
            $smo.ConnectionContext.Connect()
       }

    }
    
    catch
    {
        print-host-error "Error Establishing connection to " $machine
        write-host $_.Exception.Message
    }

    return $smo
}

function Get-Length($string)
{

    $len = $string | Measure-Object -Character |select -ExpandProperty characters
    return $len
}




function Get-SQLInfo
{
    
 
        $script:serverversion = $script:server.Information.Properties | Where-Object {$_.name -eq "VersionString"}
        $script:serverversionfull = $script:serverversion.value

        

        $script:serverversion = $script:serverversion.value.Substring(0, $script:serverversion.value.indexof("."))
        $script:serverversion = (Get-SQLSubVersion ($serverversion))        


        $script:serverversion = $script:serverversion + " " + $script:server.Information.ProductLevel

        $script:OSVersion = $script:server.Information.Platform + " " + $script:server.Information.OSVersion

        $script:sqlarray = @( @{Property="SQL Server version:     "; Value=$serverversion}
                    , @{Property="Operating System:     "; value = $script:OSVersion}
                    )

        $script:sqlarray.ForEach({[PSCustomObject]$_}) | Format-Table Property, Value -AutoSize  -Wrap
}



function Get-SQLServiceInformation ($machine)
{

    if ($machine.indexof("\") -ne "-1")
    {
    $machine = $machine.Substring(0, $machine.indexof("\"))
    
    }
    get-service -ComputerName $machine -Name *SQl* 
}


function Get-DISKInfo ($machine)
{
    print-host-information "Disk Information for $script:hostname"
    get-WmiObject win32_volume -Computername $script:hostname | sort-object Freespace -descending | Format-Table Name,  @{label="FreeSpace (GB)";Expression={$_.FreeSpace /1024/1024/1024 };FormatString="#,###,##.#0"} -AutoSize
}


function Get-DBInfo ($object)
{
    $dataTotal = $object.Databases | Measure-Object -property Size -sum
    # print-host-information "Database Information"
    $count = $datatotal.Count.ToString()
    $size = ($datatotal.sum * 1MB / 1GB).ToString("#,##0")
    write-host "Database Count:" $count
    # Print-host-information "SQL Server Database count:" $object.Databases | Measure-Object -property count
    write-host "Total Database size (GB):" $size #$dataTotal.sum | measure-object @{Expression= {$_.size*1MB/1GB}}
    $object.Databases | select Name, Size, DataSpaceUsage, IndexSpaceUsage, SpaceAvailable | sort-object Size -descending | Format-Table Name, @{label="Size (GB)";Expression={$_.Size*1MB / 1GB};FormatString="#,###,##.#0"} -Auto 
}

function Get-DBFileSizeInfo ($object)
{
    
    $dbs = $object.Databases

    
    foreach ($db in $dbs)
    {
         $fgs = $db.FileGroups
         
         foreach ($fg in $fgs)
         {
            $script:filesizes = $fg.Files 
         }
         $script:filesizes | Select Name, FileName, size, UsedSpace | Where {[float]((($_.Size - $_.UsedSpace)/$_.size)*100) -le 15 } |Format-Table  @{Name= "DBName"; Expression={$db.name}}, @{Name="FileName"; Expression={$_.Name}}, @{Name="FileSize(GB)"; Expression={($_.Size)/1024/1024};FormatString="#,###,##0.#0"}, @{Name="Used(GB)"; Expression={($_.UsedSpace)/1024/1024};FormatString="#,###,##0.#0"} ,  @{Name = "FreeSpace(%)"; Expression={[float](($_.Size - $_.UsedSpace)/$_.size)*100};FormatString="#0.#0"} -AutoSize 
    }
}
function Get-AllSQLServices
{
    #Get-Service -Computername $script:servername -Displayname "*SQL*" | Sort-Object status,displayname 

    # Get-WMIObject win32_service -filter "Name = '*SQL*'" #| format-table Name, Count, StartName -AutoSize
    Get-WMIObject -Query "Select * from Win32_service WHERE Name Like '%sql%'" | Format-Table -Property Name, Status, State, @{Name="Logon Service"; Expression= {$_.StartName}}  -AutoSize
}


function main
{
    clear-host
    Get-ServerInput

    write-host "Server Name you entered in main $script:servername"

    # Get Authentication Mode
    Input_WindowSQLAuth 


    $script:server = Set-Connection($script:servername) 
    SplashScreen_intro

    
    
    Print-header "SQL Server Version Information"    
    Get-SQLInfo


    Print-header "Cluster Information"
    Get-ActiveNodes

    write-host `n
    
    # Get DB Information on screen
    Print-header "Database Information"
    Get-DBInfo $script:server
    write-host `n


    print-header "Database Files below 15% free space"
    Get-DBFileSizeInfo $script:server

    if ($script:loginchoice -eq "W")
    {
        # Get Disk Information on screen
        print-header "Disk Information"
        Get-DISKInfo $script:servername

        print-header "SQL Services running on the server"
        Get-AllSQLServices
    }


    
    


}





#call main function
main
