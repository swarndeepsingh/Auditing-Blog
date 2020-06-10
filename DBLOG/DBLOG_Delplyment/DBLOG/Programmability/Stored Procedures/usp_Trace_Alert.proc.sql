CREATE proc [DBLog].[usp_Trace_Alert] @tracename varchar(255), @profilename_email varchar(255)
as
declare @threshold int, @rowid int, @msg varchar(2000), @emailrecipients varchar(8000), @subject varchar(255)

select @threshold = alert_threshold, @emailrecipients = EmailAlertRecipient
from trace_alerts with (NOLOCK)
where tracename = @tracename


if @tracename ='AuditFailedLogin'
begin
	declare  Check_Alert cursor
	for 
	select rowid from [DBLOG].trace_info with (NOLOCK)
	where SentAlertsNumber < @threshold and RowsImported > 0
	and tracename = @tracename
	
	open check_alert
	
	Fetch Next from check_alert
	INTO @rowid
	
	while @@FETCH_STATUS = 0
	BEGIN
	
		select @msg = 'SECURITY ALERT : Login attempt failed at server ' + @@SERVERNAME + '. Get more details from batch id: ' + cast(@rowid as varchar(20))
		set @subject = 'SECURITY ALERT : Login attempt failed at server ' + @@servername + '.'
		exec msdb.dbo.sp_send_dbmail   
		@profile_name=@profilename_email,  
		@recipients=@emailrecipients,  
		@subject=@subject,  
		@body_format = 'HTML',  
		@body=@msg,  
		@from_address = 'AnnuityNetAuditCheck<donotreply@ebix.com>'  
		
		
		update [DBLOG].Trace_Info
		set SentAlertsNumber = SentAlertsNumber +1
		where ROWID = @rowid
	Fetch Next from check_alert
	INTO @rowid
	END
	Close check_alert
	deallocate check_alert
end