USE AdventureWorks2008R2
 GO

DECLARE @RowsPerPage INT = 10
   ,@PageNumber INT = 5

DECLARE @StartRow INT
DECLARE @EndRow INT
SET @StartRow = ( @RowsPerPage * @PageNumber )
SET @EndRow = @StartRow + @RowsPerPage

-- Derived Table

SELECT FirstName
       ,LastName
       ,EmailAddress
    FROM ( SELECT PP.FirstName
               ,PP.LastName
               ,EA.EmailAddress
               ,ROW_NUMBER() OVER ( ORDER BY PP.FirstName, PP.LastName, PP.BusinessEntityID ) AS RowNumber
            FROM Person.Person PP 
            INNER JOIN Person.EmailAddress EA ON PP.BusinessEntityID = EA.BusinessEntityID
         ) PersonContact
    WHERE RowNumber > @StartRow
        AND RowNumber <= @EndRow
    ORDER BY FirstName
       ,LastName
       ,EmailAddress
 GO
 
-- CTE
 DECLARE @RowsPerPage INT = 10
   ,@PageNumber INT = 5

 DECLARE @StartRow INT ;
 DECLARE @EndRow INT ;
 SET @StartRow = ( @RowsPerPage * @PageNumber ) ;
 SET @EndRow = @StartRow + @RowsPerPage ;

 WITH   PersonContact
          AS ( SELECT PP.FirstName
                   ,PP.LastName
                   ,EA.EmailAddress
                   ,ROW_NUMBER() OVER ( ORDER BY PP.FirstName, PP.LastName, PP.BusinessEntityID ) AS RowNumber
                FROM Person.Person PP 
                INNER JOIN Person.EmailAddress EA ON PP.BusinessEntityID = EA.BusinessEntityID
             )
    SELECT FirstName
           ,LastName
           ,EmailAddress
        FROM PersonContact
        WHERE RowNumber > @StartRow
            AND RowNumber <= @EndRow
        ORDER BY FirstName
           ,LastName
           ,EmailAddress ;
GO
 
 -- Denali

 DECLARE @RowsPerPage INT = 10
   ,@PageNumber INT = 5 ;

 SELECT PP.FirstName
       ,PP.LastName
       ,EA.EmailAddress
    FROM Person.Person PP 
    INNER JOIN Person.EmailAddress EA ON PP.BusinessEntityID = EA.BusinessEntityID
    ORDER BY PP.FirstName
       ,PP.LastName
       ,PP.BusinessEntityID
    OFFSET @PageNumber*@RowsPerPage ROWS
    FETCH NEXT @RowsPerPage ROWS ONLY ;
GO
 