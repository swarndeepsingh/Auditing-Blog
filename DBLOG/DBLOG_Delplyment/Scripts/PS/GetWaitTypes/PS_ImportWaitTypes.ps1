cls

$columns=@()



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


    $results = Invoke-SQLCMD -Query "exec [DBLog].[sp_exportwaitstatusandupdate];" -ServerInstance "$DBLOGIP" -Username "dp_user" -Password "D0ntAskMeAga1N" -Database "DBLOG" -verbose 

    foreach($row in $results)
    {

        

        $insertquery = "INSERT INTO [dbo].[WaitStatsraw]
           ([servername]
           ,[WaitType]
           ,[wait_S]
           ,[Resource_S]
           ,[Signal_S]
           ,[WaitCount]
           ,[Avg_Wait_S]
           ,[Avg_Resource_S]
           ,[Avg_Signal_S]
           ,[CaptureDate])
     VALUES
           (
           '" + $row[0] + "', '" +     $row[1] + "','" +
		   $row[2]+ "','" +
		   $row[3]+ "','" +
		   $row[4]+ "','" +
		   $row[5]+ "','" +
		   $row[6]+ "','" +
		   $row[7]+ "','" +
		   $row[8]+ "','" +
		   $row[9] +"' )"

    
        
            Invoke-SQLCMD -Query "$insertquery" -ServerInstance "DBLOG"  -Database "PerformanceCollection" -verbose 
            

      
        
        for($i=0; $i -le $columns.Length-1; $i++)
        {
        $a=$i}
        
    }


}
