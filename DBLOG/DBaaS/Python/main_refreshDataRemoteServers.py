import json
from pgdatabase import cursorfromconnectionpool as pgconnectionpool, Database as pgdatabase
from pgconnectionstring import connectionstring as pgconnectionstring
import psycopg2
import sqlRequestInJson
import datetime
import sys
import threading


class getdata:
	def __init__(self):
		self.query="select ipaddress , name , serverid, port  from rtm.serverslist where active=1 "

	def return_serverlist(self):
		cs = pgconnectionstring()
		pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        # Get servers list
		with pgconnectionpool() as cursor:
			cursor.execute(self.query);
			result = cursor.fetchall()
			return result


class update:
    def __init__(self):
        pass


    def updateData(self, script):
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host)
        with pgconnectionpool() as cursor:
            cursor.execute(script);

    def returnRows(self): #self, serverid, serverip, name):        
        gd=getdata()
        return gd.return_serverlist()


    def updateServerDetailsThread(self, rows):
        threadlist=[]
        print("Starting {}" .format(str(datetime.datetime.utcnow())))
        for i, request in enumerate(rows):
            lst=list(request['ipaddress'])
            if lst.count('\\')>0:
                lst=lst[0:request['ipaddress'].find('\\')]
                request['ipaddress']=''.join(lst)
            t=threading.Thread(target=self.updateServerDetails, args=(request['ipaddress'], request['port'],request['serverid']))
            threadlist.append(t)
        
        for thread in threadlist:
            thread.start()
    
    def updateServerDetails (self, ipaddr, port,serverid):
        currentDT = str(datetime.datetime.utcnow())
        sqlreq=sqlRequestInJson.sqlrequests()
        result=sqlreq.execsql(ipaddr, "select cast(conf.value_in_use as varchar) [value_in_use], SERVERPROPERTY('PRODUCTVERSION') [version], @@servername [servername], mem.total_physical_memory_kb/1024 [physicalmemory], mem.system_memory_state_desc [memorystate] , SERVERPROPERTY('Edition') [EDITION], info.cpu_count FROM sys.dm_os_sys_info info ,  sys.configurations conf, sys.dm_os_sys_memory mem where name like '%max server memory%' OPTION (RECOMPILE);", port)
        if (result['message']=='nothing'):
            data=(result['result'])
            version=data[0]['version']
            edition=data[0]['EDITION']

            # convert these values to ascii
            version=version.decode('utf-8')
            edition=edition.decode('utf-8')

            cpucount=str(data[0]['cpu_count'])
            maxservermemory=str(data[0]['value_in_use'])
            physicalmemory=str(data[0]['physicalmemory'])
            memorystate=str(data[0]['memorystate'])

            upsert="insert into rtm.serverdetails (serverid, serverip, sqlversion, sqledition, lastupdated,connectionstatus, cpucount, maxservermemory, memory, memorystate ) values ('%s', '%s', '%s', '%s', '%s', 'connected', '%s', '%s', '%s','%s') ON CONFLICT (serverid) Do UPDATE SET sqlversion='%s', sqledition='%s', connectionstatus='connected', lastupdated='%s', cpucount='%s', maxservermemory='%s',memory='%s', memorystate='%s'"%(serverid,ipaddr,version,edition,currentDT,cpucount,maxservermemory,physicalmemory, memorystate,version,edition,currentDT,cpucount, maxservermemory,physicalmemory, memorystate)
            self.updateData(upsert)
        elif (result['message']!='nothing'):
            upsert="insert into rtm.serverdetails (serverid, serverip, lastupdated,connectionstatus ) values ('%s', '%s', '%s', '%s') ON CONFLICT (serverid) Do UPDATE SET connectionstatus='%s', lastupdated='%s'"%(serverid,ipaddr,currentDT,result['message'],result['message'],currentDT)
            #print(upsert)
            self.updateData(upsert)
          
            
threadlist=[]
upd=update()
rows=upd.returnRows()
upd.updateServerDetailsThread(rows)
