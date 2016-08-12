USE master
GO
IF OBJECT_ID('dbo.sp_DBPermissions') IS NULL
    EXEC sp_executesql N'CREATE PROCEDURE dbo.sp_DBPermissions AS PRINT ''Stub'';'
GO
/*********************************************************************************************
sp_DBPermissions V5.0
Kenneth Fisher
 
http://www.sqlstudies.com
http://sqlstudies.com/free-scripts/sp_dbpermissions/
 
This stored procedure returns 3 data sets.  The first dataset is the list of database
principals, the second is role membership, and the third is object and database level
permissions.
    
The final 2 columns of each query are "Un-Do"/"Do" scripts.  For example removing a member
from a role or adding them to a role.  I am fairly confident in the role scripts, however, 
the scripts in the database principals query and database/object permissions query are 
works in progress.  In particular certificates, keys and column level permissions are not
scripted out.  Also while the scripts have worked flawlessly on the systems I've tested 
them on, these systems are fairly similar when it comes to security so I can't say that 
in a more complicated system there won't be the odd bug.
    
Standard disclaimer: You use scripts off of the web at your own risk.  I fully expect this
     script to work without issue but I've been known to be wrong before.
    
Parameters:
    @DBName
        If NULL use the current database, otherwise give permissions based on the parameter.
    
        There is a special case where you pass in ALL to the @DBName.  In this case the SP
        will loop through (yes I'm using a cursor) all of the DBs in sysdatabases and run
        the queries into temp tables before returning the results.  WARNINGS: If you use
        this option and have a large number of databases it will be SLOW.  If you use this
        option and don't specify any other parameters (say a specific @Principal) and have
        even a medium number of databases it will be SLOW.  Also the undo/do scripts do 
        not have USE statements in them so please take that into account.
    @Principal
        If NOT NULL then all three queries only pull for that database principal.  @Principal
        is a pattern check.  The queries check for any row where the passed in value exists.
        It uses the pattern '%' + @Principal + '%'
    @Role
        If NOT NULL then the roles query will pull members of the role.  If it is NOT NULL and
        @DBName is NULL then DB principal and permissions query will pull the principal row for
        the role and the permissions for the role.  @Role is a pattern check.  The queries 
        check for any row where the passed in value exists.  It uses the pattern '%' + @Role +
        '%'
    @Type
        If NOT NULL then all three queries will only pull principals of that type.  
        S = SQL login
        U = Windows login
        G = Windows group
        R = Server role
        C = Login mapped to a certificate
        K = Login mapped to an asymmetric key
    @ObjectName
        If NOT NULL then the third query will display permissions specific to the object 
        specified and the first two queries will display only those users with those specific
        permissions.  Unfortunately at this point only objects in sys.all_objects will work.
        This parameter uses the pattern '%' + @ObjectName + '%'
    @Permission
        If NOT NULL then the third query will display only permissions that match what is in
        the parameter.  The first two queries will display only those users with that specific
        permission.
    @LoginName
        If NOT NULL then each of the queries will only pull back database principals that
        have the same SID as a login that matches the pattern '%' + @LoginName + '%'
    @Print
        Defaults to 0, but if a 1 is passed in then the queries are not run but printed
        out instead.  This is primarily for debugging.
    
Data is ordered as follows
    1st result set: DBPrincipal
    2nd result set: RoleName, UserName if the parameter @Role is used else
                    UserName, RoleName
    3rd result set: ObjectName then Grantee_Name if the parameter @ObjectName
                    is used otherwise Grantee_Name, ObjectName
    
-- V2.0
-- 8/18/2013 – Create a stub if the SP doesn’t exist, then always do an alter
-- 8/18/2013 - Use instance collation for all concatenated strings
-- 9/04/2013 - dbo can’t be added or removed from roles.  Don’t script.
-- 9/04/2013 - Fix scripts for schema level permissions.
-- 9/04/2013 – Change print option to show values of variables not the 
--             Variable names.
-- V3.0
-- 10/5/2013 - Added @Type parameter to pull only principals of a given type.
-- 10/10/2013 - Added @ObjectName parameter to pull only permissions for a given object.
-- V4.0
-- 11/18/2013 - Added parameter names to sp_addrolemember and sp_droprolemember.
-- 11/19/2013 - Added an ORDER BY to each of the result sets.  See above for details.
-- 01/04/2014 - Add an ALL option to the DBName parameter.
-- V4.1
-- 02/07/2014 - Fix bug scripting permissions where object and schema have the same ID
-- 02/15/2014 - Add support for user defined types
-- 02/15/2014 - Fix: Add schema to object GRANT and REVOKE scripts
-- V5.0
-- 4/29/2014 - Fix: Removed extra print statements
-- 4/29/2014 - Fix: Added SET NOCOUNT ON
-- 4/29/2014 - Added a USE statement to the scripts when using the @DBName = 'All' option
-- 5/01/2014 - Added @Permission parameter
-- 5/14/2014 - Added additional permissions based on information from Kendal Van Dyke's
        post http://www.kendalvandyke.com/2014/02/using-sysobjects-when-scripting.html
-- 6/02/2014 - Added @LoginName parameter
*********************************************************************************************/
    
