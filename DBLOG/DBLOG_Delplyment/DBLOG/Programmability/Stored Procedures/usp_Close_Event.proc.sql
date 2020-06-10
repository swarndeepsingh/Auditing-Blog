create proc [DBLog].[usp_Close_Event] @eventID int, @comments varchar(2000)
as
-- This proc will close the event and 
-- internally sends email using trigger on event table
update DBLog.Alert_Events
set Alert_Status = 'Close'
, Comments = @comments
where Alert_Event_ID=@eventID