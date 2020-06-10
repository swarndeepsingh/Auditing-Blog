CREATE TABLE [DBLog].[Alert_Email_Logs] (
    [AlertEmailLogID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Alert_Event_ID]  INT           NULL,
    [RecipientEmail]  VARCHAR (50)  NULL,
    [FromEmail]       VARCHAR (500) NULL,
    [Profile]         VARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([AlertEmailLogID] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF)
);