ALTER PROCEDURE dbo.sp_DBPermissions 
(
@DBName sysname = NULL, 
@Principal sysname = NULL, 
@Role sysname = NULL, 
@Type char(1) = NULL,
@ObjectName sysname = NULL,
@Permission sysname = NULL,
@LoginName sysname = NULL,
@Print bit = 0
)
AS
  
SET NOCOUNT ON
    
DECLARE @Collation nvarchar(50) 
SET @Collation = ' COLLATE ' + CAST(SERVERPROPERTY('Collation') AS nvarchar(50))
    
DECLARE @sql nvarchar(max)
DECLARE @sql2 nvarchar(max)
DECLARE @ObjectList nvarchar(max)
DECLARE @use nvarchar(500)
DECLARE @AllDBNames sysname
    
IF @DBName IS NULL OR @DBName = 'All'
    BEGIN
        SET @use = ''
        IF @DBName IS NULL
            SELECT @DBName = db_name(database_id) 
            FROM sys.dm_exec_requests 
            WHERE session_id = @@SPID
    END
ELSE
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DBName)
        SET @use = 'USE ' + QUOTENAME(@DBName) + ';' + CHAR(13)
    ELSE
        BEGIN
            RAISERROR (N'%s is not a valid database name.',
                            16, 
                            1,
                            @DBName)
            RETURN
        END
    
IF LEN(ISNULL(@Principal,'')) > 0
    SET @Principal = '%' + @Principal + '%'
        
IF LEN(ISNULL(@Role,'')) > 0
    SET @Role = '%' + @Role + '%'
    
IF LEN(ISNULL(@ObjectName,'')) > 0
    SET @ObjectName = '%' + @ObjectName + '%'
  
IF LEN(ISNULL(@LoginName,'')) > 0
    SET @LoginName = '%' + @LoginName + '%'
  
IF @Print = 1 AND @DBName = 'All'
    BEGIN
        PRINT 'DECLARE @AllDBNames sysname'
        PRINT 'SET @AllDBNames = ''master'''
        PRINT ''
    END
  
    
