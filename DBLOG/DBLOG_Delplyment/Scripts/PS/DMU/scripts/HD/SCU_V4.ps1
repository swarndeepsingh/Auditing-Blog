#############################################################
#############################################################


#
#  Mention Change ( Include Data / Change By / Summary ) above this Line:

#  SCU Version 4.0
#  Dated -  05/11/2016


#############################################################
#############################################################



# Load SMO
#[System.Reflection.Assembly]::LoadWithPartialName("microsoft.sqlserver.smo") | Out-Null
Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
$LINES= "-" *70
#Import-Module sqlps
$sqlaccount= "N'sa'"
$drive="H:"

function Get-CmdbAdminCredentials {
    Get-Credential -Message "Enter credentials for CMDB admin" -UserName "CMDB_Admin"
}


# GET VARIABLES ROUTINE
function GET_VARIABLES() 
{

    $SCRIPT:SRV = ""
    $SCRIPT:SRV2 = ""
    $SCRIPT:SRV3 = ""
    $SCRIPT:SRV4 = ""
    $ANSWER=""
    $ANSWER2=""
    $ANSWER3=""
    $CONNECTION = ""
    
    $Answer  = Read-Host "Enter server name or hit <ENTER> to abort"
    
    if ($Answer -eq "" )
    {
    exit
    }
    
    write-host `n
    $LINES
    write-host "SQL Server instances & components discovered on $Answer"
    
    $Service = get-service -computerName $ANSWER | Where-Object  {$_.DisplayName -match "SQL"} 
    $Service 
    $LINES
    write-host `n

    $Answer2 = Read-Host "Enter instance name or hit <ENTER> for default name (MSSQLSERVER)"
    write-host `n
    
    if ($Answer2 -eq "" )
    {
    $ANSWER2 = "MSSQLSERVER"
    $ANSWER3 = "DEFAULT"
    $CONNECTION=$ANSWER
    }

    else    
    {
    $CONNECTION=$ANSWER+"\"+$ANSWER2
    $ANSWER3 = "NAMED"
    }
   
    $SCRIPT:SRV  = $CONNECTION  #$CONNECTION=$ANSWER+"\"+$ANSWER2
    $SCRIPT:SRV2 = $Answer      #server
    $SCRIPT:SRV3 = $Answer2     #instance 
    $SCRIPT:SRV4 = $ANSWER3     #named / default
    
    $LINES
    SplashScreen_II
    Menuscreen_II

    $hit_enter = read-host "Hit <ENTER> to continue"
}


function CHANGE_SERVICE_ACCT
{

    write-host "Configuring SQL Server services on $SRV2"
  
    $ANSWER5 = $SRV4
    $ANSWER6 = $SRV2
    $ANSWER7 = $SRV3

    if ($ANSWER5 -eq "NAMED")    #MSSQL$      #SQLAgent$                  
    {
    (Get-WmiObject -computername $ANSWER6 -Namespace "root\microsoft\sqlserver\computermanagement11" -Class "SqlService" | Where-Object {$_.ServiceName -eq 'MSSQL$'+$ANSWER7}).SetServiceAccount("AMER\_svcuser3", '_$Vc$qlu$er3') |
        Out-Null

    (Get-WmiObject -computername $ANSWER6 -Namespace "root\microsoft\sqlserver\computermanagement11" -Class "SqlService" | Where-Object {$_.ServiceName -eq 'SQLAgent$'+$ANSWER7}).SetServiceAccount("AMER\_svcuser3", '_$Vc$qlu$er3') |
        Out-Null
    
    start-service -inputobject $(get-service -ComputerName $ANSWER6 -Name "MSSQL`$$($ANSWER7)")
    start-service -inputobject $(get-service -ComputerName $ANSWER6 -Name "SQLAgent`$$($ANSWER7)")
    }


  
    if ($ANSWER5 -eq "DEFAULT")  #MSSQLSERVER 
    {
    (Get-WmiObject -computername $ANSWER6 -Namespace "root\microsoft\sqlserver\computermanagement11" -Class "SqlService" | Where-Object {$_.ServiceName -eq 'MSSQLSERVER'}).SetServiceAccount("AMER\_svcuser3", '_$Vc$qlu$er3') |
        Out-Null

    (Get-WmiObject -computername $ANSWER6 -Namespace "root\microsoft\sqlserver\computermanagement11" -Class "SqlService" | Where-Object {$_.ServiceName -eq 'SQLSERVERAGENT'}).SetServiceAccount("AMER\_svcuser3", '_$Vc$qlu$er3') |
        Out-Null
    
    start-service -inputobject $(get-service -ComputerName $ANSWER6 -Name MSSQLSERVER)
    start-service -inputobject $(get-service -ComputerName $ANSWER6 -Name SQLSERVERAGENT)
    }


}

function ADD_USER
{
    write-output $LINES
    write-host "Adding SQL Server service account to local administrators on $SRV2"
    $computerName = $SRV2
    $userName = "_svcuser3"  
    $localGroupName = "administrators"
  
    if ($computerName -eq "") {$computerName = "$env:computername"}  
    [string]$domainName = ([ADSI]'').name  
    ([ADSI]"WinNT://$computerName/$localGroupName,group").Add("WinNT://$domainName/$userName") 

}

