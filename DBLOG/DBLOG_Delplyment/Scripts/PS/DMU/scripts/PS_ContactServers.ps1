import-module sqlps



Function get-loginCompliance ([string] $srvname)
{

    $machine = "$srvname"
    $database = "master"
    $script1 = "SELECT SERVERPROPERTY('machinename') AS 'Server Name', ISNULL(SERVERPROPERTY ('instancename'), 
    SERVERPROPERTY ('machinename')) AS 'Instance Name', name AS 'Login', is_srvrolemember('sysadmin', name) AS 'SysAdmin' FROM master.sys.sql_logins wHERE PWDCOMPARE(name,password_hash)=1  ORDER BY name"

    $script2 ="declare @list table (servername sql_variant, dbname sql_variant, instancename sql_variant, loginname sql_variant)
insert into @list
exec sp_msforeachdb ' use [?] 
declare @table table (name  varchar(256))
insert into @table
select distinct mp.name from sys.database_role_members drm
            join sys.database_principals rp on (drm.role_principal_id = rp.principal_id)
            join sys.database_principals mp on (drm.member_principal_id = mp.principal_id)
SELECT SERVERPROPERTY(''machinename'') AS ''ServerName'', ''?'' as ''DBName'', ISNULL(SERVERPROPERTY (''instancename'')
, SERVERPROPERTY (''machinename'')) AS ''Instance Name'', l.name AS ''Login'' 
FROM  master.sys.sql_logins l 
join @table t on l.name COLLATE DATABASE_DEFAULT = t.name COLLATE DATABASE_DEFAULT
wHERE PWDCOMPARE(l.name,password_hash)=1   
ORDER BY l.name'

select * from @list"

try
{
    $server = new-object Microsoft.SqlServer.Management.Smo.Server("$machine")
    $db = $server.Databases.Item($database) 
    $result1=$db.ExecuteWithResults("$script1")
    $result2=$db.ExecuteWithResults("$script2") 

    $result1.Tables[0] #| Export-Csv "c:\swarn\others\output.csv"
    $result2.Tables[0]
    }

catch
{
    write-host "Error"
}
}



$ServerList = "WAPRDS024.AMER.HOMEDEPOT.COM\PRFI19",
"WSPRDS027.AMER.HOMEDEPOT.COM\PRTA07",
"WAPRDS121.AMER.HOMEDEPOT.COM\PRDB20021",
"WAPRDS096.AMER.HOMEDEPOT.COM\PRDI86",
"WAPRCN025B.AMER.HOMEDEPOT.COM",
"WP09D8.AMER.HOMEDEPOT.COM",
"WAPRDS123.AMER.HOMEDEPOT.COM\PRTA45",
"WSPRAP129.AMER.HOMEDEPOT.COM",
"WP0439.AMER.HOMEDEPOT.COM",
"WAPRDS051.AMER.HOMEDEPOT.COM\PRDI35",
"WAPRDS017.AMER.HOMEDEPOT.COM\PRFI10U",
"WSPRDS079.AMER.HOMEDEPOT.COM",
"Tartarus.USHOMESYSTEMS.CORP",
"WP09C0.AMER.HOMEDEPOT.COM"


foreach ($server in $serverlist)
{
    
        get-loginCompliance ($server) 
}