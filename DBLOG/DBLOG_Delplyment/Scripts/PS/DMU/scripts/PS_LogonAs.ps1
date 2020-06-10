#Open IE as different user
$credential = Get-Credential
Start-Process -FilePath "C:\program files\Internet Explorer\iexplore.exe" -Credential $credential


#Open SSMS as different user
$credential = Get-Credential
Start-Process -FilePath "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\ManagementStudio\ssms.exe" -Credential $credential