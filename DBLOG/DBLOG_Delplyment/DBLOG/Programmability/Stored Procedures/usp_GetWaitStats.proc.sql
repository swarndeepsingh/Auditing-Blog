CREATE PROCEDURE dblog.usp_GetWaitStats 
    @WaitTimeSec INT = 60,
    @StopTime DATETIME = NULL
AS
BEGIN
    DECLARE @CaptureDataID int
    /* Create temp tables to capture wait stats to compare */
    IF OBJECT_ID('tempdb..#WaitStatsBench') IS NOT NULL
        DROP TABLE #WaitStatsBench
    IF OBJECT_ID('tempdb..#WaitStatsFinal') IS NOT NULL
        DROP TABLE #WaitStatsFinal
 
    CREATE TABLE #WaitStatsBench (WaitType varchar(200), wait_S decimal(20,5), Resource_S decimal (20,5), Signal_S decimal (20,5), WaitCount bigint)
    CREATE TABLE #WaitStatsFinal (WaitType varchar(200), wait_S decimal(20,5), Resource_S decimal (20,5), Signal_S decimal (20,5), WaitCount bigint)
 
    DECLARE @ServerName varchar(300)
    SELECT @ServerName = convert(nvarchar(128), serverproperty('servername'))
     
    /* Insert master record for capture data */
    INSERT INTO DBLOG.CaptureData (StartTime, EndTime, ServerName,PullPeriod)
    VALUES (GETDATE(), NULL, @ServerName, @WaitTimeSec)
     
    SELECT @CaptureDataID = SCOPE_IDENTITY()
      
/* Loop through until time expires  */
    IF @StopTime IS NULL
        SET @StopTime = DATEADD(hh, 1, getdate())
    WHILE GETDATE() < @StopTime
    BEGIN
 
        /* Get baseline */
         
        INSERT INTO #WaitStatsBench (WaitType, wait_S, Resource_S, Signal_S, WaitCount)
        SELECT
                wait_type,
                wait_time_ms / 1000.0 AS WaitS,
                (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
                signal_wait_time_ms / 1000.0 AS SignalS,
                waiting_tasks_count AS WaitCount
            FROM sys.dm_os_wait_stats
            WHERE wait_time_ms > 0.01 
            AND wait_type NOT IN ( SELECT WaitType FROM DBLOG.BenignWaits)
         
 
        /* Wait a few minutes and get final snapshot */
        WAITFOR DELAY @WaitTimeSec;
 
        INSERT INTO #WaitStatsFinal (WaitType, wait_S, Resource_S, Signal_S, WaitCount)
        SELECT
                wait_type,
                wait_time_ms / 1000.0 AS WaitS,
                (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
                signal_wait_time_ms / 1000.0 AS SignalS,
                waiting_tasks_count AS WaitCount
            FROM sys.dm_os_wait_stats
            WHERE wait_time_ms > 0.01
            AND wait_type NOT IN ( SELECT WaitType FROM DBLOG.BenignWaits)
         
        DECLARE @CaptureTime datetime 
        SET @CaptureTime = getdate()
 
        INSERT INTO DBLOG.WaitStats (CaptureDataID, WaitType, Wait_S, Resource_S, Signal_S, WaitCount, Avg_Wait_S, Avg_Resource_S,Avg_Signal_S, CaptureDate)
        SELECT  @CaptureDataID,
            f.WaitType,
            f.wait_S - b.wait_S as Wait_S,
            f.Resource_S - b.Resource_S as Resource_S,
            f.Signal_S - b.Signal_S as Signal_S,
            f.WaitCount - b.WaitCount as WaitCounts,
            CAST(CASE WHEN f.WaitCount - b.WaitCount = 0 THEN 0 ELSE (f.wait_S - b.wait_S) / (f.WaitCount - b.WaitCount) END AS numeric(10, 6))AS Avg_Wait_S,
            CAST(CASE WHEN f.WaitCount - b.WaitCount = 0 THEN 0 ELSE (f.Resource_S - b.Resource_S) / (f.WaitCount - b.WaitCount) END AS numeric(10, 6))AS Avg_Resource_S,
            CAST(CASE WHEN f.WaitCount - b.WaitCount = 0 THEN 0 ELSE (f.Signal_S - b.Signal_S) / (f.WaitCount - b.WaitCount) END AS numeric(10, 6))AS Avg_Signal_S,
            @CaptureTime
        FROM #WaitStatsFinal f
        LEFT JOIN #WaitStatsBench b ON (f.WaitType = b.WaitType)
        WHERE (f.wait_S - b.wait_S) > 0.0 -- Added to not record zero waits in a time interval.
         
        TRUNCATE TABLE #WaitStatsBench
        TRUNCATE TABLE #WaitStatsFinal
 END -- END of WHILE
  
 /* Update Capture Data meta-data to include end time */
 UPDATE DBLOG.CaptureData
 SET EndTime = GETDATE()
 WHERE ID = @CaptureDataID
END
