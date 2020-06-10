
import pymssql
from sqlconnectionstring import connectionstring 
import json
import sys
import datetime
from iTopOperations import iTopOperations as itop


class Backup:
    def __init__(self):
        pass

    def getbackuplocation(self,servername, userid,requestid,dbname):
        currentDT = str(datetime.datetime.utcnow())
        cs=connectionstring()
        
        #backuplocationquery=("select l.LocationPath from dblog.dblog.Backup_info bi join dblog.dblog.location_details l on l.locationid = bi.BackupLocationID where bi.dbname='dblog' and bi.BackupType='d' and enabled=1")
        #backuplocationquery="DECLARE @BackupDirectory NVARCHAR(100)   EXEC master..xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',      @key = 'Software\Microsoft\MSSQLServer\MSSQLServer',      @value_name = 'BackupDirectory', @BackupDirectory = @BackupDirectory OUTPUT ;  select @BackupDirectory as [LocationPath]"
        backuplocationquery="declare @backupdirectory nvarchar(300) if exists(select 1 from sys.databases where name='DBLOG') 
        begin if exists(select 1 from dblog.sys.tables where name='backup_info') begin select @backupdirectory=ld.locationpath  
        + '\%s' from dblog.dblog.backup_info BI join dblog.dblog.Location_Details ld on ld.LocationID = bi.BackupLocationID where dbname = '%s' and backuptype='D' end else begin EXEC master..xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',      
        @key = 'Software\Microsoft\MSSQLServer\MSSQLServer', @value_name = 'BackupDirectory', @BackupDirectory = @BackupDirectory OUTPUT ;  select @BackupDirectory as [LocationPath] end end else begin 	EXEC master..xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',      @key = 'Software\Microsoft\MSSQLServer\MSSQLServer', @value_name = 'BackupDirectory', @BackupDirectory = @BackupDirectory OUTPUT ; end  select @BackupDirectory as [LocationPath]  " %(dbname, dbname)
        try:
            connection=pymssql.connect(user=cs.user, password=cs.password, database='master', host=servername, as_dict=True)
            connection.autocommit(True)
        except:
            e="{}".format(sys.exc_info())
            e=e.replace("'","*")
            e=e +':'+ str(requestid)
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->getbackuplocation->connection','%s')" %(e,e,currentDT,userid)
            itop.updateDBaaS(query)
        with connection.cursor() as cursor:
            try:
                #print(backuplocationquery)
                cursor.execute(backuplocationquery)
                folder=cursor.fetchall()
                return folder[0]['LocationPath']
            except:
                e="{}".format(sys.exc_info())
                e=e.replace("'","*")
                e=e +':'+ str(requestid)
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->getbackuplocation->cursor','%s')" %(e,e,currentDT,userid)
                itop.updateDBaaS(query)
            try:
                connection.close()
            except:
                pass
            #return result

    def fullBackup(self, servername, dbname, userid, itopid, requestid ):
        currentDT = str(datetime.datetime.utcnow())
        cs=connectionstring()
        
        bk=Backup()
        backupfilename='{}_dbaas_full__{date:%Y%m%d%H%M%S%f}.bak'.format(dbname,date=datetime.datetime.now())
        backuplocation=bk.getbackuplocation(servername,userid,requestid,dbname)
        backupquery=("backup database [%s] TO DISK='%s\%s' with copy_only, compression" %(dbname,backuplocation, backupfilename))
        #print(backupquery)
        connection=pymssql.connect(user=cs.user, password=cs.password, database='master', host=servername, as_dict=True)
        
        connection.autocommit(True)
        with connection.cursor() as cursor:
            try:
                query="update dbs.backup_requests set status='backupstarted', lastupdated='{}' where requestid = '{}';".format(currentDT,requestid)
                ## add log
                comment='Starting Backup for {} to {}->{}'.format(dbname, backuplocation, backupfilename) #.replace("\\","->")
                
                query="update dbs.backup_requests set status='backupstarted', lastupdated='{}' where requestid = '{}';".format(currentDT,requestid)
                query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','{}','{}')".format(requestid,comment, currentDT )         

                
                # update dbaas table on backup starting
                itop.updateDBaaS(query)
                
                itop.iTopAddPublicLog(itopid, comment, userid)
                
                # take backup
                cursor.execute(backupquery)

                currentDT = str(datetime.datetime.utcnow())
                comment='Completed Backup for {} to {}->{}'.format(dbname, backuplocation, backupfilename)

                # add public log in ticket
                
                itop.iTopAddPublicLog(itopid, comment, userid)
                query="update dbs.backup_requests set status='completed', lastupdated='{}' where requestid = '{}';".format(currentDT,requestid)
                query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','{}','{}')".format(requestid,comment, currentDT )       
                #update dbaas table on completion of backup
                itop.updateDBaaS(query)
                itop.iTopResolved(itopid)

            except:
                e="{}".format(sys.exc_info())
                e=e.replace("'","*")
                e=e +':'+ str(requestid)
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->fullbackup','%s')" %(e,e,currentDT,userid)
                itop.updateDBaaS(query)
            #result = cursor.fetchall()
            try:
                connection.close()
            except:
                pass
            #return result

