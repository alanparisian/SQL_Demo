SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[BLD_WRK_Future_500]

-- =============================================
-- Author:		Alan Lam
-- Create date: 20170318
-- Description:	RAW -> WRK
-- MOD DATE: 
-- =============================================
AS
BEGIN

-- =============================================
-- DROP TABLE
-- =============================================
IF OBJECT_ID('Future_500') IS NOT NULL
DROP TABLE [Future_500]

-- =============================================
-- CREATE TABLE
-- =============================================
CREATE TABLE [Future_500]
(
	   [RowNumber]   INT IDENTITY(1,1)
	  ,[ID]			 INT
      ,[Name]		 VARCHAR(100)
      ,[Industry]	 VARCHAR(100)
      ,[Inception]	 INT
      ,[Employees]   INT
	  ,[State]		 VARCHAR(2)
      ,[City]		 VARCHAR(50)
      ,[Revenue]	 FLOAT --Double precision same as float; alternatively, double precision
      ,[Expenses]	 FLOAT --Double precision same as float; alternatively, double precision
      ,[Profit]		 FLOAT --Double precision same as float; alternatively, double precision
      ,[Growth]		 FLOAT --Double precision same as float; alternatively, double precision
)

-- =============================================
-- TRUNCATE TABLE
-- =============================================
TRUNCATE TABLE [Future_500]

-- =============================================
-- INSERT INTO
-- =============================================
INSERT INTO [Future_500]
(        
	   [ID]
      ,[Name]
      ,[Industry]
      ,[Inception]
      ,[Employees]
      ,[State]
      ,[City]
	  ,[Revenue]
	  ,[Expenses]
      ,[Profit]
	  ,[Growth]
)	

SELECT
	   CAST([ID] AS INT)
      ,[Name]
      ,[Industry]
      ,CAST([Inception] AS INT)
      ,[Employees]
      ,[State]
      ,[City]
	  ,CAST(REPLACE(REPLACE([Revenue], ',',''), '$','')
	   AS FLOAT)
	  ,CAST(REPLACE(REPLACE([Expenses], ',',''), ' Dollars', '')
	   AS FLOAT)
      ,CAST([Profit] AS FLOAT)
	  ,CAST(LEFT(LTRIM(Growth), 
	   CASE WHEN CHARINDEX('%', Growth) - 1 < 0
	   THEN LEN(LTRIM(Growth))
	   ELSE CHARINDEX('%', Growth) - 1 END) 
	   AS FLOAT)

FROM [dbo].[RAW_Future_500]

/* Convert Growth to % */
ALTER TABLE Future_500
ADD Growth_Percent FLOAT

UPDATE Future_500
SET Growth_Percent = Growth/100

/* Identifying missing data */
SELECT *
FROM [DSTraining].[dbo].[Future_500]
WHERE ID = '' OR Name = '' OR Industry = '' OR Inception = '' OR Employees = '' OR State = ''
OR City = '' OR Revenue = '' OR Expenses = '' OR Profit = ''

/* Removing records whose ID = 14, ID = 15, ID = 22*/
DELETE FROM Future_500
WHERE ID = 14 OR ID = 15 or ID = 22

/* Correcting empty states for records whose City = New York or City = San Francisco*/
UPDATE Future_500
SET State = 'NY'
WHERE State = '' AND City = 'New York'

UPDATE Future_500
SET State = 'CA'
WHERE State = '' AND City = 'San Francisco'

/* Correcting Expenses = 0 for record whose ID = 17  */
UPDATE Future_500
SET Expenses = Revenue - Profit
WHERE Expenses = 0 

/* Proxy Employees with industry median for Employees = 0 in Industry Retail in Inception 2012; ID = 3*/
SELECT *
FROM
(
	SELECT ID, Employees, Industry, Inception, 
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Employees) OVER(PARTITION BY Industry, Inception) AS Median_Employees_Ret_2012
	FROM Future_500
	WHERE Employees <> ''
) AS a
WHERE a.Inception = 2012 and a.Industry = 'Retail'
ORDER BY ID, Industry, Inception
/* Median_Employees_Ret_2012 = 28 */

