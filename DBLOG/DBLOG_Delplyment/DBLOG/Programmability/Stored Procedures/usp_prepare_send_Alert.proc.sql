CREATE PROC [DBLog].[usp_prepare_send_Alert]
AS
DECLARE @sql NVARCHAR(max)
	,@ref INT
	,@insertedrow INT
DECLARE @alertid INT
	,@alertType VARCHAR(500)
	,@alertQuery VARCHAR(max)
	,@alertRecipients VARCHAR(8000)
	,@AlertSubject_Query NVARCHAR(2000)
	,@AlertBody_Query NVARCHAR(2000)
	,@alertGap INT
	,@maxAlert INT
	,@innerCursor CURSOR
	,@cursorQuery NVARCHAR(4000)
	,@alertTable VARCHAR(500)
	,@alertColumn VARCHAR(500)
	,@subject VARCHAR(8000)
	,@body VARCHAR(max)
	,@subjectOut VARCHAR(8000)
	,@sendAlert INT
	,@emailProfile VARCHAR(500)
	,@alertFrom VARCHAR(500)
	,@emailprofileid INT
	,@alertNumber VARCHAR(20)
	,@alertEnvironment VARCHAR(10)
	,@srvName VARCHAR(200)
	,@importance VARCHAR(20)

-- Refresh the Jobs statuses
EXEC DBLOG.usp_extract_job_status;

DECLARE Prepare_Alert CURSOR
FOR
SELECT alertid
	,AlertType
	,AlertQuery
	,/*AlertRecipients,*/ AlertSubject_Query
	,AlertBody_Query
	,AlertGap_Minutes
	,MaxAlerts
	,alerttable
	,alertcolumn /*, Emailprofile, EmailProfileID,
 alertfrom*/
FROM dblog.Alert_Definitions WITH (NOLOCK)
WHERE [enabled] = 1

OPEN Prepare_Alert

