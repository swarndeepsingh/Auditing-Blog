Add-Type -Path "C:\Program Files\Microsoft SQL Server\130\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
Add-PSSnapin SqlServerCmdletSnapin130
Add-PSSnapin SqlServerProviderSnapin130

$srv = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $mi;

$dbs = $srv.databases

foreach($db in $dbs)
{
    $db.Name
}
