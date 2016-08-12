IF OBJECT_ID('tempdb..#tab1') IS NOT NULL DROP TABLE #tab1
GO
CREATE TABLE #tab1 (idCol INT IDENTITY, Col1 INT) 
GO
INSERT INTO #tab1 VALUES(5), (5), (3) , (1) 
GO 


IF OBJECT_ID('tempdb..#REVENUE') IS NOT NULL DROP TABLE #REVENUE
GO
CREATE TABLE #REVENUE
(
[IDColumn] int identity,
[DepartmentID] int,
[Revenue] int,
[Year] int
);
 
insert into #REVENUE
values (1,10030,1998),(2,20000,1998),(3,40000,1998),
 (1,20000,1999),(2,60000,1999),(3,50000,1999),
 (1,40000,2000),(2,40000,2000),(3,60000,2000),
 (1,30000,2001),(2,30000,2001),(3,70000,2001),
 (1,90000,2002),(2,20000,2002),(3,80000,2002),
 (1,10300,2003),(2,1000,2003), (3,90000,2003),
 (1,10000,2004),(2,10000,2004),(3,10000,2004),
 (1,20000,2005),(2,20000,2005),(3,20000,2005),
 (1,40000,2006),(2,30000,2006),(3,30000,2006),
 (1,70000,2007),(2,40000,2007),(3,40000,2007),
 (1,50000,2008),(2,50000,2008),(3,50000,2008),
 (1,20000,2009),(2,60000,2009),(3,60000,2009),
 (1,30000,2010),(2,70000,2010),(3,70000,2010),
 (1,80000,2011),(2,80000,2011),(3,80000,2011),
 (1,10000,2012),(2,90000,2012),(3,90000,2012);

 
--ROW NUMBER
SELECT Col1, 
       ROW_NUMBER() OVER(ORDER BY Col1 DESC) AS "ROW_NUMBER()"   
  FROM #Tab1

-- Rank
SELECT Col1, 
       RANK() OVER(ORDER BY Col1 DESC) AS "RANK()"   FROM #Tab1
GO

-- Dense_Rank
SELECT Col1, 
       DENSE_RANK() OVER(ORDER BY Col1 DESC) AS "DENSE_RANK"   FROM #Tab1



 select DepartmentID, Revenue, Year
 from #REVENUE
 where DepartmentID = 1;




-- LEAD
SELECT Col1, 
       LEAD(Col1) OVER(ORDER BY Col1) AS "LEAD()"   FROM #tab1 

SELECT Col1, 
       LEAD(Col1, 2) OVER(ORDER BY Col1) AS "LEAD()"   FROM #tab1

select DepartmentID, Revenue, Year,
       LAG(Revenue) OVER (ORDER BY Year) as LastYearRevenue
 from #REVENUE
 where DepartmentID = 1
 order by Year;


-- LAG
SELECT Col1, 
       LAG(Col1) OVER(ORDER BY Col1) AS "LAG()"   FROM #tab1 

select DepartmentID, Revenue, Year,
       LAG(Revenue) OVER (ORDER BY Year) as LastYearRevenue,
       LEAD(Revenue) OVER (ORDER BY Year) as NextYearRevenue
  from #REVENUE
 where DepartmentID = 1
  order by Year;


select DepartmentID, Revenue, Year,
       LAG(Revenue) OVER (ORDER BY Year) as LastYearRevenue,
       Revenue - LAG(Revenue) OVER (ORDER BY Year) as YearOverYearDelta
  from #REVENUE
 where DepartmentID = 1
  order by Year;



-- FIRST_VALUE
SELECT Col1, 
       FIRST_VALUE(Col1) OVER(ORDER BY Col1) AS "FIRST_VALUE()"   FROM #tab1 

-- LAST_VALUE
SELECT Col1, 
       LAST_VALUE(Col1) OVER(ORDER BY Col1 ) AS "LAST_VALUE()"   FROM #tab1