Update Future_500
SET Employees = 28
WHERE ID = 3

/* Proxy Employees with industry median for Employees = 0 in Industry Financial Services in Inception 2010; ID = 332*/
SELECT * 
FROM
(
	SELECT ID, Employees, Industry, Inception, 
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Employees) OVER(PARTITION BY Industry, Inception) AS Median_Employees_FS_2010
	FROM Future_500
	WHERE Employees <> ''
) AS a
WHERE a .Inception = 2010 and a.Industry = 'Financial Services'
ORDER BY ID, Industry, Inception
/* Median_Employees_FS_2010 = 40 */

UPDATE Future_500
SET Employees = 40
WHERE ID = 332

/* Proxy Revenue and Expenses with industry median for Industry Construction in Inception 2013; ID = 8*/

/**** 

EXTRA CODE FOR REFERENCE: Create a table that stores median revenue of the construction industry in 2013 
IF OBJECT_ID('Med_Rev_Con_2013', 'U') IS NOT NULL
DROP TABLE [Med_Rev_Con_2013]

SELECT * 
INTO Med_Rev_Con_2013
FROM
(
SELECT ID, Revenue, Expenses, Industry, Inception,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Revenue) OVER(PARTITION BY Industry, Inception) AS Median_Revenue_Con_2013
FROM Future_500
WHERE Revenue <> ''
) AS a

SELECT a.*, b.Median_Revenue_Con_2013
FROM Future_500 a
LEFT JOIN Med_Rev_Con_2013 b
ON a.ID = b.ID
ORDER BY ID ASC

****/

SELECT * 
FROM
(
	SELECT ID, Revenue, Expenses, Industry, Inception, 
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Expenses) OVER(PARTITION BY Industry, Inception) AS Median_Revenue_Con_2013
	FROM Future_500
	WHERE Revenue <> ''
) AS a
WHERE a .Inception = 2013 and a.Industry = 'Construction'
ORDER BY ID, Industry, Inception

UPDATE Future_500
SET Revenue = 4386023
WHERE ID = 8

SELECT * 
FROM
(
	SELECT ID, Revenue, Expenses, Industry, Inception, 
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Expenses) OVER(PARTITION BY Industry, Inception) AS Median_Expenses_Con_2013
	FROM Future_500
	WHERE Expenses <> ''
) AS a
WHERE a .Inception = 2013 and a.Industry = 'Construction'
ORDER BY ID, Industry, Inception

UPDATE Future_500
SET Expenses = 4498839
WHERE ID = 8

UPDATE Future_500
SET Profit = Revenue - Expenses
WHERE ID = 8

/* Proxy Revenue and Expenses with industry median for Industry Construction in Inception 2010; ID = 44*/
SELECT * 
FROM
(
	SELECT ID, Revenue, Expenses, Industry, Inception, 
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Revenue) OVER(PARTITION BY Industry, Inception) AS Median_Revenue_Con_2010
	FROM Future_500
	WHERE Revenue <> ''
) AS a
WHERE a .Inception = 2010 and a.Industry = 'Construction'
ORDER BY ID, Industry, Inception

UPDATE Future_500
SET Revenue = 8380367
WHERE ID = 44

SELECT * 
FROM
(
	SELECT ID, Revenue, Expenses, Industry, Inception, 
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Expenses) OVER(PARTITION BY Industry, Inception) AS Median_Expenses_Con_2010
	FROM Future_500
	WHERE Expenses <> ''
) AS a
WHERE a .Inception = 2010 and a.Industry = 'Construction'
ORDER BY ID, Industry, Inception

UPDATE Future_500
SET Expenses = 5303734
WHERE ID = 44

UPDATE Future_500
SET Profit = Revenue - Expenses
WHERE ID = 44

END
GO
