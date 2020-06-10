import-module sqlps

$machine = "WAPRDS024\PRFI19"

$script = "SELECT SERVERPROPERTY('machinename') AS 'Server Name', ISNULL(SERVERPROPERTY ('instancename'), SERVERPROPERTY ('machinename')) AS 'Instance Name', name AS 'Login With Password Equal to Login Name' FROM master.sys.sql_logins wHERE PWDCOMPARE(name,password_hash)=1  ORDER BY name"


$srv = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $machihe;

#replace your with your user database name
$dbName = "master"
$db = $srv.Databases[$dbName]


Invoke-Sqlcmd '
-ServerInstance "$srv"
-DatabaseName "$db"
-Query "$script"
Export-CSV -Literalpath "C:\output.csv"
'
-NoTypeInformation


