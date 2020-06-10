CREATE TABLE [DBLog].[JobFailuresSP_LastRun] (
    [RunTimeId]     INT                IDENTITY (1, 1) NOT NULL,
    [SPLastRunTime] DATETIMEOFFSET (7) NOT NULL
);

