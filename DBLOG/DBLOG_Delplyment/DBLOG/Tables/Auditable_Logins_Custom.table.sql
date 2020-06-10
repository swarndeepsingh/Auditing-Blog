CREATE TABLE [DBLog].[Auditable_Logins_Custom] (
    [AccountName] VARCHAR (500) NOT NULL,
    [user_type]   VARCHAR (25)  NULL,
    [priviege]    VARCHAR (25)  NULL,
    [mappedlogin] VARCHAR (500) NULL,
    [groupname]   VARCHAR (500) NULL
);

