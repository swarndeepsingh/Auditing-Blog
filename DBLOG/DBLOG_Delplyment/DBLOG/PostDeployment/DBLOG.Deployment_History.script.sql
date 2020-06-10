/* Add Deployment History*/
INSERT INTO DBLOG.DBLOG.Deployment_History
select GETDATE(), HOST_NAME(), SUSER_NAME(), '0'
GO

