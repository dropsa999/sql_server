USE master
GO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'sp_ActiveProcesses')
	EXEC ('CREATE PROC dbo.sp_ActiveProcesses AS SELECT ''stub version, to be replaced''')
GO
ALTER PROC dbo.sp_ActiveProcesses AS 
BEGIN	

	/*get active processes*/
	select r.[session_id] as [SPID]
		  ,r.transaction_isolation_level
		  ,case r.transaction_isolation_level
					when 0 then 'Unspecified' 
					when 1 then 'ReadUncommitted' 
					when 2 then 'ReadCommitted' 
					when 3 then 'Repeatable' 
					when 4 then 'Serializable' 
					when 5 then 'Snapshot'
			end as sTranIsolationLevel
			,r.[blocking_session_id] as [Blk by]
			,db_name(r.[database_id]) as [Database]
			,r.[status]
			,r.[command]
			,s.[host_name]
			,s.login_name
			,convert(char(16), r.[start_time], 120) as [StartTime]
			,convert(char(8), dateadd(ms, r.cpu_time , 0), 108) as cpu_time 
			,convert(char(8), dateadd(ms, r.total_elapsed_time, 0), 108) as total_elapsed_time
			,coalesce(r.[wait_type],'') as wait_type
			,convert(char(8), dateadd(ms, r.wait_time , 0), 108) as wait_time
			,(select top 1 substring(s2.text,  r.statement_start_offset / 2, ((case when r.statement_end_offset = -1 then (len(convert(nvarchar(max),s2.text)) * 2) else r.statement_end_offset end) - r.statement_start_offset) / 2)  ) as sql_statement
			,query_plan
	
	from sys.dm_exec_requests as r
	cross apply sys.dm_exec_sql_text(sql_handle) AS s2  
	join sys.dm_exec_sessions as s on r.session_id = s.session_id
	cross apply sys.dm_exec_query_plan (plan_handle) AS qp
	where r.[session_id] != @@spid;
END