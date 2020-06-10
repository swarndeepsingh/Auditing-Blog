
set identity_insert dblog.dblog.emailprofiles ON
if not exists(select 1 from [DBLog].[EmailProfiles] where ID = 1)
begin
	INSERT [DBLog].[EmailProfiles] (ID,[Recipients],  [Profile]) VALUES (1,N'globalsql@ebix.com;', N'DBAMail')
end
set identity_insert dblog.dblog.emailprofiles OFF

if not exists (select 1 from [DBLog].[Report_Properties] where reportname ='BackupReport_All')
BEGIN
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'SP_Name', N'[dblog].[usp_Backup_Report_All]', NULL, NULL, N'Name of the SP')
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'Parameter', N'1', N'select @param=cast(isnull(MoreValue, getdate()-1) as varchar(100)) from dblog.Report_properties where ReportName = ''BackupReport_All'' and propertyName=''Parameter'' and PropertyValue = ''2''', NULL, N'Value for first parameter')
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'Parameter', N'2', N'select @param=cast(getdate() as varchar(100))', NULL, N'Value for the second parameter')
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'Enabled', N'1', NULL, NULL, N'Enabled = 1 disabled = 1')
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'EmailProfileID', N'1', N'0', N'0', N'Email Profile ID to be used')
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'Report_Min_Gap_Hours', N'24', N'0', N'0', N'Minimum Gap between two reports of same kind')
		INSERT [DBLog].[Report_Properties] ([ReportName], [PropertyName], [PropertyValue], [AdditionalValue], [MoreValue], [Description]) VALUES (N'BackupReport_All', N'Last_Run', N'2000/01/01', N'0', N'0', N'Last time the report ran.')
END