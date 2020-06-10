# Author: Swarndeep Singh
# Date: 1/14/2016
# Purpose: This script will be called from another script
# Purpose: Other scripts passes all the required parameters as mentioned below

#requires -version 2.0 

# Add parameters
  Param (
      	[parameter(Mandatory = $true)]
      	[string] $SrcServer,      
      	[parameter(Mandatory = $true)]
      	[string] $DestServer
  )
 
 
# Create function that returns new connection object
  Function ConnectionString([string] $ServerName)
  {
    "Data Source=$DestServer;Initial Catalog='master';User ID=dp_user; Password=D0ntAskMeAga1N"
  }
 

	

# Add new function. Functin is saved to a variable for later use
  
 	$source = 'namespace System.Data.SqlClient
	{    
 		using Reflection;
 
 		public static class SqlBulkCopyExtension
 		{
 			const String _rowsCopiedFieldName = "_rowsCopied";
 			static FieldInfo _rowsCopiedField = null;
 
 			public static int RowsCopiedCount(this SqlBulkCopy bulkCopy)
 			{
 				if (_rowsCopiedField == null) _rowsCopiedField = typeof(SqlBulkCopy).GetField(_rowsCopiedFieldName, BindingFlags.NonPublic | BindingFlags.GetField | BindingFlags.Instance);            
 				return (int)_rowsCopiedField.GetValue(bulkCopy);
 			}
 		}
	}'
	
# Add reference libraries just in case
	Add-Type -ReferencedAssemblies 'System.Data.dll' -TypeDefinition $source
	$null = [Reflection.Assembly]::LoadWithPartialName("System.Data")
 
# Populate and create new connection
	  $SrcConnStr = ConnectionString $SrcServer 
	  $SrcConn  = New-Object System.Data.SqlClient.SQLConnection($SrcConnStr)

# New command to make the source of data	  
	  $CmdText = "SELECT '" + $ChildGUID + "', '" + $ParentGUID + "',  * FROM " + $SrcTable

# New command to truncate the table
	  $truncateQuery = "truncate table $SrcTable"
	  #$truncatequery = "update $SrcTable set DatabaseName ='' where 1=2"
	  #Write-Host $CmdText
	  
# create command objects
	  $SqlCommand = New-Object system.Data.SqlClient.SqlCommand($CmdText, $SrcConn) 
	  $SqlCommandTruncate = New-Object system.Data.SqlClient.SqlCommand($truncateQuery, $SrcConn) 
	  
# Open Connection and load data in memory
	Try
	{
	  $SrcConn.Open()
	  [System.Data.SqlClient.SqlDataReader] $SqlReader = $SqlCommand.ExecuteReader()
	}
	Catch [System.Exception]
	{
		
		return 
	}
	
 
# Bulk copy loaded data into destination and then truncate the table
	Try
	  {
		$DestConnStr = ConnectionString $DestServer $DestDatabase
		$bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($DestConnStr, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
		$bulkCopy.BatchSize = 20000
		$bulkCopy.DestinationTableName = $DestTable
		$bulkCopy.WriteToServer($sqlReader)

		$rows = [System.Data.SqlClient.SqlBulkCopyExtension]::RowsCopiedCount($bulkcopy)

		$SrcConn.Close()

		$SrcConn.Open()
		$SqlCommandTruncate.ExecuteNonQuery()
		$SrcConn.Close()
		
	  	

		return $rows
		
	  }
	  Catch [System.Exception]
	  {
		$ex = $_.Exception
		return $ex.Message
	  }

# Clean the mess always to avoid memory leaks
	  Finally
	  {
		
		$SqlReader.close()
		
		#$SrcConn.Close()
		$SrcConn.Dispose()
		$bulkCopy.Close()
	  }