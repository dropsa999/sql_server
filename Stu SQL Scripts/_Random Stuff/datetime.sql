-- EOM
declare @date1 datetime=getdate()
select dateadd(month,datediff(month,-1, @date1),-1)

declare @date varchar(10)
set @date=convert(varchar,year(getdate()))+ '-' +convert(varchar,(month(getdate())+1))+'-01'
select dateadd(day,-1,@date)

DECLARE @date DATETIME;  
SET @date = '2012-09-07';
SELECT EOMONTH (@date) AS Result;

DECLARE @date DATETIME;  
SET @date = GETDATE();  
SELECT EOMONTH ( @date ) as ThisMonth;  
SELECT EOMONTH ( @date, 1 ) as NextMonth;  
SELECT EOMONTH ( @date, -1 ) as LastMonth;

-- No Begining of Month though :(
DECLARE @date DATETIME = GETDATE();  
SELECT DATEADD(day,1,EOMONTH ( @date, -1 )) as BOMonth;


-- Construct date from parts

DECLARE @year INT = 2012;
DECLARE @month INT = 09;
DECLARE @day INT = 07;

SELECT Date=Convert(datetime,convert(varchar(10),@year)+'-'+convert(varchar(10),@day)+'-'+convert(varchar(10),@month),103)


SELECT DATEFROMPARTS ( 2012, 09, 07 ) AS Result;


DECLARE @year INT = 2012;
DECLARE @month INT = 09;
DECLARE @day INT;

/* DATEFROMPARTS */
SELECT DATEFROMPARTS ( @year, @month, @day) AS Result;

SELECT DATEFROMPARTS ( @year, isnull(@month,1), isnull(@day,1)) AS Result;


/* TIMEFROMPARTS */
SELECT TIMEFROMPARTS ( 23, 59, 59, 0,0 ) AS Result;

DECLARE @hour INT = 23;
DECLARE @min INT = 59;
DECLARE @sec INT = 59;
DECLARE @milli INT;

/* TIMEFROMPARTS */
SELECT TIMEFROMPARTS ( @hour, @min, @sec, ISNULL(@milli,0), 0) AS Result;

/* DATETIMEFROMPARTS */
DECLARE @year INT = 2012;
DECLARE @month INT = 09;
DECLARE @day INT = 01;
DECLARE @hour INT = 23;
DECLARE @min INT = 59;
DECLARE @sec INT = 59;
DECLARE @milli INT = 0;

SELECT DATETIMEFROMPARTS ( @year, @month, @day, @hour, @min, @sec, @milli ) AS Result;

-- Also
-- DATETIME2FROMPARTS
-- DATETIMEOFFSETFROMPARTS
-- SMALLDATETIMEFROMPARTS


use AdventureWorks2012
GO
IF OBJECT_ID('tempdb..#dateParts') IS NOT NULL
  DROP TABLE #dateParts;

CREATE TABLE #dateParts (
	EventID INT,
	[Year]	INT,
	[Month]	INT,
	[Day]	INT
)

INSERT INTO #dateParts (EventID, Year, Month, Day)
SELECT	SalesOrderID,
		DATEPART(YEAR, ModifiedDate) AS [Year],
		DATEPART(MONTH, ModifiedDate) AS [Month],
		DATEPART(DAY, ModifiedDate) AS [Day]
FROM Sales.SalesOrderDetail

SELECT * FROM #dateParts
	where datefromparts(year, Month, Day) between '2007-01-01' and '2007-12-31'

