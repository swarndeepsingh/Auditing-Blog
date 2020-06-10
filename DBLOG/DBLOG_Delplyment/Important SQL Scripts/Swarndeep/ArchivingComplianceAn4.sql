
 select trans.transactionID, trans.distributorID, trans.updateDateTime,  DATEDIFF(D,trans.updateDateTime, GETDATE()), archive.defaultArchivingDays  
 , part.partnerDisplayName
 from annuitytransactions.transactions.transactions trans with (NOLOCK)
 join transactions.ArchivingConfiguration archive
	on archive.transactionTypeID = trans.transactiontypeid
	and archive.distributorID = trans.distributorID
join security.security.Distributors dist
	on dist.distributorID = trans.distributorID
join security.Partners part
	on dist.distributorID = part.partnerid
where DATEDIFF(D,trans.updateDateTime, GETDATE()) > archive.defaultArchivingDays



 select trans.transactionID, trantype.transactiontype, trans.distributorID, trans.updateDateTime,  DATEDIFF(D,trans.updateDateTime, GETDATE()), archive.defaultArchivingDays  
 , part.partnerDisplayName
 from annuitytransactions.transactions.transactions trans with (NOLOCK)
 left outer join transactions.ArchivingConfiguration archive
	on archive.transactionTypeID = trans.transactiontypeid
	and archive.distributorID = trans.distributorID
join security.security.Distributors dist
	on dist.distributorID = trans.distributorID
join security.Partners part
	on dist.distributorID = part.partnerid
join lookups.TransactionType trantype
	on trantype.transactionTypeID = trans.transactionTypeID
where archive.archivingConfigurationID is null