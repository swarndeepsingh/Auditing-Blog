CREATE TABLE [DBLog].[Trace_Properties] (
    [TraceName]         VARCHAR (255) NOT NULL,
    [PropertyName]      VARCHAR (255) NOT NULL,
    [PropertyValue]     VARCHAR (255) NOT NULL,
    [User_Configurable] INT           NOT NULL,
    [Description]       VARCHAR (256) NOT NULL
);

