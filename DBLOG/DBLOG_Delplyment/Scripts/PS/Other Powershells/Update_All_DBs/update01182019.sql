use DBLOG
exec msdb.dbo.sp_stop_job @job_name='dblog.getRequestsJob'
print 'Stopped Request Job'
exec msdb.dbo.sp_update_job @job_name='dblog.getRequestsJob', @enabled=0
print 'Disabled request job'
exec msdb.dbo.sp_stop_job @job_name ='dblog.GetWaitStatsJob'
print 'Stopped waitstats job'
exec msdb.dbo.sp_update_job @job_name='dblog.GetWaitStatsJob', @enabled=0
print 'Disabeld waitstats job'
truncate table DBLog.WaitStats
print 'truncated waitstats table'
truncate table dblog.requests
print 'truncated reqeusts table'
exec msdb.dbo.sp_update_job @job_name='dblog.getRequestsJob', @enabled=1
exec msdb.dbo.sp_start_job @job_name='dblog.getRequestsJob'
exec msdb.dbo.sp_update_job @job_name='dblog.GetWaitStatsJob', @enabled=1
exec msdb.dbo.sp_start_job @job_name ='dblog.GetWaitStatsJob'
print 'Enabled and started all jobs'