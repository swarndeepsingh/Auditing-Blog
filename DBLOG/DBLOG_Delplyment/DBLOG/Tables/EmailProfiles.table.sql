CREATE TABLE [DBLog].[EmailProfiles] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [Recipients]      VARCHAR (MAX) NOT NULL,
    [From_Email]      VARCHAR (100) NOT NULL,
    [Profile]         VARCHAR (100) NOT NULL,
    [AlertPermission] CHAR (1)      NOT NULL,
    [Active]          CHAR (1)      NOT NULL
);



