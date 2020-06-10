Function ConnectionString([string] $ServerName, [string] $DbName)

  {

    “Data Source=$ServerName;Initial Catalog=$DbName;User ID=dp_user; Password=D0ntAskMeAga1N;Connection Timeout=0”

  }



cls

$columns=@()

$debug = "0"

$SQLServer = “10.5.20.48”

$SQLDBName = "RTM”

$SqlQuery = "select serverIP from RTM.serverdetails where connectionstatus ='Connected' "

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection

$SqlConnection.ConnectionString = “Server=$SQLServer;Database=$SQLDBName;User ID=dp_user; Password=D0ntAskMeAga1N; Application Name=SHELL; Connection Timeout=300;”

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
                    
    $SrcServer = $row[0].ToString()
    $SrcDatabase = "DBLOG"

    if ($debug = "1")
    {
        write-host""
            $time = Get-Date
            write-host $time.ToShortDateString()  $time.ToShortTimeString()
        write-host $SrcServer
    }

    $SrcConnStr = ConnectionString $SrcServer $SrcDatabase
    $SrcConn  = New-Object System.Data.SqlClient.SQLConnection($SrcConnStr)
    $CmdText = “exec dblog.sp_exportRequestsAndUpdate"
    
    $SqlCommand = New-Object system.Data.SqlClient.SqlCommand($CmdText, $SrcConn) 
    $SQLcommand.CommandTimeout = 0
    try
    {
        if ($debug = "1")
        {
            
            write-host""
            $time = Get-Date
            write-host $time.ToShortDateString()  $time.ToShortTimeString()
            write-host "Reading Data from " $SrcServer
        }
        $SrcConn.Open()    
        [System.Data.SqlClient.SqlDataReader] $SqlReader = $SqlCommand.ExecuteReader()
        #write-host $sqlreader.HasRows
    }

    catch [System.Exception]
    {
        write-host "Connection or Reader Failed"
        $ex = $_.Exception
        Write-Host $ex.Message
    }

    finally
    {

    }
    Try  
    {

        $DestConnStr = ConnectionString "DBLOG" "PerformanceCollection"
        $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($DestConnStr)
        $bulkcopy.batchsize = 500
        $bulkcopy.BulkCopyTimeOut = 0
        $bulkCopy.DestinationTableName = "vw_RequestRaw"
        $bulkCopy.WriteToServer($sqlReader)
        
    }

    Catch [System.Exception]
    {
        write-host "Bulk Copy Failed Connection"
        $ex = $_.Exception
        Write-Host $ex.Message
    }

    Finally
    {
        if ($debug = "1")
        {
            write-host""
            $time = Get-Date
            write-host $time.ToShortDateString()  $time.ToShortTimeString()
            Write-Host “$SrcServer has been completed.”
        }
    }


}

Try  
{
    $SqlReader.close()
    $SrcConn.Close()
    $SrcConn.Dispose()
    $bulkCopy.Close()
}

Catch [System.Exception]
{
    write-host "Connection Closing Failed"
    $ex = $_.Exception
    Write-Host $ex.Message
}

Finally
{
    Write-Host “$SrcServer has been completed.”
}
