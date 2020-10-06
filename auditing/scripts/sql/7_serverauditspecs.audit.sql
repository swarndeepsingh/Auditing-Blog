/*
:setvar serverauditspec "serverauditing"
:setvar SERVERAUDIT "serverauditname"
*/
USE [master]
GO
if not exists(select * from sys.server_audit_specifications where name='$(serverauditspec)')
begin
    CREATE SERVER AUDIT SPECIFICATION $(serverauditspec)
    FOR SERVER AUDIT $(SERVERAUDIT)
    ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
    ADD (SERVER_PERMISSION_CHANGE_GROUP),
    ADD (FAILED_LOGIN_GROUP),
    ADD (SERVER_PRINCIPAL_CHANGE_GROUP)
    WITH (STATE = ON)
end
GO


