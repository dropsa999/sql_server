declare @schema sysname
declare @table sysname
declare @column sysname

set @schema = 'dbo'
set @table = 'card_account'
set @column = 'interface_update_id'

select o.name
from sys.sql_dependencies as d
 inner join sys.all_objects as o on o.object_id = d.object_id
 inner join sys.all_objects as ro on ro.object_id = d.referenced_major_id
 inner join sys.all_columns as c on c.object_id = ro.object_id and c.column_id = d.referenced_minor_id
 inner join sys.sql_modules m on o.name = object_name(m.object_id) 
where (schema_name(ro.schema_id)=@schema) 
 and o.type_desc = 'sql_stored_procedure'
 and ro.name = @table
 --and c.name = @column
 and d.is_updated = 1
group by o.name