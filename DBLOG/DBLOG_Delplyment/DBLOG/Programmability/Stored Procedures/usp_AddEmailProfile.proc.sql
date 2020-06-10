CREATE proc [DBLog].[usp_AddEmailProfile] @recipients varchar(max), @profile varchar(100), @alertpermission char(1), @active char(1)
as
/*
AlertPermission A = All, S= Subscrption Based
Active = 1 True, 0 False
*/
set nocount on
insert into DBLog.EmailProfiles (Recipients, [Profile], AlertPermission, [Active])
select @recipients, @profile, @alertpermission, @active
GO
