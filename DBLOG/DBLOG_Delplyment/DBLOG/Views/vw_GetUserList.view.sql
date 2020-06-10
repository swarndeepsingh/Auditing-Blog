create view [DBLog].[vw_GetUserList]
as
select a.UserName, a.UsersEmailAddress, b.RoleName, a.Active from dblog.Users a with (NOLOCK)
join dblog.Users_Roles b with (NOLOCK)
	on a.UserName = b.UserName