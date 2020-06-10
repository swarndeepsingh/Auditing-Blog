/*exec dblog.usp_update_UserPassword 'swarns','102Ebix29'
*/


CREATE proc [DBLog].[usp_Validate_User] @userName varchar(25), @Password varchar(50), @validated int OUTPUT, @rolename varchar(50) OUTPUT,  @errorMessage varchar(200) OUTPUT  
as  
 set nocount on  
 declare @pass1 varchar(500)  
 declare @DecryptedPassword varchar(50), @encryptedPassword varchar(5000)  , @activated int
 select @pass1= PropertyValue from DBLog.MiscProperties where PropertyName = 'Location_Password_1'  
   
 select @encryptedPassword = a.password, @rolename = b.rolename, @activated = cast(Active as int) from dblog.users a   
 join dblog.users_roles b  
  on a.username = b.username  
 where a.username =@userName;  

 
 if @activated = 0
 begin  
  set @validated=0  
  set @errorMessage= 'User Account is not active, please contact sys admin'  
 end 
 
 if @activated is null
 begin
	set @validated=0  
	set @errorMessage= 'Incorrect User Name or Password Entered'  
 end 
 
 set @DecryptedPassword = decryptbypassphrase(@pass1,@encryptedpassword)  
 
 

 
 if (@DecryptedPassword = @Password)  and (@activated = 1)
 begin  

  set @validated = 1  
  set @errorMessage = 'User has been validated'  
 end  
 else if @DecryptedPassword <> @Password  
 begin  
  set @validated=0  
  set @errorMessage= 'Incorrect User Name or Password Entered'  
 end  