FETCH NEXT
FROM Prepare_Alert
INTO @alertid
	,@alertType
	,@alertQuery
	,/* @alertRecipients,*/ @AlertSubject_Query
	,@AlertBody_Query
	,@alertGap
	,@maxAlert
	,@alerttable
	,@alertcolumn /*, @emailProfile, @emailprofileid, @alertFrom*/

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @cursorQuery = 'set @Cursor = cursor for ' + @alertQuery + ' Open @Cursor'

	EXEC sp_executesql @cursorQuery
		,N'@cursor Cursor Output'
		,@innerCursor OUTPUT

	FETCH NEXT
	FROM @innerCursor
	INTO @ref

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sendAlert = 0

		IF NOT EXISTS (
				SELECT 1
				FROM dblog.alert_events WITH (NOLOCK)
				WHERE alert_id = @alertid
					AND ref_id = @ref
					AND alerttable = @alerttable
					AND alertcolumn = @alertcolumn
					AND Alert_Status = 'Open'
				)
			AND @alertType <> 'Information'
		BEGIN
			SET @sendAlert = 1

			INSERT INTO dblog.alert_events (
				alert_id
				,alert_status
				,alerttable
				,alertcolumn
				,ref_id
				,last_sent
				,alert_count
				)
			SELECT @alertid
				,'Open'
				,@alertTable
				,@alertColumn
				,@ref
				,GETDATE()
				,1
				
				SET @insertedrow = @@identity
			
		END
		ELSE IF EXISTS (
				SELECT 1
				FROM dblog.alert_events WITH (NOLOCK)
				WHERE alert_id = @alertid
					AND ref_id = @ref
					AND alerttable = @alerttable
					AND alertcolumn = @alertcolumn
					AND alert_status = 'Open'
					AND alert_count < @maxAlert
					AND DATEDIFF(minute, last_sent, getdate()) >= @alertgap
				)
			AND @alertType <> 'Information'
		BEGIN
			SET @sendAlert = 1

			UPDATE dblog.alert_events
			SET alert_count = alert_count + 1
				,last_sent = GETDATE()
			WHERE alert_id = @alertid
				AND ref_id = @ref
				AND alerttable = @alerttable
				AND alertcolumn = @alertcolumn
				AND alert_status = 'Open'
		END

		IF @sendAlert = 0
			AND @alertType = 'Information'
		BEGIN
			--if (select ISNULL(DATEDIFF(minute,max(last_sent), getdate()), 1000) from dblog.alert_events with (NOLOCK)
			--where ref_id = @ref and AlertTable = @alertTable and AlertColumn = @alertColumn) >= @alertgap
			IF NOT EXISTS (
					SELECT 1
					FROM dblog.alert_events WITH (NOLOCK)
					WHERE ref_id = @ref
						AND AlertTable = @alertTable
						AND AlertColumn = @alertColumn
					)
			BEGIN
				--if not exists(select 1 from dblog.alert_events with (NOLOCK) where alert_id = @alertid 
				--and ref_id = @ref and alerttable = @alerttable and alertcolumn = @alertcolumn and alert 
				--and alert_count < @maxAlert and DATEDIFF(minute,last_sent, getdate()) < @alertgap)
				--BEGIN
				--select @alertid, @ref, @alerttable, @alertcolumn
				SET @sendAlert = 1

				INSERT INTO dblog.alert_events (
					alert_id
					,alert_status
					,alerttable
					,alertcolumn
					,ref_id
					,last_sent
					,alert_count
					)
				SELECT @alertid
					,'Close'
					,@alertTable
					,@alertColumn
					,@ref
					,GETDATE()
					,1

				SET @insertedrow = @@identity

				-- PRINT @insertedrow
			END
		END

		IF @sendAlert = 1 -- Send Alert if this flag is true
		BEGIN
			-- Prepare Subject
			SET @sql = @AlertSubject_Query + ' ' + @alertTable + ' where ' + @alertColumn + ' = ' + cast(@ref AS VARCHAR(25))

			EXECUTE sp_executesql @sql
				,N'@sub varchar(8000) OUTPUT'
				,@subject OUTPUT

			-- Prepare Body
			SET @sql = @Alertbody_query + ' ' + @alertTable + ' where ' + @alertColumn + ' = ' + cast(@ref AS VARCHAR(25))

			EXECUTE sp_executesql @sql
				,N'@body varchar(8000) OUTPUT'
				,@body OUTPUT

			-- update Event
			IF @alerttype <> 'Information'
			BEGIN
				UPDATE dblog.alert_events
				SET alert_subject = @subject
					,alert_body = @body
				WHERE alert_id = @alertid
					AND ref_id = @ref
					AND alerttable = @alerttable
					AND alertcolumn = @alertcolumn
			END

			IF @alerttype = 'Information'
			BEGIN
				UPDATE dblog.alert_events
				SET alert_subject = @subject
					,alert_body = @body
				WHERE alert_event_id = @insertedrow
			END

			SELECT @srvname = substring(@@servername, 0, CASE charindex('.', @@servername, 0)
						WHEN 0
							THEN LEN(@@servername) + 1
						ELSE charindex('.', @@servername, 0)
						END)

			SELECT @alertEnvironment = serveraliasname
			FROM dblog.server_error WITH (NOLOCK)
			WHERE ServerName = @srvname

			SELECT @importance = c.importance
				,@alertNumber = c.errorID
			FROM dblog.alert_definitions a WITH (NOLOCK)
			LEFT JOIN dblog.error_alert b WITH (NOLOCK) ON a.AlertName = b.alert_name
			LEFT JOIN dblog.errors c WITH (NOLOCK) ON b.errorid = c.errorid
			WHERE a.AlertID = @alertid

			SET @subject = isnull(@alertNumber, 'NotDefined') + ' (' + isnull(@alertEnvironment, 'UN') + '_' + @srvname + ') : ' + @importance + ' ' + @subject

			EXEC DBLOG.usp_send_RecipientsEmails @AlertId, @subject ,@body, @insertedrow
		END

		FETCH NEXT
		FROM @innerCursor
		INTO @ref
	END

	CLOSE @innerCursor

	DEALLOCATE @innerCursor

	FETCH NEXT
	FROM Prepare_Alert
	INTO @alertid
		,@alertType
		,@alertQuery
		,/*@alertRecipients,*/ @AlertSubject_Query
		,@AlertBody_Query
		,@alertGap
		,@maxAlert
		,@alerttable
		,@alertcolumn /*, @emailProfile, @emailprofileid, @alertFrom*/
END

CLOSE Prepare_Alert

DEALLOCATE prepare_Alert

UPDATE dblog.alert_events
SET alert_status = 'Close'
WHERE alert_id IN (
		SELECT alertid
		FROM dblog.alert_definitions WITH (NOLOCK)
		WHERE AlertType = 'Information'
		)
	AND Alert_Status <> 'Close'