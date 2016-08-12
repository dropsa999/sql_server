drop table #testrowversion
create table #testrowversion
(
	first_name varchar(100) not null,
	last_name varchar(100) not null,
	therowversion rowversion
)

select * from #testrowversion

insert into #testrowversion(first_name,last_name)
values ('stuart','holms')

select * from #testrowversion

update #testrowversion
set first_name = 'bob'

select * from #testrowversion