--=========================================================================
-- Database Principals
SET @sql = 
    @use +
    'SELECT ' + CASE WHEN @DBName = 'All' THEN '@AllDBNames' ELSE '''' + @DBName + '''' END + ' AS DBName,' + 
    ' DBPrincipals.name AS DBPrincipal, SrvPrincipals.name AS SrvPrincipal, DBPrincipals.sid, ' + CHAR(13) + 
    '   DBPrincipals.type, DBPrincipals.type_desc, DBPrincipals.default_schema_name, ' + CHAR(13) + 
    '   DBPrincipals.create_date, DBPrincipals.modify_date, DBPrincipals.is_fixed_role, ' + CHAR(13) +
    '   Authorizations.name AS Role_Authorization, ' + CHAR(13) +  
    '   CASE WHEN DBPrincipals.is_fixed_role = 0 THEN ' + CHAR(13) + 
    CASE WHEN @DBName = 'All' THEN '   ''USE ['' + @AllDBNames + '']; '' + ' +CHAR(13) ELSE '' END + 
    '           ''DROP '' + CASE DBPrincipals.[type] WHEN ''C'' THEN NULL ' + CHAR(13) + 
    '               WHEN ''K'' THEN NULL ' + CHAR(13) + 
    '               WHEN ''R'' THEN ''ROLE'' ' + CHAR(13) + 
    '               WHEN ''A'' THEN ''APPLICATION ROLE'' ' + CHAR(13) + 
    '               ELSE ''USER'' END + ' + CHAR(13) + 
    '           '' ''+QUOTENAME(DBPrincipals.name' + @Collation + ') + '';'' ELSE NULL END AS Drop_Script, ' + CHAR(13) + 
    CASE WHEN @DBName = 'All' THEN '   ''USE ['' + @AllDBNames + '']; '' + ' +CHAR(13) ELSE '' END + 
    '   CASE WHEN DBPrincipals.is_fixed_role = 0 THEN ' + CHAR(13) + 
    '           ''CREATE '' + CASE DBPrincipals.[type] WHEN ''C'' THEN NULL ' + CHAR(13) + 
    '               WHEN ''K'' THEN NULL ' + CHAR(13) + 
    '               WHEN ''R'' THEN ''ROLE'' ' + CHAR(13) + 
    '               WHEN ''A'' THEN ''APPLICATION ROLE'' ' + CHAR(13) + 
    '               ELSE ''USER'' END + ' + CHAR(13) + 
    '           '' ''+QUOTENAME(DBPrincipals.name' + @Collation + ') END + ' + CHAR(13) + 
    '           CASE WHEN DBPrincipals.[type] = ''R'' THEN ' + CHAR(13) + 
    '               ISNULL('' AUTHORIZATION ''+QUOTENAME(Authorizations.name' + @Collation + '),'''') ' + CHAR(13) + 
    '               WHEN DBPrincipals.[type] = ''A'' THEN ' + CHAR(13) + 
    '                   ''''  ' + CHAR(13) + 
    '               WHEN DBPrincipals.[type] NOT IN (''C'',''K'') THEN ' + CHAR(13) + 
    '                   ISNULL('' FOR LOGIN '' + 
                            QUOTENAME(SrvPrincipals.name' + @Collation + '),'' WITHOUT LOGIN'') +  ' + CHAR(13) + 
    '                   ISNULL('' WITH DEFAULT_SCHEMA =  ''+
                            QUOTENAME(DBPrincipals.default_schema_name' + @Collation + '),'''') ' + CHAR(13) + 
    '           ELSE '''' ' + CHAR(13) + 
    '           END + '';'' +  ' + CHAR(13) + 
    '           CASE WHEN DBPrincipals.[type] NOT IN (''C'',''K'',''R'',''A'') ' + CHAR(13) + 
    '               AND SrvPrincipals.name IS NULL ' + CHAR(13) + 
    '               AND DBPrincipals.sid IS NOT NULL ' + CHAR(13) + 
    '               AND DBPrincipals.sid NOT IN (0x00, 0x01)  ' + CHAR(13) + 
    '               THEN '' -- Possible missing server principal''  ' + CHAR(13) + 
    '               ELSE '''' END ' + CHAR(13) + 
    '       AS Create_Script ' + CHAR(13) + 
    'FROM sys.database_principals DBPrincipals ' + CHAR(13) + 
    'LEFT OUTER JOIN sys.database_principals Authorizations ' + CHAR(13) + 
    '   ON DBPrincipals.owning_principal_id = Authorizations.principal_id ' + CHAR(13) + 
    'LEFT OUTER JOIN sys.server_principals SrvPrincipals ' + CHAR(13) + 
    '   ON DBPrincipals.sid = SrvPrincipals.sid ' + CHAR(13) + 
    '   AND DBPrincipals.sid NOT IN (0x00, 0x01) ' + CHAR(13) + 
    'WHERE 1=1 '
    
IF LEN(ISNULL(@Principal,@Role)) > 0 
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND DBPrincipals.name LIKE ' + 
            ISNULL(+QUOTENAME(@Principal,''''),QUOTENAME(@Role,'''')) 
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND DBPrincipals.name LIKE ISNULL(@Principal,@Role) '
    
IF LEN(@Type) = 1
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND DBPrincipals.type = ' + QUOTENAME(@Type,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND DBPrincipals.type = @Type'
    
IF LEN(@LoginName) > 0
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND SrvPrincipals.name LIKE ' + QUOTENAME(@LoginName,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND SrvPrincipals.name LIKE @LoginName'
  
IF LEN(@ObjectName) > 0
    BEGIN
        SET @sql = @sql + CHAR(13) + 
        '   AND EXISTS (SELECT 1 ' + CHAR(13) + 
        '               FROM sys.all_objects [Objects] ' + CHAR(13) + 
        '               INNER JOIN sys.database_permissions Permission ' + CHAR(13) +  
        '                   ON Permission.major_id = [Objects].object_id ' + CHAR(13) + 
        '               WHERE Permission.major_id = [Objects].object_id ' + CHAR(13) + 
        '                 AND Permission.grantee_principal_id = DBPrincipals.principal_id ' + CHAR(13)
          
        IF @Print = 1
            SET @sql = @sql + '                 AND [Objects].name LIKE ' + QUOTENAME(@ObjectName,'''') 
        ELSE
            SET @sql = @sql + '                 AND [Objects].name LIKE @ObjectName'
  
        SET @sql = @sql + ')'
    END
  
