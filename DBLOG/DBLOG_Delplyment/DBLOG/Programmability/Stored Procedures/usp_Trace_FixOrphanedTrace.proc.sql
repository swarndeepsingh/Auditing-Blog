create proc DBLog.usp_Trace_FixOrphanedTrace
as
declare @rowid int
declare fixOrphanedTrace CURSOR FOR
	select a.ROWID from DBLog.Trace_Info a with (NOLOCK)
	left join sys.traces b with (NOLOCK)
		on a.tracefile = b.path
	left outer join DBLog.Trace_Properties c with (NOLOCK)
		on a.Tracename = c.TraceName
		and c.PropertyName = 'Interval'
	where b.id is null and a.Active = 1 and DATEDIFF(minute,a.CreateDate,GETDATE()) > c.PropertyValue
Open fixOrphanedTrace
FETCH Next FROM fixOrphanedTrace into @rowid
WHILE @@FETCH_STATUS = 0
BEGIN
	update DBLog.Trace_Info set Active = 0 where ROWID = @rowid
	print 'Updated ' + cast(@rowid as varchar(10))
	FETCH Next FROM fixOrphanedTrace into @rowid	
END
CLOSE fixOrphanedTrace
deallocate fixOrphanedTrace
GO