CREATE view [DBLog].[vw_SM_MaintenanceLog_24hr]  
as  
SELECT    
quotename('JOB_DATE','"')  [JOB_DATE]    
,quotename('JOB_TYPE','"') [JOB_TYPE]    
,quotename('START_TIME','"') [START_TIME]    
,quotename('END_TIME','"') [END_TIME]    
,quotename('TIME_TAKEN','"') [TIME_TAKEN]    
,quotename('IS_SUCCESS','"') [IS_SUCCESS]    
,'DBName' [DBName]    
, quotename('JOBSIZE','"') [JOBSIZE]  
    
union    
    
select     
quotename(UPPER(replace(CONVERT(varchar(40),getdate(),106),' ', '-'))+' 00:00:00','"') [JOB_DATE]    
, quotename(case b.backuptype when 'I' then '1' when 'D' then '0' when 'L' then '2' end,'"') as [JOB_TYPE]    
, quotename(UPPER(REPLACE(CONVERT(VARCHAR(40), a.Backup_Start_Time,106), ' ', '-')) + ' ' + CONVERT(varchar(20),a.Backup_Start_Time,108),'"') [START_TIME]    
, quotename(UPPER(REPLACE(CONVERT(VARCHAR(40), a.Backup_End_Time,106), ' ', '-')) + ' ' + CONVERT(varchar(20),a.Backup_End_Time,108),'"') [END_TIME]    
, quotename(DATEDIFF(MINUTE,a.Backup_Start_Time,a.Backup_End_Time),'"') [TIME_TAKEN]    
, quotename(case when a.[status] like '%failed%' then '2' when a.[status] like '%Started%' then '99' else '1' end,'"') [IS_SUCCESS]    
, b.DBName [DBName]  
, quotename((BackupSizeKB)/1024/1024/1024,'"') [JOBSIZE]   
 from dblog.backup_jobs a with (NOLOCK)    
join dblog.Backup_info b with (NOLOCK)    
 on a.backup_id = b.backup_id    
where a.[status] not in('Started')    
and a.Backup_End_Time > GETDATE()-1
  