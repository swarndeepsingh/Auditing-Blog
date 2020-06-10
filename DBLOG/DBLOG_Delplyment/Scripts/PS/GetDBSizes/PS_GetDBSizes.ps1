cls

$columns=@()

$sqlscript_dbsize ="declare @DatabasSizeRaw table(
	[ServerName] [nvarchar](256) NOT NULL,
	[DatabaseName] [nvarchar](256) NOT NULL,
	[type_Desc] [varchar](20) NULL,
	[LogicalName] [varchar](256) NOT NULL,
	[FileName] [varchar](8000) NOT NULL,
	[SizeKB] [bigint] NOT NULL,
	[UsedKB] [bigint] NULL,
	[GrowthType] [varchar](50) NULL,
	[Growth] [bigint] NULL,
	[MaximumSize] [bigint] NULL,
	[CollectionDateTime] [datetime] NOT NULL
	)

insert into @DatabasSizeRaw
exec sp_msforeachdb '
use [?];
select 
@@servername [ServerName]
,''?'' [DatabaseName]
, type_desc
 , name [LogicalName]
 , physical_name [FileName]
 , cast(size as bigint)*8 [SizeKB]
 , case type when 2 then 0 else cast(FILEPROPERTY(NAME, ''SPACEUSED'') as bigint)*8 end as [SpaceUsedKB]
 ,  case is_percent_growth when 1 then ''Percent'' Else ''MB'' End as [GrowthType]
 , case is_percent_growth when 1 then growth else growth * 8 END as [Growth]
 , case max_size when -1 then -1 else cast(max_size as bigint) * 8 end as [MaximumSize]
 , getdate() [CollecteDate]
  from sys.database_files'

select * from @DatabasSizeRaw"



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
            $insertquery = "INSERT INTO DataCollection.[dbo].[DataFilesSizeRaw]
               ([servername]
               ,[DatabaseName]
               ,[type_Desc]
               ,[LogicalName]
               ,[FileName]
               ,[SizeKB]
               ,[UsedKB]
               ,[GrowthType]
               ,[Growth]
               ,[MaximumSize]
               ,[CollectionDateTime])
             VALUES
                   (
                   '" + $row[0] + "', '" +
                   $row[1] + "','" +
		           $row[2]+ "','" +
		           $row[3]+ "','" +
		           $row[4]+ "','" +
		           $row[5]+ "','" +
		           $row[6]+ "','" +
		           $row[7]+ "','" +
		           $row[8]+ "','" +
		           $row[9]+ "','" +
		           $row[10] +"' )"
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
