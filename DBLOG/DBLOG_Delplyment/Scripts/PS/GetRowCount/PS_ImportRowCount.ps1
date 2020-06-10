cls

$columns=@()

$sqlscript_rowcount ="create table #tablessize
(
	Servername nvarchar(1000),
	DatabaseName nvarchar(256),
	schemaname nvarchar(256),
	TableName nvarchar(256),
	RowsCount bigint,
	ReservedSizeKB bigint,
	DatasizeKB bigint,
	IndexSizeKB bigint,
	UnusedKB bigint,
	collectdate datetime
)

create table #tablesize
			(
	
				TableName nvarchar(256),
				RowsCount varchar(100),
				ReservedSizeKB varchar(100),
				DatasizeKB varchar(100),
				IndexSizeKB varchar(100),
				UnusedKB varchar(100)
			)


	declare @schname varchar(256), @tabname varchar(256)
	declare @schemaname varchar(256)
	declare @dbname nvarchar(256)
	declare @sqlstring nvarchar(2048)

	declare dblist cursor fast_forward for 
	select name from sys.databases where name not in ('tempdb', 'model') and   state_Desc = 'online'
	open dblist
	fetch next from dblist into @dbname
	while (@@FETCH_STATUS = 0)
	begin

		declare @schtab table (schemaname varchar(256),tabname varchar(256))

		
		set @sqlstring = N'use [' + @dbname  + ']; select sch.name , obj.name [TableName]  from sys.objects obj
		join sys.schemas sch
		on sch.schema_id = obj.schema_id
			where type in (''U'', ''S'', ''IT'') and is_ms_shipped = 0'
		
		delete from @schtab

		insert into @schtab
		exec sp_executesql @sqlstring

		--select * from @schtab

		declare tablist cursor fast_forward for
		select * from @schtab

		open tablist
		fetch next from tablist into @schemaname, @tabname
		while (@@fetch_status = 0 )
		begin

			set @sqlstring = 'use [' + @dbname  + ']; exec sp_spaceused ''[' + @schemaname + '].[' + @tabname + ']'''
			
			insert into #tablesize
			exec sp_executesql  @sqlstring

			insert into #tablessize
			select @@servername [ServerName]
			, @dbname [DatabaseName]
			, @schemaname [Schemaname]
			
			, TableName, 
			cast(left(RowsCount, datalength(rowscount)) as bigint) [RowCount], 
			cast(left(ReservedSizeKB, datalength(ReservedSizeKB)-2)as bigint) [ReservedSizeKB],
			cast(left(DatasizeKB, datalength(DatasizeKB)-2)as bigint) [DatasizeKB],
			cast(left(IndexSizeKB, datalength(IndexSizeKB)-2)as bigint) [IndexSizeKB],
			cast(left(UnusedKB, datalength(UnusedKB)-2)as bigint) [UnusedKB],
			getdate()  [CollectionDate]
			from #tablesize

			truncate table #tablesize

			fetch next from tablist into @schemaname, @tabname
		end
		close tablist
		deallocate tablist

		fetch next from dblist into @dbname
	end
	close dblist
	deallocate dblist


	select ServerName, DatabaseName, SchemaName, TableName, RowsCount, ReservedSizeKB, DataSizeKB, IndexSizeKB, UnusedKB, CollectDate, convert(varchar, collectdate, 111) /*cast(collectdate as date)*/ [Date] from #tablessize

	drop table #tablessize
	drop table #tablesize"

$SQLServer = “10.5.20.48”

$SQLDBName = "RTM”

$SqlQuery = "select serverIP from RTM.serverdetails where connectionstatus ='Connected' "

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

    
    try
    {
    $date = Get-Date;
    write-host "Getting Data From $DBLOGIP $date" -BackgroundColor White -ForegroundColor Black
    $results = Invoke-SQLCMD -Query "$sqlscript_rowcount" -ServerInstance "$DBLOGIP" -Username "dp_user" -Password "D0ntAskMeAga1N"  -verbose -QueryTimeout 0 -ConnectionTimeout 30
    #write-host "Completed getting data From $DBLOGIP $date" - backgroundcolor Black



    foreach($row in $results)
    {

        

        $insertquery = "INSERT INTO [dbo].[TableSizeRaw]
           ([servername]
           ,[DatabaseName]
           ,[SchemaName]
           ,[TableName]
           ,[RowsCount]
           ,[ReservedSizeKB]
           ,[DataSizeKB]
           ,[IndexSizeKB]
           ,[UnusedKB]
           ,[CollectDateTime]
           ,[CollectDate])
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

    
        #Write-Host $insertquery

            Invoke-SQLCMD -Query "$insertquery" -ServerInstance "DBLOG"  -Database "DataCollection" -verbose 
            

      
        
        #for($i=0; $i -le $columns.Length-1; $i++)
        
        #{
        #$a=$i}
        
    }


    }
    catch
    {
    write-host $sqlscript_rowcount
    }

    


}
