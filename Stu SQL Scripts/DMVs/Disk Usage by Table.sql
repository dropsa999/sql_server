WITH cte_tablestats AS
(
 SELECT 
   object_id
  ,[rows]   = SUM(CASE WHEN (index_id < 2) THEN row_count ELSE 0 END) -- index_id 0 = heap, 1 = clustered index
  ,[reserved]  = SUM(reserved_page_count)
  ,[data]   = SUM(CASE WHEN (index_id < 2)
         THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
         ELSE (lob_used_page_count + row_overflow_used_page_count)
         END)
  ,[used]   = SUM(used_page_count)
 FROM sys.dm_db_partition_stats -- returns page and row count information for partitions
 GROUP BY object_id
)
, cte_internal AS -- numbers for XML and full text indexes
(
 SELECT 
   it.parent_id
  ,[reserved]  = SUM(ps.reserved_page_count)
  ,[used]   = SUM(ps.used_page_count)
 FROM sys.dm_db_partition_stats ps
 INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
 WHERE it.internal_type IN (202,204) -- 202 = xml_index_nodes, 204 = fulltext_catalog_map
 GROUP BY it.parent_id
)
, cte_heaps AS
(
 SELECT object_id, [IsHeap] = 1 FROM sys.dm_db_partition_stats
 WHERE index_id = 0
)
, cte_spacecalc AS
(
-- sizes are retrieved in number of pages, so they should be multiplied by 8 to get the number of kilobytes
SELECT
  [schemaname] = a3.name
 ,[tablename] = a2.name
 ,[row_count] = a1.[rows]
 ,[reserved]  = (a1.reserved + ISNULL(a4.reserved,0)) * 8
 ,[data]   = a1.data * 8
 -- index = total pages used - pages used for actual data storage
 ,[index_size] = (CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data
        THEN (a1.used + ISNULL(a4.used,0)) - a1.data
        ELSE 0
        END) * 8
 -- unused = pages reserved - total pages used
 ,[unused]  = (CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used
        THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used
        ELSE 0
        END) * 8
 ,[IsHeap]  = ISNULL([IsHeap],0)
FROM  cte_tablestats a1
LEFT JOIN cte_internal a4 ON a4.parent_id = a1.object_id
INNER JOIN sys.all_objects a2 ON a1.object_id = a2.object_id -- retrieve table name
INNER JOIN sys.schemas  a3 ON a2.schema_id = a3.schema_id -- retrieve schema name
LEFT JOIN cte_heaps  h ON a1.object_id = h.object_id
WHERE a2.[type] <> N'S'
 AND a2.[type] <> N'IT'
)
SELECT
  [schemaname]
 ,[tablename]
 ,[row_count]
 ,[reserved]
 ,[data]
 ,[index_size]
 ,[unused]
 ,[IsHeap]
 ,[PercentageOfTotal] = CONVERT(NUMERIC(15,2),
         [reserved] / (SELECT totalReserved = CONVERT(NUMERIC(15,2),SUM([reserved])) FROM cte_spacecalc)
          )
FROM cte_spacecalc
ORDER BY [reserved] DESC;