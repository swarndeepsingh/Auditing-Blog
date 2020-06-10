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
$script:servername = ""
$script:hostname = ""
$script:server = ""
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




function SDS-Get-Length($string)
{

    $len = $string | Measure-Object -Character |select -ExpandProperty characters
    return $len
}

#Get user input
function SDS-Get-ServerInput
{

    $script:servername = Read-Host "Please enter Remote SQL Server Instance (IP\InstanceName) where DBLOG has to be configured or hit <ENTER> to quit"

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


function SDS-Print-host-information ( $text)
{    
    #write-host $header  -NoNewline
    write-host $text -BackgroundColor white -ForegroundColor black     
}


function SDS-Print-host-error ($text)
{   
    write-host $text -BackgroundColor red -ForegroundColor yellow
}


function SDS-Print-host-warning ($text)
{    

    write-host $text -BackgroundColor darkyellow -ForegroundColor DarkBlue       
}





function SDS-LoginChoice #Login Choice
{
   
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




function SDS-Options 
{
    
    write-host "####################################################################"
    write-host "#                                                                  #"
    write-host "#   Select from the following otpions:                             #"
    write-host "#                                                                  #"
    write-host "#   1. Setup DBLOG on Remote SQL Server                            #"
    write-host "#   2. create RTM Inventory                                        #"
    write-host "#   3. Setup Best Practices (Basic)                                #"
    write-host "#   4. Setup Best Practices (Advanced-Need Windows Authentication  #"
    write-host "#   0. EXIT program                                                #"
    write-host "#                                                                  #"
    write-host "####################################################################"
}




function SDS-DBLOG-Options 
{
    
    write-host "####################################################################"
    write-host "#                                                                  #"
    write-host "#   Select from the following sub-options for DBLOG:               #"
    write-host "#                                                                  #"
    write-host "#   1. Setup Database, Login and Deployment                        #"
    write-host "#   2. Add Remote Location                                         #"
    write-host "#   3. Setup Backup                                                #"
    write-host "#   4. Setup Audit                                                 #"
    write-host "#   9. Run ALL Options                                             #"
    write-host "#   0. EXIT program                                                #"
    write-host "####################################################################"
}






function copyright 
{
    #clear-host
    write-host "###############################################################################################"  -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                            DCU 1.1                                          #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "#                                DBLOG Configuration Utility                                  #" -ForegroundColor DarkYellow
    write-host "#                                      globalsql@ebix.com                                     #" -ForegroundColor DarkYellow
    write-host "#                                                                                             #" -ForegroundColor DarkYellow
    write-host "###############################################################################################" `n  -ForegroundColor DarkYellow

    
    write-host `n

}







# Get Windows or SQL Authentication
function SDS-Input_WindowSQLAuth
{
    
    #Read-Host "`nWe must collect some information before proceeding further. Hit <Enter>"

    SDS-LoginChoice

    $result = Read-Host  "`nEnter your selection to connect to [$script:servername]"

    switch ($result)
    {
        1 { $script:LoginChoice = "W"
            write-host ":Windows Authentication"}
        2 { $script:LoginChoice = "S"
            write-host ":SQL Authentication"
            }
        0 { SDS-Loop-main }
    }
}



function SDS-Input_Options
{
    
    #Read-Host "`nWe must collect some information before proceeding further. Hit <Enter>"

    SDS-Options

    $result = Read-Host  "`nSelect the Action you want to perform"
    
    
    switch ($result)
    {
        1 { $script:options = "1"
            SDS-DBLOG_Input_Options}

        2 { $script:options = "2"
            write-host "Create RTM Inventory"            }
        3 { $script:options = "3"
            write-host "Setup Best Practices (Basic)"            }
        4 { $script:options = "4"
            write-host "Setup Best Practices (Adanced - Need Windows Authentication)"            }
        0 { EXIT }
    }
}



function SDS-DBLOG_Input_Options
{
    
    #Read-Host "`nWe must collect some information before proceeding further. Hit <Enter>"

    SDS-DBLOG-Options

    $result = Read-Host  "`nSelect the Action you want to perform for DBLOG"
    
    
    switch ($result)
    {
        1 { $script:dblogoptions = "1"
            write-host "Setup Database, Login and Deployment"



            # Create Scripts in Variables
            SDS-VariableToScript

            # IF not exists then create login dp_user    
            SDS-IFNE_Login ($script:server)
    
            # Create DBAMail Account and Profile
            SDS-AddMailProfile 


            #IF Not Exists then create DBLOG
            SDS-IFNE_CreateDB ($script:server)
        
        }



        2 { $script:dblogoptions = "2"

            
            
            SDS-GetLocations
            SDS-AddLocation

                        }
        3 { $script:dblogoptions = "3"
            SDS-GetLocations
            SDS-AddBackup
                        }

        4 { $script:dblogoptions = "4"
            SDS-AddAudit
            
                        }

        9 { $script:dblogoptions = "9"
             # Create Scripts in Variables
            SDS-VariableToScript

            # IF not exists then create login dp_user    
            SDS-IFNE_Login ($script:server)
    
            # Create DBAMail Account and Profile
            SDS-AddMailProfile 


            #IF Not Exists then create DBLOG
            SDS-IFNE_CreateDB ($script:server)
            
            SDS-GetLocations
            SDS-AddLocation

            SDS-GetLocations
            SDS-AddBackup

            SDS-AddAudit


                        }
        0 { EXIT }
    }
}






# Initiate connection
function SDS-Set-connection($machine)
{
    try
    {

        if ($LoginChoice -eq "S")
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

       }

       elseif ($LoginChoice -eq "W")
       {
            $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
            $smo.ConnectionContext.LoginSecure = $true
            $smo.ConnectionContext.Connect()
            SDS-Print-host-information "Connection Established to $machine"
       }

    }
    
    catch
    {
        SDS-Print-host-error "Error Establishing connection to " $machine
        write-host $_.Exception.Message
        EXIT
    }

    return $smo
}






# Initiate connection
function SDS-Set-connection-RTM($machine)
{
    try
    {

        if ($LoginChoice -eq "S")
        {
            $msg = "Enter User name and password for $machine"
            $script:sqlcred = Get-Credential -Message $msg "sa"
            $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
            $smo.ConnectionContext.LoginSecure = $false
            $smo.ConnectionContext.set_Login($sqlcred.username)
            $smo.ConnectionContext.set_SecurePassword($sqlcred.Password)
            $smo.ConnectionContext.Connect()
       }

       elseif ($LoginChoice -eq "W")
       {
            $smo = New-Object Microsoft.SQLServer.Management.smo.server($machine) 
            $smo.ConnectionContext.LoginSecure = $true
            $smo.ConnectionContext.Connect()
       }

    }
    
    catch
    {
        SDS-Print-host-error "Error Establishing connection to " $machine
        write-host $_.Exception.Message
    }

    return $smo
}







# Get dp_user credentials and save in variable

function SDS-get-dp_user
{

    Read-Host "`nPlease provide [dp_user] credentials. These credentials will be used by DBLOG to monitor the server"
    $msg = "Enter Login Credentials for [dp_user] to create on [$script:servername]"
    $script:dp_usercred = Get-Credential -Message $msg "dp_user"

}




function SDS-IFNE_Login ($object)
{
    $searchstring = $script:dp_usercred.username

    $logins = $object.Logins.Name

    if ($logins -contains $searchstring)
    {
        SDS-Print-host-warning "Login $searchstring already exists, skipped creating $searchstring"
    }
    else
    {
        SDS-Print-host-information "Login $searchstring does not exists, creating $searchstring"

        $login = New-Object ('Microsoft.SqlServer.Management.Smo.Login') $script:servername, $script:dp_usercred.UserName
        $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
        $login.Create($script:dp_usercred.GetNetworkCredential().Password)

        $login.AddToRole("sysadmin")
        $login.Alter();

        $object.Logins.Refresh()

    }
}



function SDS-create_RTM_Inventory ($object)
{
    $searchstring = $script:dp_usercred.username

    $logins = $object.Logins.Name

    if ($logins -contains $searchstring)
    {
        SDS-Print-host-warning "$searchstring already exists, skipped creating $searchstring"
    }
    else
    {
        SDS-Print-host-information "$searchstring does not exists, creating $searchstring"

        $login = New-Object ('Microsoft.SqlServer.Management.Smo.Login') $script:servername, $script:dp_usercred.UserName
        $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
        $login.Create($script:dp_usercred.GetNetworkCredential().Password)

        $login.AddToRole("sysadmin")
        $login.alter

        $object.Logins.Refresh()

    }
}



function SDS-IFNE_CreateDB ($object)
{
    $searchstring = "DBLOG"
    $databases = $object.Databases.Name

    if ($databases -contains $searchstring)
    {
        SDS-Print-host-warning "$searchstring already exists, skipped creating $searchstring"
    }
    else
    {
        SDS-Print-host-information "$searchstring does not exists, creating $searchstring"
        
        Invoke-sqlcmd -ServerInstance $script:servername  -Database "Master" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "CREATE DATABASE [DBLOG];"
    
        SDS-Print-host-information "Databse DBLOG has been created successfully"

        Invoke-sqlcmd -ServerInstance $script:servername  -Database "Master" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "USE [DBLOG]; exec sp_changedbowner 'sa';"
    
        SDS-Print-host-information "DB Owner changed to 'sa' for DBLOG"

        # Deploy Objects
        SDS_Deploy_Objects;


    }
}






function SDS-AddMailProfile
{
    
        Invoke-sqlcmd -ServerInstance $script:servername  -Database "Master" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "$script:MailProfileScript"
    
        SDS-Print-host-information "DBMail Created"



    
}




function SDS-AddLocation
{

    $locationid = $null
    $locationpath = $null
    $ismapped = $null
    $mapname = $null
    $uname = $null
    $pwd = $null

    $locationid = Read-Host "Enter Location ID[Number]:"
    $locationpath = Read-Host "Enter Location Path[Path]:"
    $ismapped = Read-Host "Create Map drive? [0/1]:"

    if ($ismapped -eq 1)
    {
        $mapname = Read-Host "Enter driver letter to be mapped to:"
        $uname = Read-Host "Enter User Name to be used to connect to the mapped drive:"
        $pwd = Read-Host "Enter Password to be used to connect to the mapped drive:"
    }

    
    
    Invoke-sqlcmd -ServerInstance $script:servername  -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "EXEC [DBLog].[usp_AddNewLocation] '$locationid', '$locationpath', $isMapped, '$mapname', '$uname', '$pwd'"
    
    SDS-Print-host-information "Location Created"
    
}




function SDS-AddBackup
{

    $dbname = $null
    $backupname = $null
    $backuplocationid = $null
    $mirrorlocationid = $null
    $backuptype = $null
    $drtransfer = $null
    $compressbackup = $null
    $localretentionday = $null
    $remoteretentionday = $null
    $backuptool = $null


    #SQL, RGT, LSD

	$dbname = Read-Host "Enter Database Name:"
	$backupname = Read-Host "Enter Name for the Backup [Ex: DB_FULL]:"
	$backuplocationid = Read-Host "Enter Location ID where backup should be copied [Number]:"
	$drtransfer = Read-Host "Do you want the backups to be transferred to DR Location [Yes = 1, No = 0]:"	
    $backuptype = Read-Host "Enter the backup Type [Full - D, Diff - I, Log - L]:"
	$compressbackup = Read-Host "Do you want the Backups to be Compressed [Yes = 1, No = 0]:"
	$localretentionday = Read-Host "Enter number of Days the backup has to be retained near line [Number]:"
	$backuptool = Read-Host "Which backupTool you want use to take backup (Tool should be installed already) [SQL\RGT\LSD]:"

    if ($drtransfer -eq 1)
    {
        $mirrorlocationid = Read-Host "Enter DR Location ID, Enter [0] if not setup yet [Number]:"
        $remoteretentionday = Read-Host "Enter number of Days the backup has to be retained off site [Number]:"
    }

    
    
    Invoke-sqlcmd -ServerInstance $script:servername  -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "EXEC [DBLog].[usp_AddBackupConfiguration] '$backupname', '$dbname', '$backuplocationid', '$mirrorlocationid', '$backuptype', '$drtransfer', '$compressbackup', '$localretentionday', '$remoteretentionday', '$backuptool'"
    
    SDS-Print-host-information "Backup for $backupname Created"
    
}




function SDS-AddAudit
{

    $LoginTracePath = $null
    $TSQLTracePath = $null
    $EnableLoginAudit = $null
    $EnableSQLAudit = $null

    $auditscriptlogin = ""
    $auditscriptTSQL = ""
    $finalscript = ""

    $LoginTracePath = Read-Host "Enter Path for Login Caching (X:\..\):"
    $TSQLTracePath = Read-Host "Enter Path for TSQL Caching (X:\..\):"
    $EnableLoginAudit = Read-Host "Do you want to enable Failed Login Audit (Y/N):"
    $EnableSQLAudit = Read-Host "Do you want to enable TSQL Audit (Y/N):"

     if ($EnableLoginAudit -eq "y")
     {
        $auditscriptlogin = "update DBLOG.DBLOG.Trace_Properties   set PropertyValue ='$LoginTracePath' where TraceName = 'AuditFailedLogin' and PropertyName = 'FolderPath'; "
        $finalscript = $auditscriptlogin
     }

     if ($EnableSQLAudit -eq "y")
     {
        $EnableLoginAudit = "update DBLOG.DBLOG.Trace_Properties   set PropertyValue ='$TSQLTracePath' where TraceName = 'AuditTSQL' and PropertyName = 'FolderPath'; "
        $finalscript = $finalscript + $EnableLoginAudit
     }
    
    if ($finalscript.Length -gt 5)
    {
    
    Invoke-sqlcmd -ServerInstance $script:servername  -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "$finalscript"
    SDS-Print-host-information "Auditing has been modified."
    }
    
    
}



function SDS-GetLocations
{
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection

    $user = $script:dp_usercred.UserName
    $pwd = $script:dp_usercred.GetNetworkCredential().Password

    $sqlStatement = "select LocationID, LocationPath from dblog.dblog.location_details"
    $sqlConnection.ConnectionString = "Server=$script:servername;Database=DBLOG;UID=$user;password=$pwd"
    try
    {
        $sqlConnection.Open()

        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = $sqlStatement

        $data = $sqlcmd.ExecuteReader()

        $table = New-Object System.Data.DataTable

        $table.Load($data)

        $table | Format-Table -AutoSize
    }
    catch
    {
        Write-Output -Verbose "Error executing SQL on database DBLOG on server [$servername]. Statement: `r`n$SqlStatement"
            
        return $null
    }
}
    







function SDS_Deploy_Objects()
{

    SDS-Print-header "Start Deploying Objects in Database"

    SDS-execute-scripts $script:servername  "I:\SVN_DBLOG\GLOBALSQL\DBLOG\DBLOG\"

    SDS-Print-header "Completed Deploying Objects in Database"
}







function SDS-execute-scripts($instance, $directory)
{
    $error = 0

    #create Schema
    SDS-Print-host-information "Creating DBLOG Schema"
    Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -Query "CREATE SCHEMA [DBLog] AUTHORIZATION [dbo];"
    SDS-Print-host-information "Created DBLOG Schema`n"
    #create tables
    $tables= "$directory\Tables"
    
    $files = Get-ChildItem $tables -Filter *.sql 


    SDS-Print-host-warning "Building Tables`n"
    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being executing"
        try
        {
            Invoke-Sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        }
        catch
        {
            $error = 1
            $ErrorMessage = $_.Exception.Message
            SDS-Print-host-error "$filename execution failed, $ErrorMessage"                        
        }


        if ($error -eq 0)
        {
            SDS-Print-host-information "$filename being executed"
        }

        $error = 0
        
    }
    write-host "`n`n"



    #create Primary Keys

    $error = 0
    $pk= "$directory\Tables\Keys"
    
    $files = Get-ChildItem $pk -Filter pk_*.sql 


    SDS-Print-host-warning "Building Primary Keys`n"
    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being executing"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being executed"
    }
    write-host "`n`n"


    #create Foriegn Keys
    $fk= "$directory\Tables\Keys"
    
    $files = Get-ChildItem $fk -Filter FK_*.sql 


    SDS-Print-host-warning "Building Foreign Keys`n"
    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }
    write-host "`n`n"



    #create Constraints
    $ck= "$directory\Tables\Constraints"
    
    $files = Get-ChildItem $ck -Filter *.sql 


    SDS-Print-host-warning "Building Constraints`n"

    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }
    write-host "`n`n"



    #create Indexes
    $idx= "$directory\Tables\Indexes"
    
    $files = Get-ChildItem $idx -Filter *.sql 


    SDS-Print-host-warning "Building Indexes`n"

    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }
    write-host "`n`n"


    #create Triggers
    $trg= "$directory\Tables\Triggers"
    
    $files = Get-ChildItem $trg -Filter *.sql 

    SDS-Print-host-warning "Building Triggers`n"


    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }
    write-host "`n`n"




    #create Views
    $vw= "$directory\Views"
    
    $files = Get-ChildItem $vw -Filter *.sql 

    SDS-Print-host-warning "Building Views`n"


    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }
    write-host "`n`n"



    #create stored procedures
    $sp= "$directory\Programmability\Stored Procedures"
    
    $files = Get-ChildItem $sp -Filter *.sql 

    SDS-Print-host-warning "Building Stored Procedures`n"

    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }

    write-host "`n`n"

    #create Post Deployment
    $Jobs= "$directory\PostDeployment"
    
    $files = Get-ChildItem $jobs -Filter *.sql 

    SDS-Print-host-warning "Building Jobs and Manual Scripts`n"

    foreach ($file in $files)
    {
        $filename = $file.FullName
        SDS-Print-host-information "$filename being exeuting"
        Invoke-sqlcmd -ServerInstance $instance -Database "DBLOG" -Username $script:dp_usercred.UserName -Password $script:dp_usercred.GetNetworkCredential().Password -InputFile $filename 
        SDS-Print-host-information "$filename being exeuted"
    }

    write-host "`n`n"


}


