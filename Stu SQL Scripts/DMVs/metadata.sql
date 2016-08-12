USE AdventureWorks2012;
GO


-- Old way of doing thing

SET FMTONLY ON;
GO
SELECT * 
FROM HumanResources.Employee;
GO
SET FMTONLY OFF;
GO

-- New and cool
sp_describe_first_result_set @tsql = N'SELECT * FROM HumanResources.Employee;'


SELECT * FROM sys.dm_exec_describe_first_result_set(
N'SELECT CustomerID, TerritoryID, AccountNumber FROM Sales.Customer WHERE CustomerID = @CustomerID;',
N'@CustomerID int', 0) AS a;
GO




-- Only the the first resultset examined if there were multiple sets returned
SELECT * FROM sys.dm_exec_describe_first_result_set(
N'SELECT * FROM Sales.SalesOrderHeader;
SELECT CustomerID, TerritoryID, AccountNumber FROM Sales.Customer WHERE CustomerID = @CustomerID;',
N'@CustomerID int', 0) AS a;
GO

-- Can be used for Stored Procs as well
CREATE PROC Production.TestProc
AS
SELECT Name, ProductID, Color FROM Production.Product ;
SELECT Name, SafetyStockLevel, SellStartDate FROM Production.Product ;
GO

SELECT * FROM sys.dm_exec_describe_first_result_set
('Production.TestProc', NULL, 0) ;

DROP PROC production.testproc ;
GO


-- Lets look over objects instead of queries
SELECT p.name, r.* 
FROM sys.procedures AS p
CROSS APPLY sys.dm_exec_describe_first_result_set_for_object(p.object_id, 0) AS r;
GO


-- Find any paramaters in use in a query batch
sp_describe_undeclared_parameters 
@tsql = N'SELECT object_id, name, type_desc FROM sys.indexes WHERE object_id = @id OR name = @name' ;


sp_describe_undeclared_parameters 
	@tsql = N'SELECT object_id, name, type_desc FROM sys.indexes WHERE object_id = @id OR NAME = @name',
	@params = N'@id int' ;

sp_describe_undeclared_parameters @tsql=N'uspGetBillOfMaterials' ;
