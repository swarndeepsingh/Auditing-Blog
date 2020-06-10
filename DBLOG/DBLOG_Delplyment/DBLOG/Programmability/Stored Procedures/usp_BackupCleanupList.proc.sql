CREATE proc [DBLog].[usp_BackupCleanupList] @status varchar(30)    
as    
SET NOCOUNT ON    
if @status = 'Failed'    
begin    
 select a.delete_id, a.backup_job_id, a.Location_Type, a.File_Location , a.date_scheduled 'ToBeDeleted'     
 , a.end_time 'DeleteAttempted', a.Status, a.Message 
 , case e.BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end as 'BackupType'
 from DBLog.Backup_Delete_Files a with (NOLOCK)    
 join dblog.backup_jobs b with (NOLOCK)    
  on a.backup_job_id = b.backup_job_id  
 join dblog.Backup_info e with (NOLOCK)
	on a.Backup_ID = e.backup_id  
 where a.Message is not NULL  and a.Status <> 'Pending'  
 order by Backup_Job_ID desc, a.Delete_ID desc, a.Location_Type desc    
end    
    
if @status = 'All'    
begin    
 select top 1000 a.delete_id, a.backup_job_id, a.Location_Type, a.File_Location , a.date_scheduled 'ToBeDeleted'     
 , a.end_time 'DeleteAttempted', a.Status, a.Message   
  , case e.BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end as 'BackupType' 
 from DBLog.Backup_Delete_Files a with (NOLOCK)    
 join dblog.backup_jobs b with (NOLOCK)    
  on a.backup_job_id = b.backup_job_id    
 join dblog.Backup_info e with (NOLOCK)
	on b.Backup_ID = e.backup_id 
 order by Backup_Job_ID desc, a.Delete_ID desc, a.Location_Type desc    
end    
    
    
    
if @status = 'Completed'    
begin    
 select top 1000 a.delete_id, a.backup_job_id, a.Location_Type, a.File_Location , a.date_scheduled 'ToBeDeleted'     
, a.end_time 'DeleteAttempted', a.Status, a.Message ,
 case e.BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end as 'BackupType' 
 from DBLog.Backup_Delete_Files a with (NOLOCK)    
 join dblog.backup_jobs b with (NOLOCK)    
  on a.backup_job_id = b.backup_job_id   
 join dblog.Backup_info e with (NOLOCK)
	on b.Backup_ID = e.backup_id  
 where a.Status = 'Completed'    
 order by Backup_Job_ID desc, a.Delete_ID desc, a.Location_Type desc    
end    
    
    
    
if @status = 'Pending'    
begin    
 select c.delete_id, c.backup_job_id, c.Location_Type, c.File_Location    
 , c.ToBeDeleted, c.DeleteAttempted, c.Status, c.Message, c.BackupType from (    
 select isnull(a.delete_id,0) 'delete_id', b.backup_job_id, 'Local' as 'Location_Type', b.[FileName] as 'File_Location',    
 b.retainUntil_Local as 'ToBeDeleted',    
 NULL as 'DeleteAttempted', 'Pending' as 'Status', NULL as 'Message'   
 ,  case e.BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end as 'BackupType'  
 from DBLog.Backup_Delete_Files a with (NOLOCK)    
 right outer join dblog.backup_jobs b with (NOLOCK)    
  on a.backup_job_id = b.backup_job_id    
 join dblog.Backup_info e with (NOLOCK)
	on b.Backup_ID = e.backup_id  
 where a.Backup_Job_ID is null    
     
 Union    
     
 select isnull(a.delete_id,0), b.backup_job_id, 'Remote' as 'Location_Type',b.[FileName_Mirror] as 'File_Location',    
 b.retainUntil_remote as 'ToBeDeleted',    
 NULL as 'DeleteAttempted', 'Pending' as 'Status', NULL as 'Message'   
 ,  case e.BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end as 'BackupType'   
 from DBLog.Backup_Delete_Files a with (NOLOCK)    
 right outer join dblog.backup_jobs b with (NOLOCK)    
  on a.backup_job_id = b.backup_job_id  
  join dblog.Backup_info e with (NOLOCK)
	on b.Backup_ID = e.backup_id    
 where a.Backup_Job_ID is null) as c where ToBeDeleted is not null  order by backup_job_id asc, Location_Type desc    
    
end