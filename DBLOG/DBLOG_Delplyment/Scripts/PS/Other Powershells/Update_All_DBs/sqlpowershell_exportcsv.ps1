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
        Invoke-sqlcmd -ServerInstance "$DBLOGIP" -Database "DBLOG" -User "dp_user" -Password "D0ntAskMeAga1N" -Query "select distinct @@servername [ServerName], DBName from dblog.dblog.backup_info where backuptoolid = 'RGT' and [enabled] = 1" | Export-CsV -Path "C:\DBLOG.csv" -NoTypeInformation -Delimiter ","  -Append 
    }
    catch
    {
        Write-Host "Error: $dblogip" -BackgroundColor Red -ForeGroundColor Yellow
        write-host $_.Exception.Message
    }
    #-h-1 >> output.txt

}
