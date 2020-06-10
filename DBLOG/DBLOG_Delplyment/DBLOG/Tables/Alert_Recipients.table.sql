CREATE TABLE [DBLog].[Alert_Recipients] (
    [AlertRecipientId] INT          IDENTITY (1, 1) NOT NULL,
    [AlertId]          INT          NOT NULL,
    [EmailProfileId]   INT          NOT NULL,
    [RecipientEmail]   VARCHAR (50) NOT NULL
);

