import shutil
import subprocess
import os,datetime, sys
import ntpath
import sqlalchemy as sa

class copyfile:
    def startcopy (self,transferid, sqlserver, src, dest,  username, password):
        sqlscript=["1","2","3"]
               
        
        path, flname=ntpath.split(src)
        destdir, destmainfolder = ntpath.split(dest)

        
        
        try:
            if(len(username)>2):
                winCMD = 'NET USE ' + destdir + ' /User:' + username + ' ' + password
                subprocess.Popen(winCMD, stdout=subprocess.PIPE, shell=True)
        except:
            e="Failed Connecting to network: {}. Error: {}, {}, {}".format(dest, sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
            e=e.replace("'","*")
            print(e)
            sqlscript[2]="""update dblog.dblog.backup_transfer_job
                            set status='failed', message='Failed to connect to %s, %s'
                            where transfer_id=%d
                            """%(destdir,e,transferid)
            self.updatedb(sqlserver, sqlscript[2])
            return


        # create destination directory if does not exists
        if not os.path.exists(dest):
            os.makedirs(dest)
        
        try:
            #print('Started Copying: {}, {}\{}' .format(str(transferid),dest,flname) )
            #Started
            sourcesize=os.stat(src).st_size
            
            sqlscript[0] ="""update dblog.dblog.backup_transfer_job
                            set status='transferring', startdate=getdate(), lastupdated=getdate(), filebytes=%d
                            where transfer_id=%d""" %(sourcesize,transferid)
            
            self.updatedb(sqlserver, sqlscript[0])
            ret=shutil.copy2(src, dest)
            #Completed
            #print('Finished Copying () - {}' .format(ret,flname) )
            sqlscript[1]="""update dblog.dblog.backup_transfer_job
                            set status='completed', enddate=getdate(), message=NULL, bytescompleted=filebytes
                            where transfer_id=%d
                            """%(transferid)
            self.updatedb(sqlserver, sqlscript[1])
        except:
            e="Failed Transferring file: {}. Error: {}, {}, {}".format(flname, sys.exc_info()[0],   sys.exc_info()[1],sys.exc_info()[2])
            e=e.replace("'","*")
            print(e)
            sqlscript[2]="""update dblog.dblog.backup_transfer_job
                            set status='failed', lastupdated=getdate(), message='Failed to transfer to %s, %s'
                            where transfer_id=%d
                            """%(dest,e,transferid)
            self.updatedb(sqlserver, sqlscript[2])
        
        

    def refreshcopy(self,transferid, sqlserver, src, dest,  username, password):
        path, flname=ntpath.split(src)
        if(len(username)>2):
            winCMD = 'NET USE ' + dest + ' /User:' + username + ' ' + password
            subprocess.Popen(winCMD, stdout=subprocess.PIPE, shell=True)
        sourcesize=os.stat(src).st_size
        destsize=os.stat(dest+'\\' + flname).st_size
        sqlscript="""update dblog.dblog.backup_transfer_job
                            set filebytes=%d,  bytescompleted=%d, lastupdated=getdate()
                            where transfer_id=%d
                            """%(sourcesize, destsize, transferid)
        self.updatedb(sqlserver, sqlscript)

    def updatedb (self, servername, script):
        engine=sa.create_engine('mssql+pymssql://%s' %(servername))
        with engine.connect() as con:
            con.execute(script)
             
