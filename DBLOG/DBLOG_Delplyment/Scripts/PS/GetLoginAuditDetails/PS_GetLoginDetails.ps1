cls

$columns=@()

$sqlscript_dbsize ="
declare @logins table
(
ServerName varchar(100), DatabaseName varchar(200), RoleName varchar(50), LoginName varchar(200), typedesc varchar(200)
)

insert into @logins
SELECT @@servername, 'ServerRole' [DatabaseName], c.name as Fixed_roleName, a.name as logins ,a.type_desc 
FROM sys.server_principals a 
  INNER JOIN sys.server_role_members b ON a.principal_id = b.member_principal_id
  INNER JOIN sys.server_principals c ON c.principal_id = b.role_principal_id
ORDER BY c.name 


insert into @logins
EXECUTE master.dbo.sp_MSforeachdb 'use [?]
SELECT @@servername, db_name()as DBNAME, c.name as DB_ROLE ,a.name as Role_Member, a.type_desc
FROM sys.database_principals a 
  INNER JOIN sys.database_role_members b ON a.principal_id = b.member_principal_id
  INNER JOIN sys.database_principals c ON c.principal_id = b.role_principal_id
WHERE a.name <> ''dbo''/*and c.is_fixed_role=1 */'

select * from @logins
"



#(size*8) SizeKB,
# cast((size*8) as bigint) SizeKB,
$SQLServer = “10.5.20.48”

$SQLDBName = "RTM”

$SqlQuery = "select serverIP from RTM.serverdetails where connectionstatus ='Connected'"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection

$SqlConnection.ConnectionString = “Server=$SQLServer;Database=$SQLDBName;User ID=dp_user; Password=D0ntAskMeAga1N; Application Name=SHELL;”

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand

$SqlCmd.CommandText = $SqlQuery

$SqlCmd.Connection = $SqlConnection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter

$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet

$SqlAdapter.Fill($DataSet)

$SqlConnection.Close()

foreach ($row in $DataSet.Tables[0].Rows)

{

    $DBLOGIP = $row[0].ToString()

    
    $date = Get-Date;
    #write-host "Getting Data From $DBLOGIP $date" -BackgroundColor White -ForegroundColor Black
    
    try
    {
        #write-host "Start executing results invoke-sqlcmd for $DBLOGIP"
        $results = Invoke-SQLCMD -Query "$sqlscript_dbsize" -ServerInstance "$DBLOGIP" -Username "dp_user" -Password "D0ntAskMeAga1N"  -verbose -QueryTimeout 0 -ConnectionTimeout 30
    }
    catch
    {
        write-host "Error getting the result from table"
        write-host "$DBLOGIP"
        write-host $sqlscript_dbsize
    }
    #write-host "Completed getting data From $DBLOGIP $date" - backgroundcolor Black



    foreach($row in $results)
    {

      
        try
        {
            #write-host "Start creating script for insert data"
            $insertquery = "INSERT INTO DataCollection.[Security].[LoginRolesRaw]
               ([servername]
               ,[DatabaseName]
               ,[RoleName]
               ,[LoginName]
               ,[typedesc]
               )
             VALUES
                   (
                   '" + $row[0] + "', '" +
                   $row[1] + "','" +
		           $row[2]+ "','" +
		           $row[3]+ "','" +
		           $row[4] +"' )"
         }
         catch
         {
            write-host "error populating the array for insertquery"

            write-host "$DBLOGIP"
            write-host $sqlscript_dbsize
            write-host $insertquery
         }



    
        

        try
        {
            #write-host "Start inserting data into destination"
            Invoke-SQLCMD -Query "$insertquery" -ServerInstance "DBLOG"  -Database "DataCollection" -verbose 
        }
        catch
        {
            Write-Host "Error inserting"
            write-host $insertquery
        }
            

      
    }


    
    


}
