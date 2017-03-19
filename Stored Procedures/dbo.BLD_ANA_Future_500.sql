SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[BLD_ANA_Future_500]

-- =============================================
-- Author:		Alan Lam
-- Create date: 20170318
-- Description:	RAW -> WRK
-- MOD DATE: 
-- =============================================
AS
BEGIN

IF OBJECT_ID('A','U') IS NOT NULL
DROP TABLE A

IF OBJECT_ID('B','U') IS NOT NULL
DROP TABLE B

IF OBJECT_ID('C','U') IS NOT NULL
DROP TABLE C

IF OBJECT_ID('D','U') IS NOT NULL
DROP TABLE D

IF OBJECT_ID('Market_Share','U') IS NOT NULL
DROP TABLE Market_Share


/* 1a. Profit($) by Industry and Inception */
SELECT DISTINCT Industry, Inception, Profit_Industry_Inception
INTO A
FROM
(
SELECT Industry, 
	   Inception,
       SUM(Profit) OVER (PARTITION BY Industry, Inception) AS Profit_Industry_Inception
       FROM [DSTraining].[dbo].[Future_500]
       GROUP BY Industry, Inception, Profit
) AS A
ORDER BY Industry, Inception ASC
--(85 row(s) affected)

/* 1b. Profit($) by Industry, Inception and State*/
SELECT DISTINCT Industry, Inception, State, Profit_Industry_Inception_State
INTO B
FROM
(
SELECT Industry, 
       Inception, 
       State,
       SUM(Profit) OVER (PARTITION BY Industry, Inception, State) AS Profit_Industry_Inception_State
       FROM [DSTraining].[dbo].[Future_500]
       GROUP BY Industry, Inception, State, Profit
) AS B
ORDER BY Industry, Inception, State ASC
--(381 row(s) affected)

/* 1c. Profit($) by Industry, Inception, State and City */
SELECT DISTINCT Industry, Inception, State, City, Profit_Industry_Inception_State_City
INTO C
FROM
(
SELECT *, 
SUM(Profit) OVER (PARTITION BY Industry, Inception, State, City) AS Profit_Industry_Inception_State_City
FROM [DSTraining].[dbo].[Future_500]
) AS C
ORDER BY Industry, Inception, State, City ASC
--(484 row(s) affected)

/* EXTRA CODE FOR REFERENCE:
--Joining the above three tables to show breakdown of profit($) by state, city */

SELECT C.Industry,
	   C.Inception,
	   C.State,
	   C.City,
	   C.Profit_Industry_Inception_State_City,
	   B.Profit_Industry_Inception_State,
	   A.Profit_Industry_Inception
FROM C
LEFT JOIN B
ON C.Industry = B.Industry AND C.Inception = B.Inception AND C.State = B.State
LEFT JOIN A
ON C.Industry = A.Industry AND C.Inception = A.Inception
-- (484 row(s) affected)


/* 2a. Comparison of company profitability to industry profitability(%) (by Industry, Inception, State and City)*/
SELECT *, 
ROUND(SUM(Profit) OVER (PARTITION BY Industry, Inception, State, City)/SUM(Revenue) OVER (PARTITION BY Industry, Inception, State, City), 4) AS Profitability_Percent_Industry_Inception_State_City,
ROUND(Profit/Revenue, 4) AS Company_Profitability
FROM [DSTraining].[dbo].[Future_500]
ORDER BY Company_Profitability, Profitability_Percent_Industry_Inception_State_City DESC
-- Not very meaningful due to small amount of company inceptions in any particular years by industry, state, city. Try to aggregate the industry profitability further below.
-- (497 row(s) affected)

/* 2b. Comparison of company profitability to industry profitability(%) (by Industry, Inception)*/
SELECT * 
INTO D
FROM(SELECT *,
ROUND(SUM(Profit) OVER (PARTITION BY Industry, Inception)/SUM(Revenue) OVER (PARTITION BY Industry, Inception), 4) AS Profitability_Percent_Industry_Inception,
ROUND(Profit/Revenue, 4) AS Company_Profitability
FROM [DSTraining].[dbo].[Future_500]) AS D
ORDER BY Company_Profitability, Profitability_Percent_Industry_Inception DESC
-- A quick scan of the result reveals many company profitabilities are different from industry profitabilities. Next flag those companies which outperform the industry profitability
-- (497 row(s) affected)

/* 2c. Flag outperforming companies */
ALTER TABLE D
ADD Flag_Outperform VARCHAR(3)

UPDATE D
SET Flag_Outperform = (CASE WHEN Company_Profitability > Profitability_Percent_Industry_Inception THEN 'Y' ELSE 'N' END)
--(497 row(s) affected)


/* Market share of company in its industry per year */
-- Proxy market share by company revenue divided by industry revenue per year
SELECT *
INTO Market_Share
FROM(SELECT *,
ROUND(Revenue/SUM(Revenue) OVER (PARTITION BY Industry, Inception), 4) AS Company_Market_Share
FROM [DSTraining].[dbo].[Future_500]) AS E
ORDER BY CAST(Company_Market_Share AS DOUBLE PRECISION) DESC
--(497 row(s) affected)

END
GO
