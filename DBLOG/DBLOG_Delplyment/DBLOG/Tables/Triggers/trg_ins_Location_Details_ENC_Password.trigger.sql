CREATE TRIGGER [DBLog].[trg_ins_Location_Details_ENC_Password]
   ON  DBLog.Location_Details
   AFTER insert, update
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @pass1 varchar(500), @pass2 varchar(500), @locID int, @ismapped bit
	declare @mapname varchar(50), @username varchar(50), @pword varchar(8000)
	
	select @mapname=MapName, @username = userName, @pword = pword, @ismapped = ISMAPPED from inserted
	
	if @pword is not null
	begin
			select @pass1=	PropertyValue from DBLog.MiscProperties where PropertyName = 'Location_Password_1'
			select @locID = locationid from inserted
			
			UPDATE DBLog.Location_Details
			SET PWord =  Encryptbypassphrase(@pass1,PWORD)
			where locationID = @locID
	end
END