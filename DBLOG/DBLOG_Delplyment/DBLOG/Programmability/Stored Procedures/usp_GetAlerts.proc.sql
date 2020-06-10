
CREATE proc [DBLog].[usp_GetAlerts] @status varchar(20) 
as
if @status <>'All'
begin
select 
a.Alert_Event_ID
,b.AlertName
,a.Alert_Status
,a.Alert_Subject
,a.Alert_Body
,a.AlertRecipients
,a.Alert_count
,a.AlertTable
,a.AlertColumn
,a.Ref_ID
,a.Last_Sent
,a.Comments
 from dblog.Alert_Events a with (Nolock)
 join dblog.Alert_Definitions b with (NOLOCK)
	on a.Alert_ID = b.alertID
where  Alert_Status=@status 
order by a.Alert_Event_ID desc

end

else if @status ='All'
begin
select
a.Alert_Event_ID
,b.AlertName
,a.Alert_Status
,a.Alert_Subject
,a.Alert_Body
,a.AlertRecipients
,a.Alert_count
,a.AlertTable
,a.AlertColumn
,a.Ref_ID
,a.Last_Sent
,a.Comments
 from dblog.Alert_Events a with (Nolock)
 join dblog.Alert_Definitions b with (NOLOCK)
	on a.Alert_ID = b.alertID
order by a.Alert_Event_ID desc
end