function CONFIGURE_MOUNT_POINT_PERMISSIONS
{
    write-host "Configuring Mount Point Permissions on $SRV2"

    Invoke-Command -ComputerName $SRV2 -ScriptBlock {
    $AccountName = "amer\_svcuser3"

    foreach ($call in (
        Get-WmiObject -Class "Win32_MountPoint" |
            Select-Object Directory, Volume,
                @{Name = "DirParsed"; Expression = {
                    [string]$dir = $_.Directory

                    $dirInt = $dir.Substring($dir.IndexOf('"'))

                    $dirInt.Substring(1, $dirInt.Length - 2)
                }} |
            Where-Object {$_.DirParsed.Length -gt 4} |
            Select-Object @{Name = "icacls_cmd"; Expression = 
            { 
                $VolTemp = $_.Volume.Replace("\\", "\") 

                "icacls.exe $($VolTemp.Substring($VolTemp.IndexOf('"'))) /grant `"$($AccountName):(OI)(CI)(F)`""
            }})) {
    
        Invoke-Expression $call.icacls_cmd
        #Write-Host $call.icacls_cmd -ForegroundColor Yellow
    }
} 
}


function CONFIRMATION
{
    Write-Output $LINES
    write-host
    Write-host "Process Completed"
    write-host "PLEASE VERIFY!!!"
    write-host
    Write-Output $LINES

    $hit_enter = read-host "Hit <ENTER> to continue"
}


#############################################################
#  1.1 The CREATE_USP_TDP_BACKUP_JOB_MASTER routine creates
#  the usp_tdp_backup_job_master stored procedure.
#############################################################

function CREATE_USP_TDP_BACKUP_JOB_MASTER()
{

$SqlQueryText = @"
 USE msdb
GO

IF EXISTS (SELECT [name] FROM sysobjects WHERE [name] = 'usp_tdp_backup_job_master' AND type = 'P')
   DROP PROCEDURE usp_tdp_backup_job_master
GO

----------------------------------------------------------------------------------
-- Author:	Nick Tornese														--
-- Date:	02/24/2006															--
-- Procedure:	usp_tdp_backup_job_master										--
-- Parameters:	@maxdelay INT - Maximum delay (hhhmmss) between starting jobs	--
-- Dependancies: This function must be in place in order to work properly		--
--					msdb.dbo.usp_get_job_status									--
-- Description:	Launches TDP Full Database Backup Jobs Sequentially.			--
-- Modifications:  changed delay mechanism to sleep 10 seconds, check           --
--                 for job status, then run next job after completion           --
--                  tbs - 4/27/09                                               --
----------------------------------------------------------------------------------
CREATE PROCEDURE usp_tdp_backup_job_master
	@maxdelay INT = 230	-- Maximum delay (hhhmmss) between starting jobs

WITH ENCRYPTION
AS
DECLARE @job_id		UNIQUEIDENTIFIER,
		@job_name	SYSNAME,
		@duration	CHAR(9),
		@maxdur		CHAR(9),
		@intdur		INT,
		@job_start	INT,
		@rowcount	INT,
		@job_stat	INT,
		@msg		VARCHAR(2048),
        @status     INT,
        @counter    INT,
        @sleep      char(9)


SET @counter = 0
SET @status = -1
SET @rowcount = 0


SELECT @maxdur = LEFT(REPLACE(STR(ISNULL(@maxdelay,100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(@maxdelay,100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(@maxdelay,100),7,0),' ', '0'),2)

DECLARE job INSENSITIVE CURSOR FOR
	/*------------------------------------------------------------
-- Modified on 02.20.14 by Avi
-- Grouping Multiple steps to avoid Multiple Backups
-----------------------------------------------------------*/

	----SELECT	A.job_id, A.[name],
	----	LEFT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),3) + ':' +
	----	SUBSTRING(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),4,2) + ':' +
	----	RIGHT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),2),
	----	B.[last_run_duration]
	----FROM msdb.dbo.sysjobs A
	----INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	----INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	----INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	----WHERE A.[name] LIKE 'Full Database Backup for %'
	----AND A.[name] <> '!Database Backup Master'
	----AND A.enabled = 1 AND D.enabled != 1
	----ORDER BY B.[last_run_duration]
	
		SELECT	A.job_id, A.[name]
		,LEFT(REPLACE(STR(ISNULL(sum(B.last_run_duration),100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(sum(B.last_run_duration),100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(sum(B.last_run_duration),100),7,0),' ', '0'),2)
		,sum(B.last_run_duration) last_run_duration
	FROM msdb.dbo.sysjobs A
	INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	WHERE A.[name] LIKE 'Full Database Backup for %'
	AND A.[name] <> '!Database Backup Master'
	AND A.enabled = 1 AND D.enabled != 1
	group by A.job_id, A.[name]
	ORDER BY sum(B.last_run_duration)

OPEN job
FETCH NEXT FROM job INTO @job_id, @job_name, @duration, @intdur

WHILE @@fetch_status = 0
BEGIN
    SET @rowcount = @rowcount + 1
   
    exec  usp_get_job_status  @job_id, @status OUTPUT
    
    IF (@status = 0)
    BEGIN
            PRINT @job_name + ' is not currently running'
		EXEC @job_start = sp_start_job @job_id = @job_id

		IF @job_start = 0
		BEGIN
			PRINT 'Job started at ' + CONVERT(VARCHAR(26), GetDate(), 109)
                  PRINT 'Sleeping 5 seconds so job status can be updated'
                  WAITFOR DELAY '00:00:05'

			IF @rowcount != @@CURSOR_ROWS
			BEGIN
                     exec  usp_get_job_status  @job_id, @status OUTPUT
               
                     WHILE @status = 1
                     BEGIN
                        PRINT ' Job running, sleeping 30 seconds'
                        WAITFOR DELAY '00:00:30'
                        exec  usp_get_job_status  @job_id, @status OUTPUT                  
                     END
			END
		END
	END
	ELSE IF (@status = 1)
      BEGIN
         WHILE @status = 1
         BEGIN
            WAITFOR DELAY '00:00:30'
            PRINT ' Job running, sleeping 30 seconds'
            exec  usp_get_job_status  @job_id, @status OUTPUT
           
         END
      END
      ELSE
	BEGIN
		PRINT @msg
	END

	FETCH NEXT FROM job INTO @job_id, @job_name, @duration, @intdur
END
CLOSE job
DEALLOCATE job
GO
"@

  
Invoke-Sqlcmd -ServerInstance $SRV -query $SqlQueryText

}


##########################################################
#  1.2 The CREATE_USP_TDP_TLOGBKUP_JOB_MASTER routine creates
#  the USP_TDP_TLOGBKUP_JOB_MASTER stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_USP_TDP_TLOGBKUP_JOB_MASTER()
{

$SqlQueryText = @"
 USE msdb
GO

IF EXISTS (SELECT [name] FROM sysobjects WHERE [name] = 'usp_tdp_tlogbkup_job_master' AND type = 'P')
   DROP PROCEDURE usp_tdp_tlogbkup_job_master
GO

----------------------------------------------------------------------------------
-- Author:	Nick Tornese														--
-- Date:	02/23/2006															--
-- Procedure:	usp_tdp_tlogbkup_job_master								--
-- Parameters:	@maxdelay INT - Maximum delay (hhhmmss) between starting jobs	--
-- Dependancies: This function must be in place in order to work properly		--
--					msdb.dbo.usp_get_job_status									--
-- Description:	Launches TDPSQL TLog Backup Jobs Sequentially.					--
--              4/29/09 - tbs - made changes to check every 10 seconds for job  --
--                              to finish before starting next job              --
----------------------------------------------------------------------------------
CREATE PROCEDURE usp_tdp_tlogbkup_job_master
	@maxdelay INT = 30	-- Maximum delay (hhhmmss) between starting jobs

WITH ENCRYPTION
AS
DECLARE @job_id		UNIQUEIDENTIFIER,
		@job_name	SYSNAME,
		@duration	CHAR(9),
		@maxdur		CHAR(9),
		@intdur		INT,
		@job_start	INT,
		@rowcount	INT,
		@job_stat	INT,
		@msg		VARCHAR(2048),
                @status     INT,
                @counter    INT,
                @sleep      char(9)

 
SET @counter = 0
SET @status = -1
SET @rowcount = 0

SELECT @maxdur = LEFT(REPLACE(STR(ISNULL(@maxdelay,100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(@maxdelay,100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(@maxdelay,100),7,0),' ', '0'),2)

DECLARE job INSENSITIVE CURSOR FOR
	/*------------------------------------------------------------
-- Modified on 02.20.14 by Avi
-- Grouping Multiple steps to avoid Multiple Backups
-----------------------------------------------------------*/

	--SELECT	A.job_id, A.[name],
	--	LEFT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),3) + ':' +
	--	SUBSTRING(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),4,2) + ':' +
	--	RIGHT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),2),
	--	B.[last_run_duration]
	--FROM msdb.dbo.sysjobs A
	--INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	--INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	--INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	--WHERE A.[name] LIKE 'TLog Backup for %'
	--AND A.[name] <> '!TLog Backup Master' AND D.enabled != 1
	--ORDER BY B.[last_run_duration]
	
		SELECT	A.job_id, A.[name],
		LEFT(REPLACE(STR(ISNULL(sum(B.last_run_duration),100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(sum(B.last_run_duration),100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(sum(B.last_run_duration),100),7,0),' ', '0'),2),
		sum(B.last_run_duration)
	FROM msdb.dbo.sysjobs A
	INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	WHERE A.[name] LIKE 'TLog Backup for %'
	AND A.[name] <> '!TLog Backup Master' AND D.enabled != 1
	group by A.job_id, A.[name]
	ORDER BY 	sum(B.last_run_duration)

OPEN job
FETCH NEXT FROM job INTO @job_id, @job_name, @duration, @intdur

WHILE @@fetch_status = 0
BEGIN
	SET @rowcount = @rowcount + 1

    -- tbs - check if job is currently running
   
    exec  usp_get_job_status  @job_id, @status OUTPUT

	IF (@status = 0)
	BEGIN
        PRINT @job_name + ' is not currently running'
		EXEC @job_start = sp_start_job @job_id = @job_id

		IF @job_start = 0
		BEGIN
			PRINT '	Job started at ' + CONVERT(VARCHAR(26), GetDate(), 109)
            PRINT ' Sleeping 5 seconds so job status can be updated'
            WAITFOR DELAY '00:00:05'
			IF @rowcount != @@CURSOR_ROWS
			BEGIN
               exec  usp_get_job_status  @job_id, @status OUTPUT
               
               WHILE @status = 1
               BEGIN
                  PRINT ' Job running, sleeping 10 seconds'
                  WAITFOR DELAY '00:00:10'
                  exec  usp_get_job_status  @job_id, @status OUTPUT                  
               END
			END
		END
	END
	ELSE IF (@status = 1)
    BEGIN
       WHILE @status = 1
       BEGIN
          WAITFOR DELAY '00:00:10'
          PRINT ' Job running, sleeping 10 seconds'
          exec  usp_get_job_status  @job_id, @status OUTPUT
           
       END
    END
    ELSE
	BEGIN
		PRINT @msg
	END

	FETCH NEXT FROM job INTO @job_id, @job_name, @duration, @intdur
END
CLOSE job
DEALLOCATE job
GO
"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


##########################################################
#  1.3 The CREATE_USP_TDP_CREATE_TLOG_MONITOR routine creates
#  the USP_TDP_CREATE_TLOG_MONITOR stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_USP_TDP_CREATE_TLOG_MONITOR()
{
$SqlQueryText = @"
----------------------------------------------------------------------------------
-- Author:	Nick Tornese														--
-- Modified:	2/01/06															--
-- Procedure:	usp_tdp_create_tlog_monitor										--
-- Description: Discovers new databases and creates TLog Monitor Alert.			--
-- 		Also update alert with missing response jobs.							--
-- 		Also removes Tlog Monitor Alerts when a database is dropped.			--
-- Parameters: None																--
--                 																--
--                 																--
----------------------------------------------------------------------------------

USE msdb
GO

-- DROP usp_tdp_create_tlog_monitor if it exists
IF EXISTS (SELECT [name] FROM sys.objects WHERE [name] = 'usp_tdp_create_tlog_monitor' AND [type] = 'P')
	DROP PROCEDURE usp_tdp_create_tlog_monitor
GO


-- CREATE usp_create_tlog_monitor
CREATE PROCEDURE usp_tdp_create_tlog_monitor
-- Arguments passed to procedure
	@threshold	NVARCHAR(3) = '70'	-- Theshold in percentage for initiating a TLog backup

WITH ENCRYPTION
AS

SET NOCOUNT ON

-- Create Alerts
DECLARE	@dbname		NVARCHAR(128),	-- Holds database name from cursor
		@alertname	NVARCHAR(128),	-- Name of alert
		@instance	NVARCHAR(128),	-- Instance name for performance counter
		@perf		NVARCHAR(256),	-- The performance Condition to monitor
		@jobname	NVARCHAR(256),	-- Name of job to fire as a response
		@jobid		BINARY(16)	-- ID of job to fire as a response

SELECT	@instance = CASE CHARINDEX('\', @@SERVERNAME) WHEN 0 THEN 'SQLSERVER'
		ELSE 'MSSQL$' + CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128)) END

DECLARE DBNAME CURSOR FOR
	SELECT	[name], 'TLog Backup for ''' + [name] + ''''
	FROM	master.sys.databases
	WHERE	[name] NOT IN ('master','msdb','model','AdventureWorks','AdventureWorksDW','tempdb')
	AND	DATABASEPROPERTY([name],'IsInStandby') = 0
	AND	DATABASEPROPERTY ([name],'IsInLoad') = 0
	AND	DATABASEPROPERTY ([name],'IsOffline') = 0
	AND	DATABASEPROPERTY ([name],'IsSuspect') = 0
	AND	DATABASEPROPERTY ([name],'IsTruncLog') = 0
	AND   source_database_id is null
	ORDER BY [name]

OPEN DBNAME
FETCH NEXT FROM DBNAME INTO @dbname, @jobname

WHILE (@@fetch_status = 0)
BEGIN
	IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysalerts WHERE performance_condition LIKE 'SQLServer:Databases|Percent Log Used|' + @dbname + '|>%')
	BEGIN
		-- Check if the performance counters are loaded on the server
		IF EXISTS (SELECT * FROM master.dbo.sysperfinfo WHERE object_name = @instance + ':Databases' AND counter_name = 'Percent Log Used' AND instance_name = @dbname)
		BEGIN
			SELECT @alertname = '!TLog Monitor: ' + @dbname
			SELECT @perf = @instance + ':Databases|Percent Log Used|' + @dbname + '|>|' + @threshold
			SELECT @jobid = job_id FROM msdb.dbo.sysjobs WHERE [name] = @jobname

			IF (@jobid IS NOT NULL)
			BEGIN
				-- Check if Alert Exists
				IF NOT EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE [name] = @alertname)
				BEGIN
					PRINT 'Creating Alert: ' + @alertname

					EXECUTE msdb.dbo.sp_add_alert
						@name = @alertname,
						@message_id = 0,
						@severity = 0,
						@enabled = 1,
						@delay_between_responses = 180,
						@performance_condition = @perf,
						@include_event_description_in = 0,
						@job_name = @jobname,
						@category_name = N'[Uncategorized]'
				END

				-- Check if Alert Response Job is missing
				IF NOT EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE [name] = @alertname AND [job_id] = @jobid)
				BEGIN
					PRINT 'Adding Response Job to Alert: ' + @alertname

					EXECUTE msdb.dbo.sp_update_alert 
							@name = @alertname,
							@job_id = @jobid
				END
			END
		END
	END
	FETCH NEXT FROM DBNAME INTO @dbname, @jobname
END

CLOSE DBNAME
DEALLOCATE DBNAME


-- Check for alerts that need to be removed
DECLARE ALERT CURSOR FOR
	SELECT	[name],
		performance_condition
	FROM	msdb.dbo.sysalerts
	WHERE	performance_condition LIKE @instance + ':Databases|Percent Log Used|%'
	ORDER BY [name]

OPEN ALERT
FETCH NEXT FROM ALERT INTO @alertname, @dbname

WHILE (@@fetch_status = 0)
BEGIN
	SELECT @dbname = REPLACE(@dbname, @instance + ':Databases|Percent Log Used|','')
	SELECT @dbname = LEFT(@dbname, (CHARINDEX('|',@dbname)-1))

	IF NOT EXISTS (SELECT 	[name]
			FROM	master.dbo.sysdatabases
			WHERE	[name] = @dbname
			AND	DATABASEPROPERTY([name],'IsInStandby') = 0
			AND	DATABASEPROPERTY ([name],'IsInLoad') = 0
			AND	DATABASEPROPERTY ([name],'IsOffline') = 0
			AND	DATABASEPROPERTY ([name],'IsSuspect') = 0
			AND	DATABASEPROPERTY ([name],'IsTruncLog') = 0)

	BEGIN
		PRINT 'Removing Alert: ' + @alertname
		EXEC msdb.dbo.sp_delete_alert @name = @alertname
	END

	FETCH NEXT FROM ALERT INTO @alertname, @dbname
END

CLOSE ALERT
DEALLOCATE ALERT
GO
"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}
##########################################################
#  1.4 The CREATE_USP_INTEGRITY_JOB_MASTER routine creates
#  the USP_INTEGRITY_JOB_MASTER stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_USP_INTEGRITY_JOB_MASTER()
{

$SqlQueryText = @"
USE msdb
GO

IF EXISTS (SELECT [name] FROM sysobjects WHERE [name] = 'usp_integrity_job_master' AND type = 'P')
   DROP PROCEDURE usp_integrity_job_master
GO

----------------------------------------------------------------------------------
-- Author:	Nick Tornese							--
-- Date:	12/16/2004							--
-- Procedure:	usp_integrity_job_master						--
-- Description:	Launches Integrity Jobs Sequentially.			--
----------------------------------------------------------------------------------
CREATE PROCEDURE usp_integrity_job_master
AS
DECLARE @job_id		UNIQUEIDENTIFIER,
	@duration	CHAR(9),
	@job_start	INT,
	@rowcount	INT

SET @rowcount = 0

DECLARE job INSENSITIVE CURSOR FOR
	SELECT	A.job_id,
		LEFT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),2)
	FROM msdb.dbo.sysjobs A
	INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	WHERE A.[name] LIKE 'Integrity Check for %'
	AND A.[name] <> '!Integrity Check Master'
	AND A.enabled = 1 AND D.enabled != 1
	ORDER BY B.[last_run_duration]

OPEN job
FETCH NEXT FROM job INTO @job_id, @duration

WHILE @@fetch_status = 0
BEGIN
	SET @rowcount = @rowcount + 1

	EXEC @job_start = sp_start_job @job_id = @job_id
	IF @job_start = 0
	BEGIN
		PRINT 'Job started at ' + CONVERT(VARCHAR(26), GetDate(), 109)
		IF @rowcount != @@CURSOR_ROWS
		BEGIN
	 		WAITFOR DELAY @duration
		END
 	END

	FETCH NEXT FROM job INTO @job_id, @duration
END
CLOSE job
DEALLOCATE job
"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


##########################################################
#  1.5 The CREATE_USP_REORG_JOB_MASTER routine creates
#  the USP_REORG_JOB_MASTER stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_USP_REORG_JOB_MASTER()
{

$SqlQueryText = @"
USE msdb
GO

IF EXISTS (SELECT [name] FROM sysobjects WHERE [name] = 'usp_reorg_job_master' AND type = 'P')
   DROP PROCEDURE usp_reorg_job_master
GO

----------------------------------------------------------------------------------
-- Author:	Nick Tornese							--
-- Date:	02/16/2006							--
-- Procedure:	usp_reorg_job_master						--
-- Description:	Launches Rebuild Indexes Jobs Sequentially.				--
----------------------------------------------------------------------------------
CREATE PROCEDURE usp_reorg_job_master
AS
DECLARE @job_id		UNIQUEIDENTIFIER,
	@duration	CHAR(9),
	@job_start	INT,
	@rowcount	INT

SET @rowcount = 0

DECLARE job INSENSITIVE CURSOR FOR
	SELECT	A.job_id,
		LEFT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),2)
	FROM msdb.dbo.sysjobs A
	INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	WHERE A.[name] LIKE 'Reorg for %'
	AND A.[name] <> '!Database Reorg Master'
	AND A.enabled = 1 AND D.enabled != 1
	ORDER BY B.[last_run_duration]

OPEN job
FETCH NEXT FROM job INTO @job_id, @duration

WHILE @@fetch_status = 0
BEGIN
	SET @rowcount = @rowcount + 1

	EXEC @job_start = sp_start_job @job_id = @job_id
	IF @job_start = 0
	BEGIN
		PRINT 'Job started at ' + CONVERT(VARCHAR(26), GetDate(), 109)
		IF @rowcount != @@CURSOR_ROWS
		BEGIN
	 		WAITFOR DELAY @duration
		END
 	END

	FETCH NEXT FROM job INTO @job_id, @duration
END
CLOSE job
DEALLOCATE job
"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


##########################################################
#  1.6 The  routine  CREATE_USP_STATS_JOB_MASTER creates
#  the USP_STATS_JOB_MASTER stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_USP_STATS_JOB_MASTER()
{

$SqlQueryText = @"
USE msdb
GO

IF EXISTS (SELECT [name] FROM sysobjects WHERE [name] = 'usp_stats_job_master' AND type = 'P')
   DROP PROCEDURE usp_stats_job_master
GO

----------------------------------------------------------------------------------
-- Author:	Nick Tornese							--
-- Date:	02/16/2006							--
-- Procedure:	usp_stats_job_master						--
-- Description:	Launches Update Stats Jobs Sequentially.				--
----------------------------------------------------------------------------------
CREATE PROCEDURE usp_stats_job_master
AS
DECLARE @job_id		UNIQUEIDENTIFIER,
	@duration	CHAR(9),
	@job_start	INT,
	@rowcount	INT

SET @rowcount = 0

DECLARE job INSENSITIVE CURSOR FOR
	SELECT	A.job_id,
		LEFT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),3) + ':' +
		SUBSTRING(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),4,2) + ':' +
		RIGHT(REPLACE(STR(ISNULL(B.[last_run_duration],100),7,0),' ', '0'),2)
	FROM msdb.dbo.sysjobs A
	INNER JOIN msdb.dbo.sysjobsteps B ON A.job_id = B.job_id
	INNER JOIN msdb.dbo.sysjobschedules C ON A.job_id = C.job_id
	INNER JOIN msdb.dbo.sysschedules D ON C.schedule_id = D.schedule_id
	WHERE A.[name] LIKE 'Update Stats for %'
	AND A.[name] <> '!Database Update Stats Master'
	AND A.enabled = 1 AND D.enabled != 1
	ORDER BY B.[last_run_duration]

OPEN job
FETCH NEXT FROM job INTO @job_id, @duration

WHILE @@fetch_status = 0
BEGIN
	SET @rowcount = @rowcount + 1

	EXEC @job_start = sp_start_job @job_id = @job_id
	IF @job_start = 0
	BEGIN
		PRINT 'Job started at ' + CONVERT(VARCHAR(26), GetDate(), 109)
		IF @rowcount != @@CURSOR_ROWS
		BEGIN
	 		WAITFOR DELAY @duration
		END
 	END

	FETCH NEXT FROM job INTO @job_id, @duration
END
CLOSE job
DEALLOCATE job
"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


 
##########################################################
#  2.1 The CREATE_USP_TDP_CREATE_MAINTJOBS routine creates
#  the USP_TDP_CREATE_MAINTJOBS stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_USP_TDP_CREATE_MAINTJOBS()
{

$SqlQueryText = @"
USE msdb
GO

IF EXISTS (SELECT [name] FROM sys.objects WHERE [name] = 'usp_tdp_create_maintjobs' AND type = 'P')
   DROP PROCEDURE usp_tdp_create_maintjobs
GO

------------------------------------------------------------------------------------------
-- Author:	Nick Tornese																--
-- Modified:	11/02/2005																--
-- Procedure:	usp_tdp_create_maintjobs												--
--																						--
-- Parameters:																			--
--		@v_tdploc - Location of tsmsqlc.exe, include the final '\'						--
--	 	@v_tdpcfg - Override location of config file									--
-- 		@v_backuptime - Time Database Backups Start										--
-- 		@v_backupfreqtype - Frequency of Backups: 4 = Daily								--
--	 	@v_backupinterval - Interval of Backups: 1 = Once a day							--
--		@v_backupmaxdelay - Maximum delay (hhhmmss) between starting jobs				--
-- 		@v_tlogbaktime - Time TLog Backups Start										--
-- 		@v_tlogsubtype - SubFrequency of TLog Backups: 8 = Hours						--
-- 		@v_tlogsubinterval - SubInterval of TLog Backups: 1 = Every 1 Hour				--
-- 		@v_tlogthreshold - Theshold in percentage for initiating a TLog backup			--
--		@v_tlogmaxdelay - Maximum delay (hhhmmss) between starting jobs					--
-- 		@v_integritytime - Time Integrity Check Start									--
-- 		@v_integrityfreqtype - Frequency of Integrity Checks: 4 = Daily					--
-- 		@v_integrityinterval - Interval of Integrity Checks: 1 = Once a day				--
-- 		@v_statstime - Time Update Stats Start											--
-- 		@v_statsfreqtype - Frequency of Update Stats: 8 = Weekly						--
-- 		@v_statsinterval - Interval of Update Stats: 126 = Mon - Sat					--
-- 		@v_reorgtime - Time Reorgs Start												--
-- 		@v_reorgfreqtype - Frequency of Reorgs: 8 = Weekly								--
-- 		@v_reorginterval - Interval of Reorgs: 2 = Mon									--
-- 		@v_rptloc - Location of All Report Files										--
-- 		@v_email_operator - Email Operator for SQL Mail Alerts when jobs fail.			--
--																						--
-- Description:	Discovers new databases and creates TDP backups and Maintenance	Plans.	--
--		Creates and removes TLog percent full monitors for each database.				--
--		Also removes invalid TDP backup jobs and Maintenance Plans.						--
--																						--
-- Dependancies: These stored procedures must be in place in order to work properly		--
--		msdb.dbo.usp_tdp_backup_job_master												--
--		msdb.dbo.usp_tdp_tlogbkup_job_master											--
--		msdb.dbo.usp_tdp_create_tlog_monitor											--
--		msdb.dbo.usp_integrity_job_master												--
--		msdb.dbo.usp_reorg_job_master													--
--																						--
-- Misc: Weekly Schedule Interval Chart													--
--			Add values for multiple days												--
--			1 = Sunday																	--
--			2 = Monday																	--
--			4 = Tuesday																	--
--			8 = Wednesday																--
--			16 = Thursday																--
--			32 = Friday																	--
--			64 = Saturday																--
--																						--
--																						--
--																						--
-- Modified by: James Handley															--
-- Date: 12/29/2010																		--
-- Description: Added new Reorg/Rebuild and Upadate Statistic logic						--
--																						--
--																						--
------------------------------------------------------------------------------------------
CREATE PROCEDURE usp_tdp_create_maintjobs
-- Arguments passed to procedure
	-- TDP\TSM Specific Information 
	@v_tdploc				VARCHAR(128) = 'C:\Tivoli\tsm\TDPSQL\',	-- Location of tsmsqlc.exe, make sure you include the final '\'
	@v_tdpcfg				VARCHAR(128) = NULL,			-- Override location of config file,
	-- If NULL then use default which is instance name
	-- Override example: 'E:\tsm\tdpsql\TSMSQL.cfg'

	-- Full Backups
	@v_backuptime			INTEGER = 020000,			-- Time Database Backups Start
	@v_backupfreqtype		INTEGER = 4,				-- Frequency of Backups: 4 = Daily
	@v_backupinterval		INTEGER = 1,				-- Interval of Backups: 1 = Once a day
	@v_backupmaxdelay		INTEGER = 0000230,				-- Maximum delay (hhhmmss) between starting jobs

	-- TLog Backups
	@v_tlogbaktime			INTEGER = 000000,			-- Time TLog Backups Start
	@v_tlogsubtype			INTEGER = 8,				-- SubFrequency of TLog Backups: 8 = Hours
	@v_tlogsubinterval		INTEGER = 1,				-- SubInterval of TLog Backups: 1 = Every 1 Hour
	@v_tlogthreshold		VARCHAR(3) = '70',			-- Theshold in percentage for initiating a TLog backup
	@v_tlogmaxdelay			INTEGER = 0000030,				-- Maximum delay (hhhmmss) between starting jobs

	-- Integrity Checks
	@v_integritytime		INTEGER = 000000,			-- Time Integrity Check Start
	@v_integrityfreqtype	INTEGER = 4,				-- Frequency of Integrity Checks: 4 = Daily
	@v_integrityinterval 	INTEGER = 1,				-- Interval of Integrity Checks: 1 = Once a day

	-- Update Stats
	@v_statstime			INTEGER = 010000,			-- Time Update Stats Start
	@v_statsfreqtype		INTEGER = 8,				-- Frequency of Update Stats: 8 = Weekly
	@v_statsinterval 		INTEGER = 126,				-- Interval of Update Stats: 126 = Mon - Sat

	-- Database Reorgs
	@v_reorgtime			INTEGER = 010000,			-- Time Reorgs Start
	@v_reorgfreqtype		INTEGER = 8,				-- Frequency of Reorgs: 8 = Weekly
	@v_reorginterval 		INTEGER = 1,				-- Interval of Reorgs: 1 = Sunday
	@threshold				VARCHAR(6)   = '30.00',		-- Set the threshold cutoff for reorging or rebuilind an index (e.g. 30.00) 
	@updpercent				VARCHAR(3)	 = '30',		-- Set the precentage of tables to update during each scheduled run of the job (e.g. 30)

	-- Maintenance Plan Reports
	@v_rptloc				VARCHAR(128) = /*'Z:\Microsoft SQL Server\MSSQL.1\MSSQL\MaintLog*/'',		-- Location of All Report Files

	-- Notifications
	@v_email_operator		VARCHAR(128) = NULL			-- Email Operator for SQL Mail Alerts when jobs fail.
	
	
WITH ENCRYPTION
AS

DECLARE	@v_dbname				NVARCHAR(128),
	@v_dbrecovery				NCHAR(4),
	@v_jobstep					NVARCHAR(MAX),
	@v_jobid					UNIQUEIDENTIFIER,
	@v_jobname					NVARCHAR(128),
	@v_notify					INT,
	@v_scheduleid				INT,
	@v_tdpcmd					NVARCHAR(400),
	@v_tdperrmsg				NVARCHAR(400),
	@v_rpt						NVARCHAR(128),
	@v_tdpinst					NVARCHAR(128),			-- Added to dynamically name the .opt file - James Handley 07/27/2007	
	@SQL						NVARCHAR(MAX),
	@SQL2						NVARCHAR(MAX),
	@ProdVersion				INT,
	@Edition					VARCHAR(50)
	


--SELECT @v_tdpinst =  LOWER(LEFT(@@SERVERNAME,REPLACE(CHARINDEX('\',@@SERVERNAME),'0 ',LEN(@@SERVERNAME)+1)-1)) + '.opt'		
									-- Added to dynamically name the .opt file - James Handley 07/27/2007	
                                    
		-- Modified to incorporate DEFAULT instances - Avi Bansal - 09/11/13
SELECT @v_tdpinst =  LOWER(CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128))) + '.opt'

SELECT @v_notify = CASE ISNULL(@v_email_operator,'NULL') WHEN 'NULL' THEN 0 ELSE 2 END

-- SELECT @v_tdpcfg = ISNULL(@v_tdpcfg, (@v_tdploc + CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128)) + '.cfg'))
	-- Modified to incorporate DEFAULT instances - Avi Bansal - 09/11/13
SELECT @v_tdpcfg = ISNULL(@v_tdpcfg, (@v_tdploc + CAST(@@SERVICENAME AS VARCHAR(128)) + '.cfg'))


-- Create a Cursor of Databases and Create Maintance Plans Where Missing
DECLARE DBMaintJobs CURSOR FOR
	SELECT	database_name = CAST([name] AS VARCHAR(128)),
			db_recovery = CAST(DATABASEPROPERTYEX([name], 'recovery') AS CHAR(4))
	FROM	master.sys.databases
	WHERE	[name] NOT IN ('distribution', 'AdventureWorks', 'AdventureWorksDW', 'tempdb')
		AND [source_database_id] IS NULL
		AND	DATABASEPROPERTY([name],'IsInStandby') = 0
		AND	DATABASEPROPERTY ([name],'IsInLoad') = 0
		AND	DATABASEPROPERTY ([name],'IsOffline') = 0
		AND	DATABASEPROPERTY ([name],'IsSuspect') = 0
		AND   source_database_id is null
	ORDER BY [name]

OPEN DBMaintJobs
FETCH FROM DBMaintJobs INTO @v_dbname, @v_dbrecovery


--Get Product Version (i.e. SQL Server 2005, 2008 )
select @ProdVersion = convert(int,
					Left(
							convert(varchar,SERVERPROPERTY('ProductVersion')),
							charindex('.',convert(varchar,SERVERPROPERTY('ProductVersion'))) - 1
						)
				),
	   @Edition = convert(varchar(50),serverproperty('Edition'))

	   
--******* New Reorg/rebuild code for reorg job - James Handley*****************************
SET @SQL = ''
SET @SQL = @SQL + 'DECLARE @objectid int;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @indexid int;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @partitioncount bigint;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @schemaname nvarchar(130);' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @objectname nvarchar(130);' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @indexname nvarchar(130);' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @partitionnum bigint;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @partitions bigint;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @frag float;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @command nvarchar(4000);' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'DECLARE @isLob bit;' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)

-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function 
-- and convert object and index IDs to names.
SET @SQL = @SQL + 'SELECT  object_id AS objectid,' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + '	index_id AS indexid,' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + '	partition_number AS partitionnum,' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + '	avg_fragmentation_in_percent AS frag ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'INTO #work_to_do ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'FROM sys.dm_db_index_physical_stats (db_id(), NULL, NULL , NULL, ''LIMITED'') ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + 'WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;'  

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)

-- Declare the cursor for the list of partitions to be processed.
SET @SQL = @SQL + 'DECLARE partitions CURSOR FOR SELECT * FROM #work_to_do;' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)


-- Open the cursor.
SET @SQL = @SQL + 'OPEN partitions; ' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)

-- Loop through the partitions.
SET @SQL = @SQL + 'WHILE (1=1)' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +     'BEGIN;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'FETCH NEXT' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +            'FROM partitions' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +            'INTO @objectid, @indexid, @partitionnum, @frag;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'IF @@FETCH_STATUS < 0 BREAK;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name) ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'FROM sys.objects AS o ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'JOIN sys.schemas as s ON s.schema_id = o.schema_id ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'WHERE o.object_id = @objectid; ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'SELECT @indexname = QUOTENAME(name) ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'FROM sys.indexes ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'WHERE  object_id = @objectid AND index_id = @indexid; ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'SELECT @partitioncount = count (*) ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'FROM sys.partitions ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'WHERE object_id = @objectid AND index_id = @indexid; ' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)

-- LOB field detection
SET @SQL = @SQL +         'SET @isLob = 0; ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'IF exists (Select 1 From sys.columns With (NoLock) Where object_id = @objectid and (system_type_id In (34, 35, 99) Or max_length = -1)) ' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +         'SET @isLob = 1; ' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)

-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding.
SET @SQL = @SQL +        'IF @frag < ' + @threshold + CHAR(13) + CHAR(10)
SET @SQL = @SQL +        'SET @command = N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + N'' REORGANIZE'';' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)

SET @SQL = @SQL +        'IF @frag >= ' + @threshold + CHAR(13) + CHAR(10)

-- If Enterprise Edition Rebuild Online 
-- Modified the condition to create REBUILD ONLINE in Enterprise core edition as well
-- If @Edition LIKE ('Enterprise Edition','Enterprise Edition (64-bit)')

If @Edition LIKE ('%Enterprise%')
Begin

	SET @SQL = @SQL + 	 'SET @command = (CASE WHEN @isLob = 1 THEN N'' ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + N'' REORGANIZE''' + CHAR(13) + CHAR(10)	
	SET @SQL = @SQL +    '					   WHEN @partitioncount > 1 THEN N'' ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + N'' REBUILD''' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL +	 '					   Else N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + N'' REBUILD WITH (ONLINE = ON)''' + CHAR(13) + CHAR(10)    
    SET @SQL = @SQL +	 '				END);' + CHAR(13) + CHAR(10)
End	
Else
Begin	 

	SET @SQL = @SQL +	 'SET @command = (CASE @isLob WHEN 1 THEN N'' ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + N'' REORGANIZE''' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL +	 '  Else N''ALTER INDEX '' + @indexname + N'' ON '' + @schemaname + N''.'' + @objectname + N'' REBUILD''' + CHAR(13) + CHAR(10)
    SET @SQL = @SQL +	 'END);' + CHAR(13) + CHAR(10)
	
End	

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)	
	
SET @SQL = @SQL +        'IF @partitioncount > 1' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +        '    SET @command = @command + N'' PARTITION = '' + CAST(@partitionnum AS nvarchar(10));' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +		 'EXEC (@command);' + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)  
     
