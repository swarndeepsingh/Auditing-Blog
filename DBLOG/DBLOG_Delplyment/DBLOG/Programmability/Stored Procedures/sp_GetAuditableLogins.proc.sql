CREATE proc [DBLog].[sp_GetAuditableLogins]  
as  
declare @groups table  
(  
	groupname varchar(100)  
)  
declare @groupname varchar(100)  
create table #group_logins   
(  
	accountname varchar(500),  
	[type] varchar(25),  
	privilege varchar(25),  
	mappedloginname varchar(500),  
	permissionpath varchar(500)  
)  

create table #role_logins   
(  
	accountname varchar(500),  
	[type] varchar(25),  
	privilege varchar(25),  
	mappedloginname varchar(500),  
	permissionpath varchar(500)  
) 

	
delete from [DBLOG].Auditable_Logins  
-- Get group based logins

insert into @groups  
select loginname from master.dbo.syslogins  
where isntgroup = 1 and loginname  not Like ('NT Service%')  
declare fetchlogins cursor   
for select groupname from @groups  
OPEN fetchlogins  
FETCH NEXT FROM fetchlogins  
into @groupname  
WHILE @@FETCH_STATUS = 0  
BEGIN  
 insert into #group_logins  
 EXEC master.dbo.xp_logininfo @groupname, 'members'  
FETCH NEXT FROM fetchlogins  
into @groupname  
END  
CLOSE fetchlogins  
DEALLOCATE fetchlogins  
delete from #group_logins where  accountname like '%sql-svc%'  
  
  
 -- Get role based logins 
insert into #role_logins
select c.name as [AccountName], 'role_member' as [user_type], NULL as [privilege],c.name as [MappedLogin] , NULL as [GroupName]  from master.sys.database_role_members a
right outer join master.sys.database_principals b
	on a.role_principal_id = b.principal_id
	and b.type = 'R'
	and b.name ='sqluser'
join master.sys.database_principals c
	on a.member_principal_id = c.principal_id
	
	  
-- update group based logins
insert into [DBLOG].Auditable_Logins  
select DISTINCT a.accountname, A.type, NULL, A.mappedloginname, NULL from #group_logins a   
LEFT outer join [DBLOG].auditable_logins b with (NOLOCK)  
 on a.accountname = b.accountname  
where b.accountname is null   
ORDER BY A.ACCOUNTNAME  



-- Update custom logins from custom table
insert into [DBLOG].Auditable_Logins  
select DISTINCT a.accountname, NULL, NULL, A.mappedlogin, NULL from DBLOG.Auditable_Logins_Custom a   
LEFT outer join [DBLOG].auditable_logins b with (NOLOCK)  
 on a.accountname = b.accountname  
where b.accountname is null   
ORDER BY A.ACCOUNTNAME



-- Update role based logins
insert into [DBLOG].Auditable_Logins  
select DISTINCT a.accountname, A.type, NULL, A.mappedloginname, NULL from #role_logins a   
LEFT outer join [DBLOG].auditable_logins b with (NOLOCK)  
 on a.accountname = b.accountname  
where b.accountname is null   
ORDER BY A.ACCOUNTNAME  


/*
-- Delete unnecessary logins
DELETE FROM [DBLOG].auditable_logins where accountname in (  
select a.accountname from auditable_logins a with (NOLOCK)  
left outer join #group_logins b  
 on a.accountname = b.accountname  
 where b.accountname is null  
 
)
*/
-- Delete dbo if exists
DELETE FROM [DBLOG].auditable_logins where accountname in ('dbo')