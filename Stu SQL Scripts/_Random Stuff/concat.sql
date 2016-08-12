-- Traditional Concat
SELECT 'This ' + 'is ' + 'a ' + 'test';

-- Modern alternative
SELECT CONCAT('This ', 'is ', 'a ', 'test');

-- Mixed datatypes
SELECT 'Today: ' + getdate();

-- Traditional explict cast
SELECT 'Today: ' + cast(getdate() as varchar)

-- Modern implicit cast
SELECT CONCAT('Today: ', getdate())



-- Working with tables
use InsightProduction
GO

select CONCAT('User: ', Username, ' added: ', CreatedDateTime)
from Users
GO


USE [AdventureWorks2008R2]
GO

SELECT [AddressID], [AddressLine1], [AddressLine2], [City], [StateProvinceID], [PostalCode]
FROM [Person].[Address]
GO

SELECT ([AddressID] + ' ' + [AddressLine1] + ' ' + [AddressLine2] + ' ' + 
		[City] + ' ' + [StateProvinceID] + ' ' + [PostalCode] ) AS Address
FROM [Person].[Address]
GO

SELECT (CAST([AddressID] as varchar) + ' ' + [AddressLine1] + ' ' + [AddressLine2] + ' ' + 
		[City] + ' ' + [StateProvinceID] + ' ' + [PostalCode] ) AS Address
FROM [Person].[Address]
GO

SELECT (CAST([AddressID] as varchar) + ' ' + [AddressLine1] + ' ' + [AddressLine2] + ' ' + 
		[City] + ' ' + cast([StateProvinceID] as varchar) + ' ' + [PostalCode] ) AS Address
FROM [Person].[Address]
GO

SELECT (CAST([AddressID] as varchar) + ' ' + [AddressLine1] + ' ' + ISNULL([AddressLine2],'') + ' ' + 
		[City] + ' ' + cast([StateProvinceID] as varchar) + ' ' + [PostalCode] ) AS Address
FROM [Person].[Address]
GO

SELECT CONCAT(	[AddressID],' ',
				[AddressLine1],' ',
				[AddressLine2],' ',
				[City],' ',
				[StateProvinceID],' ',
				[PostalCode]
				) AS Address
FROM [Person].[Address]
GO



use adisdb
GO

SELECT CONCAT(FirstName, ' ', LastName) AS UserName
FROM ADUsers ;

SELECT FirstName, LastName FROM ADUsers

ALTER TABLE ADUsers
 ADD UserName AS CONCAT(FirstName, ' ', LastName) PERSISTED

SELECT UserName FROM ADUsers

/*
ALTER TABLE ADUsers  DROP COLUMN UserName ;
*/


-- This doesn't work :(
SELECT CONCAT(SELECT LastName FROM Person.Person);
