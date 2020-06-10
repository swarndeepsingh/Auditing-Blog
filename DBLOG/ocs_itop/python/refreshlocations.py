from getdata import getdata 
from queries import queries
import datetime
import requests
import json
import sys
from writeevents import logs
import re

class iTopOperations:		
	def setlocations():
	
		# compulsory for each function in this project##
		func="iTopOperations.setlocations()" 
		# END #		
			
		# create object to get scripts
		gd=getdata()
		qr=queries()
		query=qr.query()
		# get environment name
		env=qr.environment();
		
		# load sql data
		rows = gd.load_from_db(qr.query()['locations'])
		
		# load itop data in memoryview
		uri=(env+'json_data={"operation": "core/get", "class": "Location", "key":"SELECT Location", "output_fields": "friendlyname"}')
		response=requests.post(uri)
		data=json.loads(response.text)
		# Error retrieval
		if (data['code']!=0):
			msg="{} <<-->> {}".format(response.text,  uri)
			logs.writelog(func, msg)
		elif(data['code']==0):
			mylist=[]
			#a=0
			for k,v in data.get('objects').items():
				mylist.append(data.get('objects').get(k).get('fields').get('friendlyname').upper())
			
			#list of items in OCS but not in iTop
			
			for y in [x for x in rows if str(x['idc']).upper() not in mylist[0:len(mylist)]]:
				
				
				try:
					uri_obj=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"Location", "fields" : {"name":"' + y['idc'] + '","org_id":"SELECT Organization WHERE name=\'' +y['Org'] + '\'"}}')
					
					res=requests.post(uri_obj)
					jdata=json.loads(res.text)
					if(jdata['code']==0):
						msg="Object Created: {}".format(y['idc'])
						logs.writelog(func, msg)
					else:
						logs.writelog(func, res.text)
				except:
					msg="Object Creation failed: {}".format(response.text)
					logs.writelog(func, msg)