from getdata import getdata 
from queries import queries
import datetime
import requests
import json
import sys
from writeevents import logs

class iTopOperations:		
	def setvmhosts():
		objcount=0
		# compulsory for each function in this project##
		func="iTopOperations.setvhosts()" 
		# END #		
			
		# create object to get scripts
		gd=getdata()
		qr=queries()
		query=qr.query()
		# get environment name
		env=qr.environment();
		
		# load sql data
		rows = gd.load_from_db(qr.query()['virtualhosts'])
		
		# load itop data in memoryview
		uri=(env+'json_data={"operation": "core/get", "class": "Location", "key":"SELECT Hypervisor", "output_fields": "friendlyname"}')
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
			for y in [x for x in rows if str(x['vmhost']).upper() not in mylist[0:len(mylist)]]:
				objcount=objcount+1
				#uri_obj=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"Hypervisor", "fields" : {"name":"' + y['vmhost'] + '","org_id":"SELECT Organization WHERE name=\''+y['Organization']+'\'", "status":"production","business_criticity":"\''+y['businesscriticity']+'\'","server":"SELECT Server WHERE name=\''+ y['vmhost'] +'\'"}}') 
				#print(uri_obj)
				#return
				try:
					uri_obj=(env+'json_data={"operation":"core/create", "comment":"Created by itop synch process: swarndeep", "class":"Hypervisor", "fields" : {"name":"' + y['vmhost'] + '","org_id":"SELECT Organization WHERE name=\''+y['Organization']+'\'", "status":"production","business_criticity":"'+y['businesscriticity']+'","server_id":"SELECT Server WHERE name=\''+ y['vmhost'] +'\'"}}') 
					
					res=requests.post(uri_obj)
					jdata=json.loads(res.text)
					if(jdata['code']==0):
						msg="Object Created: {}".format(y['vmhost'])
						logs.writelog(func, msg)
					else:
						logs.writelog(func, res.text)
						print(uri_obj)
				except:
					msg="Object Creation failed: {}".format(res.text)
					logs.writelog(func, msg)
			if (objcount==0):
				msg="Object already synchronized"
				logs.writelog(func, msg)