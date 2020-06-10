CREATE TABLE [DBLog].[Report_Properties] (
    [ReportName]      VARCHAR (255)  NOT NULL,
    [PropertyName]    VARCHAR (255)  NOT NULL,
    [PropertyValue]   VARCHAR (8000) NOT NULL,
    [AdditionalValue] VARCHAR (500)  NULL,
    [MoreValue]       VARCHAR (500)  NULL,
    [Description]     VARCHAR (256)  NOT NULL
);

