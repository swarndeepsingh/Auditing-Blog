CREATE TRIGGER DBLog.trg_backup_Exceptions_delete 
   ON  DBLog.backup_exceptions 
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @dbname varchar(1024), @type varchar(50)
	select @dbname = DBName, @type = backuptype from deleted

	update dblog.Backup_info
	set Enabled=1
	where DBName = @dbname
	and BackupType = @type
    -- Insert statements for trigger here

END