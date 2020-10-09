/*:setvar DBAUDITNAME "chcDBaudit"
:setvar SERVERAUDIT "chcmasteraudit"
:setvar AUDITEDDB "DBToAudit"
*/
/* 
USE master
GO
IF NOT EXISTS(select * from sys.database_audit_specifications where name='$(DBAUDITNAME)')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION $(DBAUDITNAME)
    FOR SERVER AUDIT $(SERVERAUDIT)
    ADD (INSERT ON DATABASE::$(AUDITEDDB) BY [public])
    WITH (STATE = ON)
END
GO
 */

use master;

declare @script varchar(max)
set @script =''
select @script = @script + ''


use master;
set nocount on
 
declare @batchscript varchar(max)
set @batchscript = ''
select @batchscript = @batchscript + 'use [' + name + '];' + char(10) +
'create database audit specification [$(DBAUDITNAME)_' + name + ']' + char(10) + 'for server audit [$(SERVERAUDIT)]' + char(10) +
'add (select, insert, update, delete, execute, receive, references on database::' + name + ' by public)' + char(10) + 'with (state = on);' + char(10) + char(10)
from sys.databases where name not in ('master', 'model', 'msdb', 'tempdb')
 
exec (@batchscript) 