SELECT Col1, 
       LAST_VALUE(Col1) OVER(ORDER BY Col1 
	   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "LAST_VALUE()"   
	   FROM #tab1
--	   WHERE Col1=3


--PERCENT_RANK
SELECT Col1, 
       PERCENT_RANK() OVER(ORDER BY Col1) AS [PERCENT_RANK()],
       RANK() OVER(ORDER BY Col1) AS [RANK()],
       (SELECT COUNT(*) FROM #tab1) [COUNT]   FROM #tab1


select DepartmentID, Revenue, Year,
       RANK() OVER(ORDER BY Revenue) as RankYear,
       PERCENT_RANK() OVER(ORDER BY Revenue) as PercentRank
from #REVENUE
where DepartmentID = 1;


-- CUME_DIST()
SELECT Col1, 
       CUME_DIST() OVER(ORDER BY Col1) AS "CUME_DIST()"   FROM #Tab1


-- Running totals

ALTER TABLE #revenue
 ADD RunningTotal INT NULL ;

DECLARE @runningTotal INT = 0;

UPDATE r
SET @RunningTotal = r.RunningTotal = @RunningTotal + r.Revenue
FROM #Revenue AS r
--ORDER BY r.Year, r.DepartmentID

SELECT DepartmentID, Year, Revenue, RunningTotal 
FROM #REVENUE ;


SELECT r2.DepartmentID, r2.Year, r2.Revenue, 
(
	SELECT SUM(Revenue)
	FROM #revenue r
	WHERE r.IDColumn <= r2.IDColumn
) RunningTotal
FROM #revenue r2
--ORDER BY r2.DepartmentID, r2.Year ;



SELECT  DepartmentID,
        [Year],
        Revenue,
	SUM(Revenue) OVER (ORDER BY [Year],DepartmentID) AS RunningTotal
FROM #REVENUE


SELECT  DepartmentID,
        [Year],
        Revenue,
	SUM(Revenue) OVER (PARTITION BY DepartmentID ORDER BY [Year]) AS RunningTotal      
FROM #REVENUE


SELECT
	DepartmentID,
	[Year],
	Revenue,
	SUM(Revenue) OVER (Partition by DepartmentID ORDER BY [Year]
			  ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS Last5YrsRevenue,
	SUM(Revenue) OVER (Partition by DepartmentID ORDER BY [Year]
			  ROWS  UNBOUNDED PRECEDING) AS CumulativeRevenue,
	SUM(Revenue) OVER (Partition by DepartmentID ORDER BY [Year]
			  ROWS BETWEEN CURRENT ROW AND 4 FOLLOWING) AS Next5YrsRevenue
FROM #revenue ;



-- Performance
use AdventureWorks ;
GO
DBCC FREEPROCCACHE ;
GO
DBCC FREESESSIONCACHE;
GO


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
SET STATISTICS IO ON; --include IO statistics
SET NOCOUNT ON; --do not show affected rows info
GO

--Create table dbo.Orders
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
GO
--Create and populate the table dbo.Orders
SELECT TOP (10000) * INTO dbo.Orders FROM Sales.SalesOrderHeader;
--Create the clustered index
CREATE UNIQUE CLUSTERED INDEX PK_Orders ON dbo.Orders(SalesOrderID);

--Get Running Total
SELECT TOP 10000 o.SalesOrderID, o.TotalDue,
(
	SELECT SUM(TotalDue)
	FROM dbo.Orders i
	WHERE i.SalesOrderID <= o.SalesOrderID
) RunnTotal
FROM dbo.Orders o
ORDER BY o.SalesOrderID;


SELECT SalesOrderID, TotalDue, SUM(TotalDue)
OVER(ORDER BY SalesOrderID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) RunnTotal
FROM dbo.Orders o
ORDER BY o.SalesOrderID;


--Result: For the whole table (32K rows) it takes under 1 second!
--		  For the whole table (32K rows) it takes 3 min and 23 seconds!


IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
GO
