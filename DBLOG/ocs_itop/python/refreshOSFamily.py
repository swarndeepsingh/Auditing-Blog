from getdata import getdata 
from queries import queries
import datetime
import requests
import json
import sys
from writeevents import logs

class iTopOperations:
	
		
	def getNewOSFamilies():
	
		# compulsory for each function in this project##
		func="getNewOSFamilies" # Enter function name here
		
		# END #
		
		i=0
		
		
		# create object to get scripts
		gd=getdata()
		qr=queries()
		query=qr.query()
		# get environment name
		env=qr.environment();
		
		# go through each row in result of query
		for row in gd.load_from_db(qr.query()['osfamily']):
			
			# get list from iTop that matches the row mentioned above
			uri=(env+'json_data={"operation": "core/get", "class": "OSFamily", "key":"SELECT OSFamily WHERE name=\'' + row['OSFamily'] + '\'", "output_fields": "id, friendlyname"}')
			response=requests.post(uri)
			
			# convert to json
			jsondata=json.loads(response.text)
			
			# if no errors only then continue else print error
			if (jsondata['code']==0):
				# if record not available then create new record in iTop
				
				if(jsondata['message']=='Found: 0'):
					# create new osfamily
					uri_newosfamily=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"OSFamily", "fields" : {"name":"' + row['OSFamily'] + '"}}')
					
					try:
						# try posting data
						res=requests.post(uri_newosfamily)
						jdata=json.loads(res.text)
						if(jdata['code']==0):
							i=i+1
							print("Object Created: {}".format(row['OSFamily']))
							logs.writelog(func, "Object Created: {}".format(row['OSFamily']))	
						
					except:
						logs.writelog(func, res.text)
						print("Failed")
				
			else:	
				logs.writelog(func, response.text)
				print("Error Occurred")
		if(i==0):
			logs.writelog(func, 'Objects already synchronized')	


