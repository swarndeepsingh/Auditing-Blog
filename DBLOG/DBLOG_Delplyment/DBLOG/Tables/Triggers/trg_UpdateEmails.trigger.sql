-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [DBLog].[trg_UpdateEmails] 
   ON  dblog.EmailProfiles
   AFTER INSERT,UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	declare @ID int, @recipients varchar(max), @From_Email varchar(500), @profile varchar(100)
	
	select @ID = ID, @recipients = recipients, @From_Email = From_Email, @profile = Profile
	from inserted
	
	update DBLog.Alert_Definitions
	set EmailProfile = @profile
	, AlertFrom = @From_Email
	, AlertRecipients = @recipients
	where  EmailProfileID = @ID
	
	update DBLog.Alert_Events
	set Alert_From = @From_Email
	, AlertRecipients = @recipients
	where  EmailProfileID = @ID
	
	
END