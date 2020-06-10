
CREATE TRIGGER [DBLog].[trg_CheckFrequency_backup_info]
   ON  [dblog].[backup_info]
   AFTER INSERT
AS 
BEGIN
print 'DO Nothing'
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	--declare @backuptype varchar(10), @bkupID int
	--select @backuptype = backuptype, @bkupID=Backup_ID from inserted
	
	--update dblog.Backup_info
	--	set frequencyName =
	--    case @backuptype when 'D' then 'Weekly_1'  when 'I' then 'Daily_1' when 'L' then '1_Minutes' end
	--    where Backup_ID = @bkupID

END