select * 
from sys.dm_os_performance_counters
where object_name like '%Deprecated Features%'
and cntr_value > 0