--SET @SQL = @SQL +        'PRINT N''Executed: ' + @command + ';' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +        'END;' + CHAR(13) + CHAR(10)

-- Close and deallocate the cursor.
SET @SQL = @SQL +        'CLOSE partitions;' + CHAR(13) + CHAR(10)
SET @SQL = @SQL +        'DEALLOCATE partitions;' + CHAR(13) + CHAR(10)

SET @SQL = @SQL + CHAR(13) + CHAR(10)
SET @SQL = @SQL + CHAR(13) + CHAR(10)  
-- Drop the temporary table.
SET @SQL = @SQL +        'DROP TABLE #work_to_do;' + CHAR(13) + CHAR(10)
 

--******** New Update Statistics Code for Update Stats job - James Handley ****************************
SET @SQL2 = ''
SET @SQL2 = @SQL2 + 'SELECT o.name as table_name,' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + '		i.name as index_name,' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		STATS_DATE(o.id,i.indid) AS Date_Updated,' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		o.type,' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		o.xtype,' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		SCHEMA_NAME(ob.schema_id) as  schema_nm ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'into #temp_table' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'FROM sysobjects o' + CHAR(13) + CHAR(10)  
SET @SQL2 = @SQL2 + 'JOIN sys.objects ob ON ob.object_id = o.id ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'JOIN sysindexes i ON i.id = o.id' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'WHERE o.type = ''U'' and o.xtype = ''U''' + CHAR(13) + CHAR(10)

SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 

SET @SQL2 = @SQL2 + 'Select top (' + @updpercent  + ') percent table_name,' + CHAR(13) + CHAR(10)  
SET @SQL2 = @SQL2 + '		index_name,' + CHAR(13) + CHAR(10)  
SET @SQL2 = @SQL2 + '		schema_nm ' + CHAR(13) + CHAR(10)   
SET @SQL2 = @SQL2 + 'into #temp_table2 ' + CHAR(13) + CHAR(10)  
SET @SQL2 = @SQL2 + 'from #temp_table ' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'where date_updated is not null ' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'order by date_updated' + CHAR(13) + CHAR(10)  

SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 

SET @SQL2 = @SQL2 + 'DECLARE @exec_stmt nvarchar(540)' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'DECLARE @tablename sysname' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'DECLARE @indexname varchar(267)' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'DECLARE @schema_nm sysname' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'DECLARE @user_name sysname' + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + 'DECLARE @tablename_header varchar(267)' + CHAR(13) + CHAR(10) 

SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'DECLARE ms_crs_tnames CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' + CHAR(13) + CHAR(10)  
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 


SET @SQL2 = @SQL2 + 'SELECT	table_name,' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		index_name,' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		schema_nm		   ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'FROM #temp_table2 ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'order by table_name' + CHAR(13) + CHAR(10)

SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 


SET @SQL2 = @SQL2 + 'OPEN ms_crs_tnames ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'FETCH NEXT FROM ms_crs_tnames INTO @tablename, @indexname, @schema_nm ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'WHILE (@@fetch_status <> -1) ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '	BEGIN ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '		IF (@@fetch_status <> -2) ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '			BEGIN ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '				SELECT @exec_stmt = ''UPDATE STATISTICS '' + quotename(@schema_nm) + ''.'' + quotename(@tablename) + '' '' + quotename(@indexname) + '' with sample 25 percent''' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '				PRINT @exec_stmt ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '				EXEC (@exec_stmt) ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '			END ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '				FETCH NEXT FROM ms_crs_tnames INTO @tablename, @indexname, @schema_nm ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '	END ' + CHAR(13) + CHAR(10)

SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10)           


SET @SQL2 = @SQL2 + '     PRINT '' ''' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '     PRINT '' ''' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + '     raiserror(15005,-1,-1)'  + CHAR(13) + CHAR(10)             
SET @SQL2 = @SQL2 + '	 DEALLOCATE ms_crs_tnames ' + CHAR(13) + CHAR(10)

SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 
SET @SQL2 = @SQL2 + CHAR(13) + CHAR(10) 

SET @SQL2 = @SQL2 + 'drop table #temp_table ' + CHAR(13) + CHAR(10)
SET @SQL2 = @SQL2 + 'drop table #temp_table2 ' + CHAR(13) + CHAR(10)

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Create DBAdmin category if it doesn't exists
	IF NOT EXISTS (SELECT * FROM msdb.dbo.syscategories WHERE name = N'DBAdmin')
		EXECUTE msdb.dbo.sp_add_category @class = N'Job', @name = N'DBAdmin';

