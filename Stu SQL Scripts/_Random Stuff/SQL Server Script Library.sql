/* SQL Server Script Library
Author: Vincent Rainardi
Date written: 4th Dec 2014
Last updated: 18th Jan 2015

CREATE DATABASE OBJECTS
1. Create a database
2. Create a filestream database
3. Drop a database
4. Rename a database
5. Create a login
6. Delete a login
7. Create a user
8. Delete a user
9. Create a schema
10. Drop a schema
11. Create a table
12. Create a memory-optimized table
13. Delete a table
14. Create a filetable
15. Delete a filetable
16. Create a view
17. Delete a view
18. Create an index
19. Create a filtered index
19a. Force using index
20. Create a spatial index
21. Delete an index
22. Create statistics
23. Show statistics
23a. When the statistic is last updated
24. Update statistics
25. Delete a statistics
26. Create a constraint
26a. Rename a constraint
27. Drop a constraint
28. Create a primary key
29. Delete a primary key
30. Create a foreign key
31. Delete a foreign key
32. Disable a foreign key
33. Enable a foreign key
34. Disable an index
35. Enable an index
36. Rename an index
37. Create a columnstore index
38. Delete a columnstore index
39. Add a column
40. Drop a column
41. Rename a column
42. Change data type of a column
43. Create a computed column
44. Create a synonym
45. Drop a synonym
46. Enable partitioning on the server
47. Disable partitioning on the server
48. Create a partitioned table
49. Drop a partitioned table
50. Create a partitioned index
51. Delete a partitioned index
52. Create an indexed view
53. Drop an indexed view
54. Add an extended property
55. Delete an extended property
56. Enable CDC on the server
57. Disable CDC on the server
58. Enable CDC on a table
59. Disable CDC on a table
60. CDC functions
61. CDC stored procedures
62. Enable Change Tracking on the database
63. Disable Change Tracking on the database
64. Enable Change Tracking on a table
65. Disable Change Tracking on a table
66. Change Tracking functions
67. Create a trigger
68. Delete a trigger
69. Disable a trigger
70. Enable a trigger
 
DATABASE DEVELOPMENT
1. Select rows
2. Update rows
3. Insert rows
4. Delete rows
5. Grouping rows
6. Inner join
7. Left and right join
8. Full outer join
9. Join hint
10. Like operator
11. Collation
12. Corogated query
13. Select into
14. Insert Select
15. Update from
16. Delete from
17. Truncate table
18. Cast
19. Convert
20. NULLIF
21. IFNULL
22. Coalesce
23. Union and union all
24. Declare a variable
25. Create a temp table
26. Drop a temp table
27. Create global temp table
28. Drop global temp table
29. Create a table variable
30. Memory-optimized table variables
31. Looping on a table variable
32. Drop a table variable
33. Create a stored procedure
34. Execute a stored procedure
35. Drop a stored procedure
36. Create a scalar function
37. Create a table valued function
38. Create a CLR function
39. Delete a CLR function
40. Cross apply
41. Outer apply
42. While
43. Continue
44. Case when
45. If else
46. Try catch
47. Merge
48. Upsert
49. Checksum
50. String functions
51. Date functions
52. Set date format
53. Transaction
54. Pivot
55. Unpivot
56. Print the current time
57. Using row number
58. Find duplicate rows
59. Remove duplicate rows
60. Rank and dense rank
61. Choose function
62. IIF function
63. Except
64. Intersect
65. Dynamic SQL
66. Using Cursor
67. Cursor stored procedures
68. Put output of SP into a table
69. Select for XML
70. Prepare XML document
71. Remove XML document
72. Querying XML data
73. Option recompile
74. Bitwise operation
75. Waitfor
76. Applock
 
DATABASE ADMINISTRATION
1. Create a maintenance plan
2. Backup database
3. Restore database
4. Get database state
5. Get database size
6. Detact a database
7. Attach a database
8. Add a file group
9. Add a file to a database
10. Delete a file from a database
11. Move a database file
12. Inrease the size of a database
13. Reorganise an index
14. Rebuild an index
15. Check for fragmentation
16. Check size of log file
17. Check Log Sequence Number (LSN)
18. Check the last the a job run
19. Check the last time a table is accessed
20. Check the last time a user logged in
21. Create a database snapshot
22. Drop a database snapshot
23. Check for blocking
24. Check for locks
25. Check for deadlocks
26. Set deadlock priority
27. Set lock timeout
28. Check for orphaned users
29. Fix orphaned users
30. Find out the largest tables
31. Find out database space used
32. Get SQL Server version
33. Get memory used
34. Get number of connections
35. Create a job
36. Create a job step
37. Create a job schedule
38. Delete a job schedule
39. Delete a job step
40. Delete a job
41. Create a linked server to a SQL Server
42. Create a linked server to a SSAS
43. Drop a linked server
44. Find out who is connected
45. Create a role
46. Drop a role
47. Add a member to a role
48. Remove a member from a role
49. Grant permission to a stored procedure
50. Deny execution on a stored procedure
51. Grant permission to a table
52. Deny permission on a table
52a. Find out permissions
53. BCP
54. Create a trace
55. Delete a trace
56. Truncate transaction log
57. Bulk import
58. Bulk export
59. Enable data compression on a table
60. Disable data compression on a table
61. Checkpoint
62. Setup database mirroring
63. Monitoring database mirroring
64. Pausing a database mirroring session
65. Resuming a database mirroring session
66. Removing database mirroring
67. Create a server audit
68. View a SQL Server audit log
69. Cryptographic functions
70. List of all databases
71. List of columns in a table
72. List of columns in an index
73. List of statistics in an index
74. List of partitions in a table
75. Display view definition
76. Display table details
77. Find a column
78. Find an index
79. Find a view
80. Find a stored procedure
81. Find tables without a primary key
82. Find tables without an index
83. Find tables which were modified today
84. Find primary keys columns
85. Find foreign keys columns
86. Find columns with certain data types
87. Find a constraint
88. Find a trigger
89. Find a synonym
90. Find all stored procedures using a certain table
91. Find parameters in a stored procedure
92. Find owners the tables in a database
93. Find tables owned by a certain users
94. Detect page splits
95. Change isolation levels
96. Delete data from a large table
97. Row count on a large table
98. Max is too slow
99. Set row count
100. Display how long it takes to run a query
101. Display disk activity when a query runs
102. Kill a connection
103. Policy stored procedures
104. DB engine stored procedures
105. Security stored procedures
 
*/
 
