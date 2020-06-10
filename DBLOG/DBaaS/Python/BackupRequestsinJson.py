from pgdatabase import cursorfromconnectionpool, Database
from pgconnectionstring import connectionstring 
import json
import psycopg2
class newBackupRequest:

    def __init__(self):
        pass
        

 
    def getBackupRequest(self,status):
        cs = connectionstring()
        Database.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        
        with cursorfromconnectionpool() as cursor:
            lst=['waiting_for_approval','approved', 'new','submitted']
            if (status in lst):
                query="select sl.ipaddress, r.userid, ume.manageremail, replace(sl.name,'\\','/') as servername, ds.databasename, br.requestid, br.itopid, datetimetoexecute, usrs.emailaddress, usrs.firstname, usrs.lastname, options->'backuppath' as backuppath, br.status, options->'authstat' as approval, options->'approval'->'Manager' as managerapprovalrequired, options->'approval'->'SQLTeam' as sqlteamapprovalneeded from dbs.backup_requests br join dbs.requests r 	on r.id = br.requestid  join rtm.serverslist sl  	on sl.serverid = br.serverid join rtm.databases ds 	on ds.databaseid = br.databaseid join rtm.users usrs 	on usrs.userid=r.userid left outer join RTM.usermanageremail ume on ume.userid=usrs.userid where (options->>'authstat') not in('rejected') and status='%s' " % status #and br.requestid=23
            else:
                query="select sl.ipaddress, r.userid, ume.manageremail, replace(sl.name,'\\','/') as servername, ds.databasename, br.requestid, br.itopid, datetimetoexecute, usrs.emailaddress, usrs.firstname, usrs.lastname, options->'backuppath' as backuppath, br.status, options->'authstat' as approval, options->'approval'->'Manager' as managerapprovalrequired, options->'approval'->'SQLTeam' as sqlteamapprovalneeded from dbs.backup_requests br join dbs.requests r 	on r.id = br.requestid  join rtm.serverslist sl  	on sl.serverid = br.serverid join rtm.databases ds 	on ds.databaseid = br.databaseid join rtm.users usrs 	on usrs.userid=r.userid left outer join RTM.usermanageremail ume on ume.userid=usrs.userid where (options->>'authstat') not in('rejected') and status='%s' and br.datetimetoexecute <= timezone('UTC',now()) " % status #and br.requestid=23
            cursor.execute(query);
            requests=cursor.fetchall();
            return requests
