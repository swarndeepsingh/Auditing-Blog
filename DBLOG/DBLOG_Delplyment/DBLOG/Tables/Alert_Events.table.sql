CREATE TABLE [DBLog].[Alert_Events] (
    [Alert_Event_ID]      INT            IDENTITY (1, 1) NOT NULL,
    [Alert_ID]            INT            NOT NULL,
    [Alert_Status]        VARCHAR (50)   NOT NULL,
    [EmailProfileID]      INT            NOT NULL,
    [Alert_From]          VARCHAR (100)  NULL,
    [Alert_Subject_query] VARCHAR (2000) NULL,
    [Alert_Subject]       VARCHAR (2000) NULL,
    [Alert_Body_Query]    VARCHAR (5000) NULL,
    [Alert_Body]          VARCHAR (MAX)  NULL,
    [AlertRecipients]     VARCHAR (8000) NULL,
    [Alert_count]         INT            NULL,
    [Ref_ID]              INT            NOT NULL,
    [AlertTable]          VARCHAR (2000) NOT NULL,
    [AlertColumn]         VARCHAR (2000) NOT NULL,
    [Last_Sent]           DATETIME       NOT NULL,
    [Comments]            VARCHAR (MAX)  NULL
);



