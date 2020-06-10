from sqldatabase import cursorfromconnection, Database
from sqlconnectionstring import connectionstring 
import json
from pgdatabase import cursorfromconnectionpool as pgconnectionpool, Database as pgdatabase
from pgconnectionstring import connectionstring as pgconnectionstring
import psycopg2

class getserverslist:
    def __init__(self):
        pass

    def return_serverslist():
        cs=connectionstring()
        Database.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host, as_dict=True)

        with cursorfromconnection() as cursor:
             query=("SELECT [ServerID] ,[IPAddress] ,[Name] ,[Active] ,[AutoPoll] ,[parentServerID] ,[LicenseType] ,[ParentLicense] ,[DateTimeAdded] ,[AddedBy] ,[ApplicationID], [environmentid] ,[datacenterid], [port] FROM RTM.[RTM].[ServersList]")
             cursor.execute(query);            
             requests=cursor.fetchall();
             return requests

class refreshServersList():
    def __init__(self,srvrid, ipaddrs, name, active,autopoll,pntserverid,lictype, prntlicense,dtadded, added, appid, envid, dcid, port):
        self.query="insert into rtm.serverslist(serverid, ipaddress, name, active, autopoll, parentserverid, licensetype, parentlicense, datetimeadded, addedby, applicationid, environmentid, datacenterid, port) values('%s','%s','%s',case when '%s'='True' then 1 else 0 End,case when '%s'='True' then 1 else 0 End,%s,'%s','%s','%s','%s',%s,%s,%s,%s) on conflict(serverid) DO UPDATE set ipaddress=EXCLUDED.ipaddress, active=EXCLUDED.active, applicationid=EXCLUDED.applicationid, environmentid=EXCLUDED.environmentid, datacenterid=EXCLUDED.datacenterid, port=EXCLUDED.port;" % (srvrid, ipaddrs, name, active,autopoll,pntserverid,lictype, prntlicense,dtadded, added, appid, envid, dcid, port)


    def sync_serverslist(self):   
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        
        with pgconnectionpool() as cursor:
            cursor.execute(self.query);



class getdbslist:
    def __init__(self):
        pass

    def return_dblist():
        cs=connectionstring()
        Database.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host, as_dict=True)

        with cursorfromconnection() as cursor:
             query=("SELECT  databaseid, serverid, databasename FROM datacollection.dbo.[databases]")
             cursor.execute(query);            
             requests=cursor.fetchall();
             return requests

class refreshDBList():
    def __init__(self,dbid, srvrid, dbname):
        self.query="insert into rtm.databases(databaseid, serverid, databasename) values(%s,%s,'%s') on conflict(databaseid) DO NOTHING;" % (dbid, srvrid, dbname)


    def sync_dblist(self):   
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        
        with pgconnectionpool() as cursor:
            cursor.execute(self.query);



# Sync servers list
print("Syncing Servers List")
for  row in getserverslist.return_serverslist():
    #print(row)
    
    

    sl=refreshServersList(str(row['ServerID']).replace("None","Null"),row['IPAddress'].replace("None","Null"),row['Name'].replace("None","Null"),str(row['Active']).replace("None","Null"),str(row['AutoPoll']).replace("None","Null"),str(row['parentServerID']).replace("None","Null"),row['LicenseType'],str(row['ParentLicense']).replace("None","Null"),row['DateTimeAdded'],row['AddedBy'],str(row['ApplicationID']).replace("None","Null"),str(row['environmentid']).replace("None","Null"),str(row['datacenterid']).replace("None","Null"),str(row['port']))
    sl.sync_serverslist()
"""
# Sync Databases
print("Syncing Databases")
for  rowdb in getdbslist.return_dblist():
    #print(row)
    sl=refreshDBList(rowdb['databaseid'], rowdb['serverid'], rowdb['databasename'])
    sl.sync_dblist()
"""