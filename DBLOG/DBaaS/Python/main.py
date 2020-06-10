#main - Backups
from iTopOperations import iTopOperations 
from backupthread import backupOperation

#itop=iTopOperations()
###print(it.startBackup(it.getListOfQueuedBackups))
#itop.iTopBackupOperations()

# Review the backup requests and iTop requests
iTopOperations.iTopBackupOperations()

bo=backupOperation()
#print(bo.getListOfQueuedBackups())

# Start backup request, if there exists one
bo.initiateBackupThreads(bo.getListOfQueuedBackups())
