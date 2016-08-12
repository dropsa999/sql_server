SELECT
        name,
        ps.index_id,
        ps.row_count,
        create_date,
        modify_date
    FROM tempdb.sys.objects AS so
    join tempdb.sys.dm_db_partition_stats ps on so.object_id = ps.object_id
    WHERE
        name LIKE N'#%'
        and row_count > 0
