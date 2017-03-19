CREATE TABLE [dbo].[D]
(
[RowNumber] [int] NOT NULL IDENTITY(1, 1),
[ID] [int] NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Industry] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inception] [int] NULL,
[Employees] [int] NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Revenue] [float] NULL,
[Expenses] [float] NULL,
[Profit] [float] NULL,
[Growth] [float] NULL,
[Growth_Percent] [float] NULL,
[Profitability_Percent_Industry_Inception] [float] NULL,
[Company_Profitability] [float] NULL,
[Flag_Outperform] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
