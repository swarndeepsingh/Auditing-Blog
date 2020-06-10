

CREATE TRIGGER [DBLog].[trg_MiscProperties_NotDelete_Password]
   ON  dblog.MiscProperties
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	rollback tran
	raiserror('Cannot be deleted',16,1)
	
	
END