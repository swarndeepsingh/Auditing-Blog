from copyfile import copyfile
import sys
import sqlalchemy as sa


# get command line parameters
servername= (sys.argv[1])

cp=copyfile()
#setup connection
engine = sa.create_engine('mssql+pymssql://%s' %(servername))
with engine.connect() as con:
    sqlscript="""select jb.Transfer_ID transferid, jb.Source [source], jb.Destination [destination], @@SERVERNAME [server], ld.UserName [user],
convert(varchar,DECRYPTBYPASSPHRASE(mp.Propertyvalue,ld.pword)) [passwd]
from dblog.dblog.backup_transfer_job jb
inner join dblog.dblog.Backup_info bi
	on bi.Backup_ID = jb.Backup_ID
inner join dblog.dblog.Location_Details ld
	on ld.LocationID = jb.DestinationLocationID
inner join dblog.dblog.MiscProperties mp
	on PropertyName = 'Location_Password_1'	
where jb.Status='transferring'
order by jb.Transfer_ID asc"""
    rs=con.execute(sqlscript)
    for row in rs:
        cp.refreshcopy(row['transferid'],  servername, row['source'], row['destination'], row['user'], row['passwd'])
