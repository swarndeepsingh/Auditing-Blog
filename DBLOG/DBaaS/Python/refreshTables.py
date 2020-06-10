#py
import json
from pgdatabase import cursorfromconnectionpool as pgconnectionpool, Database as pgdatabase
from pgconnectionstring import connectionstring as pgconnectionstring
import psycopg2
import psycopg2.extras as ex
import sqlRequestInJson
import datetime, time
import sys
import threading
import pandas as pd

class getdata:
	def __init__(self):
		self.query="select sl.ipaddress , sl.name , sl.serverid, sl.port from rtm.serverslist sl join rtm.serverdetails sd on sl.serverid=sd.serverid  where sl.active=1 and sd.connectionstatus='connected' order by sl.serverid"

	def return_serverlist(self):
		cs = pgconnectionstring()
		pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        # Get servers list
		with pgconnectionpool() as cursor:
			cursor.execute(self.query)
			result = cursor.fetchall()
			return result


class update:
    def __init__(self):
        pass


    def updateData(self, script):
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host)
        with pgconnectionpool() as cursor:
            cursor.execute(script)

    def returnRows(self): #self, serverid, serverip, name):        
        gd=getdata()
        return gd.return_serverlist()


    def updateDatabasesThread(self, rows):
        threadlist=[]
        for  request in rows:   
            lst=list(request['ipaddress'])
            if lst.count('\\')>0:
                lst=lst[0:request['ipaddress'].find('\\')]
                request['ipaddress']=''.join(lst)
            t=threading.Thread(target=self.updateTables, args=(request['serverid'], request['ipaddress'], request['port'],))
            threadlist.append(t)        
        for i, thread in enumerate(threadlist):
            try:
                #if(i%4==0):
                    #time.sleep(2)
                thread.start()
                
            except:
                e="{}".format(sys.exc_info())
                print(e)

    def updateTables (self,  serverid, ipaddr, port):
        query=''
        currentDT = str(datetime.datetime.utcnow())
        sqlreq=sqlRequestInJson.sqlrequests()        
        result=sqlreq.execsql(ipaddr, "use master; create table ##t (servername nvarchar(512),databasename nvarchar(512),schemaname nvarchar(512),tablename nvarchar(512)) declare @script varchar(256) ='if (''?'' not in (''msdb'',''model'',''tempdb'',''master'')) begin insert into ##t select @@servername ,''?'', s.name,t.name from [?].sys.tables t join [?].sys.schemas s on t.schema_id=s.schema_id where type=''u'' end;' exec sp_msforeachdb @script  select servername, databasename, schemaname, tablename from ##t drop table ##t", port)
        
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host)
        with pgconnectionpool() as cursor:
            tablist=[]
            schlist=[]
            for row in result['result']:      
                #insert into rtm.schemas (schemaname) select schname ON CONFLICT DO NOTHING
                try:    
                    query=query+"select * from rtm.fn_create_schema_table('{}','{}','{}','{}');".format(row['servername'], row['databasename'],row['schemaname'],row['tablename'])
                    #print(query)
                    #cursor.execute(query)
                    
                    values=(row['servername'], row['databasename'],row['schemaname'],row['tablename'])
                    #values=(row[0], row[1],row[2],row[3])
                    schvalue=(row['schemaname'],)
                    tablist.append(values)
                    schlist.append(schvalue)

                except:
                    e="{}".format(sys.exc_info())
                    #print(e)
            schlist=list(dict.fromkeys(schlist))
            
            ex.execute_values(cursor,"insert into rtm.schemas(schemaname) values %s ON CONFLICT DO NOTHING;".format(), schlist)
            #ex.execute_values(cursor,"select * from rtm.fn_create_schema_table %s".format(), tablist)
            cursor.execute(query)

upd= update()
rows=upd.returnRows()
upd.updateDatabasesThread(rows)

