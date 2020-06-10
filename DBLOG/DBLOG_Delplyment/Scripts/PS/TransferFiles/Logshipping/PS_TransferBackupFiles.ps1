cls
$srcFolder=""
$destFolder=""
$SQLServer = "an3prodsql01"
$SQLDBName = "DBLOG"
$uid ="dp_user"
$pwd = "D0ntAskMeAga1N"
$SqlQuery = "SELECT  top 1 [Transfer_ID]
       ,sourceloc.LocationPath + '\' + BI.DBName [SourceFolder]
	  ,sourceloc.UserName [srcUser]
	  ,len(rtrim(ltrim(isnull(sourceloc.UserName,'')))) [srcUserExists]
	  ,cast(decryptbypassphrase(mp.propertyvalue,sourceloc.pword) as varchar) [srcPwd]
	  ,sourceloc.ISMapped [srcIsMapped]
	  ,destloc.locationpath + '\' + BI.DBName [DestinationFolder]
	  ,destloc.UserName [destUser]
	  ,len(rtrim(ltrim(destloc.UserName))) [destUserExists]
	  ,cast(decryptbypassphrase(mp.Propertyvalue, destloc.Pword) as varchar) [destPwd]
	  ,destloc.ISMapped [destIsMapped]
	  --,substring([source],	0,		len(source)+2-charindex('\',reverse([source]),0)) 
	  ,reverse(substring(reverse([source]),	0,	charindex('\',reverse([source]),0))) [FileName]
      ,[Status]
      ,[startdate]
      ,[enddate]
	  , mp.propertyvalue [Passphrase]
	  , BI.DBName
  FROM [DBLOG].[DBLog].[Backup_transfer_Job] btj
	join dblog.dblog.location_details destloc
		on destloc.LocationID = btj.DestinationLocationID
	join dblog.dblog.location_details sourceloc
		on sourceloc.LocationID = btj.SourceLocationID
	join dblog.dblog.MiscProperties mp
		on PropertyName = 'Location_Password_1'
	join dblog.dblog.Backup_info BI
		on BI.Backup_ID = btj.Backup_ID
  where status = 'Pending'
  and reverse(substring(reverse([source]),	0,	charindex('\',reverse([source]),0))) like '%.dmp'
  order by transfer_id asc;"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True; User ID = 
$uid; Password = $pwd;"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)




if ($dataset.Tables[0].rows.count -gt 0)
{

	$row = $DataSet.Tables[0].Rows[0]

    # set Source Map Drive
    if($row.srcUserExists -gt 0)
    {
        # get a free drive letter
        $drivearray=@(ls function:[d-z]: -n|?{!(test-path $_)})
        $sourcemapdrive = $drivearray[$drivearray.length-1]
        $net.MapNetworkDrive($sourcemapdrive, $($row.SourceFolder),"$false",$row.srcUser,$row.srcPwd)
        $srcFolder = $sourcemapdrive
    }
    else
    {
        $srcFolder = $row.SourceFolder
    }

    #set Destination Map Drive
    if($row.destUserExists -gt 0)
    {
        # get a free drive letter
        $drivearray=@(ls function:[d-z]: -n|?{!(test-path $_)})
        $destinationmapdrive = $drivearray[$drivearray.length-1]
        $net.MapNetworkDrive($destinationmapdrive, $($row.DestinationFolder),"$false",$row.destUser,$row.destPwd)
        $destFolder = $destinationmapdrive
    }
    else
    {
        $destFolder = $row.DestinationFolder
    }

    write-host $srcFolder $destFolder

    # $row.SourceFolder + "\" + $row.filename  + "_transfer_log.log /R:5 /W:180 /Z /tee /np /copy:DT"

    #write-host "`n Transferring "  $row.FileName

    #write-host $command

    #$result = robocopy  $($srcFolder)  $($destFolder)  $($row.FileName)/log:$($row.SourceFolder)\$($row.filename)_transfer_log.log /R:5 /W:180 /Z /tee /np /copy:DT

    #xcopy 
    #robocopy $command

    #$result

    #write-host "Transferred"
	

}
else
{
    write-host "No Data, quiting"
}