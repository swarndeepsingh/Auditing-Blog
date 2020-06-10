create procedure [DBLog].[usp_Request_User] @UserName varchar(50), @Password varchar(50), @rolename varchar(50), @emailAddress varchar(600)
as
	set nocount on
	declare @pass1 varchar(500), @error int
	declare @encryptedPassword varchar(5000)
	select @pass1= PropertyValue from DBLog.MiscProperties where PropertyName = 'Location_Password_1'
	
	set @encryptedPassword = ENCRYPTBYPASSPHRASE(@pass1,@Password)
	
	begin tran
	insert into [dblog].users
	select @UserName, 0, @encryptedPassword, @emailAddress
		
	
	-- Error handler
	set @error = @@ERROR
	if @error <> 0 GOTO errorhandler
	
	
	insert into [dblog].[users_roles]
	select @UserName, @rolename
		-- Error handler
	set @error = @@ERROR
	if @error <> 0 GOTO errorhandler
	
	
	-- if no error then commit
	commit tran

	-- get out of the procedure
	return
	
	-- start error handling here
	errorHandler:
	rollback tran
	raiserror ('Error Occurred. Error ID - %d. User cannot be created',10,1,@error);