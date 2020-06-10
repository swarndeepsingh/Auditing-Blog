from getdata import getdata 
from queries import queries
import datetime
import requests
import json
import sys
from writeevents import logs

class iTopOperations:		
	def setmodels():
	
		# compulsory for each function in this project##
		func="iTopOperations.setmodels()" 
		# END #		
		i=0		
		# create object to get scripts
		gd=getdata()
		qr=queries()
		query=qr.query()
		# get environment name
		env=qr.environment();
		
		# go through each row in result of query
		for a,row in enumerate(gd.load_from_db(qr.query()['models'])):
			
			# get list from iTop that matches the row mentioned above
			
			uri=(env+'json_data={"operation": "core/get", "class": "Model", "key":"SELECT m FROM Model AS m JOIN Brand AS b ON m.brand_id=b.id WHERE m.friendlyname=\'' + row['Model'] + '\' AND b.friendlyname=\''+ row['Brand'] + '\'", "output_fields": "id, friendlyname"}')
			response=requests.post(uri)
			
			# convert to json
			jsondata=json.loads(response.text)
			
			
			# if no errors only then continue else print error
			if (jsondata['code']==0):
				
				
				# if record not available then create new record in iTop
				if(jsondata['message']=='Found: 0'):
					# create new Object
					#uri_obj=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"Model",  "fields" : { "name":"' + row['Model'] + '", "brand_id":{"finalclass":"Brand", "name":"' + row['Brand'] + '"}}}')
					uri_obj=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"Model",  "fields" : { "name":"' + row['Model'] + '", "brand_id":"SELECT Brand WHERE name=\'' + row['Brand'] + '\'","type":"Server"}}')
					
					try:
						# try posting data
						res=requests.post(uri_obj)
						jdata=json.loads(res.text)
						if(jdata['code']==0):
							i=i+1
							print("Object Created: {}".format(row['Model']))
							logs.writelog(func, "Object Created: {}".format(row['Model']))	
						else:
							logs.writelog(func, res.text)
							print(uri_obj)
						
					except:
						msg="{} <<-->> {}".format(res.text,  uri_obj)
						logs.writelog(func, res.text)
						print("Failed")
					
			else:	
				msg="{} <<-->> {}".format(response.text,  uri)
				logs.writelog(func, msg)
				print("Error Occurred")
		if(i==0):
			logs.writelog(func, 'Objects already synchronized')	


