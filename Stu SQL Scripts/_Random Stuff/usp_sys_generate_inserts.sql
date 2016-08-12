/*NOTE: This script will give error if you have MONEY data type field in table.

Create this procedure and use following command to execute this:

Exec usp_Generate_Inserts 'Customers' --Customers is the table name

Go

--Output is something like this for all the rows

INSERT INTO [dbo].[Customers](CustomerID,CompanyName,ContactName,ContactTitle,Address,City,Region,PostalCode,Country,Phone,Fax) VALUES('ALFKI','Alfreds Futterkiste','Maria Anders','Sales Representative','Obere Str. 57','Berlin',NULL,'12209','Germany','030-0074321','030-0076545')
*/
CREATE Procedure [dbo].[usp_sys_generate_inserts] ( @p_tablename varchar(50) )
As
/******************************************************************************
This is a utility stored procedure to generate insert statements.
*******************************************************************************/
Begin

Set NOCOUNT ON

Declare @strSQLMain varchar(8000)
Declare @sSQLInsert varchar(500)
Declare @sSQLFrom varchar(8000)
Declare @sComma char(1)
Declare @sOpenParenthesis char(1)
Declare @sCloseParenthesis char(1)
Declare @singleQuote varchar(10)
Declare @concat varchar(10)


Set @sComma = ','
Set @sOpenParenthesis = '('
Set @sCloseParenthesis = ')'
Set @singleQuote = ''''
Set @concat = '''+'''
Set @sSQLFrom = ''


-- drop if the temp table is not deleted from the previous RUN.
If Exists ( Select 1 From Information_Schema.Tables where Table_Type = 'BASE TABLE' and Table_Name = 'tmpResultsuspGI')
Begin
Drop table tmpResultsuspGI
End

-- Check , if table exists.
If Exists ( Select 1 From Information_Schema.Tables where Table_Type = 'BASE TABLE' and Table_Name = @p_tablename )
begin
-- Get the columns.
declare @name varchar(50),@xtype varchar(50)
declare curColumns cursor 
for Select s.name,st.name 
from sysColumns s
inner join sysTypes st On s.xtype = st.xtype
where id = Object_ID(@p_tablename) and st.status=0
--based on their data type

select @sSQLInsert = 'INSERT INTO [dbo].[' + @p_tablename+']' +@sOpenParenthesis
open curColumns;
fetch next from curColumns into @name,@xtype
while @@fetch_status = 0
begin
/** Query Format 
select cast(countryID as varchar(30) )+ ',''' + CountryCode + '''' + ',''' + countryname + '''' 
from Country
**/
select @sSQLInsert = @sSQLInsert + @name + @sComma
if @xtype in ('char','varchar','datetime','smalldatetime','nvarchar','nchar','uniqueidentifier')
begin
select @sSQLFrom = @sSQLFrom + '''''''''' + '+ IsNull(cast(' + @name + ' as varchar(500)),''NULL'') +' + '''''''''' + '+' + ''',''' + '+'
end
else
begin
select @sSQLFrom = @sSQLFrom + 'cast(IsNull(cast(' + @name + ' as varchar(500)),''NULL'') as varchar(500)) ' + '+' + ''',''' + '+'
end

fetch next from curColumns into @name,@xtype
end
close curColumns;
deallocate curColumns;
select @sSQLInsert = substring(@sSQLInsert,1,Len(@sSQLInsert) -1 )
select @sSQLInsert = @sSQLInsert + @sCloseParenthesis
select @sSQLFrom = substring(@sSQLFrom,1,Len(@sSQLFrom) -5 )
select @sSQLFrom = @sSQLFrom + ' as DText'

end
else
begin
Print 'Table does not exists.'
return
end

Set @strSQLMain = 'Select ' + @sSQLFrom + ' into [dbo].tmpResultsuspGI From [' + @p_tablename + ']'
--print @strSQLMain
exec (@strSQLMain)

If ObjectProperty(Object_ID(@p_tablename),'TableHasIdentity') = 1
Begin
Select 'Set IDENTITY_INSERT [' + @p_tablename + '] ON ' 
End

Select @sSQLInsert + ' VALUES' + @sOpenParenthesis + Replace(DText,'''NULL''','NULL') + @sCloseParenthesis As [--Statements]
From [dbo].tmpResultsuspGI

If ObjectProperty(Object_ID(@p_tablename),'TableHasIdentity') = 1
Begin
Select 'Set IDENTITY_INSERT ' + @p_tablename + ' OFF ' 
End

Drop table [dbo].tmpResultsuspGI

End