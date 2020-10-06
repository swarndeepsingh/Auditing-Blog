/*:setvar DBAUDITNAME "chcDBaudit"
:setvar SERVERAUDIT "chcmasteraudit"
:setvar AUDITEDDB "DBToAudit"
*/

USE awsec2auditing
GO
IF NOT EXISTS(select * from sys.database_audit_specifications where name='$(DBAUDITNAME)')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION $(DBAUDITNAME)
    FOR SERVER AUDIT $(SERVERAUDIT)
    ADD (INSERT ON DATABASE::$(AUDITEDDB) BY [public])
    WITH (STATE = ON)
END
GO