-- 1. Create database
CREATE DATABASE Database1
ON PRIMARY
( NAME = 'Database1_Data',
FILENAME = 'E:\MSSQL\Data\Database1_Data.mdf',
SIZE = 10 GB, MAXSIZE = 100 GB, FILEGROWTH = 5 GB
),
FILEGROUP SECONDARY
( NAME = 'Database1_Index',
FILENAME = 'F:\MSSQL\Data\Database1_Index.mdf',
SIZE = 4 GB, MAXSIZE = 30 GB, FILEGROWTH = 2 GB
)
LOG ON
( NAME = 'Database1_Log',
FILENAME = 'G:\MSSQL\DATA\Database1_Log.ldf',
SIZE = 1 GB, FILEGROWTH = 512 MB
)
GO
-- Suffix: KB, MB, GB, TB
-- Data file: min 5 MB to accomodate Model DB, max 16 TB
-- Log file: min 512 KB, max 2 TB
-- File growth: min 64 KB, rounded to nearest 64 KB
 
-- 2. Create a filestream database
 
-- To enable filestream: Configuration Manager, SQL Server Properties, FILESTREAM tab, then:
EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO
 
CREATE DATABASE Database2
ON PRIMARY
( NAME = 'Database2_Data',
FILENAME = 'E:\MSSQL\Data\Database2_Data.mdf',
SIZE = 10 GB, MAXSIZE = 100 GB, FILEGROWTH = 5 GB
),
FILEGROUP FileStreamGroup1 CONTAINS FILESTREAM
( NAME = 'Database2_Filestream',
FILENAME = 'F:\MSSQL\Filestream\Database2'
)
LOG ON
( NAME = 'Database2_Log',
FILENAME = 'G:\MSSQL\DATA\Database2_Log.ldf',
SIZE = 1 GB, FILEGROWTH = 512 MB
)
GO
 
ALTER DATABASE [Database2] SET FILESTREAM (DIRECTORY_NAME = N'Database2') WITH NO_WAIT
GO
 
-- 3. Drop database
IF EXISTS (SELECT * FROM SYS.DATABASES WHERE NAME = 'Database1')
DROP DATABASE Database1
-- Compatibility view: SYSDATABASES
 
-- 4. Rename a database
ALTER DATABASE Database1 MODIFY Name = Database2
GO
 
