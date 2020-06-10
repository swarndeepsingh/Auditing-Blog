cls
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
    $dblogip
    try
    {
    SQLCMD -S "$DBLOGIP" -d "DBLOG" -U "dp_user" -P "D0ntAskMeAga1N" -i "F:\SVN_CHECKOUT\DBLOG\Scripts\PS\Other Powershells\Start_WaitTypeJobs\sqlscript.sql" 
    }
    Catch [System.Exception]
    {
        
        $ex = $_.Exception
        Write-Host $ex.Message
    }
}
