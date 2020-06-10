import datetime

class logs:
	def writelog( mdl, msg):
		filename = "logs/" + datetime.datetime.now().strftime("%Y%m%d")+"_events.log"
		# added "/"
		file=open(filename,'a')
		date=str(datetime.datetime.now())
		module=mdl
		event=(date+','+module+','+msg+'\n')
		file.write(event)
		file.close()
		print(event)
