cd c:\dblog\bits_transfer
$number=0
$i=1

do
{
	cls
	write-host "loop number $i"
	

	.\PS_BITS_TRANSFER.ps1 an3prodsql01
	$i++
	start-sleep -s 10
	
}
while ($i -gt $number)
