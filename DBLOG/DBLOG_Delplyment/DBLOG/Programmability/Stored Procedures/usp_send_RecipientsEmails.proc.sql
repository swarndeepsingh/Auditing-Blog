CREATE PROC [DBLog].[usp_send_RecipientsEmails] @alertid INT
	,@subject VARCHAR(8000)
	,@body VARCHAR(max)
	, @alert_event_id INT
AS
DECLARE @Email VARCHAR(50)
	,@intCounter INT
	,@TotalRecords INT
	,@alertfrom VARCHAR(500)
	,@profile VARCHAR(500)
DECLARE @RecipientEmails TABLE (
	RowEmailId INT IDENTITY(1, 1) PRIMARY KEY
	,RecipientEmail VARCHAR(50)
	,FromEmail VARCHAR(500)
	,[Profile] VARCHAR(500)
	)

-- Set Configuration options
--Exec sp_configure 'show advanced options', 1
-- reconfigure with override
--Exec sp_configure 'SQL Mail XPs', 1
--	reconfigure with override
-- Add indivisual email IDs
INSERT INTO @RecipientEmails (
	RecipientEmail
	,FromEmail
	,[Profile]
	)
SELECT E.Recipients
	,E.From_Email
	,E.[Profile]
FROM DBLog.Alert_Subscription A WITH (NOLOCK)
JOIN DBLog.EmailProfiles E WITH (NOLOCK) ON E.ID = A.EmailProfileID
	AND E.Active = 1
	AND E.AlertPermission = 'S' -- S = "Subscription based alerts"
WHERE A.AlertID = @alertID

-- Add All Permission Email IDs	
UNION
SELECT E.Recipients
	,E.From_Email
	,E.[Profile]
FROM DBLog.EmailProfiles E WITH (NOLOCK)
WHERE E.Active = 1
	AND E.AlertPermission = 'A' -- A= "All alerts subscriptions by default"

SET @TotalRecords = @@ROWCOUNT
SET @intCounter = 1

-- LOOP TO send individual emails
WHILE (@intCounter <= @TotalRecords)
BEGIN
	-- Get email
	SELECT @Email = RecipientEmail
		,@alertfrom = FromEmail
		,@profile = [Profile]
	FROM @RecipientEmails
	WHERE RowEmailId = @intCounter

	EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile
		,@recipients = @email
		,@subject = @subject
		,@body_format = 'HTML'
		,@body = @body
		,@from_address = @alertFrom
		
	
	INSERT INTO DBLOG.Alert_Email_Logs
	select @alert_event_id, RecipientEmail, FromEmail, [Profile] from @RecipientEmails WHERE RowEmailId = @intCounter
	

	SET @intCounter = @intCounter + 1
END