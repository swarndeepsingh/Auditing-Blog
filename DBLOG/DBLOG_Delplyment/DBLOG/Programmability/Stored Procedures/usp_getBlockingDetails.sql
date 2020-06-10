create proc dblog.usp_getBlockingDetails @start datetime, @end datetime
as
declare @id int, @trcst datetime, @trcend datetime, @blktrans varchar(50), @xml XML 
 declare @block table (id int, /*trcst datetime, trcend datetime, */blktran varchar(50), blocked varchar(500), blocking varchar(500)  ,blockedspid int, blockingspid int
 ,blockTranStart datetime)
  declare cur  cursor
  for
  select  id/*, tracestarttime, traceendtime*/, blockingtransactions, reportxml from [DBLog].[DBLog].[BlockingReport]
  		where tracestarttime between @start and @end

  open cur
  fetch next from cur into @id/*, @trcst, @trcend*/, @blktrans, @xml
  while (@@FETCH_STATUS =0)
  begin
	 if (@xml is not null)
		insert into @block
	 	select @id/*, @trcst, @trcend*/, @blktrans, a.b.value('blocked-process[1]/process[1]/inputbuf[1]','varchar(100)') [BlockedProcess]
		, a.b.value('blocking-process[1]/process[1]/inputbuf[1]','varchar(100)') [BlockingProcess] 
		, a.b.value('(blocked-process[1]/process[1]/@spid)[1]','varchar(100)') [blockedprocessid] 
		, a.b.value('(blocking-process[1]/process[1]/@spid)[1]','varchar(100)') [blockingprocessid] 
		, a.b.value('(blocked-process[1]/process[1]/@lasttranstarted)[1]', 'datetime') [BlockedTransactionStart]
		from @xml.nodes('blocked-process-report') a(b)
	fetch next from cur into @id,/* @trcst, @trcend,*/ @blktrans, @xml
  end
  close cur
  deallocate cur

  select distinct id,blockingspid, blocking [blockingCommand], blockedspid,  blocked [BlockedCommand],   blockTranStart  from @block order by blockTranStart
