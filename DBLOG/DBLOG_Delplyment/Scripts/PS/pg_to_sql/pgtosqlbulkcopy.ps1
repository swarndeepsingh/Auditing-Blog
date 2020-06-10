#requires -version 2.0 
  Param (
      [parameter(Mandatory = $true)]
      [string] $SrcServer,
      [parameter(Mandatory = $true)]
      [string] $SrcDatabase,
      [parameter(Mandatory = $true)]
      [string] $SrcTable,
      [parameter(Mandatory = $true)]
      [string] $DestServer,
      [string] $DestDatabase, # Name of the destination database is optional. When omitted, it is set to the source database name.
      [string] $DestTable, # Name of the destination table is optional. When omitted, it is set to the source table name.
      [switch] $Truncate # Include this switch to truncate the destination table before the copy.
  )
 
  Function pgConnectionString([string] $ServerName, [string] $DbName)
  {
    $MyServer = $servername
    $MyPort  = "5432"
    $MyDB = $DbName
    $MyUid = "dev"
    $MyPass = "102Ebix29"

    $DBConnectionString = "Driver={PostgreSQL ANSI(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
  }


  Function ConnectionString([string] $ServerName, [string] $DbName)
  {
    "Data Source=$ServerName;Initial Catalog=$DbName;User ID=dp_user; Password=D0ntAskMeAga1N"
  }

 
  ########## Main body ############
  If ($DestDatabase.Length –eq 0) {
    $DestDatabase = $SrcDatabase
  }
 
  If ($DestTable.Length –eq 0) {
    $DestTable = $SrcTable
  }
 
  
 
    
Try
{

    $DBConnectionString = "Driver={PostgreSQL ANSI(x64)};Server=$SrcServer;Port=5432;Database=$SrcDatabase;Uid=dev;Pwd=102Ebix29;"
    #pgConnectionString $SrcServer $SrcDatabase
    #"Driver={PostgreSQL ANSI(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
    $DBConn = New-Object System.Data.Odbc.OdbcConnection;
    $DBConn.ConnectionString = $DBConnectionString;
    $DBConn.Open();
    $DBCmd = $DBConn.CreateCommand();
    $DBCmd.CommandText = "SELECT * FROM public." + $SrcTable
    $result=$DBCmd.ExecuteReader();
}
Catch [System.Exception]
{
    $ex = $_.Exception
    Write-Host $ex.Message
}
 
  Try
  {
    $DestConnStr = ConnectionString $DestServer $DestDatabase
    $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($DestConnStr, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
	$bulkCopy.BatchSize = 20000
    $bulkCopy.DestinationTableName = $DestTable
    $bulkCopy.WriteToServer($result)
  }
  Catch [System.Exception]
  {
    $ex = $_.Exception
    Write-Host $ex.Message
  }
  Finally
  {
    Write-Host "Table $SrcTable in $SrcDatabase database on $SrcServer has been copied to table $DestTable in $DestDatabase database on $DestServer"
    $DBConn.Close();
    
    $bulkCopy.Close()
  }