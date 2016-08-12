declare @proc_name varchar(128) = 'xp_xmlsave_report_template'

select	object_name(ps.object_id), 
	cast(qp.query_plan as xml) as xml_plan, 
	substring(st.text,qs.statement_start_offset/2+1,
	((case when qs.statement_end_offset = -1 then datalength(st.text) else qs.statement_end_offset end) - qs.statement_start_offset)/2 + 1) as sqltext,
	qs.*
	
from sys.dm_exec_query_stats as qs
join sys.dm_exec_procedure_stats as ps on qs.sql_handle = ps.sql_handle
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
cross apply sys.dm_exec_text_query_plan(qs.plan_handle,statement_start_offset, statement_end_offset) as qp

where ps.object_id = object_id(@proc_name) or @proc_name is null

order by ps.sql_handle;