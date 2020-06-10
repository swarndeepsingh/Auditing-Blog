

-- Job timings
select 
 j.name as 'JobName',
 run_date,
 run_time,
 msdb.dbo.agent_datetime(run_date, run_time) as 'RunDateTime', h.*
From msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobhistory h 
 ON j.job_id = h.job_id 
where j.enabled = 1  --Only Enabled Jobs
order by RunDateTime desc

-- Job 
SELECT sj.name
   , sja.*
FROM msdb.dbo.sysjobactivity AS sja
INNER JOIN msdb.dbo.sysjobs AS sj ON sja.job_id = sj.job_id
WHERE sja.start_execution_date IS NOT NULL
   AND sja.stop_execution_date IS NULL



EXEC msdb.dbo.sp_help_job @Job_name = 'dblog.GetWaitStatsJob'



-- Currently running jobs
SELECT
ja.job_id,
j.name AS job_name,
ja.start_execution_date,      
ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
Js.step_name
FROM msdb.dbo.sysjobactivity ja 
LEFT JOIN msdb.dbo.sysjobhistory jh 
ON ja.job_history_id = jh.instance_id
JOIN msdb.dbo.sysjobs j 
ON ja.job_id = j.job_id
JOIN msdb.dbo.sysjobsteps js
ON ja.job_id = js.job_id
AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions   ORDER BY agent_start_date DESC)
AND start_execution_date is not null
AND stop_execution_date is null

