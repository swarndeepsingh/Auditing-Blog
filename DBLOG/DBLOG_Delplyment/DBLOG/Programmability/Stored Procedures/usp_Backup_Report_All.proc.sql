
CREATE proc [DBLog].[usp_Backup_Report_All] @StartDate datetime, @endDate datetime, @emailprofileID varchar(10)
as
declare @tableHTML varchar(max),  @tableHTML1 varchar(max),@html nvarchar(max), @Recipients varchar(max)
, @from varchar(100), @Profile varchar(100), @subject varchar(500)
set @tableHTML='
<style>
html {font: 12px arial, helvetica;}
body {
font: normal 11px auto "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
color: #4f6b72;
background: #E6EAE9;
}

P
{
        font-family: ''Trebuchet MS'', ''Arial'', ''Sans-Serif'';
        font-size: 10pt;
        color: #000066;
        position: relative;
}
table {background-color: white;font-size: 12px;width:100%;border: 1px solid #444;color: #808000;word-break:break-all;word-wrap:break-word}

TH
{
        font-family: ''Trebuchet MS'', ''Arial'', ''Sans-Serif'';
        font-size: 8pt;
        font-weight: bold;
        color: #ffffff;
        background: #687684;
}
TR
{
        font-family: ''Trebuchet MS'', ''Arial'', ''Sans-Serif'';
        font-size: 10pt;
        font-weight: bold;
        color: #000066;
        /*background: #330033;*/

}
TD
{
        font-family: ''Trebuchet MS'', ''Arial'', ''Sans-Serif'';
        font-size: 8pt;
        color: #000066;
        /*background: #FFFFFF;*/

}

.trSty{
    background-color: expression((this.sectionRowIndex%2==0) ? "#F9FEFF" : "#FFFFFF")
}
</style>

<HTML><P> Daily Backup Report between ' +cast(@StartDate as varchar(40)) + ' and ' + cast(@endDate as varchar(40)) +'</P> <Table border="1"> 


<tr>
<th>Backup Job ID</th>
<th>Backup Date</th>
<th>Frequency</th>
<th>Type</th>
<th>Server</th>
<th>Database</th>
<th>Duration(Min.)</th>
<th>Local File</th>
<th align = right>Backup Size(KB)</th>' + 
CAST ((select
td=a.Backup_Job_ID,'',  
td=convert(varchar(30),a.Backup_Start_Time,120), '',  
td=ISNULL(b.[description],'Not Defined'),'',
td= case BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end, '',
td=a.ServerName, '',  
td=a.DBName, '', 
--Following will convert td to td align=right, enjoy!!
(SELECT 'right' AS '@align',DATEDIFF(Minute,a.Backup_Start_Time,a.Backup_End_Time) AS 'data()' for XML path('td'),type),
td=a.[FileName], '',  
(SELECT 'right' AS '@align',REPLACE(CONVERT(NVARCHAR, CONVERT(MONEY, isnull(a.FileSizeKB,0)), 1), '.00', '') AS 'data()' for XML path('td'),type)
--td=REPLACE(CONVERT(NVARCHAR, CONVERT(MONEY, isnull(a.FileSizeKB,0)), 1), '.00', ''),''
 from dblog.backup_all_info a 
 left outer join DBLog.FrequencyInfo b with (nolock)
	on a.FrequencyName = b.frequencyName
where a.status in ('Completed', 'Started') and Backup_Start_Time between @StartDate and @endDate
for XML PATH ('tr'), TYPE) as NVARCHAR(MAX))    
+N'</Table>'


set @tableHTML1='<P> Failed Backup Report</P> <Table border="1"> 
<tr>
<th>Backup Job ID</th>
<th>Backup Date</th>
<th>Frequency</th>
<th>Type</th>
<th>Server</th>
<th>Database</th>
<th>Status</th>' + 
CAST ((select
td=a.Backup_Job_ID,'',  
td=convert(varchar(30),a.Backup_Start_Time,120), '',  
td=ISNULL(b.[description],'Not Defined'),'',
td= case BackupType when 'D' then 'L0' when 'I' then 'L1' when 'L' then 'L2' end, '',
td=a.ServerName, '',  
td=a.DBName, '', 
td=a.status, ''
 from dblog.backup_all_info a 
left outer join DBLog.FrequencyInfo b with (nolock)
	on a.FrequencyName = b.frequencyName
join dblog.Alert_Events c
	on a.Backup_Job_ID = c.Ref_ID
	and c.AlertTable = 'dblog.Backup_all_info' 
	and c.alertcolumn ='Backup_Job_id' 
	and c.Alert_Status ='Open'
where a.status not in( 'Completed', 'Started')
for XML PATH ('tr'), TYPE) as NVARCHAR(MAX))    
+N'</Table></HTML>' 


set @html=isnull(@tableHTML,'<P>No Backup History Found</P>')
+isnull(@tableHTML1,'<P>No Failed Backups found</P>')

select @Recipients = Recipients , @from =From_email, @Profile  = Profile
from dblog.EmailProfiles with (NOLOCK) where ID=@emailprofileID



 set @subject = 'Daily Backup Report for ' + @@SERVERNAME + ' between ' +cast(@StartDate as varchar(40)) + ' and ' + cast(@endDate as varchar(40))
 
 
-- set @html = REPLACE(@html,'<td>','<td align = "right">')
exec msdb.dbo.sp_send_dbmail     
@profile_name=@Profile,    
@recipients=@Recipients,    
@subject=@subject,    
@body_format = 'HTML',    
@body = @html,
@from_address = @from
GO