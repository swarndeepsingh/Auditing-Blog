create proc [DBLog].[usp_UpdateAlertSubscription] @emailprofileid int, @alertid int, @action varchar(10), @user varchar(255)
as
if @action = 'Insert'
Begin
	if not exists(select 1 from DBLOG.Alert_Subscription where EmailProfileID=@emailprofileid and AlertID = @alertid)
	begin
		Insert into DBLOG.Alert_Subscription (EmailProfileID, AlertID, Addedby, LastUpdated)
		values (@emailprofileid, @alertid, @user, getdate())
	End
END
if @action = 'Delete'
Begin
	Delete from DBLOG.Alert_Subscription where  EmailProfileID=@emailprofileid and AlertID = @alertid
end