IF LEN(@Permission) > 0
    BEGIN
        SET @sql = @sql + CHAR(13) + 
        '   AND EXISTS (SELECT 1 ' + CHAR(13) + 
        '               FROM sys.database_permissions Permission ' + CHAR(13) +  
        '               WHERE Permission.grantee_principal_id = DBPrincipals.principal_id ' + CHAR(13)
          
        IF @Print = 1
            SET @sql = @sql + '                 AND Permission.permission_name LIKE ' + QUOTENAME(@Permission,'''') 
        ELSE
            SET @sql = @sql + '                 AND Permission.permission_name LIKE @Permission'
  
        SET @sql = @sql + ')'
    END
  
SET @sql = @sql + CHAR(13) +
    'ORDER BY DBPrincipals.name '
    
IF @Print = 1
    PRINT '-- Database Principals' + CHAR(13) + CAST(@sql AS varchar(max)) + CHAR(13) + CHAR(13)
ELSE
    IF @DBName = 'All'
        BEGIN
            -- Create temp table to store the data in
            CREATE TABLE #DBPrincipals (
                DBName sysname NULL,
                DBPrincipal sysname NULL,
                SrvPrincipal sysname NULL,
                sid varbinary(85) NULL,
                type char(1) NULL,
                type_desc nchar(60) NULL,
                default_schema_name sysname NULL,
                create_date datetime NULL,
                modify_date datetime NULL,
                is_fixed_role bit NULL,
                Role_Authorization sysname NULL,
                Drop_Script varchar(max) NULL,
                Create_Script varchar(max) NULL
                )
    
            -- Add insert statement to @sql
            SET @sql =  'INSERT INTO #DBPrincipals ' + CHAR(13) + 
                        @sql
    
            -- Declare a READ_ONLY cursor to loop through the databases
            DECLARE cur_DBList CURSOR
            READ_ONLY
            FOR SELECT name FROM sys.databases ORDER BY name
    
            OPEN cur_DBList
    
            FETCH NEXT FROM cur_DBList INTO @AllDBNames
            WHILE (@@fetch_status <> -1)
            BEGIN
                IF (@@fetch_status <> -2)
                BEGIN
                    SET @sql2 = 'USE ' + QUOTENAME(@AllDBNames) + ';' + CHAR(13) + @sql
                    EXEC sp_executesql @sql2, 
                        N'@Principal sysname, @Role sysname, @Type char(1), @ObjectName sysname, 
                        @AllDBNames sysname, @Permission sysname, @LoginName sysname', 
                        @Principal, @Role, @Type, @ObjectName, @AllDBNames, @Permission, @LoginName
                    -- PRINT @sql2
                END
                FETCH NEXT FROM cur_DBList INTO @AllDBNames
            END
    
            CLOSE cur_DBList
            DEALLOCATE cur_DBList
            SELECT * FROM #DBPrincipals
            DROP TABLE #DBPrincipals
        END
    ELSE
        EXEC sp_executesql @sql, N'@Principal sysname, @Role sysname, @Type char(1), 
            @ObjectName sysname, @Permission sysname, @LoginName sysname', 
            @Principal, @Role, @Type, @ObjectName, @Permission, @LoginName
    
--=========================================================================
-- Database Role Members
SET @sql = 
    @use + 
    'SELECT ' + CASE WHEN @DBName = 'All' THEN '@AllDBNames' ELSE '''' + @DBName + '''' END + ' AS DBName,' + 
    ' Users.name AS UserName, Roles.name AS RoleName, ' + CHAR(13) + 
    CASE WHEN @DBName = 'All' THEN '   ''USE ['' + @AllDBNames + '']; '' + ' + CHAR(13) ELSE '' END + 
    '   ''EXEC sp_droprolemember @rolename = ''+QUOTENAME(Roles.name' + @Collation + 
                ','''''''')+'', @membername = ''+QUOTENAME(CASE WHEN Users.name = ''dbo'' THEN NULL
                ELSE Users.name END' + @Collation + 
                ','''''''')+'';'' AS Drop_Script, ' + CHAR(13) + 
    CASE WHEN @DBName = 'All' THEN '   ''USE ['' + @AllDBNames + '']; '' + ' + CHAR(13) ELSE '' END + 
    '   ''EXEC sp_addrolemember @rolename = ''+QUOTENAME(Roles.name' + @Collation + 
                ','''''''')+'', @membername = ''+QUOTENAME(CASE WHEN Users.name = ''dbo'' THEN NULL
                ELSE Users.name END' + @Collation + 
                ','''''''')+'';'' AS Add_Script ' + CHAR(13) + 
    'FROM sys.database_role_members RoleMembers ' + CHAR(13) + 
    'JOIN sys.database_principals Users ' + CHAR(13) + 
    '   ON RoleMembers.member_principal_id = Users.principal_id ' + CHAR(13) + 
    'JOIN sys.database_principals Roles ' + CHAR(13) + 
    '   ON RoleMembers.role_principal_id = Roles.principal_id ' + CHAR(13) + 
    'WHERE 1=1 '
        
IF LEN(ISNULL(@Principal,'')) > 0
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND Users.name LIKE '+QUOTENAME(@Principal,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND Users.name LIKE @Principal'
    
IF LEN(ISNULL(@Role,'')) > 0
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND Roles.name LIKE '+QUOTENAME(@Role,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND Roles.name LIKE @Role'
    
IF LEN(@Type) = 1
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND Users.type = ' + QUOTENAME(@Type,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND Users.type = @Type'
  
IF LEN(@LoginName) > 0
    BEGIN
        SET @sql = @sql + CHAR(13) + 
        '   AND EXISTS (SELECT 1 ' + CHAR(13) + 
        '               FROM sys.server_principals SrvPrincipals ' + CHAR(13) + 
        '               WHERE Users.sid NOT IN (0x00, 0x01) ' + CHAR(13) + 
        '                 AND SrvPrincipals.sid = Users.sid ' + CHAR(13) + 
        '                 AND Users.type NOT IN (''R'') ' + CHAR(13) 
        IF @Print = 1
            SET @sql = @sql + CHAR(13) + '  AND SrvPrincipals.name LIKE ' + QUOTENAME(@LoginName,'''')
        ELSE
            SET @sql = @sql + CHAR(13) + '  AND SrvPrincipals.name LIKE @LoginName'
  
        SET @sql = @sql + ')'
    END
  
IF LEN(@ObjectName) > 0
    BEGIN
        SET @sql = @sql + CHAR(13) + 
        '   AND EXISTS (SELECT 1 ' + CHAR(13) + 
        '               FROM sys.all_objects [Objects] ' + CHAR(13) + 
        '               INNER JOIN sys.database_permissions Permission ' + CHAR(13) +  
        '                   ON Permission.major_id = [Objects].object_id ' + CHAR(13) + 
        '               WHERE Permission.major_id = [Objects].object_id ' + CHAR(13) + 
        '                 AND Permission.grantee_principal_id = Users.principal_id ' + CHAR(13)
          
        IF @Print = 1
            SET @sql = @sql + '                 AND [Objects].name LIKE ' + QUOTENAME(@ObjectName,'''') 
        ELSE
            SET @sql = @sql + '                 AND [Objects].name LIKE @ObjectName'
  
        SET @sql = @sql + ')'
    END
  
IF LEN(@Permission) > 0
    BEGIN
        SET @sql = @sql + CHAR(13) + 
        '   AND EXISTS (SELECT 1 ' + CHAR(13) + 
        '               FROM sys.database_permissions Permission ' + CHAR(13) +  
        '               WHERE Permission.grantee_principal_id = Users.principal_id ' + CHAR(13)
          
        IF @Print = 1
            SET @sql = @sql + '                 AND Permission.permission_name LIKE ' + QUOTENAME(@Permission,'''') 
        ELSE
            SET @sql = @sql + '                 AND Permission.permission_name LIKE @Permission'
  
        SET @sql = @sql + ')'
    END
  
IF LEN(@Role) > 0
    SET @sql = @sql + CHAR(13) +
        'ORDER BY Roles.name, Users.name '
ELSE
    SET @sql = @sql + CHAR(13) +
        'ORDER BY Users.name, Roles.name '
    
IF @Print = 1
    PRINT '-- Database Role Members' + CHAR(13) + CAST(@sql AS varchar(max)) + CHAR(13) + CHAR(13)
ELSE
    IF @DBName = 'All'
        BEGIN
            -- Create temp table to store the data in
            CREATE TABLE #DBRoles (
                DBName sysname NULL,
                UserName sysname NULL,
                RoleName sysname NULL,
                Drop_Script varchar(max) NULL,
                Add_Script varchar(max) NULL
                )
    
            -- Add insert statement to @sql
            SET @sql =  'INSERT INTO #DBRoles ' + CHAR(13) + 
                        @sql
    
            -- Declare a READ_ONLY cursor to loop through the databases
            DECLARE cur_DBList CURSOR
            READ_ONLY
            FOR SELECT name FROM sys.databases ORDER BY name
    
            OPEN cur_DBList
    
            FETCH NEXT FROM cur_DBList INTO @AllDBNames
            WHILE (@@fetch_status <> -1)
            BEGIN
                IF (@@fetch_status <> -2)
                BEGIN
                    SET @sql2 = 'USE ' + QUOTENAME(@AllDBNames) + ';' + CHAR(13) + @sql
                    EXEC sp_executesql @sql2, 
                        N'@Principal sysname, @Role sysname, @Type char(1), @ObjectName sysname, 
                        @AllDBNames sysname, @Permission sysname, @LoginName sysname', 
                        @Principal, @Role, @Type, @ObjectName, @AllDBNames, @Permission, @LoginName
                    -- PRINT @sql2
                END
                FETCH NEXT FROM cur_DBList INTO @AllDBNames
            END
    
            CLOSE cur_DBList
            DEALLOCATE cur_DBList
            SELECT * FROM #DBRoles
            DROP TABLE #DBRoles
        END
    ELSE
        EXEC sp_executesql @sql, N'@Principal sysname, @Role sysname, @Type char(1), 
            @ObjectName sysname, @Permission sysname, @LoginName sysname', 
            @Principal, @Role, @Type, @ObjectName, @Permission, @LoginName
    
--=========================================================================
-- Database & object Permissions
SET @ObjectList =
    '; WITH ObjectList AS (' + CHAR(13) + 
    '   SELECT NULL AS SchemaName , ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       database_id AS id, ' + CHAR(13) + 
    '       ''DATABASE'' AS class_desc,' + CHAR(13) + 
    '       '''' AS class ' + CHAR(13) + 
    '   FROM master.sys.databases' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT SCHEMA_NAME(sys.all_objects.schema_id) ' + @Collation + ' AS SchemaName,' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       object_id AS id, ' + CHAR(13) + 
    '       ''OBJECT_OR_COLUMN'' AS class_desc,' + CHAR(13) + 
    '       ''OBJECT'' AS class ' + CHAR(13) + 
    '   FROM sys.all_objects' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT name ' + @Collation + ' AS SchemaName, ' + CHAR(13) + 
    '       NULL AS name, ' + CHAR(13) + 
    '       schema_id AS id, ' + CHAR(13) + 
    '       ''SCHEMA'' AS class_desc,' + CHAR(13) + 
    '       ''SCHEMA'' AS class ' + CHAR(13) + 
    '   FROM sys.schemas' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       principal_id AS id, ' + CHAR(13) + 
    '       ''DATABASE_PRINCIPAL'' AS class_desc,' + CHAR(13) + 
    '       CASE type_desc ' + CHAR(13) + 
    '           WHEN ''APPLICATION_ROLE'' THEN ''APPLICATION ROLE'' ' + CHAR(13) + 
    '           WHEN ''DATABASE_ROLE'' THEN ''ROLE'' ' + CHAR(13) + 
    '           ELSE ''USER'' END AS class ' + CHAR(13) + 
    '   FROM sys.database_principals' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       assembly_id AS id, ' + CHAR(13) + 
    '       ''ASSEMBLY'' AS class_desc,' + CHAR(13) + 
    '       ''ASSEMBLY'' AS class ' + CHAR(13) + 
    '   FROM sys.assemblies' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT SCHEMA_NAME(sys.types.schema_id) ' + @Collation + ' AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       user_type_id AS id, ' + CHAR(13) + 
    '       ''TYPE'' AS class_desc,' + CHAR(13) + 
    '       ''TYPE'' AS class ' + CHAR(13) + 
    '   FROM sys.types' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT SCHEMA_NAME(schema_id) ' + @Collation + ' AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       xml_collection_id AS id, ' + CHAR(13) + 
    '       ''XML_SCHEMA_COLLECTION'' AS class_desc,' + CHAR(13) + 
    '       ''XML SCHEMA COLLECTION'' AS class ' + CHAR(13) + 
    '   FROM sys.xml_schema_collections' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       message_type_id AS id, ' + CHAR(13) + 
    '       ''MESSAGE_TYPE'' AS class_desc,' + CHAR(13) + 
    '       ''MESSAGE TYPE'' AS class ' + CHAR(13) + 
    '   FROM sys.service_message_types' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       service_contract_id AS id, ' + CHAR(13) + 
    '       ''SERVICE_CONTRACT'' AS class_desc,' + CHAR(13) + 
    '       ''CONTRACT'' AS class ' + CHAR(13) + 
    '   FROM sys.service_contracts' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       service_id AS id, ' + CHAR(13) + 
    '       ''SERVICE'' AS class_desc,' + CHAR(13) + 
    '       ''SERVICE'' AS class ' + CHAR(13) + 
    '   FROM sys.services' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       remote_service_binding_id AS id, ' + CHAR(13) + 
    '       ''REMOTE_SERVICE_BINDING'' AS class_desc,' + CHAR(13) + 
    '       ''REMOTE SERVICE BINDING'' AS class ' + CHAR(13) + 
    '   FROM sys.remote_service_bindings' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       route_id AS id, ' + CHAR(13) + 
    '       ''ROUTE'' AS class_desc,' + CHAR(13) + 
    '       ''ROUTE'' AS class ' + CHAR(13) + 
    '   FROM sys.routes' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       fulltext_catalog_id AS id, ' + CHAR(13) + 
    '       ''FULLTEXT_CATALOG'' AS class_desc,' + CHAR(13) + 
    '       ''FULLTEXT CATALOG'' AS class ' + CHAR(13) + 
    '   FROM sys.fulltext_catalogs' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       symmetric_key_id AS id, ' + CHAR(13) + 
    '       ''SYMMETRIC_KEY'' AS class_desc,' + CHAR(13) + 
    '       ''SYMMETRIC KEY'' AS class ' + CHAR(13) + 
    '   FROM sys.symmetric_keys' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       certificate_id AS id, ' + CHAR(13) + 
    '       ''CERTIFICATE'' AS class_desc,' + CHAR(13) + 
    '       ''CERTIFICATE'' AS class ' + CHAR(13) + 
    '   FROM sys.certificates' + CHAR(13) + 
    '   UNION ALL' + CHAR(13) + 
    '   SELECT NULL AS SchemaName, ' + CHAR(13) + 
    '       name ' + @Collation + ' AS name, ' + CHAR(13) + 
    '       asymmetric_key_id AS id, ' + CHAR(13) + 
    '       ''ASYMMETRIC_KEY'' AS class_desc,' + CHAR(13) + 
    '       ''ASYMMETRIC KEY'' AS class ' + CHAR(13) + 
    '   FROM sys.asymmetric_keys' + CHAR(13) +  
    '   ) ' + CHAR(13)
  
    SET @sql =
    'SELECT ' + CASE WHEN @DBName = 'All' THEN '@AllDBNames' ELSE '''' + @DBName + '''' END + ' AS DBName,' + CHAR(13) + 
    ' Grantee.name AS Grantee_Name, Grantor.name AS Grantor_Name, ' + CHAR(13) + 
    '   Permission.class_desc, Permission.permission_name, ' + CHAR(13) + 
    '   ObjectList.name AS ObjectName, ' + CHAR(13) + 
    '   ObjectList.SchemaName, ' + CHAR(13) + 
    '   Permission.state_desc,  ' + CHAR(13) + 
    CASE WHEN @DBName = 'All' THEN '   ''USE ['' + @AllDBNames + '']; '' + ' + CHAR(13) ELSE '' END + 
    '   ''REVOKE '' + ' + CHAR(13) + 
    '   CASE WHEN Permission.[state]  = ''W'' THEN ''GRANT OPTION FOR '' ELSE '''' END + ' + CHAR(13) + 
    '   '' '' + Permission.permission_name' + @Collation + ' +  ' + CHAR(13) + 
    '       CASE WHEN Permission.major_id <> 0 THEN '' ON '' + ' + CHAR(13) + 
    '           ObjectList.class + ''::'' +  ' + CHAR(13) + 
    '           ISNULL(QUOTENAME(ObjectList.SchemaName),'''') + ' + CHAR(13) + 
    '           CASE WHEN ObjectList.SchemaName + ObjectList.name IS NULL THEN '''' ELSE ''.'' END + ' + CHAR(13) + 
    '           ISNULL(QUOTENAME(ObjectList.name),'''') ' + CHAR(13) + 
    '           ' + @Collation + ' + '' '' ELSE '''' END + ' + CHAR(13) + 
    '       '' FROM '' + QUOTENAME(Grantee.name' + @Collation + ')  + ''; '' AS Revoke_Statement, ' + CHAR(13) + 
    CASE WHEN @DBName = 'All' THEN '   ''USE ['' + @AllDBNames + '']; '' + ' + CHAR(13) ELSE '' END + 
    '   CASE WHEN Permission.[state]  = ''W'' THEN ''GRANT'' ELSE Permission.state_desc' + @Collation + 
            ' END + ' + CHAR(13) + 
    '       '' '' + Permission.permission_name' + @Collation + ' + ' + CHAR(13) + 
    '       CASE WHEN Permission.major_id <> 0 THEN '' ON '' + ' + CHAR(13) + 
    '           ObjectList.class + ''::'' +  ' + CHAR(13) + 
    '           ISNULL(QUOTENAME(ObjectList.SchemaName),'''') + ' + CHAR(13) + 
    '           CASE WHEN ObjectList.SchemaName + ObjectList.name IS NULL THEN '''' ELSE ''.'' END + ' + CHAR(13) + 
    '           ISNULL(QUOTENAME(ObjectList.name),'''') ' + CHAR(13) + 
    '           ' + @Collation + ' + '' '' ELSE '''' END + ' + CHAR(13) + 
    '       '' TO '' + QUOTENAME(Grantee.name' + @Collation + ')  + '' '' +  ' + CHAR(13) + 
    '       CASE WHEN Permission.[state]  = ''W'' THEN '' WITH GRANT OPTION '' ELSE '''' END +  ' + CHAR(13) + 
    '       '' AS ''+ QUOTENAME(Grantor.name' + @Collation + ')+'';'' AS Grant_Statement ' + CHAR(13) + 
    'FROM sys.database_permissions Permission ' + CHAR(13) + 
    'JOIN sys.database_principals Grantee ' + CHAR(13) + 
    '   ON Permission.grantee_principal_id = Grantee.principal_id ' + CHAR(13) + 
    'JOIN sys.database_principals Grantor ' + CHAR(13) + 
    '   ON Permission.grantor_principal_id = Grantor.principal_id ' + CHAR(13) + 
    'LEFT OUTER JOIN ObjectList ' + CHAR(13) + 
    '   ON Permission.major_id = ObjectList.id ' + CHAR(13) + 
    '   AND Permission.class_desc = ObjectList.class_desc ' + CHAR(13) + 
    'WHERE 1=1 '
    
IF LEN(ISNULL(@Principal,@Role)) > 0
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND Grantee.name LIKE ' + ISNULL(QUOTENAME(@Principal,''''),QUOTENAME(@Role,'''')) 
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND Grantee.name LIKE ISNULL(@Principal,@Role) '
            
IF LEN(@Type) = 1
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND Grantee.type = ' + QUOTENAME(@Type,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND Grantee.type = @Type'
    
IF LEN(@ObjectName) > 0
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND ObjectList.name LIKE ' + QUOTENAME(@ObjectName,'''') 
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND ObjectList.name LIKE @ObjectName '
    
IF LEN(@Permission) > 0
    IF @Print = 1
        SET @sql = @sql + CHAR(13) + '  AND Permission.permission_name = ' + QUOTENAME(@Permission,'''')
    ELSE
        SET @sql = @sql + CHAR(13) + '  AND Permission.permission_name = @Permission'
  
IF LEN(@LoginName) > 0
    BEGIN
        SET @sql = @sql + CHAR(13) + 
        '   AND EXISTS (SELECT 1 ' + CHAR(13) + 
        '               FROM sys.server_principals SrvPrincipals ' + CHAR(13) + 
        '               WHERE SrvPrincipals.sid = Grantee.sid ' + CHAR(13) + 
        '                 AND Grantee.sid NOT IN (0x00, 0x01) ' + CHAR(13) + 
        '                 AND Grantee.type NOT IN (''R'') ' + CHAR(13) 
        IF @Print = 1
            SET @sql = @sql + CHAR(13) + '  AND SrvPrincipals.name LIKE ' + QUOTENAME(@LoginName,'''')
        ELSE
            SET @sql = @sql + CHAR(13) + '  AND SrvPrincipals.name LIKE @LoginName'
  
        SET @sql = @sql + ')'
    END
  
IF LEN(@ObjectName) > 0
    SET @sql = @sql + CHAR(13) +
        'ORDER BY ObjectList.name, Grantee.name '
ELSE
    SET @sql = @sql + CHAR(13) +
        'ORDER BY Grantee.name, ObjectList.name '
    
IF @Print = 1
    BEGIN
        SET @sql = @use+@ObjectList+@sql
        PRINT '-- Database & object Permissions' 
        PRINT CAST(@sql AS varchar(max))
    END
ELSE
    IF @DBName = 'All'
        BEGIN
            -- Create temp table to store the data in
            CREATE TABLE #DBPermissions (
                DBName sysname NULL,
                Grantee_Name sysname NULL,
                Grantor_Name sysname NULL,
                class_desc nvarchar(60) NULL,
                permission_name nvarchar(128) NULL,
                ObjectName sysname NULL,
                SchemaName sysname NULL,
                state_desc nvarchar(60) NULL,
                Revoke_Script varchar(max) NULL,
                Grant_Script varchar(max) NULL
                )
    
            -- Add insert statement to @sql
            SET @sql =  @use + @ObjectList + 
                        'INSERT INTO #DBPermissions ' + CHAR(13) + 
                        @sql
    
            -- Declare a READ_ONLY cursor to loop through the databases
            DECLARE cur_DBList CURSOR
            READ_ONLY
            FOR SELECT name FROM sys.databases ORDER BY name
    
            OPEN cur_DBList
    
            FETCH NEXT FROM cur_DBList INTO @AllDBNames
            WHILE (@@fetch_status <> -1)
            BEGIN
                IF (@@fetch_status <> -2)
                BEGIN
                    SET @sql2 = 'USE ' + QUOTENAME(@AllDBNames) + ';' + CHAR(13) + @sql
                    EXEC sp_executesql @sql2, 
                        N'@Principal sysname, @Role sysname, @Type char(1), @ObjectName sysname, 
                            @AllDBNames sysname, @Permission sysname, @LoginName sysname', 
                        @Principal, @Role, @Type, @ObjectName, @AllDBNames, @Permission, @LoginName
                    -- PRINT @sql2
                END
                FETCH NEXT FROM cur_DBList INTO @AllDBNames
            END
    
            CLOSE cur_DBList
            DEALLOCATE cur_DBList
            SELECT * FROM #DBPermissions
            DROP TABLE #DBPermissions
        END
    ELSE
        BEGIN
            SET @sql = @use + @ObjectList + @sql
            EXEC sp_executesql @sql, N'@Principal sysname, @Role sysname, @Type char(1), 
                @ObjectName sysname, @Permission sysname, @LoginName sysname', 
                @Principal, @Role, @Type, @ObjectName, @Permission, @LoginName
        END
GO