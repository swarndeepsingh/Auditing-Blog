function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\130\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules"
Import-Module sqlps
}




# Declare variabales
$server = @()
$serverversion = @()
$serverversionfull = @()
$mi = @()




#$mi = "wp30ef"



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
        "13" {$ver = " SQL Server 2016 - $serverversionfull"; break}
        "12" {$ver = " SQL Server 2014 - $serverversionfull"; break}
        "11" {$ver = " SQL Server 2012 - $serverversionfull"; break}
        "10" {$ver = " SQL Server 2008 - $serverversionfull"; break}
        "9" {$ver = " SQL Server 2005 - $serverversionfull"; break}
    }
    return $ver
}

function Print-host-connection
{

    
    # $secondline = "################ " -NoNewline; write-host "Connection: $mi" -BackgroundColor DarkRed -ForegroundColor Yellow -NoNewline; Write-Host " ####################"
    $secondline = "################################ Connected To : $mi ################################"
    $secondlinecount = Get-Length($secondline)
    $emptyline = " " * $secondlinecount
    $firstline ="#" * $secondlinecount
    $thirdline = "#" * $secondlinecount
    write-host $firstline
    write-host $secondline
    write-host $thirdline
    write-host $emptyline
    
     
}

function Print-host-information ($header, $text)
{
    
    write-host $header  -NoNewline
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
        $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) -ErrorAction Stop
    }
    
    catch
    {
        print-host-error "Error Establishing connection to " $machine
        return
    }

    return $smo
}

function Get-Length($string)
{

    $len = $string | Measure-Object -Character |select -ExpandProperty characters
    return $len
}






function main
{


    $mi = Get-ServerInput

    clear-host
    Print-host-information "Estabilishing Connection " $mi

      $server = Set-Connection($mi) 

    $serverversion = $server.Information.Properties | Where-Object {$_.name -eq "VersionString"}
    $serverversionfull = $serverversion.value
    $serverversion = $serverversion.value.Substring(0, $serverversion.value.indexof("."))

    Get-SQLVersion $server

    clear-host
    Print-host-connection

   

    Print-host-information "SQL Server Version: " (Get-SQLSubVersion ($serverversion))
}



#call main function
main