-- 5. Create a login
CREATE LOGIN [DOMAIN\SQL Guy] FROM WINDOWS WITH DEFAULT_DATABASE=[Database1]
GO
 
-- 6. Delete a login
IF EXISTS (SELECT * FROM SYS.SYSLOGINS WHERE NAME = 'DOMAIN\SQL Guy')
DROP LOGIN [DOMAIN\SQL Guy]
GO
-- Compatibility view: SYSLOGINS
 
-- 7. Create a user
CREATE USER [DOMAIN\SQL Guy] FOR LOGIN [DOMAIN\SQL Guy]
GO
 
-- 8. Delete a user
IF EXISTS (SELECT * FROM SYS.SYSUSERS WHERE NAME = 'DOMAIN\SQL Guy')
DROP USER [DOMAIN\SQL Guy]
GO
-- Drop user automatically drop their memberships
-- Compatibility view: SYSUSERS
 
-- 9. Create schema
CREATE SCHEMA Schema1 AUTHORIZATION [dbo]
GO -- Create schema must be the only statement in the batch
 
-- 10. Drop a schema
IF EXISTS (SELECT * FROM SYS.SCHEMAS WHERE NAME = 'Schema1')
DROP SCHEMA Schema1
GO
 
-- 11. Create a table
CREATE TABLE dbo.Table1
( Column1 INT NOT NULL IDENTITY (1, 1),
Column2 NVARCHAR(10),
Column3 DATE,
Column4 DECIMAL(14, 5),
CONSTRAINT PK_Table1 PRIMARY KEY CLUSTERED (Column1 ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [PRIMARY]
) ON [PRIMARY]
GO
 
-- 12. Create a memory-optimized table
CREATE TABLE dbo.Table2
( Column1 INT NOT NULL IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
Column2 INT INDEX NC_Column2 NONCLUSTERED HASH WITH (BUCKET_COUNT=1000),
Column3 DATETIME2
) WITH (MEMORY_OPTIMIZED=ON)
GO
 
-- 13. Delete a table
IF OBJECT_ID('dbo.Table1') IS NOT NULL
DROP TABLE dbo.Table1
GO
-- Compatibility view: SYSOBJECTS
 
-- 14. Create Filetable
CREATE TABLE dbo.FileTable1 AS FILETABLE
WITH
( FILETABLE_DIRECTORY = 'E:\MSSQL\Folder1',
FILETABLE_COLLATE_FILENAME = database_default
)
GO
 
-- 15. Delete Filetable
IF OBJECT_ID('dbo.FileTable1') IS NOT NULL
DROP TABLE dbo.FileTable1
GO
 
-- 16. Create a view
CREATE VIEW View1 AS
SELECT T1.Column1, T2.Column2, T1.Column3
FROM Table1 T1
JOIN Table2 T2 on T1.Column1 = T2.Column2
WHERE T2.Column3 = 'Active'
-- Create view must be the only statement in the batch
 
-- 17. Delete a view
IF OBJECT_ID('dbo.View1') IS NOT NULL
DROP VIEW dbo.View1
 
-- 18. Create an index
CREATE INDEX NC_Table1_Column2Column4 ON dbo.Table1 (Column2 DESC,Column4 ASC) --This is NONCLUSTERED
CREATE CLUSTERED INDEX CI_Table1_Column1 ON dbo.Table1 (Column1) --Can take a long time if the table has 1 million rows
 
-- 19. Create a filtered index
CREATE INDEX FI_Table1_Column2Column4WithColumn3NotNull
ON dbo.Table1 (Column2 DESC,Column4 ASC)
WHERE Column3 IS NOT NULL
 
-- 19a. Force using index
SELECT Column2, Column3 FROM TABLE1
WITH ( INDEX(FI_Table1_Column2Column4WithColumn3NotNull) )
WHERE Column3 = 'FKA'
 
-- 20. Create a spatial index
CREATE SPATIAL INDEX SI_Table1_Column1
ON Table1 (Column1)
USING GEOMETRY_GRID
WITH
( Bounding_Box = (0,0,100,100),
GRIDS = LOW, LOW, MEDIUM, HIGH,
CELLS_PER_OBJECT = 64,
PAD_INDEX = ON
)
 
-- 21. Delete an index
IF EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'NC_Table1_Column2Column4')
DROP INDEX NC_Table1_Column2Column4 ON dbo.Table1
-- Compatibility view: sysindexes
 
