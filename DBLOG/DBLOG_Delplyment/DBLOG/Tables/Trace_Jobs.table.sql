CREATE TABLE [DBLog].[Trace_Jobs] (
    [Tracename]  VARCHAR (255) NOT NULL,
    [SPName]     VARCHAR (255) NOT NULL,
    [Active]     BIT           NOT NULL,
    [CreateDate] DATETIME      NOT NULL
);