-- ************************************************************************************
-- Database Backup Job
-- ************************************************************************************
	-- Add Backup Job to Maintenance Plans
	SELECT	@v_jobname = 'Full Database Backup for ''' + @v_dbname + '''',
			@v_rpt = @v_rptloc --+ '\' + @v_dbname + '_FullBackupRpt.txt'

	IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = @v_jobname)
	BEGIN
		PRINT 'Adding Job ' + @v_jobname

		-- Define TDP command for Backup Job Step 1
		SET @v_tdpcmd = @v_tdploc + 'tdpsqlc.exe BACKUP "' + @v_dbname + '" Full /CONFIGfile=' + @v_tdpcfg + ' /TSMOPTFILE=' + @v_tdploc + @v_tdpinst

		-- Build Error Message
		SELECT @v_tdperrmsg = 'MSSQL Instance: ' + @@SERVERNAME + ': Full Database Backup for ' + @v_dbname + ' Failed. Please check the dsierror.log for details.'

		-- Define TSQL command for job step
		SELECT @v_jobstep ='powershell "$drive\PowerShellScripts\DBbackupV2.ps1 -filename '+''''+ @v_tdploc+'tdpsqlc.exe'+''''+' -arguments '+''''+'BACKUP "'+@v_dbname+'" Full /CONFIGfile='+@v_tdpcfg+' /TSMOPTFILE='+@v_tdploc+@v_tdpinst+''''+' -instance '+ ''''+@@SERVERNAME+''''+' -errormsg '+''''+@v_tdperrmsg+''''+ '"'			
		
		EXECUTE msdb.dbo.sp_add_job
			@job_id = @v_jobid OUTPUT,
			@job_name = @v_jobname,
			@owner_login_name = $sqlaccount,
			@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
			@category_name = N'DBAdmin',
			@enabled = 1,
			@notify_level_email = @v_notify,
			@notify_level_page = 2,
			@notify_level_netsend = 0, 
			@notify_level_eventlog = 2,
			@delete_level = 0,
			@notify_email_operator_name = @v_email_operator,
			@notify_page_operator_name = @v_email_operator

		-- Add the Backup Job Target Servers
 		EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'
 
 		-- Add xp_maint Step
		EXECUTE msdb.dbo.sp_add_jobstep
			@job_id = @v_jobid,
			@step_id = 1,
			@step_name = 'step 1',
			@command = @v_jobstep,
			@database_name = N'master',
			@server = N'',
			@database_user_name = N'',
			@subsystem = N'CMDExec',
			@cmdexec_success_code = 0,
			@flags = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@output_file_name = @v_rpt,
			@on_success_step_id = 0,
			@on_success_action = 1,
			@on_fail_step_id = 0,
			@on_fail_action = 2

	-- Backup Schedule
		EXECUTE msdb.dbo.sp_add_schedule
			@schedule_id = @v_scheduleid OUTPUT,
			@schedule_name = @v_jobname,
			@enabled = 0,
			@freq_type = @v_backupfreqtype,
			@freq_interval = @v_backupinterval,
			@freq_recurrence_factor = 1,
			@freq_subday_type = 0,
			@freq_subday_interval = 0,
			@active_start_time = @v_backuptime

		EXECUTE msdb.dbo.sp_attach_schedule
			@job_id = @v_jobid,
			@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
	END

-- ************************************************************************************
-- TLog Backup Job
-- ************************************************************************************
	-- Define TSQL command for job step
	SELECT	@v_tdpcmd = @v_tdploc + 'tdpsqlc.exe BACKUP "' + @v_dbname + '" Log /CONFIGfile=' + @v_tdpcfg + ' /TSMOPTFILE=' + @v_tdploc + @v_tdpinst,
			@v_rpt = @v_rptloc --+ '\' + @v_dbname + '_TLogBackupRpt.txt'

	-- Build Error Message
	SELECT @v_tdperrmsg = 'MSSQL Instance: ' + @@SERVERNAME + ': TLog Backup for ' + @v_dbname + ' Failed. Please check the dsierror.log for details.'

	-- Define TSQL command for job step
	SELECT @v_jobstep ='powershell "$drive\PowerShellScripts\DBbackupV2.ps1 -filename '+''''+ @v_tdploc+'tdpsqlc.exe'+''''+' -arguments '+''''+'BACKUP "'+@v_dbname+'" Log /CONFIGfile='+@v_tdpcfg+' /TSMOPTFILE='+@v_tdploc+@v_tdpinst+''''+' -instance '+ ''''+@@SERVERNAME+''''+' -errormsg '+''''+@v_tdperrmsg+''''+ '"'			


	-- Evaluate Need
	IF (@v_dbrecovery <> 'SIMP' AND @v_dbname != 'model')
	BEGIN
		-- Add TLog Backup Job to Maintenance Plans
		SELECT	@v_jobname = 'TLog Backup for ''' + @v_dbname + ''''
		
		IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = @v_jobname)
		BEGIN
			PRINT 'Adding Job ' + @v_jobname

			EXECUTE msdb.dbo.sp_add_job
				@job_id = @v_jobid OUTPUT,
				@job_name = @v_jobname,
				@owner_login_name = $sqlaccount,
				@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
				@category_name = N'DBAdmin',
				@enabled = 1,
				@notify_level_email = 0,
				@notify_level_page = 0,
				@notify_level_netsend = 0, 
				@notify_level_eventlog = 2,
				@delete_level = 0,
				@notify_email_operator_name = NULL --@v_email_operator

			-- Add the Backup Job Target Servers
 			EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'
 
 			-- Add xp_maint Step
			EXECUTE msdb.dbo.sp_add_jobstep
				@job_id = @v_jobid,
				@step_id = 1,
				@step_name = 'step 1',
				@command = @v_jobstep,
				@database_name = N'master',
				@server = N'',
				@database_user_name = N'',
				@subsystem = N'CMDExec',
				@cmdexec_success_code = 0,
				@flags = 0,
				@retry_attempts = 0,
				@retry_interval = 0,
				@output_file_name = @v_rpt,
				@on_success_step_id = 0,
				@on_success_action = 1,
				@on_fail_step_id = 0,
				@on_fail_action = 2

			-- TLog Backup Schedule
			EXECUTE msdb.dbo.sp_add_schedule
				@schedule_id = @v_scheduleid OUTPUT,
				@schedule_name = @v_jobname,
				@enabled = 0,
				@freq_type = @v_backupfreqtype,
				@freq_interval = @v_backupinterval,
				@freq_recurrence_factor = 1,
				@freq_subday_type = @v_tlogsubtype,
				@freq_subday_interval = @v_tlogsubinterval,
				@active_start_time = @v_tlogbaktime

			EXECUTE msdb.dbo.sp_attach_schedule
				@job_id = @v_jobid,
				@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
		END
	END
	ELSE
	BEGIN
		-- Remove TLog Job
		IF EXISTS (SELECT command FROM msdb.dbo.sysjobsteps WHERE command = @v_jobstep)
		BEGIN
			-- Remove TLog Backup Jobs That Are Not Needed
			DECLARE RemoveTLog CURSOR FOR
				SELECT job_id
				FROM msdb.dbo.sysjobsteps
				WHERE command = @v_jobstep

			OPEN RemoveTLog
			FETCH FROM RemoveTLog INTO @v_jobid

			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT 'Removing TLog Backup for database ' + @v_dbname
				EXECUTE msdb.dbo.sp_delete_job @job_id = @v_jobid
				FETCH FROM RemoveTLog INTO @v_jobid
			END
			CLOSE RemoveTLog
			DEALLOCATE RemoveTLog
		END
	END

-- ************************************************************************************
-- Integrity Check Job
-- ************************************************************************************
	-- Add Integrity Check Job to Maintenance Plans
	SELECT	@v_jobname = 'Integrity Check for ''' + @v_dbname + '''',
			@v_rpt = @v_rptloc --+ '\' + @v_dbname + '_CHECKDBRpt.txt'

	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @v_jobname)
	BEGIN
		PRINT 'Adding Job ' + @v_jobname

		-- Define xp_sqlmaint Step 1
		SELECT @v_jobstep = 'DBCC CHECKDB WITH NO_INFOMSGS'

		EXECUTE msdb.dbo.sp_add_job
			@job_id = @v_jobid OUTPUT,
			@job_name = @v_jobname,
			@owner_login_name = $sqlaccount,
			@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
			@category_name = N'DBAdmin',
			@enabled = 1,
			@notify_level_email = @v_notify,
			@notify_level_page = 0,
			@notify_level_netsend = 0, 
			@notify_level_eventlog = 2,
			@delete_level = 0,
			@notify_email_operator_name = @v_email_operator

		-- Add the Backup Job Target Servers
 		EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'
 
 		-- Add xp_maint Step
		EXECUTE msdb.dbo.sp_add_jobstep
			@job_id = @v_jobid,
			@step_id = 1,
			@step_name = 'step 1',
			@command = @v_jobstep,
			@database_name = @v_dbname,
			@server = N'',
			@database_user_name = N'',
			@subsystem = N'TSQL',
			@cmdexec_success_code = 0,
			@flags = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@output_file_name = @v_rpt,
			@on_success_step_id = 0,
			@on_success_action = 1,
			@on_fail_step_id = 0,
			@on_fail_action = 2

	-- Integrity Check Schedule
		EXECUTE msdb.dbo.sp_add_schedule
			@schedule_id = @v_scheduleid OUTPUT,
			@schedule_name = @v_jobname,
			@enabled = 0,
			@freq_type = @v_integrityfreqtype,
			@freq_interval = @v_integrityinterval,
			@freq_recurrence_factor = 1,
			@freq_subday_type = 0,
			@freq_subday_interval = 0,
			@active_start_time = @v_integritytime

		EXECUTE msdb.dbo.sp_attach_schedule
			@job_id = @v_jobid,
			@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
	END

-- ************************************************************************************
-- Update Stats Job
-- ************************************************************************************
	-- Update Stats Job
	SELECT	@v_jobname = 'Update Stats for ''' + @v_dbname + '''',
			@v_rpt = @v_rptloc --+ '\' + @v_dbname + '_UpdateStatsRpt.txt'

	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @v_jobname)
	BEGIN
		PRINT 'Adding Job ' + @v_jobname

		-- Define xp_sqlmaint Step 1
		SELECT @v_jobstep = @SQL2

		EXECUTE msdb.dbo.sp_add_job
			@job_id = @v_jobid OUTPUT,
			@job_name = @v_jobname,
			@owner_login_name = $sqlaccount,
			@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
			@category_name = N'DBAdmin',
			@enabled = 1,
			@notify_level_email = @v_notify,
			@notify_level_page = 0,
			@notify_level_netsend = 0, 
			@notify_level_eventlog = 2,
			@delete_level = 0,
			@notify_email_operator_name = @v_email_operator

		-- Add the Backup Job Target Servers
 		EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'
 
 		-- Add xp_maint Step
		EXECUTE msdb.dbo.sp_add_jobstep
			@job_id = @v_jobid,
			@step_id = 1,
			@step_name = 'step 1',
			@command = @v_jobstep,
			@database_name = @v_dbname,
			@server = N'',
			@database_user_name = N'',
			@subsystem = N'TSQL',
			@cmdexec_success_code = 0,
			@flags = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@output_file_name = @v_rpt,
			@on_success_step_id = 0,
			@on_success_action = 1,
			@on_fail_step_id = 0,
			@on_fail_action = 2

	-- Update Statistics Schedule
		EXECUTE msdb.dbo.sp_add_schedule
			@schedule_id = @v_scheduleid OUTPUT,
			@schedule_name = @v_jobname,
			@enabled = 0,
			@freq_type = @v_statsfreqtype,
			@freq_interval = @v_statsinterval,
			@freq_recurrence_factor = 1,
			@freq_subday_type = 0,
			@freq_subday_interval = 0,
			@active_start_time = @v_statstime

		EXEC msdb.dbo.sp_attach_schedule
			@job_id = @v_jobid,
			@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
	END

-- ************************************************************************************
-- Reorg Database Job
-- ************************************************************************************
	-- Reorg Database Job
	SELECT	@v_jobname = 'Reorg for ''' + @v_dbname + '''',
			@v_rpt = @v_rptloc --+ '\' + @v_dbname + '_ReorgRpt.txt'

	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @v_jobname)
	BEGIN
		PRINT 'Adding Job ' + @v_jobname

		-- Define xp_sqlmaint Step 1
		SELECT @v_jobstep = @SQL

		EXECUTE msdb.dbo.sp_add_job
			@job_id = @v_jobid OUTPUT,
			@job_name = @v_jobname,
			@owner_login_name = $sqlaccount,
			@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
			@category_name = N'DBAdmin',
			@enabled = 1,
			@notify_level_email = @v_notify,
			@notify_level_page = 0,
			@notify_level_netsend = 0, 
			@notify_level_eventlog = 2,
			@delete_level = 0,
			@notify_email_operator_name = @v_email_operator

		-- Add the Backup Job Target Servers
 		EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'
 
 		-- Add xp_maint Step
		EXECUTE msdb.dbo.sp_add_jobstep
			@job_id = @v_jobid,
			@step_id = 1,
			@step_name = 'step 1',
			@command = @v_jobstep,
			@database_name = @v_dbname,
			@server = N'',
			@database_user_name = N'',
			@subsystem = N'TSQL',
			@cmdexec_success_code = 0,
			@flags = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@output_file_name = @v_rpt,
			@on_success_step_id = 0,
			@on_success_action = 1,
			@on_fail_step_id = 0,
			@on_fail_action = 2

	-- Database Reorg Schedule
		EXECUTE msdb.dbo.sp_add_schedule
			@schedule_id = @v_scheduleid OUTPUT,
			@schedule_name = @v_jobname,
			@enabled = 0,
			@freq_type = @v_reorgfreqtype,
			@freq_interval = @v_reorginterval,
			@freq_recurrence_factor = 1,
			@freq_subday_type = 0,
			@freq_subday_interval = 0,
			@active_start_time = @v_reorgtime

		EXECUTE msdb.dbo.sp_attach_schedule
			@job_id = @v_jobid,
			@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
	END

	FETCH NEXT FROM DBMaintJobs INTO @v_dbname, @v_dbrecovery
END

CLOSE DBMaintJobs
DEALLOCATE DBMaintJobs

-- ************************************************************************************
-- Create and Remove TLog % Full Alerts
-- ************************************************************************************
	-- This procedure creates and removes TLog % Full Alerts
 	EXECUTE msdb.dbo.usp_tdp_create_tlog_monitor @v_tlogthreshold

-- ************************************************************************************
-- Identify Maintenance Jobs to Delete
-- First we need a list of maintenance jobs and the corresponding job_id
-- Create a temporary table to house the list
-- We have to base this on the standard job name
-- Parse the job name to find the databases and populate temporary table
-- ************************************************************************************
-- Reset Variable @v_dbname
SET @v_dbname = NULL

CREATE TABLE #JobList (
	job_id		UNIQUEIDENTIFIER,
	dbname		VARCHAR(128),
	jobname		VARCHAR(128))	

INSERT INTO #JobList (job_id, dbname, jobname)
	SELECT	job_id, [name], [name]
	FROM	msdb.dbo.sysjobs
	WHERE	[name] LIKE 'Full Database Backup for ''%'
		OR	[name] LIKE 'TLog Backup for ''%'
		OR	[name] LIKE 'Integrity Check for ''%'
		OR	[name] LIKE 'Update Stats for ''%'
		OR	[name] LIKE 'Reorg for ''%'

UPDATE	#JobList
SET	dbname = REPLACE(dbname, 'Full Database Backup for ''', '')

UPDATE	#JobList
SET	dbname = REPLACE(dbname, 'TLog Backup for ''', '')

UPDATE	#JobList
SET	dbname = REPLACE(dbname, 'Integrity Check for ''', '')

UPDATE	#JobList
SET	dbname = REPLACE(dbname, 'Update Stats for ''', '')

UPDATE	#JobList
SET	dbname = REPLACE(dbname, 'Reorg for ''', '')

