CREATE TABLE [DBLog].[DBUsage] (
    [CollectionDate] DATETIME      NOT NULL,
    [Servername]     VARCHAR (200) NOT NULL,
    [DatabaseName]   VARCHAR (200) NOT NULL,
    [table_name]     [sysname]     NOT NULL,
    [row_count]      DECIMAL(18,2)           NULL,
    [reserved_size]  DECIMAL(18,2)          NULL,
    [space_used]     DECIMAL(18,2)           NULL
);

