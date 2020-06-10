function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules"
Import-Module sqlps
}


Load-Modules

# DESKTOP-VM2BPCP


# Declare variabales
$server = @()
$serverversion = @()
$serverversionfull = @()
$mi = @()
$connectstatus = @()
$OSVersion = @()
$sqlarray = @()




#Get user input
function Get-ServerInput
{
    clear-host
    $ret = Read-Host "Please enter sql server name"
    return $ret
}


# Get SQL Version
function Get-SQLSubVersion ($version)
{
    switch($version)
    {
        "13" {$ver = "SQL Server 2016 - $serverversionfull"; break}
        "12" {$ver = "SQL Server 2014 - $serverversionfull"; break}
        "11" {$ver = "SQL Server 2012 - $serverversionfull"; break}
        "10" {$ver = "SQL Server 2008 - $serverversionfull"; break}
        "9" {$ver = "SQL Server 2005 - $serverversionfull"; break}
    }
    return $ver
}



function Print-header ($header)
{
  
    # $secondline = "################ " -NoNewline; write-host "Connection: $mi" -BackgroundColor DarkRed -ForegroundColor Yellow -NoNewline; Write-Host " ####################"
    $secondline = "################################ $header ################################"
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


function Print-host-error ($header,$text)
{
    
    write-host $header  -NoNewline
    write-host $text -BackgroundColor red -ForegroundColor yellow     

     
}


function Print-host-warning ($header,$text)
{
    
    write-host $header  -NoNewline
    write-host $text -BackgroundColor darkyellow -ForegroundColor DarkBlue  
     
}


# Initiate connection
function Set-connection($machine)
{
    try
    {
        $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
        write-host $smo
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


function Quit-Execution
{
    return
}


function Get-SQLInfo
{
    
        # Get SQL Versions       

    

        

        $serverversion = $server.Information.Properties | Where-Object {$_.name -eq "VersionString"}
        $serverversionfull = $serverversion.value


        $serverversion = $serverversion.value.Substring(0, $serverversion.value.indexof("."))
        $serverversion = (Get-SQLSubVersion ($serverversion))        


        $serverversion = $serverversion + " " + $server.Information.ProductLevel

        $OSVersion = $server.Information.Platform + " " + $server.Information.OSVersion

        $sqlarray = @( @{Property="SQL Server version:     "; Value=$serverversion}
                    , @{Property="Operating System:     "; value = $OSVersion}
                    )

                        $sqlarray.ForEach({[PSCustomObject]$_}) | Format-Table Property, Value -AutoSize  -Wrap
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
    get-WmiObject win32_volume -Computername $machine 
    #| Format-Table DeviceId, FreeSpace, Size, VolumeName 
}


function Get-DBInfo ($object)
{
    $object.Databases | select Name, Size, DataSpaceUsage, IndexSpaceUsage, SpaceAvailable | Format-Table -AutoSize 
}

function main
{

    $connectstatus = 0
    $mi = Get-ServerInput
    #clear-host
    Print-host-information "Estabilishing Connection " $mi

      $server = Set-Connection($mi) 

        #Get-SQLVersion $server
        #clear-host
        Print-header ("Connected To $mi")

        Print-host-information "SQL Server Version Information"
        Get-SQLInfo

        Print-host-information "SQL Server Services"
        Get-SQLServiceInformation $mi

        # Print-host-information "Disk Information"
        # Get-DISKInfo ($mi)
       
        Get-DBInfo $server
}




#call main function
clear-host

main