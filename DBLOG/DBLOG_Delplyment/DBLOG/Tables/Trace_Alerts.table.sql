CREATE TABLE [DBLog].[Trace_Alerts] (
    [TraceName]           VARCHAR (255)  NOT NULL,
    [AlertMethod]         VARCHAR (255)  NOT NULL,
    [Alert_Threshold]     INT            NOT NULL,
    [EmailAlertRecipient] VARCHAR (8000) NOT NULL
);

