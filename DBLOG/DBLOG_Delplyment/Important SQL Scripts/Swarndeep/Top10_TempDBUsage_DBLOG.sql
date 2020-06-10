
with cte_TempDb
as (
select object_id, sum(TempDBMB) [TotalTempDBUsage], cast(start_time as date) Date, db.DatabaseName, sl.name
 from [dbo].[RequestsProcessed]  rq
join datacollection..[databases] db
	on db.DatabaseID = rq.databaseid
join rtm.rtm.serverslist sl
	on sl.serverid = rq.serverid
join performancecollection.dbo.SQLHandleMaster sqlhandle
	on sqlhandle.objectid = rq.object_id
where rq.serverid in (select serverid from rtm.rtm.serverslist where name = 'an3uatsql01')
and db.databasename not in ('master', 'msdb', 'tempdb', 'distribution')
group by rq.object_id, cast(rq.start_time as date), db.DatabaseName, sl.name
having sum(tempdbmb) >1
--order by cast(start_time as date), sum(tempdbmb)  desc
)
select ROW_NUMBER() OVER(PARTITION BY Date order by TotalTempDBUSage desc) as rowid, * into #temp from cte_Tempdb a

select * from #temp
where rowid < 11
drop table #temp




with cte_TempDb
as (
select object_id, sum(TempDBMB) [TotalTempDBUsage], cast(format(start_time, 'MM/dd/yyyy HH:00') as datetime) [Date], db.DatabaseName, sl.name
 from [dbo].[RequestsProcessed]  rq
join datacollection..[databases] db
	on db.DatabaseID = rq.databaseid
join rtm.rtm.serverslist sl
	on sl.serverid = rq.serverid
join performancecollection.dbo.SQLHandleMaster sqlhandle
	on sqlhandle.objectid = rq.object_id

where rq.serverid in (select serverid from rtm.rtm.serverslist where name in ('an3uatsql01', 'an3prodsql01', 'an3pssql01a'))
and db.databasename not in ('master', 'msdb', 'tempdb', 'distribution') and rq.start_time > getdate()-10
group by rq.object_id, cast(format(start_time, 'MM/dd/yyyy HH:00') as datetime), db.DatabaseName, sl.name
having sum(tempdbmb) >1
--order by cast(start_time as date), sum(tempdbmb)  desc
)
select ROW_NUMBER() OVER(PARTITION BY name, date order by TotalTempDBUSage desc) as rowid, * into #temp from cte_Tempdb a order by [date] desc




select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PROD.AnnuityTransactions.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'AnnuityTransactions'
and rowid between 1 and 5 and tmp.name = 'an3prodsql01'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PROD.AnnuityProducts.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'AnnuityProducts'
and rowid between 1 and 5 and tmp.name = 'an3prodsql01'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PROD.System.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'System'
and rowid between 1 and 5 and tmp.name = 'an3prodsql01'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PROD.UI.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'UI'
and rowid between 1 and 5 and tmp.name = 'an3prodsql01'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PROD.Security.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'Security'
and rowid between 1 and 5 and tmp.name = 'an3prodsql01'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PROD.FeedsStaging.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'FeedsStaging'
and rowid between 1 and 5 and tmp.name = 'an3prodsql01'


--PS--- 

select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PS.AnnuityTransactions.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'AnnuityTransactions'
and rowid between 1 and 5 and tmp.name = 'an3pssql01a'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PS.AnnuityProducts.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'AnnuityProducts'
and rowid between 1 and 5 and tmp.name = 'an3pssql01a'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PS.System.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'System'
and rowid between 1 and 5 and tmp.name = 'an3pssql01a'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PS.UI.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'UI'
and rowid between 1 and 5 and tmp.name = 'an3pssql01a'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PS.Security.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'Security'
and rowid between 1 and 5 and tmp.name = 'an3pssql01a'
union
select obj.name [ObjectName], obj.type_desc, tmp.TotalTempDBUsage, tmp.DatabaseName, tmp.Date from #temp tmp
join AN3PS.FeedsStaging.Sys.Objects obj
	on obj.object_id = tmp.object_id
where tmp.DatabaseName = 'FeedsStaging'
and rowid between 1 and 5 and tmp.name = 'an3pssql01a'