-- 22. Create statistics
CREATE STATISTICS Stat1
ON Table1(Column1, Column2) --By default query optimizer determines the statistically significant sample size
 
CREATE STATISTICS Stat1
ON Table1(Column1, Column2)
WHERE Column3 &amp;amp;gt; '2014-01-01' --Filtered Statistics
 
CREATE STATISTICS Stat1
ON Table1(Column1, Column2)
WITH SAMPLE 20 PERCENT --The optimizer scans all rows on a data page so the actual number is not 20%
 
-- 23. Show statistics
DBCC SHOW_STATISTICS ('dbo.Table1', Index1) --to specify schema use single or double aposthrophy
DBCC SHOW_STATISTICS (Table1, Index1) WITH HISTOGRAM --RANGE_ROWS = number of rows in each step/bucket
DBCC SHOW_STATISTICS (Table1, Index1) WITH STAT_HEADER --Density is not used, Average key length is in bytes
DBCC SHOW_STATISTICS (Table1, Index1) WITH DENSITY_VECTOR --Density = 1 / (Distinct Values - 200)
 
SELECT * FROM sys.stats WHERE object_id = object_id('Table1')
SELECT * FROM sys.stats_columns WHERE object_id = object_id('Table1')
 
-- 23a. When the statistic is last updated
SELECT Name, stats_date(object_id,stats_id) FROM sys.stats WHERE object_id = object_id('Table3') --Can be used for both index and statistic
SELECT Name, stats_date(object_id,index_id) FROM sys.indexes WHERE object_id = object_id('Table3') and Type_Desc &amp;amp;lt;&amp;amp;gt; 'HEAP' --For index
 
-- 24. Update statistics
UPDATE STATISTICS Table1(Index1)
EXEC sp_updatestats -- All tables
 
-- 25. Delete a statistics
DROP STATISTICS Table1.Stat1 --Can't drop statistics of an index
 
-- 26. Create a constraint
ALTER TABLE Table1 ADD CONSTRAINT Constraint1 UNIQUE (Column2, Column3) --Unique constraint. This creates a unique index.
ALTER TABLE Table1 ADD CONSTRAINT Constraint1 CHECK (Column2 &amp;amp;lt; 10) --Check constraint
ALTER TABLE Table1 ADD CONSTRAINT Constraint1 PRIMARY KEY (Column1) --Primary Key constraint
ALTER TABLE Table1 ADD CONSTRAINT Constraint1 FOREIGN KEY (Column1) REFERENCES Table2(Colomn1) --Foreign Key constraint
ALTER TABLE Table1 ALTER COLUMN Coloumn1 INT NOT NULL --NOT NULL constraint
 
-- 26a. Rename a constraint
EXEC sp_rename 'Constraint1', 'Constraint2'
 
-- 27. Drop a constraint
ALTER TABLE Table1 DROP CONSTRAINT Constraint1
 
-- 28. Create a primary key
ALTER TABLE Table1 ADD CONSTRAINT PK1 PRIMARY KEY CLUSTERED (Column1, Column2) --Best: clustered PK on an identity column
 
-- 29. Delete a primary key
ALTER TABLE Table1 DROP CONSTRAINT PK1 --Takes a long time to recreate a Clustered PK
 
-- 30. Create a foreign key
ALTER TABLE Table1 ADD CONSTRAINT FK1 FOREIGN KEY (Column1) REFERENCES Table2(Colomn1) --Table2 must have PK on Column1
 
-- 30a. View foreign keys information
SELECT * FROM sys.foreign_keys
--Compatibility view: sys.sysforeignkeys
 
