CREATE TRIGGER [DBLog].[trg_MiscProperties_ReadOnly_Password]
   ON  [DBLog].[MiscProperties]
   AFTER UPDATE
AS 
BEGIN
print 'DO Nothing'
/*
	declare @value varchar(500)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if update(PropertyValue)
		begin
			select @value = propertyname from inserted;
			if @value in ('Location_Password_2', 'Location_Password_1')
			begin
				GOTO EndOfTrigger
			end
			rollback tran
			raiserror('Value cannot be edited',16,1)
		END
		
		return
		EndOfTrigger:
		
*/	
END