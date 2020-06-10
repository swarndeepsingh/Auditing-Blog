CREATE PROCEDURE [DBLog].[sp_ValidateJobRun]
as
Declare @spname varchar(255), @tracename varchar(255)
declare @sql varchar(500)
Declare Validate_JobRun CURSOR for
Select SPName, tracename from [DBLog].Trace_Jobs  where active=1

	OPEN Validate_JobRun

	Fetch NEXT from Validate_JobRun
	INTO @spname, @tracename

	WHILE @@FETCH_STATUS = 0
	BEGIN

		exec [DBLOG].usp_InitiateTrace @tracename
		Fetch NEXT from Validate_JobRun
		INTO @spname, @tracename
	END
	CLOSE Validate_JobRun
	Deallocate Validate_JobRun