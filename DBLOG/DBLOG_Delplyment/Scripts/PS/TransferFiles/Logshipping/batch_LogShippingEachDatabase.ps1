
 cd c:\dblog
 
import-module sqlps

c:\dblog\LogShipping_v2.ps1 -dbname AnnuityTransactions -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;
c:\dblog\LogShipping_v2.ps1 -dbname AnnuityProducts -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;
c:\dblog\LogShipping_v2.ps1 -dbname FeedStaging -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;
c:\dblog\LogShipping_v2.ps1 -dbname Lookups -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;
c:\dblog\LogShipping_v2.ps1 -dbname Security -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;
c:\dblog\LogShipping_v2.ps1 -dbname System -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;
c:\dblog\LogShipping_v2.ps1 -dbname UI -drservername LAAN4DRXSQL01 -sourceservername an3prodsql01;

