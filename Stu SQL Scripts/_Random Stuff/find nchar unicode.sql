declare @target_string nvarchar(100) = 'stuartï¿¿ holms'
declare @search_char nchar = '¿'

select	unicode(@search_char), 
	nchar(unicode(@search_char)), 
	case when @target_string like '%' + nchar(unicode(@search_char)) + '%' then 1 else 0 end as is_found
	

set transaction isolation level read uncommitted;
declare @search_char nchar = '¿';
select * 
from dbo.transaction_head
where company_id = 10001 -- UPATE!
and period_id = 1 -- UPDATE!
and trans_description like '%' + nchar(unicode(@search_char)) + '%';


--select top 10 * from transaction_head
--update transaction_head
--set trans_description = 'stuartï¿¿ holms'
--where transaction_ref = 'REF0000010111000111001'