DECLARE @Max_log INT;
SET @Max_log =  50240; -- size of the transaction log in MB
SELECT  COUNT(*) AS Cnt
FROM    master.sys.master_files
WHERE   type_desc = 'LOG'
        AND ( ( [size] * 8 ) / 1024 ) > @Max_log
        AND database_id = DB_ID();


SELECT MAX(( [size] * 8 ) / 1024)
FROM master.sys.master_files
WHERE type_desc = 'LOG'
AND database_id = DB_ID();


SELECT * FROM sys.master_files AS mf

74359

DBCC SQLPERF (Logspace)