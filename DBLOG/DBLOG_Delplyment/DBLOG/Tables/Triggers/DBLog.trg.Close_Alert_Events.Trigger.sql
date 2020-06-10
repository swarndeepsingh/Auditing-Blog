CREATE TRIGGER DBLog.trg_Close_Alert_Events 
   ON  DBLog.Alert_Events
   AFTER UPDATE
AS 
BEGIN
	if update(alert_status)
	begin
		
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @alerteventid int, @alert_subject varchar(500), @alert_from varchar(500), @alertid int
	, @emailprofile varchar(8000), @alertrecipient varchar(8000), @emailbody varchar(8000)
	,@comments varchar(max)
	if exists(select 1 from  inserted a
	join Alert_Definitions b with 	(NOLOCK)
		on a.Alert_ID = b.AlertID
	 where a.Alert_Status in('close', 'closed','resolved')
	 and b.AlertType <> 'Information')
	 begin

			select @alerteventid = a.alert_event_id, @alert_subject = a.Alert_Subject
			,@alertid = a.Alert_ID,@emailprofile = b.emailprofile, @alertrecipient = b.AlertRecipients
			,@alert_from = a.Alert_From, @comments = a.Comments
			  from inserted a
			join Alert_Definitions b with 	(NOLOCK)
				on a.Alert_ID = b.AlertID
			 where a.Alert_Status in('close', 'closed','resolved')
			 and b.AlertType <> 'Information'
			
			
			set @alert_subject = 'Resolved: ' + @alert_subject
			
				 
		set @emailbody ='<P>No Action needed. The Alert has been closed.<P>' + '<p>Comments:<BR>' + @comments + '  <BR><p><I>DO NOT REPLY to this e-mail address, contact DBA of ' + @@servername + '.</I></p>'
	
		
			 exec msdb.dbo.sp_send_dbmail       
			 @profile_name=@emailProfile,      
			 @recipients=@alertrecipient,      
			 @subject=@alert_subject,      
			 @body_format = 'HTML',      
			 @body=@emailbody,      
			 @from_address = @alert_from  
	end
end
END
GO
