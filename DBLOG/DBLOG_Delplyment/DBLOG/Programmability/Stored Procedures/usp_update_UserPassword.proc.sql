create proc [DBLog].[usp_update_UserPassword] @userName varchar(25), @password varchar(50)
as
	set nocount on
	declare @pass1 varchar(500), @error int
	declare @encryptedPassword varchar(5000)
	select @pass1= PropertyValue from DBLog.MiscProperties where PropertyName = 'Location_Password_1'
	
	set @encryptedPassword = ENCRYPTBYPASSPHRASE(@pass1,@password)
	
	begin tran
	update [dblog].users
	set [password] = @encryptedPassword
	where userName = @userName
	
	
	
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
	raiserror ('Error Occurred. Error ID - %d. Password not changed',10,1,@error);