SELECT FK.name AS FKName,
object_name(FK.parent_object_id) AS ChildTable,
col_name(FK.parent_object_id, FKC.constraint_column_id) as ChildColumn,
object_name(FK.referenced_object_id) AS ParentTable, --In ANSI standard, &amp;amp;quot;Parent table&amp;amp;quot; is the table with the PK. But in SQL Server, &amp;amp;quot;Parent table&amp;amp;quot; is the table with the FK.
col_name(FKC.referenced_object_id, FKC.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys FK
JOIN sys.foreign_key_columns AS FKC ON FK.object_id = FKC.constraint_object_id
 
-- 31. Delete a foreign key
ALTER TABLE Table1 DROP CONSTRAINT FK1
 
-- 32. Disable a foreign key
ALTER TABLE Table1 NOCHECK CONSTRAINT FK1 --This is just disabling for UPDATE and INSERT, but not for Replication
ALTER TABLE Table1 NOCHECK CONSTRAINT ALL --Disable all FKs on Table1 (not PK, Check &amp;amp;amp; Unique constraints)
--Disable all FKs on all tables: EXECUTE sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
 
-- 33. Enable a foreign key
ALTER TABLE Table1 WITH CHECK CHECK CONSTRAINT FK1 --Enabling for UPDATE and INSERT, not for Replication
ALTER TABLE Table1 WITH CHECK CHECK CONSTRAINT ALL --Enable all FKs on Table1 (not PK, Check &amp;amp;amp; Unique constraints
--Enable all FKs on all tables: EXECUTE sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
 
-- 34. Disable an index
ALTER INDEX Index1 ON Table1 DISABLE --if the Clustered Index is disabled, NC indexes will be automatically disabled
ALTER INDEX ALL ON Table1 DISABLE --disable all indexes on Table1
 
-- 35. Enable an index
ALTER INDEX Index1 ON Table1 REBUILD
ALTER INDEX ALL on Table1 REBUILD --enable all indexes on Table1. Can be used for all indexes.
CREATE INDEX Index1 ON Table1(Column2) WITH (DROP_EXISTING = ON) --Cannot be used for indexes for Unique Constraint
DBCC DBREINDEX (Table1, Index1) --Can be used for all indexes
 
-- 36. Rename an index
IF EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1')
EXEC sp_rename 'Table1.Index1', 'Index2', 'INDEX'
 
-- 37. Create a columnstore index
IF NOT EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1')
CREATE COLUMNSTORE INDEX Index1 ON Table1(Column1)
 
-- 38. Delete a columnstore index
IF EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1')
DROP INDEX Table1.Index1
 
-- 39. Add a column
IF NOT EXISTS
( SELECT * FROM sys.columns
WHERE name = 'Column1' and object_id = object_id('Table1')
)
ALTER TABLE Table1 ADD Column1 INT
 
-- 40. Drop a column
IF EXISTS
( SELECT * FROM sys.columns
WHERE name = 'Column1' and object_id = object_id('Table1')
)
ALTER TABLE Table1 DROP COLUMN Column1
 
-- 41. Rename a column 
IF EXISTS 
( SELECT * FROM sys.columns 
 WHERE Name = 'Column1' and object_id = object_id('Table1')
)
EXEC sp_rename 'Table1.Column1', 'Column2', 'COLUMN'
 
-- 42. Change data type of a column
IF EXISTS 
( SELECT * FROM sys.columns 
 WHERE Name = 'Column1' and object_id = object_id('Table1')
)
ALTER TABLE Table1 ALTER COLUMN Col1 DECIMAL (9,2)
 
-- 43. Create a computed column
IF NOT EXISTS 
( SELECT * FROM sys.columns 
 WHERE Name = 'Column3' and object_id = object_id('Table1')
)
ALTER TABLE Table1 ADD Column3 AS Column1 * Column2
 
-- 44. Create a synonym
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'Synonym1')
 CREATE SYNONYM Synonym1 FOR Server1.Database1.Schema1.Table1
 
-- 45. Drop a synonym
IF EXISTS (SELECT * FROM sys.synonyms WHERE name = 'Synonym1')
 DROP SYNONYM Synonym1 
 
-- 46. Enable more than 15000 partitions (on 2008 R2)
EXEC sp_db_increased_partitions 'Database1', 'ON' --We can replace ON with TRUE
EXEC sp_db_increased_partitions 'Database1' -- to check
 
-- 47. Disable more than 15000 partitions (on 2008 R2)
EXEC sp_db_increased_partitions 'Database1', 'OFF' --We can replace OFF with FALSE. Ensure no tables has more than 1000 partitions first.
 
-- 48. Create a partitioned table 
CREATE PARTITION FUNCTION PF1 (INT) AS RANGE LEFT FOR VALUES (20140101, 20140201, 20140301)
GO
CREATE PARTITION SCHEME PS1 AS PARTITION PF1 
ALL TO ([PRIMARY]) --Ideally on different file groups located on different disks
GO
CREATE TABLE Table1 
( Column1 INT, 
 Column2 VARCHAR(20)
) ON PS1 (Colomn1)
GO
 
-- 48a. Find out if a table is partitioned or not
SELECT * FROM sys.tables T
JOIN sys.indexes I on T.object_id = I.object_id and I.[TYPE] in (0,1) --0 is heap, 1 is clustered index
JOIN sys.partition_schemes PS on PS.data_space_id = I.data_space_id
WHERE T.Name = 'Table1'
 
-- 49. Drop a partitioned table
DROP TABLE Table1
GO
DROP PARTITION SCHEME PS1
GO
DROP PARTITION FUNCTION PF1
GO
 
-- 50. Create a partitioned index
IF NOT EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1')
 CREATE INDEX Index1 ON TableP1(Column1, Column2) --Must include the partitioning column. If we don't, SQL Server will add it automatically.
IF NOT EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1')
 CREATE CLUSTERED INDEX Index1 ON TableP1(Column1, Column2) --Must include the partitioning column. 
 
-- 51. Delete a partitioned index
IF EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1' AND object_id = object_id('Table1'))
 DROP INDEX Table1.Index1
 
-- 52. Create an indexed view
IF NOT EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1' AND object_id = object_id('View1', 'VIEW'))
 CREATE UNIQUE CLUSTERED INDEX Index1 ON View1(Column1)
-- The view must not contain LEFT/RIGHT JOIN, SELECT in FROM, UNION, DISTINCT, MIN/MAX, CTE, COUNT, ORDER BY, PIVOT, OVER, APPLY.
-- The view must be created using WITH SCHEMABINDING. 
-- The first indexed view must be unique clustered.
 
-- 53. Drop an indexed view
IF EXISTS (SELECT * FROM SYS.INDEXES WHERE NAME = 'Index1' AND object_id = object_id('View1', 'VIEW'))
 DROP INDEX View1.Index1
 
-- 54. Add an extended property
IF NOT EXISTS (SELECT * FROM fn_listextendedproperty('Description',NULL,NULL,NULL,NULL,NULL,NULL))
EXEC sp_addextendedproperty 
 @name = N'Description', --Add extended property on the database
 @value = 'Risk Data Warehouse';
 
IF NOT EXISTS (SELECT * FROM fn_listextendedproperty('Description','SCHEMA','dbo','TABLE','Customer',NULL,NULL))
EXEC sp_addextendedproperty 
 @name = 'Description', --Add extended property on a table
 @value = 'This table stores the customer details', 
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'TABLE', @level1name = 'Customer'
 
IF NOT EXISTS (SELECT * FROM fn_listextendedproperty('Description','SCHEMA','dbo','TABLE','Account','COLUMN','Balance'))
EXEC sp_addextendedproperty 
 @name = 'Description', --Add extended property on a column
 @value = 'This column contains the balance of the account on a particular date',
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'TABLE', @level1name = 'Account',
 @level2type = 'COLUMN',@level2name = 'Balance'
 
-- 54a. View an extended property
SELECT O.Name as ObjectName, C.Name as ColumnName, EP.Name as ExtPropName, EP.Value as ExtPropValue
FROM sys.extended_properties EP
JOIN sys.objects O on O.object_id = EP.major_id
LEFT JOIN sys.columns C on C.object_id = EP.major_id and C.column_id = EP.minor_id
WHERE EP.class_desc = 'OBJECT_OR_COLUMN' --View the extended properties of all tables and columns
 
SELECT * FROM fn_listextendedproperty(NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- View the extended properties of the database
SELECT * FROM fn_listextendedproperty(NULL,'SCHEMA','dbo','TABLE','Table1',NULL,NULL) --View the extended properties of Table1
 
-- 55. Delete an extended property
IF EXISTS (SELECT * FROM fn_listextendedproperty('Description','SCHEMA','dbo','TABLE','Customer',NULL,NULL))
EXEC sp_dropextendedproperty 
 @name = 'Description', --Delete an extended property on a table
 @level0type = 'SCHEMA', @level0name = 'dbo',
 @level1type = 'TABLE', @level1name = 'Customer'
 
IF EXISTS (SELECT * FROM fn_listextendedproperty('Description','SCHEMA','dbo','TABLE','Account','COLUMN','Balance'))
EXEC sp_dropextendedproperty 
 @name = 'Description' --Delete an extended property on a column
 ,@level0type = 'SCHEMA', @level0name = 'dbo'
 ,@level1type = 'TABLE', @level1name = 'Account'
 ,@level2type = 'COLUMN', @level2name = 'Balance';