drop procedure stu_test
go
create procedure stu_test
(
	@period_id varchar(10)	
)
as

select top 10 * from card_account;

select * from transaction_head
where period_id = @period_id
option (recompile);
go


exec stu_test 228;

exec stu_test 729;


select	p.name as [procedure_name],
	qp.query_plan,
	p.create_date,
	x.cached_time,
	x.last_execution_time,
	x.execution_count
from sys.procedures as p
left outer join	
( 
	select	*
	from	sys.dm_exec_procedure_stats as ps
	where	database_id = db_id() 
)  as x on  p.object_id = x.object_id
cross apply sys.dm_exec_query_plan( x.plan_handle ) as qp

where p.name = 'stu_test'