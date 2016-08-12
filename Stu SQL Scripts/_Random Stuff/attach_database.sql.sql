/******************************************************************************
    Name: Create Each Database for Attach
    Author: Ron Carpenter
    Date: 08/18/2009
    Revision: 1.0
    Purpose: This script will generate scripts to create each database on a
             sever for attach. It handles multiple files, multiple files,
             multiple files on a filegroup and multiple log files. There is a
             parameter to attach the logs or create the databases for attach
             with rebuild log.

    Author: Ron Carpenter
    Date: 01/20/2010
    Revision: 1.1
    Purpose: Updated the script to handle filestream data.
******************************************************************************/
USE [master] ;
GO
CREATE TABLE #_dba_migrate_db
    (
     FileID int IDENTITY(1,1)
                NOT NULL,
     DBName varchar(255) NOT NULL,
     DBGroupName varchar(255) NOT NULL,
     DBType tinyint NOT NULL,
     DBFileLogicalName varchar(255) NOT NULL,
     DBFileName varchar(1000) NOT NULL,
     DBSize varchar(15) NOT NULL,
     DBMaxSize varchar(15) NOT NULL,
     DBFileGrowth varchar(15) NOT NULL,
     CONSTRAINT PK_#_dba_migrate_db PRIMARY KEY CLUSTERED (DBType ASC,FileID ASC)
    ) ;
GO
sp_msforeachdb
'
USE [?] ;

IF DB_NAME() NOT IN (''master'',''model'',''msdb'',''tempdb'')
    INSERT INTO
        #_dba_migrate_db
        (
         DBName,
         DBGroupName,
         DBType,
         DBFileLogicalName,
         DBFileName,
         DBSize,
         DBMaxSize,
         DBFileGrowth
        )
        SELECT
            DB_NAME(),
            COALESCE(fg.name,''LOG''),
            f.type,
            LTRIM(RTRIM(f.name)),
            LTRIM(RTRIM(f.physical_name)),
            CAST(CEILING(((CONVERT(decimal(25,2),f.size) / 1024) * 8)) AS varchar(15)) + ''MB'',
            CASE f.max_size
              WHEN-1 THEN ''UNLIMITED''
              ELSE CAST(CEILING(((CONVERT(decimal(25,2),f.max_size) / 1024) * 8)) AS varchar(15)) + ''MB''
            END,
            CASE f.is_percent_growth
              WHEN 1 THEN CAST(f.growth AS varchar(15)) + ''%''
              ELSE CAST(CEILING(((CONVERT(decimal(25,2),f.growth) / 1024) * 8)) AS varchar(15)) + ''MB''
            END
        FROM
            sys.database_files f
        LEFT OUTER JOIN sys.filegroups fg
            ON f.data_space_id = fg.data_space_id ;
'
GO

SET NOCOUNT ON ;

SELECT
    'USE [master] ;' + CHAR(10) + 'GO' + CHAR(10) ;

DECLARE
    @DBName varchar(255),
    @DBGroupName varchar(255),
    @DBType int,
    @FileID int,
    @MaxData int,
    @MaxLog int,
    @MaxFileStrem int,
    @IncludeLog bit ;

SET @IncludeLog = 1 ;

DECLARE db_cursor CURSOR
    FOR SELECT DISTINCT
            DBName
        FROM
            #_dba_migrate_db

OPEN db_cursor ;

FETCH NEXT FROM db_cursor INTO @DBName ;
WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT
            'CREATE DATABASE ' + @DBName + ' ON'

        DECLARE group_cursor CURSOR
            FOR SELECT
                    MIN(FileID),
                    CASE DBType
                      WHEN 2 THEN 0
                      ELSE DBType
                    END,
                    DBGroupName
                FROM
                    #_dba_migrate_db
                WHERE
                    DBName = @DBName AND
                    (DBType <> 1 OR @IncludeLog = 1)
                GROUP BY
                    DBGroupName,
                    DBType
                ORDER BY
                    CASE DBType
                      WHEN 2 THEN 0
                      ELSE DBType
                    END,
                    MIN(FileID) ;

        OPEN group_cursor ;

        FETCH NEXT FROM group_cursor INTO @FileID,@DBType,@DBGroupName ;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT
                    @MaxData = MAX(FileID)
                FROM
                    #_dba_migrate_db
                WHERE
                    DBName = @DBName AND
                    DBType IN (0,2) ;

                SELECT
                    @MaxLog = MAX(FileID)
                FROM
                    #_dba_migrate_db
                WHERE
                    DBName = @DBName AND
                    DBType = 1 ;

                SELECT
                    CASE WHEN DBType = 0 AND DBGroupName = 'PRIMARY' THEN DBGroupName
                         WHEN DBType = 1 THEN DBGroupName + ' ON'
                         WHEN DBType = 2 THEN 'FILEGROUP ' + DBGroupName + ' CONTAINS FILESTREAM'
                         ELSE 'FILEGROUP ' + DBGroupName
                    END
                FROM
                    #_dba_migrate_db
                WHERE
                    FileID = @FileID ;

                SELECT
                    '(' + CHAR(10) + '	NAME = ' + DBFileLogicalName + ', ' + CHAR(10) + '	FILENAME = ''' + DBFileName + CASE WHEN DBType <> 2 THEN ''',' + CHAR(10) + '	SIZE = ' + DBSize + ',' + CHAR(10) + '	MAXSIZE = ' + DBMaxSize + ',' + CHAR(10) + '	FILEGROWTH = ' + DBFileGrowth
                                                                                                                             ELSE ''''
                                                                                                                        END + CHAR(10) + ')' + CASE WHEN FileID IN (@MaxData,@MaxLog) THEN ''
                                                                                                                                                    ELSE ','
                                                                                                                                               END
                FROM
                    #_dba_migrate_db
                WHERE
                    DBName = @DBName AND
                    DBGroupName = @DBGroupName ;

                FETCH NEXT FROM group_cursor INTO @FileID,@DBType,@DBGroupName ;
            END

        CLOSE group_cursor ;

        DEALLOCATE group_cursor ;

        SELECT
            CASE WHEN @IncludeLog = 1 THEN 'FOR ATTACH;'
                 ELSE 'FOR ATTACH_REBUILD_LOG;'
            END + CHAR(10) + 'GO' + CHAR(10) ;

        FETCH NEXT FROM db_cursor INTO @DBName ;
    END

CLOSE db_cursor ;

DEALLOCATE db_cursor ;

DROP TABLE #_dba_migrate_db ;
