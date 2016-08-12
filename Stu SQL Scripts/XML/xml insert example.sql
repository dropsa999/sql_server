CREATE PROCEDURE usp_InsertShoppingCartOrder ( @xml XML )
AS 
    BEGIN       
        INSERT  INTO WebSales
                ( ProductID ,
                  SalePrice ,
                  SaleDate ,
                  SaleBatchID ,
                  CustomerID            
                )
                SELECT  Table1.Column1.value('@ProductID', 'INT') ,
                        Table1.Column1.value('@Price', 'FLOAT') ,
                        Table1.Column1.value('@SaleDate', 'DATETIME') ,
                        Table1.Column1.value('@SaleBatchID', 'INT') ,
                        Table1.Column1.value('@CustomerID', 'INT')
                FROM    @xml.nodes('/ShoppingCart/Purchase') AS Table1 ( Column1 )

    END
    
    
    CREATE PROCEDURE usp_InsertShoppingCartOrder ( @xml XML )
    AS 
        BEGIN
            DECLARE @Pointer INT
            EXECUTE sp_xml_preparedocument @Pointer OUTPUT, @xml 
            INSERT  INTO WebSales
                    ( ProductID ,
                      SalePrice ,
                      SaleDate ,
                      SaleBatchID ,
                      CustomerID      
                    )
                    SELECT  ProductID ,
                            Price ,
                            SaleDate ,
                            SaleBatchID ,
                            CustomerID
                    FROM    OPENXML (@Pointer,'/ShoppingCart/Purchase')       
                    WITH       
                    (ProductID INT,Price MONEY,SaleDate SMALLDATETIME,SaleBatchID INT,CustomerID INT) 
            EXEC sp_xml_removedocument @Pointer 
        END

