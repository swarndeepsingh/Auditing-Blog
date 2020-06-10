cd c:\dblog\bits_transfer
$number=0
$i=1

do
{
	
	write-host "loop number $i"
	
	
	.\PS_Update_Status_Transfer an3prodsql01
	.\PS_ValidateFiles.ps1 an3prodsql01

	$i++
	write-host "Sleeping"	
	start-sleep -s 30
	cls
	
	
	
}
while ($i -gt $number)
