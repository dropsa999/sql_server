IF OBJECT_ID('tempdb..#REVENUE') IS NOT NULL DROP TABLE #REVENUE
GO
CREATE TABLE #REVENUE
(
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


--IIF
-- assume we want to display an indicator to see if we are above
-- or below average. First we start with the average over departmentID
select Year, DepartmentID, Revenue,
 avg(Revenue) OVER (PARTITION by DepartmentID) as AverageRevenue
from #REVENUE
order by DepartmentID, year;
 

-- without IIF using the CASE statement we would get the following
select Year, DepartmentID, Revenue, AverageRevenue,
 case when Revenue > AverageRevenue THEN 'Better Than Average'
 else 'Not' end as Ranking
from (select Year, DepartmentID, Revenue,
 avg(Revenue) OVER (PARTITION by DepartmentID) as AverageRevenue
 from #REVENUE ) as t
order by DepartmentID, year;
 


-- now the same functionality using IIF and simplifying the code
select Year, DepartmentID, Revenue, AverageRevenue,
 iif(Revenue > AverageRevenue, 'Better Than Average', 'Not') as Ranking
from (select Year, DepartmentID, Revenue,
 avg(Revenue) OVER (PARTITION by DepartmentID) as AverageRevenue
 from #REVENUE ) as t
order by DepartmentID, year;





-- CHOOSE
-- the old way using case.
declare @corners as int = 6
SELECT CASE @corners
 WHEN 1 THEN 'point'
 WHEN 2 THEN 'line'
 WHEN 3 THEN 'triangle'
 WHEN 4 THEN 'square'
 WHEN 5 THEN 'pentagon'
 WHEN 6 THEN 'hexagon'
 WHEN 7 THEN 'heptagon'
 WHEN 8 THEN 'octagon'
 else NULL
 END;

declare @corners as int = 6
SELECT choose(@corners, 'point', 'line', 'triangle', 'square',
 'pentagon', 'hexagon', 'heptagon', 'octagon')
 
-- CHOOSE day of week example
DECLARE @day as int=4
SELECT CHOOSE(@day,'Sunday','Monday', 'Tuesday',
              'Wednesday','Thursday','Friday','Saturday')
