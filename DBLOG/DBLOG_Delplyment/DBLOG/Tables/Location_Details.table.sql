CREATE TABLE [DBLog].[Location_Details] (
    [LocationID]   INT            NOT NULL,
    [LocationPath] VARCHAR (4000) NOT NULL,
    [ISMapped]     BIT            NOT NULL,
    [MapName]      VARCHAR (50)   NULL,
    [UserName]     VARCHAR (500)  NULL,
    [Pword]        VARCHAR (8000) NULL
);

