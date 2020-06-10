## BEGINNING ##
#Input Params
param(
[Parameter(mandatory=$true)]
[string] $smtpserver,
[Parameter(mandatory=$true)]
[string] $from,
[Parameter(mandatory=$true)]
[string] $to
)

#Import libraries
import-module FailoverClusters

#Get Cluster and Hostname
$cluster = Get-Cluster
$hostname=hostname


#Print out cluster name for debugging
write-output $smtpserver

#split email addresses
[string[]]$To=$to.split("+",[System.StringSplitOptions]::RemoveEmptyEntries)

#Export Cluster logs info cluster file

Get-ClusterLog -Destination C:\clu\CluLogs -Cluster $cluster.ToString() -node $hostname.ToString() -TimeSpan 12


#Filter messages related to failover only
$message=Get-Content -Path C:\clu\clulogs\*.* | Select-String -Pattern "SQL Server(.)*OnlinePending`-`->Online" | Out-String


#If message is not empty then send email with messages in the box
if ($message)
{
Send-MailMessage -To $to -Subject "9966 Cluster ($cluster) Failover Alert on node: $hostname" `
			-From $from -Body $message `
			-SmtpServer $smtpserver
}


## END ##