UPDATE	#JobList
SET	dbname = REPLACE(dbname, '''', '')

DELETE FROM #JobList
WHERE	dbname LIKE '%,%' OR dbname = '*'

DECLARE delJobs CURSOR FOR
	SELECT	A.job_id, A.jobname
	FROM	#JobList A
	LEFT OUTER JOIN master.sys.databases C ON C.[name] = A.dbname
	WHERE	source_database_id is null AND 
	(C.[name] IN ('distribution', 'AdventureWorks', 'AdventureWorksDW', 'tempdb')
	OR	[source_database_id] IS NOT NULL
	OR	DATABASEPROPERTY(C.[name],'IsInStandby') = 1
	OR	DATABASEPROPERTY (C.[name],'IsInLoad') = 1
	OR	DATABASEPROPERTY (C.[name],'IsOffline') = 1
	OR	DATABASEPROPERTY (C.[name],'IsSuspect') = 1
	OR	C.[name] IS NULL)	
	ORDER BY A.dbname, A.jobname

OPEN delJobs
FETCH FROM delJobs INTO @v_jobid, @v_jobname

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Deleting Backup Job ' + @v_jobname

	EXECUTE msdb.dbo.sp_delete_job @job_id = @v_jobid
	SET @v_jobid = NULL

	FETCH NEXT FROM delJobs INTO @v_jobid, @v_jobname
END

CLOSE delJobs
DEALLOCATE delJobs
DROP TABLE #JobList

-- ************************************************************************************
-- !Database Backup Master
-- ************************************************************************************
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = '!Database Backup Master')
BEGIN
	SELECT	@v_jobname = '!Database Backup Master',
			@v_rpt = @v_rptloc --+ '\' + 'Database_Backup_Master.txt'

	EXECUTE msdb.dbo.sp_add_job
		@job_id = @v_jobid OUTPUT,
		@job_name = @v_jobname, 
		@owner_login_name = $sqlaccount,
		@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
		@category_name = N'DBAdmin',
		@enabled = 1,
		@notify_level_email = @v_notify, 
		@notify_level_page = 0,
		@notify_level_netsend = 0, 
		@notify_level_eventlog = 2,
		@delete_level = 0,
		@notify_email_operator_name = @v_email_operator

	-- Add the Backup Job Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'

	-- Add Step 1 - Launch Job Step
	SELECT @v_jobstep = 'EXEC usp_tdp_backup_job_master ' + CAST(@v_backupmaxdelay AS CHAR(7))

	EXECUTE msdb.dbo.sp_add_jobstep
		@job_id = @v_jobid,
		@step_id = 1,
		@step_name = 'Launch Jobs',
		@command = @v_jobstep,
		@database_name = N'msdb',
		@server = N'',
		@database_user_name = N'',
		@subsystem = N'TSQL',
		@cmdexec_success_code = 0,
		@flags = 0,
		@retry_attempts = 0,
		@retry_interval = 0,
		@output_file_name = @v_rpt,
		@on_success_step_id = 0,
		@on_success_action = 1,
		@on_fail_step_id = 0,
		@on_fail_action = 2

	EXECUTE msdb.dbo.sp_update_job
			@job_id = @v_jobid, 
			@start_step_id = 1

	EXECUTE msdb.dbo.sp_add_schedule
		@schedule_id = @v_scheduleid OUTPUT,
		@schedule_name = @v_jobname,
		@enabled = 1,
		@freq_type = @v_backupfreqtype,
		@freq_interval = @v_backupinterval,
		@freq_recurrence_factor = 1,
		@freq_subday_type = 0,
		@freq_subday_interval = 0,
		@active_start_time = @v_backuptime

	EXECUTE msdb.dbo.sp_attach_schedule
		@job_id = @v_jobid,
		@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL

END


-- ************************************************************************
-- !Database Backup SysResouce 
-- ************************************************************************
  
if not exists ( SELECT name FROM msdb.dbo.sysjobs WHERE name = '!Database Backup SysResource')
Begin
    DECLARE @jobId BINARY(16)
    EXEC  msdb.dbo.sp_add_job @job_name=N'!Database Backup SysResource', 
	    @enabled=1, 
	    @notify_level_eventlog=0, 
	    @notify_level_email=2, 
	    @notify_level_netsend=2, 
	    @notify_level_page=2, 
	    @delete_level=0, 
	    @description=N'Backups System resource Database', 
	    @category_name=N'[Uncategorized (Local)]', 
	    @owner_login_name=$sqlaccount, @job_id = @jobId OUTPUT
        --select @jobId
        --GO
        EXEC msdb.dbo.sp_add_jobserver @job_name=N'!Database Backup SysResource', @server_name = N'(local)'
        --GO
        --USE [msdb]
        --GO
        EXEC msdb.dbo.sp_add_jobstep @job_name=N'!Database Backup SysResource', @step_name=N'Bkup', 
	    @step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -executionpolicy bypass \\wsprds051\SQL_Monitoring\mssqlresource_backup.ps1', 
		@database_name=N'master'--, 
		--@output_file_name=N'\\wsprds051\POWERSHELL_Scripts\mssqlresource_log.txt', 
		--@flags=2
        --GO
        --USE [msdb]
        --GO
        EXEC msdb.dbo.sp_update_job @job_name=N'!Database Backup SysResource', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Backups System resource Database', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=$sqlaccount, 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
        --GO
        --USE [msdb]
        --GO
        DECLARE @schedule_id int
        EXEC msdb.dbo.sp_add_jobschedule @job_name=N'!Database Backup SysResource', @name=N'sch', 
        @enabled=1, 
        @freq_type=8, 
        @freq_interval=1, 
        @freq_subday_type=1, 
        @freq_subday_interval=0, 
        @freq_relative_interval=0, 
        @freq_recurrence_factor=1, 
        @active_start_date=20140520, 
        @active_end_date=99991231, 
        @active_start_time=1500, 
        @active_end_time=235959, @schedule_id = @schedule_id OUTPUT
        --select @schedule_id
END



-- ************************************************************************************
-- !TLog Backup Master
-- ************************************************************************************
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = '!Database TLog Backup Master')
BEGIN
	SELECT	@v_jobname = '!Database TLog Backup Master',
			@v_rpt = @v_rptloc --+ '\' + 'TLog_Backup_Master.txt'

	EXECUTE msdb.dbo.sp_add_job
		@job_id = @v_jobid OUTPUT,
		@job_name = @v_jobname, 
		@owner_login_name = $sqlaccount,
		@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
		@category_name = N'DBAdmin',
		@enabled = 1,
		@notify_level_email = 0, 
		@notify_level_page = 0,
		@notify_level_netsend = 0, 
		@notify_level_eventlog = 2,
		@delete_level = 0,
		@notify_email_operator_name = NULL --@v_email_operator

	-- Add the Backup Job Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'

	-- Add Step
	SELECT @v_jobstep = 'EXEC usp_tdp_tlogbkup_job_master ' + CAST(@v_tlogmaxdelay AS CHAR(7))

	EXECUTE msdb.dbo.sp_add_jobstep
		@job_id = @v_jobid,
		@step_id = 1,
		@step_name = 'Launch Jobs',
		@command = @v_jobstep,
		@database_name = N'msdb',
		@server = N'',
		@database_user_name = N'',
		@subsystem = N'TSQL',
		@cmdexec_success_code = 0,
		@flags = 0,
		@retry_attempts = 0,
		@retry_interval = 0,
		@output_file_name = @v_rpt,
		@on_success_step_id = 0,
		@on_success_action = 1,
		@on_fail_step_id = 0,
		@on_fail_action = 2

	EXECUTE msdb.dbo.sp_update_job
			@job_id = @v_jobid, 
			@start_step_id = 1

	EXECUTE msdb.dbo.sp_add_schedule
		@schedule_id = @v_scheduleid OUTPUT,
		@schedule_name = @v_jobname,
		@enabled = 1,
		@freq_type = @v_backupfreqtype,
		@freq_interval = @v_backupinterval,
		@freq_recurrence_factor = 1,
		@freq_subday_type = @v_tlogsubtype,
		@freq_subday_interval = @v_tlogsubinterval,
		@active_start_time = @v_tlogbaktime

	EXECUTE msdb.dbo.sp_attach_schedule
		@job_id = @v_jobid,
		@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
END

-- ************************************************************************************
-- !Integrity Check Master
-- ************************************************************************************
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = '!Database Integrity Check Master')
BEGIN
	SELECT	@v_jobname = '!Database Integrity Check Master',
			@v_rpt = @v_rptloc --+ '\' + 'Integrity_Check_Master.txt'

	EXECUTE msdb.dbo.sp_add_job
		@job_id = @v_jobid OUTPUT,
		@job_name = @v_jobname, 
		@owner_login_name = $sqlaccount,
		@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
		@category_name = N'DBAdmin',
		@enabled = 1,
		@notify_level_email = @v_notify,
		@notify_level_page = 0,
		@notify_level_netsend = 0, 
		@notify_level_eventlog = 2,
		@delete_level = 0,
		@notify_email_operator_name = @v_email_operator

	-- Add the Backup Job Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'

	-- Add Step
	SET @v_jobstep = 'EXEC usp_integrity_job_master'

	EXECUTE msdb.dbo.sp_add_jobstep
		@job_id = @v_jobid,
		@step_id = 1,
		@step_name = 'Launch Jobs',
		@command = @v_jobstep,
		@database_name = N'msdb',
		@server = N'',
		@database_user_name = N'',
		@subsystem = N'TSQL',
		@cmdexec_success_code = 0,
		@flags = 0,
		@retry_attempts = 0,
		@retry_interval = 0,
		@output_file_name = @v_rpt,
		@on_success_step_id = 0,
		@on_success_action = 1,
		@on_fail_step_id = 0,
		@on_fail_action = 2

	EXECUTE msdb.dbo.sp_update_job
			@job_id = @v_jobid, 
			@start_step_id = 1

	EXECUTE msdb.dbo.sp_add_schedule
		@schedule_id = @v_scheduleid OUTPUT,
		@schedule_name = @v_jobname,
		@enabled = 1,
		@freq_type = @v_integrityfreqtype,
		@freq_interval = @v_integrityinterval,
		@freq_recurrence_factor = 1,
		@freq_subday_type = 0,
		@freq_subday_interval = 0,
		@active_start_time = @v_integritytime

	EXECUTE msdb.dbo.sp_attach_schedule
		@job_id = @v_jobid,
		@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
END

-- ************************************************************************************
-- !Database Update Stats Master
-- ************************************************************************************
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = '!Database Update Stats Master')
BEGIN
	SELECT	@v_jobname = '!Database Update Stats Master',
			@v_rpt = @v_rptloc --+ '\' + 'Database_Update Stats_Master.txt'

	EXECUTE msdb.dbo.sp_add_job
		@job_id = @v_jobid OUTPUT,
		@job_name = @v_jobname, 
		@owner_login_name = $sqlaccount,
		@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
		@category_name = N'DBAdmin',
		@enabled = 1,
		@notify_level_email = @v_notify,
		@notify_level_page = 0,
		@notify_level_netsend = 0, 
		@notify_level_eventlog = 2,
		@delete_level = 0,
		@notify_email_operator_name = @v_email_operator

	-- Add the Backup Job Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'

	-- Add Step
	SET @v_jobstep = 'EXEC usp_stats_job_master'

	EXECUTE msdb.dbo.sp_add_jobstep
		@job_id = @v_jobid,
		@step_id = 1,
		@step_name = 'Launch Jobs',
		@command = @v_jobstep,
		@database_name = N'msdb',
		@server = N'',
		@database_user_name = N'',
		@subsystem = N'TSQL',
		@cmdexec_success_code = 0,
		@flags = 0,
		@retry_attempts = 0,
		@retry_interval = 0,
		@output_file_name = @v_rpt,
		@on_success_step_id = 0,
		@on_success_action = 1,
		@on_fail_step_id = 0,
		@on_fail_action = 2

	EXECUTE msdb.dbo.sp_update_job
			@job_id = @v_jobid, 
			@start_step_id = 1

	EXECUTE msdb.dbo.sp_add_schedule
		@schedule_id = @v_scheduleid OUTPUT,
		@schedule_name = @v_jobname,
		@enabled = 1,
		@freq_type = @v_statsfreqtype,
		@freq_interval = @v_statsinterval,
		@freq_recurrence_factor = 1,
		@freq_subday_type = 0,
		@freq_subday_interval = 0,
		@active_start_time = @v_statstime

	EXECUTE msdb.dbo.sp_attach_schedule
		@job_id = @v_jobid,
		@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
END

-- ************************************************************************************
-- !Database Reorg Master
-- ************************************************************************************
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = '!Database Reorg Master')
BEGIN
	SELECT	@v_jobname = '!Database Reorg Master',
			@v_rpt = @v_rptloc --+ '\' + 'Database_Reorg_Master.txt'

	EXECUTE msdb.dbo.sp_add_job
		@job_id = @v_jobid OUTPUT,
		@job_name = @v_jobname, 
		@owner_login_name = $sqlaccount,
		@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
		@category_name = N'DBAdmin',
		@enabled = 1,
		@notify_level_email = @v_notify,
		@notify_level_page = 0,
		@notify_level_netsend = 0, 
		@notify_level_eventlog = 2,
		@delete_level = 0,
		@notify_email_operator_name = @v_email_operator

	-- Add the Backup Job Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'

	-- Add Step
	SET @v_jobstep = 'EXEC usp_reorg_job_master'

	EXECUTE msdb.dbo.sp_add_jobstep
		@job_id = @v_jobid,
		@step_id = 1,
		@step_name = 'Launch Jobs',
		@command = @v_jobstep,
		@database_name = N'msdb',
		@server = N'',
		@database_user_name = N'',
		@subsystem = N'TSQL',
		@cmdexec_success_code = 0,
		@flags = 0,
		@retry_attempts = 0,
		@retry_interval = 0,
		@output_file_name = @v_rpt,
		@on_success_step_id = 0,
		@on_success_action = 1,
		@on_fail_step_id = 0,
		@on_fail_action = 2

	EXECUTE msdb.dbo.sp_update_job
			@job_id = @v_jobid, 
			@start_step_id = 1

	EXECUTE msdb.dbo.sp_add_schedule
		@schedule_id = @v_scheduleid OUTPUT,
		@schedule_name = @v_jobname,
		@enabled = 1,
		@freq_type = @v_reorgfreqtype,
		@freq_interval = @v_reorginterval,
		@freq_recurrence_factor = 1,
		@freq_subday_type = 0,
		@freq_subday_interval = 0,
		@active_start_time = @v_reorgtime

	EXECUTE msdb.dbo.sp_attach_schedule
		@job_id = @v_jobid,
		@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
END

-- ************************************************************************************
-- !Check Maintenance Plans Job: runs sp_define_maintplans every 2 hours
-- ************************************************************************************
IF NOT EXISTS (SELECT [name] FROM msdb.dbo.sysjobs_view WHERE [name] = '!Check Maintenance Jobs')
BEGIN
	SELECT	@v_jobname = '!Check Maintenance Jobs'
			
	PRINT 'Creating !Check Maintenance Jobs'
	SET @v_jobid = NULL

	EXECUTE msdb.dbo.sp_add_job
		@job_id = @v_jobid OUTPUT,
		@job_name = @v_jobname, 
		@owner_login_name = $sqlaccount,
		@description = 'PLEASE DO NOT ALTER. This job belongs to DBAdmin.',
		@category_name = N'DBAdmin',
		@enabled = 1,
		@notify_level_email = @v_notify, 
		@notify_level_page = 0,
		@notify_level_netsend = 0, 
		@notify_level_eventlog = 2,
		@delete_level = 0,
		@notify_email_operator_name = @v_email_operator

	-- Add the Backup Job Target Servers
	EXECUTE msdb.dbo.sp_add_jobserver @job_id = @v_jobid, @server_name = N'(local)'

	-- Add Step
	SET @v_jobstep = 'EXECUTE usp_tdp_create_maintjobs 
	@v_tdploc = ''' + @v_tdploc + ''', 
	@v_tdpcfg = ''' + @v_tdpcfg + ''', 
	@v_backuptime = ' + CAST(@v_backuptime AS VARCHAR) + ',
	@v_backupfreqtype = ' + CAST(@v_backupfreqtype AS VARCHAR) + ',
	@v_backupinterval = ' + CAST(@v_backupinterval AS VARCHAR) + ',
	@v_backupmaxdelay = ' + CAST(@v_backupmaxdelay AS VARCHAR) + ',
	@v_tlogbaktime = ' + CAST(@v_tlogbaktime AS VARCHAR) + ',
	@v_tlogsubtype = ' + CAST(@v_tlogsubtype AS VARCHAR) + ',
	@v_tlogsubinterval = ' + CAST(@v_tlogsubinterval AS VARCHAR) + ',
	@v_tlogthreshold = ''' + @v_tlogthreshold + ''',
	@v_tlogmaxdelay = ' + CAST(@v_tlogmaxdelay AS VARCHAR) + ',
	@v_integritytime = ' + CAST(@v_integritytime AS VARCHAR) + ',
	@v_integrityfreqtype = ' + CAST(@v_integrityfreqtype AS VARCHAR) + ',
	@v_integrityinterval = ' + CAST(@v_integrityinterval AS VARCHAR) + ',
	@v_statstime = ' + CAST(@v_statstime AS VARCHAR) + ',
	@v_statsfreqtype = ' + CAST(@v_statsfreqtype AS VARCHAR) + ',
	@v_statsinterval = ' + CAST(@v_statsinterval AS VARCHAR) + ',
	@v_reorgtime = ' + CAST(@v_reorgtime AS VARCHAR) + ',
	@v_reorgfreqtype = ' + CAST(@v_reorgfreqtype AS VARCHAR) + ',
	@v_reorginterval = ' + CAST(@v_reorginterval AS VARCHAR) + ',
	@v_rptloc = ''' + @v_rptloc + ''',
	@v_email_operator = ' + CASE ISNULL(@v_email_operator,'NULL') WHEN 'NULL' THEN 'NULL' ELSE '''' + @v_email_operator + '''' END + ''

	EXECUTE msdb.dbo.sp_add_jobstep
		@job_id = @v_jobid,
		@step_id = 1,
		@step_name = 'Check Maintenance Jobs',
		@command = @v_jobstep,
		@database_name = N'msdb',
		@server = N'',
		@database_user_name = N'',
		@subsystem = N'TSQL',
		@cmdexec_success_code = 0,
		@flags = 4,
		@retry_attempts = 0,
		@retry_interval = 0,
		@output_file_name = N'',
		@on_success_step_id = 0,
		@on_success_action = 1,
		@on_fail_step_id = 0,
		@on_fail_action = 2

	EXECUTE msdb.dbo.sp_update_job
			@job_id = @v_jobid, 
			@start_step_id = 1

	EXECUTE msdb.dbo.sp_add_schedule
		@schedule_id = @v_scheduleid OUTPUT,
		@schedule_name = @v_jobname,
		@enabled = 1,
		@freq_type = 4,
		@freq_interval = 1,
		@freq_recurrence_factor = 1,
		@freq_subday_type = 8,
		@freq_subday_interval = 1,
		@active_start_time = 000000

	EXECUTE msdb.dbo.sp_attach_schedule
		@job_id = @v_jobid,
		@schedule_id = @v_scheduleid

		SELECT	@v_jobid = NULL,
				@v_scheduleid = NULL
END
GO

 
EXECUTE msdb.dbo.usp_tdp_create_maintjobs

"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}

##########################################################
#  3.0 The CREATE_JOB_!CYCLE_ERROR_LOG routine creates
#  the JOB_!CYCLE_ERROR_LOG stored procedure.
#
#  Called from MAIN 
##########################################################

function CREATE_JOB_!CYCLE_ERROR_LOG()
{

$SqlQueryText = @"
USE msdb
GO

----------------------------------------------------------------------------------
-- Author:	Nick Tornese							--
-- Date:	2/16/2006							--
-- Job:		!Cycle Error Log						--
-- Description:	Creates a job that executes sp_cycle_errorlog.			--
----------------------------------------------------------------------------------
-- Create DBAdmin category if it doesn't exists
IF NOT EXISTS (SELECT * FROM msdb.dbo.syscategories WHERE [name] = N'DBAdmin')
	EXECUTE msdb.dbo.sp_add_category @name = N'DBAdmin'
GO

-- Delete Job If Exists
IF EXISTS (SELECT * FROM msdb.dbo.sysjobs_view WHERE [name] = N'!Cycle Error Log')
	EXECUTE msdb.dbo.sp_delete_job @job_name = '!Cycle Error Log'
GO

-- Create Job - !Check Tape Backups
DECLARE	@jobid	BINARY(16),
	@cmd	VARCHAR(256)

SELECT	@cmd = 'EXECUTE sp_cycle_errorlog'

EXECUTE msdb.dbo.sp_add_job
	@job_id = @jobid OUTPUT,
	@job_name = '!Cycle Error Log', 
	@owner_login_name = $sqlaccount,
	@description = 'PLEASE DO NOT ALTER. This job belongs to the SQL Server DBAs.',
	@category_name = N'DBAdmin',
	@enabled = 1,
	@notify_level_email = 0,
	@notify_level_page = 0,
	@notify_level_netsend = 0, 
	@notify_level_eventlog = 2,
	@delete_level = 0

-- Add the Backup Job Target Servers
EXECUTE msdb.dbo.sp_add_jobserver @job_id = @jobid, @server_name = N'(local)';

-- Add Step 1 - Delete Backups
EXECUTE msdb.dbo.sp_add_jobstep
	@job_id = @jobid,
	@step_id = 1,
	@step_name = 'Cycle Error Log',
	@command = @cmd,
	@database_name = N'master',
	@server = N'',
	@database_user_name = N'',
	@subsystem = N'TSQL',
	@cmdexec_success_code = 0,
	@flags = 0,
	@retry_attempts = 0,
	@retry_interval = 0,
	@output_file_name = NULL,
	@on_success_step_id = 0,
	@on_success_action = 1,
	@on_fail_step_id = 0,
	@on_fail_action = 2

EXECUTE msdb.dbo.sp_update_job
		@job_id = @jobid, 
		@start_step_id = 1

-- Add Job Schedule - Scavenger
EXECUTE msdb.dbo.sp_add_jobschedule 
	@job_id = @jobid,
	@name = 'Cycle Error Log', 
	@enabled = 1,
	@freq_type = 8,
	@freq_interval = 1,
	@freq_recurrence_factor = 1,
	@freq_subday_type = 1,
	@freq_subday_interval = 1,
	@active_start_time = 000000
GO

"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


##########################################################
#   4.0 The CREATE_USP_GET_JOBSTATUS routine creates
#  the USP_GET_JOB_STATUS stored procedure
#
#  Called from MAIN 
##########################################################


function CREATE_USP_GET_JOB_STATUS()
{

$SqlQueryText = @"
SET NOCOUNT ON;
USE msdb
GO

IF object_id('dbo.usp_get_job_status') IS NOT NULL
  drop procedure dbo.usp_get_job_status;
GO

CREATE PROCEDURE dbo.usp_get_job_status
   @job_id UNIQUEIDENTIFIER,
   @status INT OUTPUT
    
AS

SET @status = -1

if OBJECT_ID('tempdb..#xp_results') is not null
      drop table #xp_results

CREATE TABLE #xp_results
    (job_id                UNIQUEIDENTIFIER NOT NULL,      
     last_run_date         INT              NOT NULL,      
     last_run_time         INT              NOT NULL,      
     next_run_date         INT              NOT NULL,      
     next_run_time         INT              NOT NULL,      
     next_run_schedule_id  INT              NOT NULL,      
     requested_to_run      INT              NOT NULL,      
     request_source        INT              NOT NULL,      
     request_source_id     sysname          COLLATE database_default NULL,      
     running               INT              NOT NULL,       
     current_step          INT              NOT NULL,      
     current_retry_attempt INT              NOT NULL,      
     job_state             INT              NOT NULL)      

insert into #xp_results 
      exec master.dbo.xp_sqlagent_enum_jobs 1, ' ', @job_id
 
select @status = running from #xp_results rj
      inner join msdb.dbo.sysjobs sj
         on sj.job_id = rj.job_id

drop table #xp_results

RETURN @status

GO
 

"@

Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


function TDP_Jobs
{

    #1.1
    Write-Output "`nEntering function 1.1 CREATE_USP_TDP_BACKUP_JOB_MASTER"  
    CREATE_USP_TDP_BACKUP_JOB_MASTER

    #1.2
    Write-Output "`nEntering function 1.2 CREATE_USP_TDP_TLOGBKUP_JOB_MASTER"
    CREATE_USP_TDP_TLOGBKUP_JOB_MASTER

    #1.3
    Write-Output "`nEntering function 1.3 CREATE_USP_TDP_CREATE_TLOG_MONITOR"
    CREATE_USP_TDP_CREATE_TLOG_MONITOR

    #1.4
    Write-Output "`nEntering function 1.4 CREATE_USP_INTEGRITY_JOB_MASTER"
    CREATE_USP_INTEGRITY_JOB_MASTER 

    #1.5 
    Write-Output "`nEntering function 1.5 CREATE_USP_REORG_JOB_MASTER"
    CREATE_USP_REORG_JOB_MASTER

    #1.6
    Write-Output "`nEntering function 1.6 CREATE_USP_STATS_JOB_MASTER"
    CREATE_USP_STATS_JOB_MASTER

    #2.1 
    Write-Output "`nEntering function 2.0 CREATE_USP_TDP_CREATE_MAINTJOBS"
    CREATE_USP_TDP_CREATE_MAINTJOBS

    #3.0
    Write-Output "`nEntering function 3.0 CREATE_JOB_!CYCLE_ERROR_LOG"
    CREATE_JOB_!CYCLE_ERROR_LOG

    #4.0
    Write-Output "`nEntering function 4.0 CREATE_USP_GET_JOB_STATUS "
    CREATE_USP_GET_JOB_STATUS

}


##########################################################
#  SMALL routine                                         #
##########################################################

function SMALL
{

$SqlQueryText = @"
------------------------------
-- Server Configurations -----
------------------------------


sp_configure 'show advanced options', 1;
GO
RECONFIGURE with override
GO


sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE with override
GO

sp_configure 'remote admin connections', 1;
GO
RECONFIGURE with override
GO

--Commeneted the below configurations , since its part of build document

--sp_configure 'max server memory (MB)', 57344;
--GO
--RECONFIGURE with override
--GO

--sp_configure 'min server memory (MB)', 40960;
--GO
--RECONFIGURE with override
--GO

--sp_configure 'max degree of parallelism', 4;
--GO
--RECONFIGURE with override
--GO

sp_configure 'fill factor (%)', 75;
GO
RECONFIGURE with override
GO

sp_configure 'remote query timeout (s)', 0;
GO
RECONFIGURE with override
GO

sp_configure 'Agent XPs', 1;
GO
RECONFIGURE with override
GO

------------------------------------
---- Temp DB Configurations --------
------------------------------------

USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = tempdev, NEWNAME='tempdb')
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = N'tempdb', SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = N'templog', SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_2', FILENAME = N'G:\MSSQL\Instance\TempDB2\tempdb_2.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO


------------------------------------
---- System DB initial sizing ------
------------------------------------

USE [master]
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'master', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'mastlog', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
USE [master]
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
USE [master]
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBData', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBLog', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO


--------------------------------------
---- SQL Agent History Configuration --
--------------------------------------

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=100000, 
		@jobhistory_max_rows_per_job=1000
GO


---------------------------------------
---- Server Logins --------------------
---------------------------------------
USE [master]
GO
CREATE LOGIN [Amer\GG_SQL_MONITORING] FROM WINDOWS;
EXEC sp_addsrvrolemember [Amer\GG_SQL_MONITORING], sysadmin

--Commented the below line, since the service account is part of GG Monitoring
--CREATE LOGIN [AMER\_svcnomlqs] FROM WINDOWS;
--EXEC sp_addsrvrolemember [AMER\_svcnomlqs], sysadmin

CREATE LOGIN [AMER\GG_SQL_DBAs] FROM WINDOWS;
EXEC sp_addsrvrolemember [AMER\GG_SQL_DBAs], sysadmin


--Encrypted the sa password since the OLD SCU have password exposed
ALTER LOGIN [sa] WITH PASSWORD=N'Î±?zÖ!"¶`Å£©àÝéÑÄ7?»z1ë£½¾?'
GO

----------------------------------------------
-------login Creation Script------------------
----------------------------------------------
USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[New_login]    Script Date: 08/24/2015 09:03:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_new_login](@loginNM varchar(50),@pw varchar(50)= NULL,@pwd varchar(32)=null output) 
with encryption

as 
SET NOCOUNT ON
begin
declare @sql varchar(max)
,@length int
,@charpool varchar (200)
,@poollength int
,@randomstring varchar(500)
,@loopcount int
,@pass varchar(25)
SET @Length = RAND() * 5 + 8
SET @CharPool = 'a1bcdefg2hijk3mn4opqrstu7vwxy9zABC8DEFGH6IJKLMNPQ0RSTUVW0XYZ'
SET @PoolLength = Len(@CharPool)
SET @LoopCount = 0
SET @RandomString = ''

WHILE (@LoopCount < @Length) BEGIN
    SELECT @RandomString = @RandomString + 
        SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength), 1)
    SELECT @LoopCount = @LoopCount + 1
END


iF NOT EXISTS(SELECT 1 FROM MASTER..SYSLOGINS WHERE NAME = @loginNM)

begin try
if @pw is not null 
set @pass = @pw
else set @pass=@randomstring
SET @SQL= 'CREATE LOGIN [' + @loginNM + ']' + CHAR(10)
SET @SQL= @SQL + 'WITH PASSWORD  = N''' + @pass + ''',' + CHAR(10)
SET @SQL= @SQL + 'CHECK_POLICY = ON,'  + CHAR(10)
SET @SQL= @SQL + 'CHECK_EXPIRATION = OFF,' + CHAR(10)
SET @SQL= @SQL + 'DEFAULT_DATABASE = msdb;' + CHAR(10)

Execute (@sql )
set @pwd = @pass
return
end try
begin catch
 SELECT 
        ERROR_NUMBER() AS ErrorNumber,
ERROR_MESSAGE() as errormessage
--select @SQL
end catch

else select 'Login already exists.. '


End

GO
CREATE LOGIN [AMER\GG_SECURITY_SQL_PROVISIONER] FROM WINDOWS;
GO
GRANT EXECUTE ON [msdb].[dbo].[usp_new_login] to [AMER\GG_SECURITY_SQL_PROVISIONER]


Use [master]
go
Grant Alter any login to [AMER\GG_SECURITY_SQL_PROVISIONER]
go



"@

Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}


##########################################################
#  Medium routine                                        #
##########################################################

function MEDIUM
{

$SqlQueryText = @"
------------------------------
-- Server Configurations -----
------------------------------


sp_configure 'show advanced options', 1;
GO
RECONFIGURE with override
GO


sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE with override
GO

sp_configure 'remote admin connections', 1;
GO
RECONFIGURE with override
GO

-- Commeneted the below configurations , since its part of build document

--sp_configure 'max server memory (MB)', 57344;
--GO
--RECONFIGURE with override
--GO

--sp_configure 'min server memory (MB)', 40960;
--GO
--RECONFIGURE with override
--GO

--sp_configure 'max degree of parallelism', 4;
--GO
--RECONFIGURE with override
--GO

sp_configure 'fill factor (%)', 75;
GO
RECONFIGURE with override
GO

sp_configure 'remote query timeout (s)', 0;
GO
RECONFIGURE with override
GO

sp_configure 'Agent XPs', 1;
GO
RECONFIGURE with override
GO

------------------------------------
---- Temp DB Configurations --------
------------------------------------

USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = tempdev, NEWNAME='tempdb')
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = N'tempdb', SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = N'templog', SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_2', FILENAME = N'G:\MSSQL\Instance\TempDB2\tempdb_2.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_3', FILENAME = N'G:\MSSQL\Instance\TempDB3\tempdb_3.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_4', FILENAME = N'G:\MSSQL\Instance\TempDB4\tempdb_4.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO



------------------------------------
---- System DB initial sizing ------
------------------------------------

USE [master]
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'master', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'mastlog', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
USE [master]
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
USE [master]
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBData', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBLog', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO


--------------------------------------
---- SQL Agent History Configuration --
--------------------------------------

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=100000, 
		@jobhistory_max_rows_per_job=1000
GO


---------------------------------------
---- Server Logins --------------------
---------------------------------------

USE [master]
GO
CREATE LOGIN [Amer\GG_SQL_MONITORING] FROM WINDOWS;
EXEC sp_addsrvrolemember [Amer\GG_SQL_MONITORING], sysadmin

--Commented the below line, since the service account is part of GG Monitoring
--CREATE LOGIN [AMER\_svcnomlqs] FROM WINDOWS;
--EXEC sp_addsrvrolemember [AMER\_svcnomlqs], sysadmin

CREATE LOGIN [AMER\GG_SQL_DBAs] FROM WINDOWS;
EXEC sp_addsrvrolemember [AMER\GG_SQL_DBAs], sysadmin

ALTER LOGIN [sa] WITH PASSWORD=N'Î±?zÖ!"¶`Å£©àÝéÑÄ7?»z1ë£½¾?'
GO


----------------------------------------------
-------login Creation Script------------------
----------------------------------------------
USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[New_login]    Script Date: 08/24/2015 09:03:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_new_login](@loginNM varchar(50),@pw varchar(50)= NULL,@pwd varchar(32)=null output) 
with encryption

as 
SET NOCOUNT ON
begin
declare @sql varchar(max)
,@length int
,@charpool varchar (200)
,@poollength int
,@randomstring varchar(500)
,@loopcount int
,@pass varchar(25)
SET @Length = RAND() * 5 + 8
SET @CharPool = 'a1bcdefg2hijk3mn4opqrstu7vwxy9zABC8DEFGH6IJKLMNPQ0RSTUVW0XYZ'
SET @PoolLength = Len(@CharPool)
SET @LoopCount = 0
SET @RandomString = ''

WHILE (@LoopCount < @Length) BEGIN
    SELECT @RandomString = @RandomString + 
        SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength), 1)
    SELECT @LoopCount = @LoopCount + 1
END


iF NOT EXISTS(SELECT 1 FROM MASTER..SYSLOGINS WHERE NAME = @loginNM)

begin try
if @pw is not null 
set @pass = @pw
else set @pass=@randomstring
SET @SQL= 'CREATE LOGIN [' + @loginNM + ']' + CHAR(10)
SET @SQL= @SQL + 'WITH PASSWORD  = N''' + @pass + ''',' + CHAR(10)
SET @SQL= @SQL + 'CHECK_POLICY = ON,'  + CHAR(10)
SET @SQL= @SQL + 'CHECK_EXPIRATION = OFF,' + CHAR(10)
SET @SQL= @SQL + 'DEFAULT_DATABASE = msdb;' + CHAR(10)

Execute (@sql )
set @pwd = @pass
return
end try
begin catch
 SELECT 
        ERROR_NUMBER() AS ErrorNumber,
ERROR_MESSAGE() as errormessage
--select @SQL
end catch

else select 'Login already exists.. '


End

GO
CREATE LOGIN [AMER\GG_SECURITY_SQL_PROVISIONER] FROM WINDOWS;
GO
GRANT EXECUTE ON [msdb].[dbo].[usp_new_login] to [AMER\GG_SECURITY_SQL_PROVISIONER]


Use [master]
go
Grant Alter any login to [AMER\GG_SECURITY_SQL_PROVISIONER]
go

"@

Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}

##########################################################
#  Large routine                                         #
##########################################################

function LARGE
{

$SqlQueryText = @"

------------------------------
-- Server Configurations -----
------------------------------


sp_configure 'show advanced options', 1;
GO
RECONFIGURE with override
GO


sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE with override
GO

sp_configure 'remote admin connections', 1;
GO
RECONFIGURE with override
GO

-- Commeneted the below configurations , since its part of build document

--sp_configure 'max server memory (MB)', 57344;
--GO
--RECONFIGURE with override
--GO

--sp_configure 'min server memory (MB)', 40960;
--GO
--RECONFIGURE with override
--GO

--sp_configure 'max degree of parallelism', 4;
--GO
--RECONFIGURE with override
--GO

sp_configure 'fill factor (%)', 75;
GO
RECONFIGURE with override
GO

sp_configure 'remote query timeout (s)', 0;
GO
RECONFIGURE with override
GO

sp_configure 'Agent XPs', 1;
GO
RECONFIGURE with override
GO

------------------------------------
---- Temp DB Configurations --------
------------------------------------

USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = tempdev, NEWNAME='tempdb')
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = N'tempdb', SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] MODIFY FILE (NAME = N'templog', SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_2', FILENAME = N'G:\MSSQL\Instance\TempDB2\tempdb_2.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_3', FILENAME = N'G:\MSSQL\Instance\TempDB3\tempdb_3.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_4', FILENAME = N'G:\MSSQL\Instance\TempDB4\tempdb_4.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_5', FILENAME = N'G:\MSSQL\Instance\TempDB5\tempdb_5.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_6', FILENAME = N'G:\MSSQL\Instance\TempDB6\tempdb_6.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_7', FILENAME = N'G:\MSSQL\Instance\TempDB7\tempdb_7.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb_8', FILENAME = N'G:\MSSQL\Instance\TempDB8\tempdb_8.ndf' , SIZE = 1048576KB , FILEGROWTH = 102400KB )
GO


------------------------------------
---- System DB initial sizing ------
------------------------------------

USE [master]
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'master', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'mastlog', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
USE [master]
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
USE [master]
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBData', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBLog', SIZE = 1024000KB , FILEGROWTH = 102400KB )
GO

--------------------------------------
---- SQL Agent History Configuration --
--------------------------------------

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=100000, 
		@jobhistory_max_rows_per_job=1000
GO


---------------------------------------
---- Server Logins --------------------
---------------------------------------

USE [master]
GO
CREATE LOGIN [Amer\GG_SQL_MONITORING] FROM WINDOWS;
EXEC sp_addsrvrolemember [Amer\GG_SQL_MONITORING], sysadmin

--Commented the below line, since the service account is part of GG Monitoring
--CREATE LOGIN [AMER\_svcnomlqs] FROM WINDOWS;
--EXEC sp_addsrvrolemember [AMER\_svcnomlqs], sysadmin

CREATE LOGIN [AMER\GG_SQL_DBAs] FROM WINDOWS;
EXEC sp_addsrvrolemember [AMER\GG_SQL_DBAs], sysadmin

ALTER LOGIN [sa] WITH PASSWORD=N'Î±?zÖ!"¶`Å£©àÝéÑÄ7?»z1ë£½¾?'
GO


----------------------------------------------
-------login Creation Script------------------
----------------------------------------------
USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[New_login]    Script Date: 08/24/2015 09:03:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_new_login](@loginNM varchar(50),@pw varchar(50)= NULL,@pwd varchar(32)=null output) 
with encryption

as 
SET NOCOUNT ON
begin
declare @sql varchar(max)
,@length int
,@charpool varchar (200)
,@poollength int
,@randomstring varchar(500)
,@loopcount int
,@pass varchar(25)
SET @Length = RAND() * 5 + 8
SET @CharPool = 'a1bcdefg2hijk3mn4opqrstu7vwxy9zABC8DEFGH6IJKLMNPQ0RSTUVW0XYZ'
SET @PoolLength = Len(@CharPool)
SET @LoopCount = 0
SET @RandomString = ''

WHILE (@LoopCount < @Length) BEGIN
    SELECT @RandomString = @RandomString + 
        SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength), 1)
    SELECT @LoopCount = @LoopCount + 1
END


iF NOT EXISTS(SELECT 1 FROM MASTER..SYSLOGINS WHERE NAME = @loginNM)

begin try
if @pw is not null 
set @pass = @pw
else set @pass=@randomstring
SET @SQL= 'CREATE LOGIN [' + @loginNM + ']' + CHAR(10)
SET @SQL= @SQL + 'WITH PASSWORD  = N''' + @pass + ''',' + CHAR(10)
SET @SQL= @SQL + 'CHECK_POLICY = ON,'  + CHAR(10)
SET @SQL= @SQL + 'CHECK_EXPIRATION = OFF,' + CHAR(10)
SET @SQL= @SQL + 'DEFAULT_DATABASE = msdb;' + CHAR(10)

Execute (@sql )
set @pwd = @pass
return
end try
begin catch
 SELECT 
        ERROR_NUMBER() AS ErrorNumber,
ERROR_MESSAGE() as errormessage
--select @SQL
end catch

else select 'Login already exists.. '


End

GO
CREATE LOGIN [AMER\GG_SECURITY_SQL_PROVISIONER] FROM WINDOWS;
GO
GRANT EXECUTE ON [msdb].[dbo].[usp_new_login] to [AMER\GG_SECURITY_SQL_PROVISIONER]


Use [master]
go
Grant Alter any login to [AMER\GG_SECURITY_SQL_PROVISIONER]
go

"@
Invoke-Sqlcmd -ServerInstance $SRV  -query $SqlQueryText

}

    Function Prompt-User 
    {
    
    $SqlServerName=$SRV
    
    Restart-SqlService -SqlServerName $SqlServerName
    Create-DummyDatabase -SqlServerName $SqlServerName
    Fill-TransactionLog -SqlServerName $SqlServerName
    Fill-DataFile -SqlServerName $SqlServerName
    Offline-Database -SqlServerName $SqlServerName
    Grow-DataFile -SqlServerName $SqlServerName
    Drop-Database -SqlServerName $SqlServerName

    }

    Function Restart-SqlService 
    {
    param 
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$SqlServerName
    )

    Add-Type -Path "C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    if ($SqlServer.InstanceName -eq "")
     {
        $SqlServiceName = "MSSQLSERVER"
        $SqlAgentServiceName = "SQLSERVERAGENT"
     }
    else 
     {
        $SqlServiceName = 'MSSQL$' + $SqlServer.InstanceName
        $SqlAgentServiceName = 'SQLAgent$' + $SqlServer.InstanceName
     }
   
    Write-Host "Stopping service... $SqlAgentServiceName ... on $($SqlServer.ComputerNamePhysicalNetBIOS)" -ForegroundColor Green

    try 
    {
        (Get-WmiObject -ComputerName $SqlServer.ComputerNamePhysicalNetBIOS -Class "Win32_Service" |
         Where-Object {$_.Name -eq $SqlAgentServiceName}).StopService() | Out-Null
    }
    catch 
    {
        Write-Error $_.Exception
    }

    Start-Sleep -seconds 15

    Write-Host "Stopping service... $SqlServiceName ... on $($SqlServer.ComputerNamePhysicalNetBIOS)" -ForegroundColor Green

    try 
    {
        (Get-WmiObject -ComputerName $SqlServer.ComputerNamePhysicalNetBIOS -Class "Win32_Service" |
         Where-Object {$_.Name -eq $SqlServiceName}).StopService() | Out-Null
    }
    catch 
    {
        Write-Error $_.Exception
    }

    #sleep for 5 minutes so that we ensure the alerting has time to pick up the stopped service
    Write-Host "Sleeping for 15 seconds... $((Get-Date).ToLongTimeString())" -ForegroundColor Green
    Start-Sleep -seconds 15

    Write-Host "Starting service... $SqlServiceName ... on $($SqlServer.ComputerNamePhysicalNetBIOS)" -ForegroundColor Green

    try 
    {
        (Get-WmiObject -ComputerName $SqlServer.ComputerNamePhysicalNetBIOS -Class "Win32_Service" |
         Where-Object {$_.Name -eq $SqlServiceName}).StartService() | Out-Null
    }
    catch 
    {
        Write-Error $_.Exception
    }

    Start-Sleep -seconds 15

    Write-Host "Starting service... $SqlAgentServiceName ... on $($SqlServer.ComputerNamePhysicalNetBIOS)" -ForegroundColor Green

    try 
    {
        (Get-WmiObject -ComputerName $SqlServer.ComputerNamePhysicalNetBIOS -Class "Win32_Service" |
         Where-Object {$_.Name -eq $SqlAgentServiceName}).StartService() | Out-Null
    }
    catch 
    {
        Write-Error $_.Exception
    }
}

    Function Create-DummyDatabase 
    {
    param 
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SqlServerName
    )

    Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
    Add-Type -Path "C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.SmoExtended.dll"

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    if ($SqlServer.DefaultFile.Substring($SqlServer.DefaultFile.Length - 1) -ne "\") {
        $SqlDataFile = "\MonitorTestDb.mdf"
    }
    else 
    {
        $SqlDataFile = "MonitorTestDb.mdf"
    }

    if ($SqlServer.DefaultLog.Substring($SqlServer.DefaultLog.Length - 1) -ne "\") 
    {
        $SqlLogFile = "\MonitorTestDb.ldf"
    }
    else 
    {
        $SqlLogFile = "MonitorTestDb.ldf"
    }
   

    Write-Host "Creating TEST database..." -ForegroundColor Green
    $DummyDb = New-Object Microsoft.SqlServer.Management.Smo.Database($SqlServer, "MonitorTestDb")
    $DummyDb.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full
    $newfg = New-Object Microsoft.SqlServer.Management.Smo.FileGroup($DummyDb, "PRIMARY")
    $DummyDb.FileGroups.Add($newfg)
    $newdf = New-Object Microsoft.SqlServer.Management.Smo.DataFile($newfg, "MonitorTestDb_data")
    $newdf.FileName = $SqlServer.DefaultFile + $SqlDataFile
    $newdf.Size = 4 * 1024 # 4 MB
    $newdf.GrowthType = [Microsoft.SqlServer.Management.Smo.FileGrowthType]::None
    $newfg.Files.Add($newdf)
    $newlf = New-Object Microsoft.SqlServer.Management.Smo.LogFile($DummyDb, "MonitorTestDb_log")
    $newlf.FileName = $SqlServer.DefaultLog + $SqlLogFile
    $newlf.Size = 1024 # 1 MB
    $newlf.GrowthType = [Microsoft.SqlServer.Management.Smo.FileGrowthType]::None
    $DummyDb.LogFiles.Add($newlf)

    try 
    {
        $DummyDb.Create()
    }
    catch 
    {
        Write-Error $_.Exception
    }

    Write-Host "Backing up TEST database to NUL..." -ForegroundColor Green
    $SqlBackup = New-Object Microsoft.SqlServer.Management.Smo.Backup
    $SqlBackup.Database = "MonitorTestDb"
    $SqlBackup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
    $SqlBackup.Devices.AddDevice("NUL:",  [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
    $SqlBackup.SqlBackup($SqlServer)

    Write-Host "Creating TEST table..." -ForegroundColor Green
    $newtbl = New-Object Microsoft.SqlServer.Management.Smo.Table($DummyDb, "TestTable")
    $DummyDb.Tables.Add($newtbl)
    $newcol = New-Object Microsoft.SqlServer.Management.Smo.Column($newtbl, "Col1", [Microsoft.SqlServer.Management.Smo.DataType]::NVarCharMax)
    $newtbl.Columns.Add($newcol)
    $newtbl.Create()

    }

    Function Fill-TransactionLog 
    {
    param 
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SqlServerName
    )

    Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    Write-Host "Filling transaction log..." -ForegroundColor Green
    try 
    {
    while ($true) 
      {
        #Write-Host "Inserting row..."
        $SqlServer.Databases["MonitorTestDb"].ExecuteNonQuery("insert into dbo.TestTable values(N'a');")
        $SqlServer.Databases["MonitorTestDb"].ExecuteNonQuery("delete from dbo.TestTable;")
        }
      }
    catch 
    {
        Write-Host "INSERTS/DELETES expectedly threw error..." -ForegroundColor Green
    }

    Write-Host "Sleeping for 15 seconds... $((Get-Date).ToLongTimeString())" -ForegroundColor Green
    Start-Sleep -seconds 15

    Write-Host "Changing database recovery model to SIMPLE..." -ForegroundColor Green
    $SqlServer.Databases["MonitorTestDb"].RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple
    $SqlServer.Databases["MonitorTestDb"].Alter()
    }

    Function Fill-DataFile 
    {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SqlServerName
    )

    Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    Write-Host "Filling datafile..." -ForegroundColor Green

    try {
        while ($true) {
            #Write-Host "Inserting row..."
            $SqlServer.Databases["MonitorTestDb"].ExecuteNonQuery("insert into dbo.TestTable values(replicate(N'a', 4000));") 
        }
    }
    catch {
        Write-Host "INSERTS expectedly threw error..." -ForegroundColor Green
    }

    Write-Host "Sleeping for 15 seconds... $((Get-Date).ToLongTimeString())" -ForegroundColor Green
    Start-Sleep -seconds 15
}

    Function Offline-Database 
    {
    param 
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SqlServerName
    )

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    Write-Host "Killing all database processes..." -ForegroundColor Green
    $SqlServer.KillAllProcesses("MonitorTestDb")

    Write-Host "Taking database offline..." -ForegroundColor Green
    $SqlServer.Databases["MonitorTestDb"].SetOffline()

    Write-Host "Sleeping for 15 seconds... $((Get-Date).ToLongTimeString())" -ForegroundColor Green
    Start-Sleep -seconds 15

    Write-Host "Bringing database online..." -ForegroundColor Green
    $SqlServer.Databases["MonitorTestDb"].SetOnline()
    }

    Function Grow-DataFile 
    {
    param 
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SqlServerName
    )

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    Write-Host "Growing data file..." -ForegroundColor Green

    $PrimaryDf = $SqlServer.Databases["MonitorTestDb"].FileGroups["PRIMARY"].Files[0]
    $PrimaryDf.Size = $PrimaryDf.Size + $PrimaryDf.VolumeFreeSpace - (1 * 1024 * 1024) # leave 1 GB free
    $PrimaryDf.Alter()

    Write-Host "Sleeping for 15 seconds... $((Get-Date).ToLongTimeString())" -ForegroundColor Green
    Start-Sleep -seconds 15
    }

    Function Drop-Database 
    {
    param 
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SqlServerName
    )

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    Write-Host "Killing all database processes..." -ForegroundColor Green
    $SqlServer.KillAllProcesses("MonitorTestDb")

    Write-Host "Dropping the database..." -ForegroundColor Green
    $SqlServer.Databases["MonitorTestDb"].Drop()
    }


    function instance_config
    {

    if ($config -eq "small")
    {
    write-host "Configuring SQL Server instance. Configuration Type = SMALL"
    small
    }

    if($config -eq "medium")
    {
    write-host "Configuring SQL Server instance. Configuration Type = MEDIUM"
    medium
    }

    if ($config -eq "large")
    {
    write-host "Configuring SQL Server instance. Configuration Type = LARGE"
    large
    }


    }

#########################################################################
#  Upload to CMDB
##########################################################################

Function Add-CMDB {
    param (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]] $SqlServerInstanceList = $env:COMPUTERNAME
    )

    begin {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
            }

    process {
 
      
        $HostsQry = "
        Select  NodeName FROM sys.dm_os_cluster_nodes 
        union
        SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS')
                "

        $HADRInfoQry = "
        Declare @HADRInfo table (
		CurrentSQLServer varchar(50),
		HADRType char(2),
		HADRServer varchar(50),
		ListenerName varchar(50),
		AGName varchar(50)
			)	

            BEGIN
            -- For Mirroring
            if exists ( 
	            select distinct @@servername 'Principal',  mirroring_partner_instance 'Mirror'
	            from sys.database_mirroring where mirroring_partner_instance is not null
		            )
		
            Begin
	            Insert into @HADRInfo
	            select @@servername,'MR',@@SERVERNAME,Null,Null 
	            union
	            select distinct @@servername,'MR',mirroring_partner_instance ,Null,Null 
	            from sys.database_mirroring	where mirroring_partner_instance is not null
            End

            -- For LogShipping
            if exists (
	            select distinct primary_server,Secondary_Server 
	            from msdb.dbo.log_shipping_monitor_primary p inner join msdb..log_shipping_primary_secondaries s
	            on p.primary_id = s.primary_id
			            )
            Begin
	            Insert into @HADRInfo
	            select distinct @@servername,'LS',primary_server,Null,Null
	            from msdb.dbo.log_shipping_monitor_primary 
	            union
	            select distinct @@servername,'LS',Secondary_Server,Null,Null
	            from msdb..log_shipping_primary_secondaries
            End


            -- For AlwaysOn
            if (SELECT @@MICROSOFTVERSION / 0x01000000) > 10
	            if exists (select member_name from sys.dm_hadr_cluster_members)
            Begin
	            Insert into @HADRInfo
	            select distinct @@servername,'AO',replica_server_name,Null,Null
	            from sys.availability_replicas

	            Update @HADRInfo
	            set ListenerName = agl.dns_name, AGName = ag.name 
	            from sys.availability_group_listeners agl
	            inner join sys.availability_groups ag
	            on agl.group_id = ag.group_id
	            where CurrentSQLServer = @@servername and HADRType = 'AO'

            End

            Select * from @HADRInfo

            END
                    "


        foreach ($SqlServerInstance in $SqlServerInstanceList) 
            {
            try {
                 $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerInstance)


# SQL Server Level #

            # Instance Name
                $InstanceArray = $SqlServerInstance.Split("\")
                $SqlNetworkName = $InstanceArray[0]
                if (!$InstanceArray[1]) {
                    $SqlInstanceName = "MSSQLSERVER"
                }
                else {
                    $SqlInstanceName = $InstanceArray[1]
                }  

            # Active Node Name
                 $vComputerName = $SqlServer.ComputerNamePhysicalNetBIOS  

                if ( ! $vComputerName ) {
                    $vComputerName = $SqlNetworkName
                }
                                    

            # SQL Variables #
                $vClu = $SqlServer.IsClustered
                $sqlverMaj = $SqlServer.VersionMajor
                $sqlverMin = $SqlServer.VersionMinor
                $sqlverBld = $SqlServer.BuildNumber
                $sqlver = $SqlServer.VersionString
                $sqlsp = $SqlServer.ProductLevel
                $sqledt = $SqlServer.Edition

                $srvmem = $SqlServer.PhysicalMemory
                $srvcpu = $SqlServer.Processors
                
                # $memSrv = $SqlServer.information.physicalMemory
                $memMax = $SqlServer.configuration.maxServerMemory.runValue
                $memMin = $SqlServer.configuration.minServerMemory.runValue

                $cpuqry ="SELECT cpu_count FROM  sys.dm_os_sys_info"
                $cpus = $SqlServer.Databases["Master"].ExecuteWithResults($cpuqry)
                $sqlcpu = $cpus.Tables[0] | select-object -expandproperty cpu_count
       


            # HADR ....
               $SqlDestServer = new-object microsoft.sqlserver.management.smo.server("WSPRDS051\PRDB20028")
               $SqlDestServer.ConnectionContext.LoginSecure = $false
               $SqlDestServer.ConnectionContext.Login = $CmdbAdminCred.UserName
               $SqlDestServer.ConnectionContext.SecurePassword = $CmdbAdminCred.Password
               
             ## -- Cleanup existing data from Temp Tables
             
             $DelInsQry = "delete from dbo.Tmp_SQLSystemInfo"
             $DelHstQry = "delete from dbo.Tmp_SQLHOSTS"
             $DelHDRQry = "delete from dbo.Tmp_SQLHADR"

            $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($DelInsQry)
            $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($DelHstQry)
            $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($DelHDRQry)
  
            ##  -- Cleanup existing data from Temp Tables  
            
            
 
            Foreach($Row in $SqlServer.Databases["master"].ExecuteWithResults($HADRInfoQry).Tables[0] ) 
                {

                $vHADRType = $row.HadrType
                $vHADRServer = $Row.HADRServer
                $vListner = $Row.ListenerName
                $vAGName = $Row.AGName

                    $HADRquery = "INSERT INTO [CMDBSQL].[dbo].[Tmp_SQLHADR](
                                    [SQLServerInstance]
                                   ,[SQL_Network_Name]
                                   ,[Instance_Name]
                                   ,[HADRType]
                                   ,[HADRServer]
                                   ,[ListenerName]
                                   ,[AGName])
                                VALUES (
                                    '$SqlServerInstance'
                                    ,'$SqlNetworkName'
                                    ,'$SqlInstanceName'
                                    ,'$vHADRType'
                                    ,'$vHADRServer'
                                    ,'$vListner'
                                    ,'$vAGName'
                                    )"

                    

                    $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($HADRquery)


                }

                # SQL Server Services #
                Get-WmiObject -query "select   Name, DisplayName,  StartName, State, StartMode from win32_service where Name like '%SQL%' " -computer "$SqlNetworkName"  |
                ForEach-Object {
                    $SrvNm = $_.Name
                    $SrvDisNm = $_.DisplayName
                    $SrvStNm = $_.startname
                    $Srvstate = $_.state
                    $srvmode = $_.StartMode


            $srvquery = "INSERT INTO [CMDBSQL].[dbo].[SQLServer_Services]
                ([SQL_Network_Name]
                ,[ServName]
                ,[ServDisplayName]
                ,[ServAccountName]
                ,[ServStatus]
                ,[ServStartMode])
                Values
                ('$SqlNetworkName'
                 ,'$srvNm' 
                 ,'$SrvDisNm'
                 ,'$SrvStNm'
                 ,'$Srvstate'
                 ,'$srvmode')"

           $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($srvquery)
                }

                ## SQL Server Services ##


                
                # SQL Features #

                $SqlWmiNamespace = Get-WmiObject -ComputerName "$SqlNetworkName" -Namespace "root\microsoft\sqlserver" -Class "__NAMESPACE" |
                Where-Object {$_.Name -like "ComputerManagement*"} |
                Sort-Object Name -Descending |
                Select-Object -ExpandProperty Name -First 1

                $SqlWmiNamespace = "root\microsoft\sqlserver\" + $SqlWmiNamespace

                Get-WmiObject -ComputerName "$SqlNetworkName" -Namespace $SqlWmiNamespace -Class "SqlService" |
                Select-Object SQLServiceType -unique |
                ForEach-Object {
                $SQLSrvType = $_.SQLServiceType

                $SQLFeatureQuery = "INSERT INTO [CMDBSQL].[dbo].[Instance_To_Features]
                                    ([SQL_Network_Name]
                                    ,[Instance_Name]
                                    ,[SQLFeatureID])
                                    VALUES
                                    ('$SqlNetworkName'
                                    ,'$SqlInstanceName'
                                    ,'$SQLSrvType')"

                $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($SQLFeatureQuery)
                        }




                ## SQL Features ##



            ## HADR ...
## SQL Server Level ##         

# Hosts #

                Foreach($Row in $SqlServer.Databases["master"].ExecuteWithResults($HostsQry).Tables[0] ) 
                    {
                    $NodeNm = $Row.NodeName

                # Host Variables #
                    $vLogicalCPUs = 0 
                    $vPhysicalCPUs = 0 
                    $vCPUCores = 0 
                    $vSocketDesignation = 0 
                    $HT_status = ""
                    $vIsHyperThreaded = -1 

                    $vHWType = ""
                    $OSVer = ""
                    $OSSP = ""
                    $vType = ""
                    $Mem = 0
                    $dom = ""

            # Get the Processor information from the WMI object 
                $vProcessors = [object[]]$(get-WMIObject Win32_Processor -ComputerName $NodeNm) 

            # To account for older machines 
                if ($vProcessors[0].NumberOfCores -eq $null) 
                { 
                $vSocketDesignation = new-object hashtable 
                $vProcessors |%{$vSocketDesignation[$_.SocketDesignation] = 1} 
                $vPhysicalCPUs = $vSocketDesignation.count 
                $vLogicalCPUs = $vProcessors.count 
                } 
            # If the necessary hotfixes are installed as mentioned below, then the NumberOfCores and NumberOfLogicalProcessors can be fetched correctly
                else 
                { 
                $vCores = $vProcessors.count 
                $vLogicalCPUs = $($vProcessors|measure-object NumberOfLogicalProcessors -sum).Sum 
                $vPhysicalCPUs = $($vProcessors|measure-object NumberOfCores -sum).Sum 
                } 
                 if ($vLogicalCPUs -gt $vPhysicalCPUs) 
                 { 
                 $HT_status = "Active" 
                 }
                 else
                 { 
                 $HT_status = "Inactive" 
                 }
            
            
                $vHWType = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $NodeNm| Select-Object -ExpandProperty model
                $vOS =Get-WmiObject Win32_OperatingSystem -ComputerName $NodeNm| Select-Object -expandproperty caption
                $vOSSP = get-wmiobject win32_operatingsystem -ComputerName $NodeNm | select -expandproperty servicepackmajorversion
        

                if ($vHWType -like  "VMWare*")
                { 
                $vType = "Y" 
                }
                else
                { 
                $vType = "N" 
                }
            
                 if ( ! $vCores ) {
                    $vCores = 0
                }
                
                if ( ! $NumberOfCores ) {
                    $NumberOfCores = 0
                }
                
                $clunm = 
                Get-WmiObject -ComputerName $NodeNm -Namespace "root\mscluster" -Class "MSCluster_Cluster" -Impersonation Impersonate -Authentication PacketPrivacy -ErrorVariable err -ErrorAction SilentlyContinue |
                Select-Object –ExpandProperty Name
                # write-host $clunm 
 
 
                $mem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $NodeNm | Select-Object @{Name = "TotalPhysicalMemoryGB"; Expression = {[int]($_.TotalPhysicalMemory / 1GB)}} | Select-Object -ExpandProperty TotalPhysicalMemoryGB
                $dom = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $NodeNm | select-object -ExpandProperty domain



  #                  $SqlDestServer = new-object microsoft.sqlserver.management.smo.server("WSPRDS051\PRDB20028")

                    $Hstquery = "INSERT INTO [CMDBSQL].[dbo].[Tmp_SQLHosts](
                                    [SQLServerInstance]
                                   ,[SQL_Network_Name]
                                   ,[Instance_Name]                                    
                                   ,[HOST_NAME]
                                   ,[DOMAIN]
                                   ,[OS]
                                   ,[Sockets]
                                   ,[Cores]
                           		   ,[LogicalProcessors]
		                           ,[HTStatus]
                                   ,[Memory_GB]
                                   ,[VM_Flag]
                                   ,[Cluster_Name])
                                VALUES (
                                    '$SqlServerInstance'
                                    ,'$SqlNetworkName'
                                    ,'$SqlInstanceName'
                                    ,'$NodeNm'
                                    ,'$dom'
                                    ,'$vOS'
                                    ,$vCores
                                    ,$vPhysicalCPUs
                               		,$vLogicalCPUs
		                            ,'$HT_status'
                                    ,$mem
                                    ,'$vType'
                                    ,'$clunm'
                                    )"

                    # write-host $Hstquery

                    $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($Hstquery)
 
                    }

 #   $SqlDestServer = new-object microsoft.sqlserver.management.smo.server("WSPRDS051\PRDB20028")

   
    $sysquery = "INSERT INTO [CMDBSQL].[dbo].[Tmp_SQLSystemInfo]
           ([SQLServerInstance]
           ,[SQL_Network_Name]
           ,[Instance_Name]
           ,[HostName]
           ,[HW]
           ,[OS_Version]
           ,[OS_SP]
           ,[SQL_Version]
           ,[SQL_SP]
           ,[SQLVerMaj]
           ,[SQLVerMin]
           ,[SQLVerBld]
           ,[Edition]
           ,[Cluster]
           ,[Virtual]
           ,[Sockets]
           ,[Cores]
           ,[LogicalProc]
           ,[HTStatus]
           ,[Memory_GB]
           ,[SQL_Max_Memory]
           ,[SQL_Min_Memory]
           ,[SQL_Processors]
           ,[Domain]
           ,[MonDateTime])
     VALUES
         (
           '$SqlServerInstance'
           ,'$SqlNetworkName'
           ,'$SqlInstanceName'
           ,'$vComputerName'
           ,'$vHWType'
           ,'$vOS'
           ,'$vOSSP'
           ,'$SQLVer'
           ,'$SQLSP'
           ,$sqlverMaj
           ,$sqlverMin
           ,$sqlverBld
           ,'$sqledt'
           ,'$vClu'
           ,'$vType'
           ,$vCores
           ,$vPhysicalCPUs
           ,$vLogicalCPUs
           ,'$HT_status'
           ,$Mem
           ,$Memmax
           ,$Memmin
           ,$sqlcpu
           ,'$dom'
           ,getdate())"

# write-host $sysquery

   $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($sysquery)

   
            $output = New-Object System.Object
            $output | 
                Add-Member -MemberType NoteProperty -Name "SqlInstanceName" -Value $SqlInstanceName
            $output | 
                Add-Member -MemberType NoteProperty -Name "SqlNetworkName" -Value $SqlNetworkName

            Write-Output $output


            }
                catch {
                  # Write-Error $_.Exception
                  # write-host $SqlServerInstance
                  
                  $errexc = $_.Exception -replace "'","''"
 
                  $SqlDestServer = new-object microsoft.sqlserver.management.smo.server("WSPRDS051\PRDB20028")
                  $SqlDestServer.ConnectionContext.LoginSecure = $false
               $SqlDestServer.ConnectionContext.Login = $CmdbAdminCred.UserName
               $SqlDestServer.ConnectionContext.SecurePassword = $CmdbAdminCred.Password

                $query = "INSERT INTO [CMDBSQL].[dbo].[CMDB_DataLoad_Failures]
                       ([PS_Function]
                       ,[SQLServerInstance]
                       ,[FailureDt] 
                       ,[ErrorMsg]
                        )
                 VALUES
                     ( 'CMDBSQL_CollectInfo'
                       ,'$SqlServerInstance'
                       ,getdate()
                       ,'$errexc'
                       )"

                $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($query)
               
  #               Log-SqlMonitoringError -Exception $_.exception -Message $_.exception.message -EntityName $SqlServerInstance -EntityType "PS Script Fucnction" -ErrorSource "CMDBSQL_CollectInfo"

            }
        }
    }
} 


Function Fill-Cmdb {
    param (
        [Parameter(Mandatory = $true)]
        [string]$INSTANCE_NAME,

        [Parameter(Mandatory = $true)]
        [string]$SQL_NETWORK_NAME,
        
        [Parameter(Mandatory = $true)]
        [string]$LifeCycle,

        [Parameter(Mandatory = $false)]
        [string]$InsComments = "",

        [Parameter(Mandatory = $false)]
        [string]$InsAlias = "",

        [Parameter(Mandatory = $true)]
        [string]$Location,

        [Parameter(Mandatory = $false)]
        [string]$Host_Comments = "",

        [Parameter(Mandatory = $false)]
        [string]$Host_Alias = "",

        [Parameter(Mandatory = $true)]
        [string]$Application = "BUILD_STATE",

        [Parameter(Mandatory = $false)]
        [string]$CmdbInstance = "WSPRDS051\PRDB20028",

        [Parameter(Mandatory = $false)]
        [string]$CmdbDatabase = "CMDBSQL"
    )

     Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"


    $StoredProcCommand = "
        exec dbo.insert_cmdbsql
            @instance_name = '$INSTANCE_NAME',
            @sql_network_name = '$SQL_NETWORK_NAME',
            @LIFE_CYCLE = '$LifeCycle',
            @Ins_Comments = '$InsComments',
            @Ins_Alias = '$InsAlias',
            @Application = '$Application',
            @Location = '$Location',
            @HOST_COMMENTS = '$HOST_COMMENTS',
            @Host_Alias = '$Host_Alias'
            
              "

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($CmdbInstance)
    $SqlServer.ConnectionContext.LoginSecure = $false
               $SqlServer.ConnectionContext.Login = $CmdbAdminCred.UserName
               $SqlServer.ConnectionContext.SecurePassword = $CmdbAdminCred.Password

    #write-host $StoredProcCommand
    $SqlServer.Databases[$CmdbDatabase].ExecuteNonQuery($StoredProcCommand)


}


function Accept-Input {

    $Application = Read-Host "Enter Application Name"
    #$SQLServerInstance = Read-Host "Enter Instance name Server\Ins format"
    $SQLServerInstance = $SRV

    $validlc = "(PR|QP|QA|AD)"
    $LifeCycle = Read-Host "Enter LifeCycle - Valid Values - PR,QP,QA,AD"

    if (!($LifeCycle -match $validlc)) {
        
        do {
            Write-Host "Invalid Application LifeCycle"
            $LifeCycle = Read-Host "Enter LifeCycle - Valid Values - PR,QP,QA,AD"
            }
            while (!($LifeCycle -match $validlc))
       }


    $Ins_Comments = Read-Host "Enter Instance Comments"
    $Ins_Alias = Read-Host "Enter Instance Alias"

    $validloc = "(ATC|SSC)"
    $Location = Read-Host "Enter Host Location - SSC or ATC"

    if (!($Location -match $validloc)) {
        
        do {
            Write-Host "Invalid Location"
            $Location = Read-Host "Enter Host Location - SSC or ATC"
            }
            while (!($Location -match $validloc))
       }


    $Host_Comments = Read-Host "Enter Host Comments"
    $Host_Alias = Read-Host "Enter Host Alias, if any"

 
    $InstanceInfo = Add-CMDB -SqlServerInstanceList $SQLServerInstance
    


    if ($InstanceInfo.SqlInstanceName -eq "") {
    $InstanceInfo.SqlInstanceName = "MSSQLSERVER"
        } 



    Fill-Cmdb -INSTANCE_NAME $InstanceInfo.SqlInstanceName -SQL_NETWORK_NAME $InstanceInfo.SqlNetworkName -LifeCycle $LifeCycle -InsComments $Ins_Comments -InsAlias $Ins_Alias -Application $Application -Location $Location -Host_Comments $Host_Comments -Host_Alias $Host_Alias 
}

##########################################

Function OnBoard_App {
    param (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]] $SqlServerInstanceList = $env:COMPUTERNAME
    )

    begin {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
            }

    process {
 
 
        $AODBQry = "
                    select
                            agl.dns_name as ListenerName,
                            ag.name as AGName,
		                    ar.replica_server_name as ReplicaName,
		                    adc.database_name as DatabaseName
                    from	sys.availability_groups ag 
		                    inner join sys.availability_group_listeners agl on agl.group_id = ag.group_id
		                    inner join sys.availability_replicas ar on ar.group_id = ag.group_id
		                    inner join sys.availability_databases_cluster adc on adc.group_id = ag.group_id

                    "


        foreach ($SqlServerInstance in $SqlServerInstanceList) 
            {
            try {
                 $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerInstance)


            # HADR ....
               $SqlDestServer = new-object microsoft.sqlserver.management.smo.server("WSPRDS051\PRDB20028")
               
             ## -- Cleanup existing data from Temp Tables
             
             $DelAODBQry = "delete from dbo.Tmp_AODBs"
  
            $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($DelAODBQry)

            
            
 
            Foreach($Row in $SqlServer.Databases["master"].ExecuteWithResults($AODBQry).Tables[0] ) 
                {

                $vLSNM = $row.ListenerName
                $vAGNm = $Row.AGName
                $vrepNm = $Row.ReplicaName
                $vDBNm = $Row.Databasename

                    $AOInsquery = "INSERT INTO [CMDBSQL].[dbo].[Tmp_AODBs](
                                                [LSNm]
                                               ,[AGNm]
                                               ,[RepNm]
                                               ,[DBNm])
                                VALUES (
                                     '$vLSNM'
                                    ,'$vAGNm'
                                    ,'$vrepNm'
                                    ,'$vDBNm'
                                     )"

                    

                    $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($AOInsquery)


                }

  
  <#
   
            $output = New-Object System.Object
            $output | 
                Add-Member -MemberType NoteProperty -Name "SqlInstanceName" -Value $SqlInstanceName
            $output | 
                Add-Member -MemberType NoteProperty -Name "SqlNetworkName" -Value $SqlNetworkName

            Write-Output $output
#>

            }
                catch {
                  # Write-Error $_.Exception
                  # write-host $SqlServerInstance
                  
                  $errexc = $_.Exception -replace "'","''"
 
                  $SqlDestServer = new-object microsoft.sqlserver.management.smo.server("WSPRDS051\PRDB20028")

                $query = "INSERT INTO [CMDBSQL].[dbo].[CMDB_DataLoad_Failures]
                       ([PS_Function]
                       ,[SQLServerInstance]
                       ,[FailureDt] 
                       ,[ErrorMsg]
                        )
                 VALUES
                     ( 'Add_Listener'
                       ,'$SqlServerInstance'
                       ,getdate()
                       ,'$errexc'
                       )"

                $SqlDestServer.Databases["CMDBSQL"].ExecuteNonQuery($query)
               
                 Log-SqlMonitoringError -Exception $_.exception -Message $_.exception.message -EntityName $SqlServerInstance -EntityType "PS Script Fucnction" -ErrorSource "Add_Listener"

            }
        }
    }
} 


Function Add-Listener {
    param (
 
        [Parameter(Mandatory = $true)]
        [string]$Listener,
        
        [Parameter(Mandatory = $true)]
        [string]$Application ,

        [Parameter(Mandatory = $false)]
        [string]$CmdbInstance = "WSPRDS051\PRDB20028",

        [Parameter(Mandatory = $false)]
        [string]$CmdbDatabase = "CMDBSQL"
    )

     Add-Type -Path "C:\Program Files\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"

    $StoredProcCommand = "
        exec dbo.Add_Listener
            @Listener = '$SqlServerInstance',
            @Application = '$Application'  
             "

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($CmdbInstance)

    #write-host $StoredProcCommand
    $SqlServer.Databases[$CmdbDatabase].ExecuteNonQuery($StoredProcCommand)


}



function Prompt-User-AO {

    $SQLServerInstance = Read-Host "Enter Listener name "
    $Application = Read-Host "Enter Application Name"


    $AOInfo = OnBoard_App -SqlServerInstanceList $SQLServerInstance
    




    Add-Listener -Listener $SQLServerInstance -Application $Application 
}



    # Prompt-User-AO

##########################################

#######################################################################


function SplashScreen_IX # Configure SQL Instance
{
    clear-host
    write-host "##################################################################################"
    write-host "#                                                                                #"
    write-host "#   Configure SQL Instance                                                       #"
    write-host "#                                                                                #"
    write-host "##################################################################################`n" 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "              Connection:" $srv 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "##################################################################################`n"
 }

function SplashScreen_VIII # SCOM Alerting
{
    clear-host
    write-host "##################################################################################"
    write-host "#                                                                                #"
    write-host "#   TEST SCOM Alerting                                                           #"
    write-host "#                                                                                #"
    write-host "##################################################################################`n" 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "              Connection:" $srv 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "##################################################################################`n"
 }



function SplashScreen_VII #intro screen
{
    clear-host
    write-host "#################################################################"
    write-host "#                                                               #"
    write-host "#                           S. C. U.                            #"
    write-host "#                                                               #"
    write-host "#                   SQL configuration utility                   #"
    write-host "#                                                               #"
    write-host "#                                                               #"
    write-host "#################################################################" 
    write-host `n
}


function SplashScreen_VI # RUN ALL
{
    clear-host
    write-host "##################################################################################"
    write-host "#                                                                                #"
    write-host "#   RUN ALL                                                                      #"
    write-host "#                                                                                #"
    write-host "##################################################################################`n" 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "              Connection:" $srv 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "##################################################################################`n"
 }


function SplashScreen_V # Upload to Local CMDB
{
    clear-host
    write-host "################################################################################"
    write-host "#                                                                              #"
    write-host "#           Upload to Local CMDB Database                                      #"
    write-host "#                                                                              #"
    write-host "################################################################################`n" 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "              Connection:" $srv 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "################################################################################`n"
 }



function SplashScreen_IV # configure SQL service accounts
{
    clear-host
    write-host "##################################################################################"
    write-host "#                                                                                #"
    write-host "#   Configure SQL Service accounts                                               #"
    write-host "#                                                                                #"
    write-host "##################################################################################`n" 
    write-host "                                                                                  "
    write-host "                                                                                  "
    write-host "              Connection:" $srv 
    write-host "                                                                                  "
    write-host "                                                                                  "
    write-host "##################################################################################`n"
 }


function SplashScreen_III # configure TDP
{
    clear-host
    write-host "##################################################################################"
    write-host "#                                                                                #"
    write-host "#   Configure TDP Jobs                                                           #"
    write-host "#                                                                                #"
    write-host "##################################################################################`n" 
    write-host "                                                                                 "
    write-host "                                                                                 "
    write-host "              Connection:" $srv 
    write-host "                                                                                 "
    write-host "                                                                                 "
    write-host "##################################################################################`n"
}


function SplashScreen_II #configure instance
{
    write-host "SQL Instance configurationon options for $connection`n"
    write-host "1. Small : CPU 2 RAM 16 TLog (1 x 25GB)  TempDB (2 x 25GB) Data (2 x 50GB)   "
    write-host "2. Medium: CPU 4 RAM 32 TLog (1 X 100GB) TempDB (4 x 25GB) Data (2 x 100GB)  "
    write-host "3. Large : CPU 8 RAM 64 TLog (1 x 100GB) TempDB (8 X 25GB) Data (4 x 100GB)  "
    write-host `n
    write-host "Please select from the options listed above:"
}

 function Menuscreen_II
{
    $title   = #"`n`n`n  "Configure SQL Instance"
    $message = ""#Please select from one of the options"
    $one     = New-Object System.Management.Automation.Host.ChoiceDescription "&1", "1. small"
    $two     = New-Object System.Management.Automation.Host.ChoiceDescription "&2", "2. medium"
    $three   = New-Object System.Management.Automation.Host.ChoiceDescription "&3", "3. large"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $three)
    
    :OuterLoop do
    {        
        $result = $host.UI.PromptForChoice($title, $message, $options, 0)
                
        switch ($result)
        {
            0 {$config ="SMALL"
               main2}
            1 {$config ="MEDIUM"
               main2}
            2 {$config ="LARGE"
               main2}
            default {break OuterLoop}
        }
    }
    while (99 -ne 100)

}


function SplashScreen_I #main screen
{
    clear-host
    write-host "####################################################################"
    write-host "#                                                                  #"
    write-host "#                                                                  #"
    write-host "#   Select from the following otpions:                             #"
    write-host "#                                                                  #"
    write-host "#   1. Configure SQL service accounts                              #"
    write-host "#   2. Configure SQL Instance                                      #"
    write-host "#   3. Configure TDP Jobs                                          #"
    write-host "#   4. Test SCOM Alerting                                          #"
    write-host "#   5. Upload to Local CMDB                                        #"
    write-host "#   6. Add new Listener App                                        #"
    write-host "#                                                                  #"                                                                                  
    write-host "#   9. RUN ALL                                                     #"
    write-host "#   0. EXIT program                                                #"
    write-host "#                                                                  #"
    write-host "####################################################################"   
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "              Connection:" $srv 
    write-host "                                                                    "
    write-host "                                                                    "
    write-host "####################################################################`n"      
}

function Menuscreen_I
{
    $title   = #"`n`n`n  "Welcome to the SQL SERVER post install configuration program"
    $message = ""#Please select from one of the options"
    $one     = New-Object System.Management.Automation.Host.ChoiceDescription "&1", "1. Configure service accounts"
    $two     = New-Object System.Management.Automation.Host.ChoiceDescription "&2", "2. Configure SQL Instance"
    $three   = New-Object System.Management.Automation.Host.ChoiceDescription "&3", "3. Configure TDP Jobs"
    $four    = New-Object System.Management.Automation.Host.ChoiceDescription "&4", "4. Test SCOM Alerting"
    $five    = New-Object System.Management.Automation.Host.ChoiceDescription "&5", "5. Upload to Local CMDB"
    $Six     = New-Object System.Management.Automation.Host.ChoiceDescription "&6", "6. Add Listener App"
    $nine    = New-Object System.Management.Automation.Host.ChoiceDescription "&9", "9. RUN ALL"
    $zero    = New-Object System.Management.Automation.Host.ChoiceDescription "&0", "0. Exit program"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($one, $two, $three, $four, $five, $Six, $nine, $zero)
    
    :OuterLoop do
    {        
        $result = $host.UI.PromptForChoice($title, $message, $options, 7)
                
        switch ($result)
        {
            0 {SplashScreen_IV
               ADD_USER
               CHANGE_SERVICE_ACCT
               CONFIGURE_MOUNT_POINT_PERMISSIONS
               CONFIRMATION
               main2}
            1 {SplashScreen_IX
               instance_config
               CONFIRMATION
               main2}
            2 {SplashScreen_III
               TDP_Jobs
               CONFIRMATION
               main2}
            3 {SplashScreen_VIII
               Prompt-User
               CONFIRMATION
               main2}
            4 {SplashScreen_V
               Accept-Input
               write-host "Instance information Uploaded to Local CMDB Database"
               $hit_enter = read-host "Hit <ENTER> to continue"
               main2}
            5 {SplashScreen_X
               Prompt-User-AO
               write-host "New Listener Application added to Local CMDB Database"
               $hit_enter = read-host "Hit <ENTER> to continue"
               main2}
            6 {SplashScreen_IV
               ADD_USER
               CHANGE_SERVICE_ACCT
               CONFIRMATION
               SplashScreen_IX
               instance_config
               CONFIRMATION
               SplashScreen_III
               TDP_Jobs
               CONFIRMATION
               SplashScreen_VIII
               Prompt-User
               CONFIRMATION
               SplashScreen_V
               Accept-Input
               write-host "Instance information Uploaded to Local CMDB Database"
               $hit_enter = read-host "Hit <ENTER> to continue"
               exit}
            7 {exit}
            default {break OuterLoop}
        }
    }
    while (99 -ne 100)

}


function main
{
SplashScreen_VII  #intro screen
Get_Variables
SplashScreen_I    #main menu
Menuscreen_I
}

function main2
{
SplashScreen_I    #main menu
Menuscreen_I
}





$CmdbAdminCred = Get-CmdbAdminCredentials

main
exit