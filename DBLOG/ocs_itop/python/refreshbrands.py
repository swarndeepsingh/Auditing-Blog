from getdata import getdata 
from queries import queries
import datetime
import requests
import json
import sys
from writeevents import logs

class iTopOperations:		
	def getbrands():
	
		# compulsory for each function in this project##
		func="iTopOperations.getbrands()" 
		# END #		
		i=0		
		# create object to get scripts
		gd=getdata()
		qr=queries()
		query=qr.query()
		# get environment name
		env=qr.environment();
		
		# go through each row in result of query
		for row in gd.load_from_db(qr.query()['brands']):
			# get list from iTop that matches the row mentioned above
			uri=(env+'json_data={"operation": "core/get", "class": "Brand", "key":"SELECT Brand WHERE name=\'' + row['Brand'] + '\'", "output_fields": "id, friendlyname"}')
			response=requests.post(uri)
			
			# convert to json
			jsondata=json.loads(response.text)
			
			# if no errors only then continue else print error
			if (jsondata['code']==0):
				# if record not available then create new record in iTop
				
				if(jsondata['message']=='Found: 0'):
					# create new Object
					uri_obj=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"Brand", "fields" : {"name":"' + row['Brand'] + '"}}')
					
					try:
						# try posting data
						res=requests.post(uri_obj)
						jdata=json.loads(res.text)
						if(jdata['code']==0):
							i=i+1
							print("Object Created: {}".format(row['Brand']))
							logs.writelog(func, "Object Created: {}".format(row['Brand']))	
						
					except:
						logs.writelog(func, res.text)
						print("Failed")
				
			else:	
				logs.writelog(func, response.text)
				print("Error Occurred")
		if(i==0):
			logs.writelog(func, 'Objects already synchronized')	


