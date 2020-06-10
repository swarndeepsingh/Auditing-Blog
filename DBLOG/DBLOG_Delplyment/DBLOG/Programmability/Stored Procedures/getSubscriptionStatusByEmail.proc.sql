CREATE procedure [DBLog].[getSubscriptionStatusByEmail] (@emailid int)  
as  
with subscription_cte(Stat, alertname, alertid)  
as(  
-- For subscribed
select 1, adf.alertname, adf.alertid from dblog.alert_definitions adf  
join dblog.alert_subscription asn  
 on adf.alertid = asn.alertid  
where asn.emailprofileid = @emailid  
   
union  
-- For Unsubscribed
select 0, adf.alertname, adf.alertid from dblog.alert_definitions adf  
left outer join dblog.alert_subscription asn  
 on adf.alertid = asn.alertid  
where adf.alertid not in ( select adf.alertid from dblog.alert_definitions adf  
join dblog.alert_subscription asn  
 on adf.alertid = asn.alertid  
where asn.emailprofileid = @emailid)  
)  
select * from subscription_cte