USE [awsec2auditing]
GO

if not exists (select 1 from sys.objects where name ='audittracker')
begin
    CREATE TABLE [dbo].[audittracker](
        [auditbatchid] [int] IDENTITY(1,1) NOT NULL,
        [eventbegin] [datetime2](7) NULL,
        [eventend] [datetime2](7) NULL,
        [numberofrows] [bigint] NULL,
        [processedtime] [datetime] NULL,
    PRIMARY KEY CLUSTERED 
    (
        [auditbatchid] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
    GO
end
go