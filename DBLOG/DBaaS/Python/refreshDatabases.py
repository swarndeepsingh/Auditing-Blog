#py
import json
from pgdatabase import cursorfromconnectionpool as pgconnectionpool, Database as pgdatabase
from pgconnectionstring import connectionstring as pgconnectionstring
import psycopg2
import psycopg2.extras as ex
import sqlRequestInJson
import datetime
import sys
import threading

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
    # empty initialize class
    def __init__(self):
        pass

    # following function retuns cursor from postgres
    def updateData(self, script):
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host)
        with pgconnectionpool() as cursor:
            cursor.execute(script)

    # Following would call the fuction return_serverlist defined in the class above to get list of servers to be connected to
    def returnRows(self): #self, serverid, serverip, name):        
        gd=getdata()
        return gd.return_serverlist()

    # This is the thread function, this would create thread based on number of servers to be connected to
    def updateDatabasesThread(self, rows):
        # Empty thread list
        threadlist=[]
        for  request in rows:   
            lst=list(request['ipaddress'])
            # removing "\" from ip address as psycopg2 does not like "\", rather will provide port number for connection.
            if lst.count('\\')>0:
                lst=lst[0:request['ipaddress'].find('\\')]
                request['ipaddress']=''.join(lst)
            # The threading function takes paraters like fuction and arguments to be referencedd by each thread
            t=threading.Thread(target=self.updateDatabases, args=(request['serverid'], request['ipaddress'], request['port'],))
            # Adding thread to the list
            threadlist.append(t)

         # start the thread
        for thread in threadlist:
            try:
                thread.start()
            except:
                e="{}".format(sys.exc_info())
                print(e)

        

        # Making sure all threads are completed
        print("Done")

    # Following function will get database name from sql server and then would save into postgres
    def updateDatabases (self,  serverid, ipaddr, port):
        currentDT = str(datetime.datetime.utcnow())
        sqlreq=sqlRequestInJson.sqlrequests()
        # get data from SQL Server and adding result to result variable
        result=sqlreq.execsql(ipaddr, "select name from sys.databases", port)
        cs = pgconnectionstring()
        pgdatabase.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host)
        with pgconnectionpool() as cursor:
            dblist=[]
            for row in result['result']: 
                try:
                    values=(row['name'], serverid)
                    # append database name and serverid in list to be used later with execute_values
                    dblist.append(values)
                except:
                    e="{}".format(sys.exc_info())
                    print(e)
            # Following line of code will insert data into postgres, without using loop as it takes list that will be passed to insert values by function itself
            ex.execute_values(cursor,'insert into rtm.databases(databasename, serverid) values %s  on conflict(serverid, databasename) DO NOTHING', dblist)
            
# finally put all together
# creating object from class
upd= update()
# return data from function
rows=upd.returnRows()
#Start thread
print("Started {}" .format(str(datetime.datetime.utcnow())))
upd.updateDatabasesThread(rows)
print("Ended {}" .format(str(datetime.datetime.utcnow())))