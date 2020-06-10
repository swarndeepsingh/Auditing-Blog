## Start here ##

$SQLServer = “10.5.20.48”

$SQLDBName = “RTM”

$SqlQuery = "select serverIP from RTM.serverdetails where connectionstatus ='Connected'"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection

$SqlConnection.ConnectionString = “Server=$SQLServer;Database=$SQLDBName;User ID=dp_user; Password=D0ntAskMeAga1N”

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand

$SqlCmd.CommandText = $SqlQuery

$SqlCmd.Connection = $SqlConnection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter

$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet

$SqlAdapter.Fill($DataSet)

$SqlConnection.Close()

[System.Guid] $guidObject = [System.Guid]::NewGuid() 

$parentguid  = $guidObject.Guid

foreach ($row in $DataSet.Tables[0].Rows)

{
	[System.Guid] $guidObject = [System.Guid]::NewGuid() 
	$childguid  = $guidObject.Guid

	# Start of import process

	$Starttime = Get-Date
	$DBLOGIP = $row[0].ToString()

	#$Log=F:\SVN_CHECKOUT\DBLOG\Scripts\PS\ImportSM\scripts\bulkcopyDBUSAGE.ps1 -SrcServer $DBLOGIP -SrcDatabase "DBLOG" -SrcTable "DBLOG.DBUSAGE" -DestServer "10.5.20.48" -DestDatabase "DataCollection" -DestTable "dbo.DBUSAGE" -ChildGUID $childguid -ParentGUID $parentguid
    
       $DBLOGIP

	
	#end of import process

	$Endtime = Get-Date

	#Save log back to database

	
	$SqlConnectionOutput = New-Object System.Data.SqlClient.SqlConnection
	$SqlConnectionOutput.ConnectionString = “Server=$SQLServer;Database=DataCollection;User ID=dp_user; Password=D0ntAskMeAga1N”

	$SqlConnectionOutput.Open()

	
	#$query = "Insert into ExecutionLog (ProcessName, ParentBatchID, ChildBatchID, servername, tablename , starttime, endtime, message , Source) VALUES('DBUSAGE','" + $parentguid + "', '" + $childguid + "' , '" + $DBLOGIP + "', 'DBUSAGE', '" + $Starttime + "' , '" + $Endtime + "' , '" + $Log + "', 'PowerShell')";

	#Write-Host = $query

	#$SqlCmdOutput = New-Object System.Data.SqlClient.SqlCommand ($query, $SqlConnectionOutput )
	

	
	
	#$SqlCmdOutput.ExecuteNonQuery();
	$SqlConnectionOutput.Close()

}

