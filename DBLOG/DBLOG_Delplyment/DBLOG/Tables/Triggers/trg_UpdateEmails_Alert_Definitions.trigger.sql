CREATE TRIGGER [DBLog].[trg_UpdateEmails_Alert_Definitions]
   ON  dblog.Alert_Definitions
   AFTER UPDATE
AS 
BEGIN
		SET NOCOUNT ON;
	if update(EmailProfileID)
	BEGIN
		

	declare @ID int, @recipients varchar(max), @From_Email varchar(500), @profile varchar(100)
	select @ID = EmailProfileID from inserted
	
	select  @recipients = recipients, @From_Email = From_Email, @profile = Profile
	from DBLog.EmailProfiles
	where ID = @ID
	
	
	update DBLog.Alert_Definitions
	set EmailProfile = @profile
	, AlertFrom = @From_Email
	, AlertRecipients = @recipients
	where  EmailProfileID = @ID
	
	/*update DBLog.Alert_Events
	set Alert_From = @From_Email
	, AlertRecipients = @recipients
	where  EmailProfileID = @ID
	*/
	END
END