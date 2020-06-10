CREATE TRIGGER [DBLog].[ActivateUser]
   ON  [DBLog].[Users]
   AFTER Update
AS 
BEGIN
	SET NOCOUNT ON;
	
	declare @email varchar(500), @mailprofile varchar(500), @Subject varchar(500), @body varchar(1024),@adminUser varchar(500);
	declare @from varchar(200), @status bit, @statusStr varchar(20)
	if update(active)
	begin
		select @status = Active from inserted;
		
		if @status = 0  set @statusStr = 'Declined'
		if @status = 1  set @statusStr = 'Approved'
		
		select top 1 @mailprofile = profile, @from = from_email from EmailProfiles order by ID;
		
		select @Subject = 'Attention! DBLog request has been ' + @statusStr + '.', @email = UsersEmailAddress  from inserted
		
		select @body = 'Dear ' + UserName + ',<P>Your request has been ' + @statusStr + '.</P><BR> Thanks <BR> DBLog Monitor' from inserted
		exec msdb.dbo.sp_send_dbmail   
		@profile_name=@mailprofile,  
		@recipients=@email,  
		@subject=@subject,  
		@body_format = 'HTML',  
		@body=@body,  
		@from_address = @from		
			
	END
	
END