CREATE VIEW DBLog.Backup_all_info
AS
SELECT     a.Backup_Start_Time, a.Backup_End_Time, a.Backup_ID, a.Backup_Job_ID, a.FileName, a.FileName_Mirror, a.retainUntil_local, a.retainUntil_remote, a.status, 
                      b.BackupType, b.BackupName, b.DBName, b.ServerName, c.Destination, c.Message, c.Source, c.Status AS TransferStatus, c.startdate, c.enddate, c.Transfer_ID, a.BackupSizeKB 'FileSizeKB',
					  b.frequencyName
FROM         DBLog.Backup_Jobs AS a WITH (NOLOCK) INNER JOIN
                      DBLog.Backup_info AS b WITH (NOLOCK) ON a.Backup_ID = b.Backup_ID LEFT OUTER JOIN
                      DBLog.Backup_transfer_Job AS c WITH (NOLOCK) ON a.Backup_ID = c.Backup_ID AND a.Backup_Job_ID = c.Backup_Job_ID