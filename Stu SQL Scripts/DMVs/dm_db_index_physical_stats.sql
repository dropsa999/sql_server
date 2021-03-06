DECLARE @db_id SMALLINT;
DECLARE @object_id INT;

/* http://technet.microsoft.com/en-us/library/ms188917(v=sql.105).aspx */

SET @db_id = DB_ID(N'DSELK');
SET @object_id = OBJECT_ID(N'DSELK.dbo.Account');

IF @db_id IS NULL
BEGIN;
    PRINT N'Invalid database';
END;
ELSE IF @object_id IS NULL
BEGIN;
    PRINT N'Invalid object';
END;
ELSE
BEGIN;
    SELECT * FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'LIMITED');
END;
GO