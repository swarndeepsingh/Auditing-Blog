cls
$SQLServer = “10.5.20.48”

$SQLDBName = "healthsmart”

$SqlQuery = "select name from sys.tables where is_ms_shipped=0 "





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
    cd F:\dblogrepo_svn\DBLOG\Scripts\PS\pg_to_sql
    $table=$row.name
    ./pgtosqlbulkcopy "10.5.20.74" "healthsmart_qhix" "$table" "10.5.20.48" "healthsmart" "$table"
    #SQLCMD -S "$DBLOGIP" -d "DBLOG" -U "dp_user" -P "D0ntAskMeAga1N" -i "F:\SVN_CHECKOUT\DBLOG\Scripts\PS\Other Powershells\Update_All_DBs\Update582018.sql" 
    write-host $row.name
    }
    catch
    {
    Write-Host "Error: $dblogip" -BackgroundColor Red -ForeGroundColor Yellow
    }
    #-h-1 >> output.txt

}