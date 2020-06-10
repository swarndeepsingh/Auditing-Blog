CREATE TABLE [DBLog].[Alert_Subscription] (
    [SubscriptionID] INT            IDENTITY (1, 1) NOT NULL,
    [EmailProfileID] INT            NOT NULL,
    [AlertID]        INT            NOT NULL,
    [AddedBy]        VARCHAR (8000) NOT NULL,
    [LastUpdated]    DATETIME       NOT NULL
);

