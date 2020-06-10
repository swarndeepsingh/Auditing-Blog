from pgdatabase import cursorfromconnectionpool, Database
from pgconnectionstring import connectionstring 
import json
import psycopg2
class newdbrequest:

    def __init__(self, status):
        self.status = status
        

 
    def getdbrequest(self):
        cs = connectionstring()
        Database.initialize(user=cs.user, password=cs.password, database=cs.database, host=cs.host) 
        
        with cursorfromconnectionpool() as cursor:

            query=("select req.id, req.userid, usr.username, req.databasename, req.technology, req.datacenterid, usr.emailaddress from dbs.dbs_requests req"+\
            " join rtm.users usr"+\
	        " on usr.userid = req.userid where status='{}'".format(self.status))
            

            cursor.execute(query);
            
            requests=cursor.fetchall();

            return requests
            
            #print(json.dumps(requests))
            #for row in requests:
            #    print(dict(row))
            #    print(row['databasename'])
            #    #dict_result.append(dict(row))
            ##print(dict_result)

            #datainjson=[json.dumps(dict(record)) for record in cursor]

           
            #datainjson = json.dumps(requests)
            #print(datainjson)


myclass = newdbrequest("New")
# define a dictionary variable
dict_result=[]
for i, row in enumerate(myclass.getdbrequest()):
    print(dict(row));
    print(dict(row)['id'])