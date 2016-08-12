/*********** CREATE LOGGING TABLE *************/
DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;
 
DECLARE @schema VARCHAR(4000) ;
EXEC sp_WhoIsActive
@get_transaction_info = 1,
@get_plans = 1,
@RETURN_SCHEMA = 1,
@SCHEMA = @schema OUTPUT ;
 
SET @schema = REPLACE(@schema, '<table_name>', @destination_table) ;
 
PRINT @schema
EXEC(@schema) ;


/********* CAPTURE WHO IS ACTIVE ***************/

DECLARE
    @destination_table VARCHAR(4000) ,
    @msg NVARCHAR(1000) ;
 
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;
 
DECLARE @numberOfRuns INT ;
SET @numberOfRuns = 100 ;
 
WHILE @numberOfRuns > 0
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @get_plans = 1,
            @DESTINATION_TABLE = @destination_table ;
 
        SET @numberOfRuns = @numberOfRuns - 1 ;
 
        IF @numberOfRuns > 0
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' +
                 'Logged info. Waiting...'
                RAISERROR(@msg,0,0) WITH nowait ;
 
                WAITFOR DELAY '00:00:05'
            END
        ELSE
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' + 'Done.'
                RAISERROR(@msg,0,0) WITH nowait ;
            END
 
    END ;
GO

/*************** REPORT ON RESULTS ***************************/

DECLARE @destination_table NVARCHAR(2000), @dSQL NVARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;
SET @dSQL = N'SELECT collection_time, * FROM dbo.' +
 QUOTENAME(@destination_table) + N' order by 1 desc' ;
print @dSQL
EXEC sp_executesql @dSQL