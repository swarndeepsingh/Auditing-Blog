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


foreach ($row in $DataSet.Tables[0].Rows)

{

	# Start of import process

	$Starttime = Get-Date
	$DBLOGIP = $row[0].ToString()

	$Log=C:\DBLOG_Powershell\Import_ClusterInfo\scripts\bulkcopy.ps1 -SrcServer $DBLOGIP -DestServer "10.5.20.48" 
	
	#end of import process

	$Endtime = Get-Date


}

