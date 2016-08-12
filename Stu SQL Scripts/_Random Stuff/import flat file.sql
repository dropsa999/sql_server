SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

alter procedure loaddata as
BEGIN
declare @query varchar(7000)
declare @string varchar(1500)
declare @string1 varchar(500)
drop table x
create table x (name varchar(2000))
set @query ='master.dbo.xp_cmdshell "type C:\SAMPLE_FILE.TXT"'
insert x exec (@query)
declare C1 cursor local fast_forward for select name from x;
open c1
fetch next from c1 into @string
while @@FETCH_STATUS = 0
	BEGIN
	fetch next from c1 into @string1
		if (len(@string1)<>0 or @string1<>null)
		  Begin	
			set @string=@string+@string1
		  END
		ELSE if  @string<>''
                    Begin
			insert into filedata values(
			substring(@string,1,16),
			substring(@string,17,35),
			substring(@string,52,25),
			substring(@string,77,25),
			substring(@string,102,25),
			substring(@string,127,25),
			substring(@string,152,25),
			substring(@string,177,20),
			substring(@string,197,15),
			substring(@string,212,15),
			substring(@string,227,50),
			substring(@string,277,15),
			substring(@string,292,17),
			substring(@string,309,17),
			substring(@string,326,17),
			substring(@string,343,17),
			substring(@string,360,17),
			substring(@string,377,17),
			substring(@string,394,3),
			substring(@string,397,6),
			substring(@string,403,4),
			substring(@string,407,6),
			substring(@string,413,40),
			substring(@string,453,15),
			substring(@string,468,1),
			substring(@string,469,30),
			substring(@string,499,30),
			substring(@string,529,30),
			substring(@string,559,30),
			substring(@string,588,30),
			substring(@string,619,30),
			substring(@string,649,30),
			substring(@string,679,30),
			substring(@string,709,30),
			substring(@string,739,30))
			set @string=''
		   End
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
