from copyfile import copyfile
import sys
import sqlalchemy as sa
import threading

# get command line parameters
servername= (sys.argv[1])
backuptype=(sys.argv[2])

filetype = 'l' if backuptype=='log' else 'i' if backuptype=='diff' else 'd' if backuptype=='full' else print('Not valid input for backuptype') 

#get number of threads to be run
def get_threadcount(backuptype):
    
    MAX_THREADS=0

    engine = sa.create_engine('mssql+pymssql://%s' %(servername))
    with engine.connect() as con:
        sqlscript=""" select a.BackupType, a.threads from(
 select 'L' 'BackupType',mp_log.propertyvalue-instances.count as threads from dblog.dblog.MiscProperties mp_log
 outer apply(select COUNT(1) [count] from dblog.dblog.Backup_transfer_Job btj 
				inner join dblog.dblog.Backup_info bi_log
					on btj.backup_id = bi_log.Backup_ID
					and bi_log.BackupType='L'
					and btj.[Status]='transferring') as instances
	WHERE mp_log.PropertyName = 'TRANSFER_LOG_BAKCUP_MAX_THREADS'
UNION ALL
 select 'I' 'BackupType', mp_log.propertyvalue-instances.count as threads from dblog.dblog.MiscProperties mp_log
 outer apply(select COUNT(1) [count] from dblog.dblog.Backup_transfer_Job btj 
				inner join dblog.dblog.Backup_info bi_log
					on btj.backup_id = bi_log.Backup_ID
					and bi_log.BackupType='I'
					and btj.[Status]='transferring') as instances
	WHERE mp_log.PropertyName = 'TRANSFER_DIFF_BAKCUP_MAX_THREADS'
UNION ALL
 select 'D' 'BackupType', mp_log.propertyvalue-instances.count as threads from dblog.dblog.MiscProperties mp_log
 outer apply(select COUNT(1) [count] from dblog.dblog.Backup_transfer_Job btj 
				inner join dblog.dblog.Backup_info bi_log
					on btj.backup_id = bi_log.Backup_ID
					and bi_log.BackupType='D'
					and btj.[Status]='transferring') as instances
	WHERE mp_log.PropertyName = 'TRANSFER_FULL_BAKCUP_MAX_THREADS'
) as a where a.BackupType = '%s'"""%(backuptype)
        rs=con.execute(sqlscript)
        for row in rs:
            MAX_THREADS=row['threads']
    return MAX_THREADS
    
        

def start_copy():
    cp=copyfile()
    threadlist=[]
    threads=get_threadcount(filetype)
    
    #setup connection
    engine = sa.create_engine('mssql+pymssql://%s' %(servername))
    with engine.connect() as con:
        sqlscript="""select top %d jb.Transfer_ID transferid, jb.Source [source], jb.Destination [destination], @@SERVERNAME [server], ld.UserName [user],
    convert(varchar,DECRYPTBYPASSPHRASE(mp.Propertyvalue,ld.pword)) [passwd]
    from dblog.dblog.backup_transfer_job jb
    inner join dblog.dblog.Backup_info bi
            on bi.Backup_ID = jb.Backup_ID
    inner join dblog.dblog.Location_Details ld
            on ld.LocationID = jb.DestinationLocationID
    inner join dblog.dblog.MiscProperties mp
            on PropertyName = 'Location_Password_1'
    inner join dblog.dblog.backup_jobs bj
        on bj.backup_job_id = jb.backup_job_id
    where bi.BackupType = '%s' and jb.Status='Pending' and bj.backup_start_time > '2019-02-01'
    order by jb.Transfer_ID asc""" %(threads, filetype)

        
        
        rs=con.execute(sqlscript)
        for i, row in enumerate(rs):
            t=threading.Thread(target=cp.startcopy, args=(row['transferid'],  servername, row['source'], row['destination'], row['user'], row['passwd']))
            # cp.startcopy(row['transferid'],  servername, row['source'], row['destination'], row['user'], row['passwd'])
            threadlist.append(t)

        for thread in threadlist:
            thread.start()

def main():
    start_copy()


#main function
main()
            
                               
