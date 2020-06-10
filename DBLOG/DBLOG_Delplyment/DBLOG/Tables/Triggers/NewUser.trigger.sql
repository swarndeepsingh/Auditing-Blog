
CREATE TRIGGER [DBLog].[NewUser]
   ON  [DBLog].[Users]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	declare @email varchar(500), @mailprofile varchar(500), @Subject varchar(500), @body varchar(1024),@adminUser varchar(500);
	declare @from varchar(200)
	select top 1 @mailprofile = profile, @from = from_email from EmailProfiles order by ID;
	
	select @Subject = 'Attention! ' + UserName + ' has requested access to DBLog.' from inserted
	
	declare new_user CURSOR
	FOR
    select distinct a.UsersEmailAddress, a.UserName from dblog.users a with (NOLOCK)
    left join dblog.Users_Roles b with (NOLOCK)
		on a.UserName = b.UserName
	where b.RoleName = 'Administrator'	
	OPEN new_user
	
	Fetch Next from new_user into @email, @adminUser	
	WHILE @@FETCH_STATUS = 0
	BEGIN 		
		select @body = 'Dear ' + @adminUser + ', <BR><U><P>' + UserName + '</U> has requested access. Please login to DBLog to approve or decline the request.<P><BR> Thanks <BR> DBLog Monitor' from inserted
		exec msdb.dbo.sp_send_dbmail   
		@profile_name=@mailprofile,  
		@recipients=@email,  
		@subject=@subject,  
		@body_format = 'HTML',  
		@body=@body,  
		@from_address = @from		
		Fetch Next from new_user into @email, @adminUser
	end
	close new_user
	deallocate new_user
	
END