CREATE procedure [DBLog].[usp_ftp_PutFile]
/*@ftp_id int,
@FTPServer	varchar(128) ,
@FTPUser	varchar(128) ,
@FTPPWD		varchar(128) ,
@FTPPath	varchar(128) ,
@FTPFileName	varchar(128) ,

@SourcePath	varchar(128) ,
@SourceFile	varchar(128) ,

@workdir	varchar(128)*/
as


/*
exec s_ftp_PutFile 	
		@FTPServer = 'myftpsite' ,
		@FTPUser = 'username' ,
		@FTPPWD = 'password' ,
		@FTPPath = '/dir1/' ,
		@FTPFileName = 'test2.txt' ,
		@SourcePath = 'c:\vss\mywebsite\' ,
		@SourceFile = 'MyFileName.html' ,
		
		@workdir = 'c:\temp\'
*/

declare	@cmd varchar(1000), @ftp_upload_id int, @ftpjobid int
declare 
@FTPServer	varchar(128) ,
@FTPUser	varchar(128) ,
@FTPPWD		varchar(128) ,
@FTPPath	varchar(128) ,
@FTPFileName	varchar(128) ,

@SourcePath	varchar(128) ,
@SourceFile	varchar(128) ,

@workdir	varchar(128), 
@locationid int,
@bcp_id int,
@ftp_id int

declare @workfilename varchar(128),@logfilename varchar(128)

declare ftp_upload cursor FOR
select FTP_Job_ID from dblog.ftp_jobs with (NOLOCK) 
where ftp_status ='Pending'  order by ftp_job_id

-- Get the first pending FTP JOB ID
-- select top 1 @ftpjobid = FTP_Job_ID from dblog.ftp_jobs with (NOLOCK) where ftp_status ='Pending'  order by ftp_job_id

OPEN ftp_upload

FETCH NEXT FROM ftp_upload
into @ftpjobid
	WHILE @@FETCH_STATUS = 0
	BEGIN
			if @ftpjobid is null
				goto NOFile

			-- Populate variables
			select @FTPServer = c.ftp_server, @FTPUser = c.ftp_user_name, @FTPPath = c.FTP_Path,
			@workdir = work_folder, @bcp_id = b.bcp_id, @ftp_id = c.ftp_id, @locationid = b.bcp_location_id
			, @SourceFile = b.BCP_File
			from dblog.ftp_jobs a with (NOLOCK)
			join dblog.bcp_info b with (NOLOCK)
				on a.bcp_id = b.bcp_id
			join dblog.ftp_info c with (NOLOCK)
				on a.ftp_id = c.ftp_id
			where ftp_job_id = @ftpjobid

			select @workfilename = '\ftpSmartMonitor_' + cast(@ftpjobid as varchar(5))+ '.hid'
			select @logfilename = '\ftpSmartMonitor_' + cast(@ftpjobid as varchar(5))+ '.log'

			/*
			select @FTPServer , @FTPUser, @FTPPath ,
			@workdir , @bcp_id , @ftp_id , @locationid 
			, @SourceFile , @workfilename
			*/

			-- Map and set the source file path
			exec DBLog.usp_MapLocation @locationID, @SourcePath output


			-- Get FTP Username and password
			declare @pass1 varchar(500)
			declare @DecryptedPassword varchar(50), @encryptedPassword varchar(5000)
			select @pass1= PropertyValue from DBLog.MiscProperties where PropertyName = 'Location_Password_1'


			select @encryptedPassword = a.password from dblog.users a 
				join dblog.users_roles b
					on a.username = b.username
				where a.username =@FTPUser;
				
			set @DecryptedPassword = decryptbypassphrase(@pass1,@encryptedpassword)	

				
			set @FTPPWD = @DecryptedPassword


			-- set up the work file

				
				
				-- deal with special characters for echo commands
				select @FTPServer = replace(replace(replace(@FTPServer, '|', '^|'),'<','^<'),'>','^>')
				select @FTPUser = replace(replace(replace(@FTPUser, '|', '^|'),'<','^<'),'>','^>')
				select @FTPPWD = replace(replace(replace(@FTPPWD, '|', '^|'),'<','^<'),'>','^>')
				select @FTPPath = replace(replace(replace(@FTPPath, '|', '^|'),'<','^<'),'>','^>')
				SELECT @FTPFileName = '/'+@SourceFile
				
				
				
			-- Start Uploading to FTP


				update dblog.ftp_jobs
				set ftp_status = 'Uploading', starttime=GETDATE()
				where ftp_job_id = @ftpjobid;
				
				
				select	@cmd = 'echo '					+ '****Start Uploading*****' + cast(GETDATE() as varchar(50))
						+ ' >> ' + @workdir + @logfilename
				exec master..xp_cmdshell @cmd
				
				
				/*select @cmd = 'echo ' + ' FTP  '
				+ ' > ' + @workdir + @workfilename
				exec master..xp_cmdshell @cmd */
				
				
				select	@cmd = 'echo '					+ 'open ' + @FTPServer
						+ ' > ' + @workdir + @workfilename
				exec master..xp_cmdshell @cmd 
				
				
				select	@cmd = 'echo '					+ @FTPUser
						+ '>> ' + @workdir + @workfilename
				exec master..xp_cmdshell @cmd
				
				
				select	@cmd = 'echo '					+ @FTPPWD
						+ '>> ' + @workdir + @workfilename
				exec master..xp_cmdshell @cmd
				
				
				select	@cmd = 'echo '					+ 'put ' + @SourcePath +'\'+ @SourceFile + ' ' + @FTPPath + @FTPFileName
						+ ' >> ' + @workdir +@workfilename
				exec master..xp_cmdshell @cmd
				
				
				select	@cmd = 'echo '					+ 'quit'
						+ ' >> ' + @workdir + @workfilename
				exec master..xp_cmdshell @cmd
				
				
				
				-- Send the log file to ftp -s command for upload from workfile.
				select @cmd = 'ftp -s:' + @workdir + @workfilename + ' >> ' + @workdir + @logfilename
				print @cmd
				
				exec master..xp_cmdshell @cmd
				
				
				-- Delete the work file
				select @cmd ='del ' + @workdir + @workfilename 
				exec master..xp_cmdshell @cmd
				
				select	@cmd = 'echo '					+ '****End Uploading*****' + cast(GETDATE() as varchar(50))
						+ ' >> ' + @workdir + @logfilename
				exec master..xp_cmdshell @cmd
				
				
				exec dblog.usp_DeleteMapLocation @locationID
				
				
				update dblog.ftp_jobs
				set ftp_status = 'Uploaded', endtime=GETDATE()
				where ftp_job_id = @ftpjobid;
				
				FETCH NEXT FROM ftp_upload
				into @ftpjobid
			END
		CLOSE ftp_upload
		deallocate ftp_upload
		
	
	return
	NoFile:
	print 'No request found for FTP Upload'
