import BackupRequestsinJson as backup
from environments import environments
import requests, json, datetime, sys
from pgdatabase import cursorfromconnectionpool, Database
from pgconnectionstring import connectionstring 
import psycopg2
#import executeFullBackup

class iTopOperations:     
    
    def iTopCreatnewTicket(emailaddress, servername, database, service, servicesubcategory,userid):
        obj=environments()
        env=obj.environment()
        currentDT = str(datetime.datetime.utcnow())
        #bservice=service#="Database Support US OP (SQL)"
        #bservicesubcategory=servicesubcategory#="Backup"
        try:  
            uri=(env+'json_data={"operation":"core/create", "comment":"DBLOG", "class":"UserRequest", "output_fields":"id, friendlyname, status","fields": {"org_id":"SELECT Organization WHERE name = \'EBIX\'", "caller_id":"SELECT Person WHERE email=\'%s\'","description":"Backup Requested from Server \'%s\' and database \'%s\'","title":"Backup Requested from Server \'%s\' and database \'%s\'","service_id":"SELECT Service WHERE name=\'%s\'","servicesubcategory_id":"SELECT ServiceSubcategory AS a JOIN Service AS b ON a.service_id=b.id WHERE a.name=\'%s\' AND b.name=\'%s\'"}}' % (emailaddress, servername,database, servername, database,    service,   servicesubcategory, service ))               
            #print(uri)
            res=requests.post(uri,verify=False)
            #print(res.text)
            jdata=json.loads(res.text)
            #print("jdata")
            return jdata            
        except:                
            e="{}".format(sys.exc_info()[0])
            #print(e)
            e=e.replace("'","*")
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopCreatnewTicket','%s')" %(e,e,currentDT,userid)
            iTopOperations.updateDBaaS(query)

    def iTopAssignTicket(iTopID, userid):
        obj=environments()
        env=obj.environment()
        currentDT = str(datetime.datetime.utcnow())
        try:
            uri=(env+'json_data={"operation":"core/update", "comment":"DBLOG", "class":"UserRequest","key":"SELECT UserRequest WHERE friendlyname=\'%s\'", "output_fields":"id, friendlyname, status","fields":{"status":"assigned","agent_id":"SELECT Person WHERE first_name=\'DBLOG\' AND name=\'DBLOG\'"}}' % (iTopID))
            res=requests.post(uri,verify=False)
            jdata=json.loads(res.text)
            return jdata
        except:
            e="{}".format(sys.exc_info()[0])
            e=e.replace("'","*")
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopAssignTicket','%s')" %(e,e,currentDT,userid)
            iTopOperations.updateDBaaS(query)

    def iTopWaitForApproval(iTopID, manageremail, userid):
        obj=environments()
        env=obj.environment()
        currentDT = str(datetime.datetime.utcnow())
        try:
            uri=(env+'json_data={"operation":"core/update", "comment":"DBLOG", "class":"UserRequest","key":"SELECT UserRequest WHERE friendlyname=\'%s\'", "output_fields":"id, friendlyname, status","fields":{"status":"waiting_for_approval","approver_id":"SELECT Person WHERE email=\'%s\'"}}' % (iTopID, manageremail)) 
            res=requests.post(uri,verify=False)
            jdata=json.loads(res.text)
            return jdata
        except:
            e="{}".format(sys.exc_info()[0])
            e=e.replace("'","*")
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopWaitForApproval','%s')" %(e,e,currentDT,userid)
            iTopOperations.updateDBaaS(query)

    def iTopAddPublicLog(iTopID, Log, userid):
        
        obj=environments()
        env=obj.environment()
        Log=Log.replace("&","and")
        Log=Log.replace("\\","//")
        currentDT = str(datetime.datetime.utcnow())
        try:
            uri=(env+'json_data={"operation":"core/update", "comment":"DBLOG", "class":"UserRequest","key":"SELECT UserRequest WHERE friendlyname=\'%s\'", "output_fields":"id, friendlyname, status","fields":{"public_log":"%s"}}' % (iTopID, Log)) 
            
            res=requests.post(uri,verify=False)
            jdata=json.loads(res.text)
            return jdata
        except:
            e="{}".format(sys.exc_info()[0])
            e=e.replace("'","*")
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopAddPublicLog','%s')" %(e,e,currentDT,userid)
            iTopOperations.updateDBaaS(query)

    def iTopGetStatus(iTopID, userid):
        obj=environments()
        env=obj.environment()
        currentDT = str(datetime.datetime.utcnow())
        try:
            uri=(env+'json_data={"operation":"core/get", "class":"UserRequest","key":"SELECT UserRequest WHERE friendlyname=\'%s\'", "output_fields":"id, friendlyname, status"}' % (iTopID)) 
            res=requests.post(uri,verify=False)
            jdata=json.loads(res.text)
            return jdata
        except:
            e="{}".format(sys.exc_info()[0])
            e=e.replace("'","*")
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopGetStatus','%s')" %(e,e,currentDT,userid)
            iTopOperations.updateDBaaS(query)



    def iTopBackupOperations():     
        currentDT = str(datetime.datetime.utcnow())
        myclass = backup.newBackupRequest()
        ##############################################
        ## create ticket for submitted\new requests ##
        ##############################################
        for i, row in enumerate(myclass.getBackupRequest('submitted')):
            # create ticket in iTop
            data=iTopOperations.iTopCreatnewTicket(row['emailaddress'], row['servername'],row['databasename'], 'Database Support US OP (SQL)','Backup',row['userid'])
            # update status in database
            if(data['code']==0):
                try:
                    for k,v in data.get('objects').items():                        
                        itop=(data.get('objects').get(k).get('fields').get('friendlyname'))
                        status=(data.get('objects').get(k).get('fields').get('status'))
                        #update status in database
                        query="update dbs.backup_requests set itopid='{}', status='{}', lastupdated='{}' where requestid = '{}';".format(itop,status,currentDT,row['requestid'])
                        # add log
                        query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','created itop ticket: {}','{}')".format(row['requestid'],itop, currentDT )                        
                        iTopOperations.updateDBaaS(query)
                except:
                    e="{}".format(sys.exc_info()[0])
                    e=e.replace("'","*")
                    query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations','%s')" %(e,e,currentDT,row['userid'])
                    iTopOperations.updateDBaaS(query)
            if(data['code']!=0):
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations','%s')" %(data,'Error',currentDT,row['userid'])
                iTopOperations.updateDBaaS(query)

        ################################################################################################################
        # update ticket to assign if status changed to new and changed to awaiting approval if manager approval needed #
        ################################################################################################################
        for i, row in enumerate(myclass.getBackupRequest('new')):
            # create tickets
            try:
                if(row['managerapprovalrequired']=='no'):
                    data=iTopOperations.iTopAssignTicket(row['itopid'],row['userid'])
                    if(data['code']==0):
                        for k,v in data.get('objects').items():                        
                            itop=(data.get('objects').get(k).get('fields').get('friendlyname'))
                            status=(data.get('objects').get(k).get('fields').get('status'))
                            #update status in database
                            query="update dbs.backup_requests set status='{}', lastupdated='{}' where requestid = '{}';".format(status,currentDT,row['requestid'])
                            # add log
                            query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','Ticket has been assigned: {}','{}')".format(row['requestid'],itop, currentDT )                        
                            iTopOperations.updateDBaaS(query)
                            iTopOperations.iTopAddPublicLog(row['itopid'], 'Ticket Assigned', row['userid'])
                    if(data['code']!=0):
                        query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations->new','%s')" %(data,'Error',currentDT,row['userid'])
                        iTopOperations.updateDBaaS(query)
                elif(row['managerapprovalrequired']=='yes'):
                    data=iTopOperations.iTopWaitForApproval(row['itopid'], row['manageremail'],row['userid'])
                    if(data['code']==0):
                        for k,v in data.get('objects').items():                        
                            itop=(data.get('objects').get(k).get('fields').get('friendlyname'))
                            status=(data.get('objects').get(k).get('fields').get('status'))
                            #update status in database
                            query="update dbs.backup_requests set status='{}', lastupdated='{}' where requestid = '{}';".format(status,currentDT,row['requestid'])
                            # add log
                            query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','Ticket has been changed to awaiting approval: {}','{}')".format(row['requestid'],itop, currentDT )                        
                            iTopOperations.updateDBaaS(query)
                    if(data['code']!=0):
                        query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations->managerapprovalyes','%s')" %(data,'Error',currentDT,row['userid'])
                        iTopOperations.updateDBaaS(query)
            except:
                e="{}".format(sys.exc_info()[0])
                e=e.replace("'","*")
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->assigned','%s')" %(e,e,currentDT,row['userid'])
                iTopOperations.updateDBaaS(query)


        #########################################################################################
        # If status changed from waiting_for_approval to approved                               #
        #########################################################################################

        for i, row in enumerate(myclass.getBackupRequest('waiting_for_approval')):
            data=iTopOperations.iTopGetStatus(row['itopid'], row['userid'])

            if(data['code']==0):
                try:
                    for k,v in data.get('objects').items():
                        status=(data.get('objects').get(k).get('fields').get('status'))
                        if(status=='approved'):
                            #update status to approved in database
                            query="update dbs.backup_requests set status='{}', lastupdated='{}' where requestid = '{}';".format(status,currentDT,row['requestid'])
                            # add log
                            query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','approved: {}','{}')".format(row['requestid'],row['itopid'], currentDT )                        
                            iTopOperations.updateDBaaS(query)
                            iTopOperations.iTopAddPublicLog(row['itopid'], 'Ticket Approved', row['userid'])
                            #Assign ticket after approval
            

                        if(status=='rejected'):
                            #update status to approved in database
                            query="update dbs.backup_requests set status='{}', lastupdated='{}' where requestid = '{}';".format(status,currentDT,row['requestid'])
                            # add log
                            query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','Rejected: {}','{}')".format(row['requestid'],row['itopid'], currentDT )                        
                            iTopOperations.updateDBaaS(query)
                            iTopOperations.iTopAddPublicLog(row['itopid'], 'Ticket Rejected', row['userid'])
                            #Assign ticket after approval
            
                            
                except:
                    e="{}".format(sys.exc_info()[0])
                    e=e.replace("'","*")
                    query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations','%s')" %(e,e,currentDT,row['userid'])
                    iTopOperations.updateDBaaS(query)
            if(data['code']!=0):
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations->waiting_for_approval','%s')" %(data,'Error',currentDT,row['userid'])
                iTopOperations.updateDBaaS(query)

        #########################################################################################
        # If status changed from approved then reset status to assigned             #
        #########################################################################################

        for i, row in enumerate(myclass.getBackupRequest('approved')):
            data=iTopOperations.iTopGetStatus(row['itopid'], row['userid'])
            if(data['code']==0):
                try:
                    for k,v in data.get('objects').items():
                        status=(data.get('objects').get(k).get('fields').get('status'))
                        iTopOperations.iTopAssignTicket(row['itopid'],row['userid'])
                        query="update dbs.backup_requests set status='{}', lastupdated='{}' where requestid = '{}';".format(status,currentDT,row['requestid'])
                        # add log
                        query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','Ticket has been assigned: {}','{}')".format(row['requestid'],row['itopid'], currentDT )                        
                        iTopOperations.updateDBaaS(query)
                        iTopOperations.iTopAddPublicLog(row['itopid'], 'Ticket Assigned', row['userid'])
                except:
                    e="{}".format(sys.exc_info()[0])
                    e=e.replace("'","*")
                    query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations','%s')" %(e,e,currentDT,row['userid'])
                    iTopOperations.updateDBaaS(query)
            if(data['code']!=0):
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations->approved','%s')" %(data,'Error',currentDT,row['userid'])
                iTopOperations.updateDBaaS(query)

        ######################################################################################################
        # If status is assigned then start the backup if execution date is equal or greater than current date#
        ######################################################################################################

        for i, row in enumerate(myclass.getBackupRequest('assigned')):
            data=iTopOperations.iTopGetStatus(row['itopid'], row['userid'])
            if(data['code']==0):
                try:
                    for k,v in data.get('objects').items():
                        status=(data.get('objects').get(k).get('fields').get('status'))
                        iTopOperations.iTopAssignTicket(row['itopid'],row['userid'])
                        query="update dbs.backup_requests set status='queued', lastupdated='{}' where requestid = '{}';".format(currentDT,row['requestid'])
                        # add log
                        query=query+"insert into dbs.request_log(requestid, comments,datetimeadded) values ('{}','Ready for backup: {}','{}')".format(row['requestid'],row['itopid'], currentDT )                        
                        iTopOperations.updateDBaaS(query)
                        iTopOperations.iTopAddPublicLog(row['itopid'], 'Ready for backup', row['userid'])
                except:
                    e="{}".format(sys.exc_info()[0])
                    e=e.replace("'","*")
                    query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations','%s')" %(e,e,currentDT,row['userid'])
                    iTopOperations.updateDBaaS(query)
            if(data['code']!=0):
                query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopBackupOperations->assigned','%s')" %(data,'Error',currentDT,row['userid'])
                iTopOperations.updateDBaaS(query)

    def iTopResolved(iTopID):
        obj=environments()
        env=obj.environment()
        currentDT = str(datetime.datetime.utcnow())
        try:
            uri=(env+'json_data={"operation":"core/update", "comment":"DBLOG", "class":"UserRequest","key":"SELECT UserRequest WHERE friendlyname=\'%s\'", "output_fields":"id, friendlyname, status","fields":{"status":"resolved"}}' % (iTopID)) 
            res=requests.post(uri,verify=False)
            jdata=json.loads(res.text)
            return jdata
        except:
            e="{}".format(sys.exc_info()[0])
            e=e.replace("'","*")
            query="insert into RTM.apperrors(errormessage, errorstack, errordate, errorsource, userid) values ('%s','%s','%s','iTopOperation->iTopResolve','%s')" %(e,e,currentDT,userid)
            iTopOperations.updateDBaaS(query)
                


    def updateDBaaS(query):
        
        cs = connectionstring()
        Database.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        with cursorfromconnectionpool() as cursor:  
            print(query)             
            cursor.execute(query);


    
#it= iTopOperations()
##print(it.startBackup(it.getListOfQueuedBackups))
#iTopOperations.updateDBaaS('Select getdate()')
