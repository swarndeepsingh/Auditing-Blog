create proc DBLOG.usp_getDiskInfo
as
DECLARE @psinfo TABLE(data  NVARCHAR(100)) ;
 declare @drive varchar(10), @freespaceGB numeric(20,2), @totalsize numeric(20,2);
INSERT INTO @psinfo
EXEC xp_cmdshell 'Powershell.exe "Get-WMIObject Win32_LogicalDisk -filter "DriveType=3"| Format-Table DeviceID, FreeSpace, Size"'  ;
DELETE FROM @psinfo WHERE data is null  or data like '%DeviceID%' or data like '%----%';

update @psinfo set data = REPLACE(data,' ',',');
;With DriveSpace as (
 
select SUBSTRING(data,1,2)  as [Drive], replace((left((substring(data,(patindex('%[0-9]%',data)) , len(data))),CHARINDEX(',',
(substring(data,(patindex('%[0-9]%',data)) , len(data))))-1)),',','')
 
as [FreeSpace] , replace(right((substring(data,(patindex('%[0-9]%',data)) , len(data))),PATINDEX('%,%', 
 
(substring(data,(patindex('%[0-9]%',data)) , len(data))))) ,',','')
 
as [Size] from @psinfo
 
) 


SELECT Drive,  convert(dec( 6,2),CONVERT(dec(17,2),FreeSpace)/(1024*1024*1024)) as FreeSpaceGB, 
convert(dec( 6,2),CONVERT(dec(17,2), size)/(1024*1024*1024)) as SizeGB,
cast(convert(dec( 6,2),CONVERT(dec(17,2),FreeSpace)/(1024*1024*1024)) / convert(dec( 6,2),CONVERT(dec(17,2), size)/(1024*1024*1024)) * 100 as int) as FreeSpacePercent
 FROM DriveSpace order by 2 desc; 
GO
