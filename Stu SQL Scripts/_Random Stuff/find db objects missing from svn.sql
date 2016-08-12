DECLARE @Directory varchar(255) = 'X:\ReleaseRoot\Database\Source'

IF OBJECT_ID('tempdb..#DirTree') IS NOT NULL
    DROP TABLE #DirTree

CREATE TABLE #DirTree 
(
    Id int identity(1,1),
    SubDirectory varchar(255),
    Depth smallint,
    FileFlag bit,
    ParentDirectoryID int,
    ObjectName varchar(255)
)

INSERT INTO #DirTree (SubDirectory, Depth, FileFlag)
EXEC master..xp_dirtree @Directory, 10, 1

UPDATE #DirTree
SET ParentDirectoryID = (SELECT MAX(Id) FROM #DirTree d2 WHERE Depth = d.Depth - 1 AND d2.Id < d.Id)
from #DirTree as d

--select * from #DirTree where FileFlag = 1 and (SubDirectory not like '%.SQL' and SubDirectory not like '%.PRC')
UPDATE #DirTree
SET ObjectName = replace(replace(SubDirectory,'.sql',''), '.prc','')

	 
IF OBJECT_ID('tempdb..#ALLOBJECTS') IS NOT NULL
    DROP TABLE #ALLOBJECTS

select    db.type_desc as ObjectDescription
		, db.TwoPartObjectName
		,db.ObjectName
		,(select SubDirectory from #DirTree where Id = dt.ParentDirectoryID	) as SVNFolderLocation
		,case when dt.Id is null then 0 else 1 end as ExistsSVN
into #ALLOBJECTS	 
from 
(
	select o.name as ObjectName, s.name as [schema], s.name + '.' + o.name as TwoPartObjectName, o.type_desc
	from sys.objects o
	join sys.schemas as s on o.schema_id = s.schema_id
) as db
left outer join #DirTree as dt on db.TwoPartObjectName = dt.ObjectName
where db.type_desc not in ('USER_TABLE', 'SERVICE_QUEUE', 'CHECK_CONSTRAINT', 'DEFAULT_CONSTRAINT', 'FOREIGN_KEY_CONSTRAINT', 'PRIMARY_KEY_CONSTRAINT', 'UNIQUE_CONSTRAINT', 'SYSTEM_TABLE', 'INTERNAL_TABLE')


select * from #ALLOBJECTS

select	distinct 'dbo.' + o.name as objectname
, case when m.definition like '%exec @result = xp_interface_%' or m.definition like '%exec @result = dbo.xp_interface_%' then 1 else 0 end as IsWrapper
, case when m.definition like '%xp_interface_service_Build_Interface_Log%' then 1 else 0 end as HasLogging
, case when o.name like '%xp_interface_import_Bank%' then 1 else 0 end as IsGlobal
,ao.ExistsSVN

from	sys.sql_modules m
join	sys.objects o on  m.object_id = o.object_id
left outer join #ALLOBJECTS as ao on o.name = ao.ObjectName
where	o.name like 'xp_interface_import%'
