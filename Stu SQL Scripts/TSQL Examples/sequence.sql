USE AdventureWorks2008R2
GO

-- Build it
CREATE SEQUENCE [Seq]
 AS [int]
 START WITH 1
 INCREMENT BY 1
 MAXVALUE 25000 ;
GO

-- Run five times
SELECT NEXT VALUE FOR Seq AS SeqNumber;
SELECT NEXT VALUE FOR Seq AS SeqNumber;
SELECT NEXT VALUE FOR Seq AS SeqNumber;
SELECT NEXT VALUE FOR Seq AS SeqNumber;
SELECT NEXT VALUE FOR Seq AS SeqNumber;
GO 
 
-- First Run
SELECT NEXT VALUE FOR Seq, c.CustomerID
 FROM Sales.Customer c ;
GO

-- Second Run
SELECT NEXT VALUE FOR Seq, c.AccountNumber
 FROM Sales.Customer c ;
GO

-- Restart the Sequence
ALTER SEQUENCE [Seq]
 RESTART WITH 1 ;
GO

 -- Sequence Restarted
SELECT NEXT VALUE FOR Seq, c.CustomerID
 FROM Sales.Customer c ;
GO

 -- Cleanup
DROP SEQUENCE [Seq] ;
GO
