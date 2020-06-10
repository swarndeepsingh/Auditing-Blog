function Load-Modules
{
#Add SMO
Add-Type -Path "C:\Program Files\Microsoft SQL Server\130\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
# Add PS
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules"
Import-Module sqlps
}