function SDS-VariableToScript
{

$script:MailProfileScript = "
declare @accountid int, @profileid int

IF NOT Exists (select 1 from msdb.dbo.sysmail_account where [name] = 'DBAMail')
BEGIN

	-- Create a Database Mail account
	EXECUTE msdb.dbo.sysmail_add_account_sp
		@account_name = 'DBAMail',
		@description = 'Mail account for DBLOG e-mail.',
		@email_address = 'globalsql@ebix.com',
		@replyto_address = 'globalsql@ebix.com',
		@display_name = 'DBA Mail',
		@mailserver_name = 'mail2.ebix.com' ;

	
END


IF NOT Exists(select * from msdb.dbo.sysmail_profile where [name]  = 'DBAMail')
begin
	-- Create a Database Mail profile
	EXECUTE msdb.dbo.sysmail_add_profile_sp
		@profile_name = 'DBAMail',
		@description = 'Profile used for DBLOG mail.' ;

	

END


select @accountid = account_id from msdb.dbo.sysmail_account where [name] = 'DBAMail';
select @profileid = profile_id from msdb.dbo.sysmail_profile where [name]  = 'DBAMail'


IF NOT Exists (select 1 from msdb.dbo.sysmail_profileaccount where profile_id = @profileid and account_id = @accountid)
BEGIN
		-- Add the account to the profile
	EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
		@profile_name = 'DBAMail',
		@account_name = 'DBAMail',
		@sequence_number =1 ;
END


if not exists (select 1 from msdb.dbo.sysmail_principalprofile where profile_id = @profileid)
BEGIN
	-- Grant access to the profile to the DBMailUsers role
	EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
		@profile_name = 'DBAMail',
		@principal_name = 'public',
		@is_default = 0 ;
END

"

}


function SDS-InitiateConection
{
            SDS-Get-ServerInput
            # Get Authentication Mode
            SDS-Input_WindowSQLAuth 
            #initiate connection
            $script:server = SDS-Set-connection($script:servername)  
            SDS-Print-header "Connection: $script:servername"
            SDS-get-dp_user
            clear-host
            copyright
}


function SDS-main
{
    clear-host
    copyright
    SDS-InitiateConection

    SDS-Input_Options

}

SDS-main;



