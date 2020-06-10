import BackupRequestsinJson as backup
from environments import environments
import requests, json, datetime, sys
from pgdatabase import cursorfromconnectionpool, Database
from pgconnectionstring import connectionstring 
import psycopg2
from iTopOperations import iTopOperations as itop
from executeFullBackup import Backup
import threading
from time import sleep

#userid, itopid, requestid

class backupOperation:
    def getListOfQueuedBackups(self):
        currentDT = str(datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S%f'))
        #currentDT = str(datetime.datetime.now())
        myclass = backup.newBackupRequest()
        backuplist=[]
        for i, row in enumerate(myclass.getBackupRequest('queued')):
            #backuplist.append({"server":row['ipaddress'], "databasename":row['databasename']})
            data=itop.iTopGetStatus(row['itopid'], row['userid'])
            #print("itopid {}".format(row["itopid"]))
            if(data['code']==0):
                try:
                    for k,v in data.get('objects').items():
                        status=(data.get('objects').get(k).get('fields').get('status'))
                        
                        if (status=='assigned'):
                            backuplist.append({"server":row['ipaddress'], "databasename":row['databasename'],"userid":row['userid'],"itopid":row['itopid'], "requestid":row['requestid']})
                            
                except:
                    e="{}".format(sys.exc_info()[0])
                    e=e.replace("'","*")
                    query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->getListOfQueuedBackups','%s')" %(e,e,currentDT,row['userid'])
                    itop.updateDBaaS(query)
        return backuplist

    def initiateBackupThreads(self,list):
        it= backupOperation()
        backuplist=it.getListOfQueuedBackups()
        
        threadlist=[]        

        bk=Backup()
        
        for i,request in enumerate(backuplist):
            # initiate the thread
            t=threading.Thread(target=bk.fullBackup, args=(request['server'], request['databasename'], request['userid'], request['itopid'], request['requestid']))
            # add thread to the list so that it is accessible later
            threadlist.append(t)
        
        
        for thread in threadlist:
            thread.start()

        
        return
        


        for thread in threadlist:
            if(thread.isAlive()==True):
                print("Thread is running")
            else:
                print("Thread completed")

        for thread in threadlist:
            thread.join()

        for thread in threadlist:
            if(thread.isAlive()==True):
                print("Thread is running")
            else:
                print("Thread completed")
            print(thread.name)

        # Making sure all threads are completed
        print("Done")



