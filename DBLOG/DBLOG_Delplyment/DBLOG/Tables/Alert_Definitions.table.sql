CREATE TABLE [DBLog].[Alert_Definitions] (
    [AlertID]            INT            IDENTITY (1, 1) NOT NULL,
    [AlertName]          VARCHAR (50)   NOT NULL,
    [Enabled]            BIT            NOT NULL,
    [AlertType]          VARCHAR (500)  NOT NULL,
    [DateAdded]          DATETIME       NOT NULL,
    [AlertQuery_Type]    VARCHAR (50)   NOT NULL,
    [AlertTable]         VARCHAR (500)  NULL,
    [AlertColumn]        VARCHAR (500)  NULL,
    [AlertQuery]         VARCHAR (MAX)  NOT NULL,
    [AlertMethod]        VARCHAR (50)   NULL,
    [EmailProfileID]     INT            NOT NULL,
    [EmailProfile]       VARCHAR (500)  NOT NULL,
    [AlertFrom]          VARCHAR (500)  NULL,
    [AlertRecipients]    VARCHAR (8000) NULL,
    [AlertSubject_Query] VARCHAR (2000) NULL,
    [AlertBody_Query]    VARCHAR (2000) NULL,
    [AlertGap_minutes]   INT            NULL,
    [MaxAlerts]          INT            NULL,
    [createdBy]          VARCHAR (500)  NULL
);



