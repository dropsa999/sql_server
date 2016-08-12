--http://www.databasejournal.com/features/mssql/article.php/3820771/Formatted-date-in-SQL-Server-2008.htm
--YYYY  - Year in YYYY Format including century  
--Yr  - Year in YY format  
--QQ  - Display Quarter  
--MM  - Display Month  
--WW  - Diplay Week  
--DD  - Display day  
--24HH  - Display hour in 24 hr format  
--12HH  - Display hour in 12 hr format  
--MI  - Display minutes  
--SS  - Display seconds  
--MS  - Display Milliseconds  
--MCS  - Display MicroSeconds  
--NS  - Display NanoSeconds  
--DAY  - Display day name example: Monday  
--MONTH-  - Display Month name example: August  
--MON  - Display short month name example: Aug  
--AMPM  - Display AM / PM for 12 hr format  
--TZ  - Display time offset  
--UNIXPOSIX  - Display unix posix time. Number of seconds from 1/1/1970  
--UCASE  - Display the result in upper case  
--LCASE  - Display the result in lower case  

IF  EXISTS (SELECT * FROM sys.objects 
   WHERE object_id = OBJECT_ID(N'[dbo].[ufn_gen_format_date]') 
   AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ufn_gen_format_date]
GO

/****** Object:  UserDefinedFunction [dbo].[ufn_gen_format_date]    
   Script Date: 05/12/2009 23:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET CONCAT_NULL_YIELDS_NULL OFF
go
CREATE function [dbo].[ufn_gen_format_date] 
   (@inputdate datetime ,@format varchar(500))
returns varchar(500)
as
begin
declare @year varchar(4)			--YYYY
declare @shortyear varchar(4)		--Yr
declare @quarter varchar(4)			--QQ
declare @month varchar(2)			--MM
declare @week varchar(2)			--WW
declare @day varchar(2)				--DD
declare @24hours varchar(2)			--24HH
declare @12hours varchar(2)			--HH
declare @minutes varchar(2)			--MI
declare @seconds varchar(2)			--SS
declare @milliseconds varchar(3)	--MS
declare @microseconds varchar(6)	--MCS
declare @nanoseconds varchar(9)		--NS
declare @dayname varchar(15)		--DAY
declare @monthname varchar(15)		--MONTH
declare @shortmonthname varchar(15)	--MON
declare @AMPM	 varchar(15)		--AMPM
declare @TZ	 varchar(15)			--TZ
declare @UNIXPOSIX	 varchar(15)	--UNIXPOSIX
					--UCASE
					--LCASE

					
declare @formatteddate varchar(500)		


--Assign current date and time to 
if (@inputdate is NULL or @inputdate ='')
begin
set @inputdate = getdate()
end

if (@format is NULL or @format ='')
begin
set @format ='YYYY-MM-DD 12HH:MI:SS AMPM'
end

--set all values

set @year		= convert(varchar(4),year(@inputdate))
set @shortyear	= right(@year,2)
set @quarter	= convert(varchar(1),datepart(QQ,(@inputdate)))
set @month		= right('0'+convert(varchar(2),month(@inputdate)),2)
set @week		= right('0'+convert(varchar(2),datepart(ww,(@inputdate))),2)
set @day		= right('0'+convert(varchar(2),day(@inputdate)),2)
set @24hours	= right('0'+convert(varchar(2),datepart(hh,@inputdate)),2)
--set @TZ		= convert(varchar(10),datename(TZ,convert(varchar(20),@inputdate)))
set @UNIXPOSIX	= convert(varchar(15),datediff(ss,convert(datetime,'01/01/1970 00:00:000'),@inputdate))

if datepart(hh,@inputdate) >12
begin
set @12hours      = right('0'+convert(varchar(2),datepart(hh,@inputdate)) -12,2)
end
else
begin
set @12hours      = right('0'+convert(varchar(2),datepart(hh,@inputdate)) ,2)
end

if datepart(hh,@inputdate) >11 
begin
set @AMPM ='PM'
end
else
begin
set @AMPM ='AM'
end

set @minutes      = right('0'+convert(varchar(2),datepart(n,@inputdate)),2)
set @seconds      = right('0'+convert(varchar(2),datepart(ss,@inputdate)),2)
set @milliseconds = convert(varchar(3),datepart(ms,@inputdate))
--set @microseconds = convert(varchar(6),datepart(mcs,@inputdate))
--set @dayname      = datename(weekday,@inputdate)
set @monthname    = datename(mm,@inputdate)
set @shortmonthname= left(datename(mm,@inputdate),3)
set @formatteddate = @format
set @formatteddate=replace(@formatteddate,'MONTH',@monthname)
set @formatteddate=replace(@formatteddate,'MON',@shortmonthname)
set @formatteddate=replace(@formatteddate,'AMPM',@AMPM)

set @formatteddate=replace(@formatteddate,'YYYY',@year)
set @formatteddate=replace(@formatteddate,'Yr',@shortyear)
set @formatteddate=replace(@formatteddate,'QQ',@quarter)
set @formatteddate=replace(@formatteddate,'WW',@week)
set @formatteddate=replace(@formatteddate,'MM',@month)
set @formatteddate=replace(@formatteddate,'DD',@Day)
set @formatteddate=replace(@formatteddate,'24HH',@24hours)
set @formatteddate=replace(@formatteddate,'12HH',@12hours)
set @formatteddate=replace(@formatteddate,'Mi',@minutes)
set @formatteddate=replace(@formatteddate,'SS',@seconds)
set @formatteddate=replace(@formatteddate,'MS',@milliseconds)
--set @formatteddate=replace(@formatteddate,'MCS',@microseconds)
--set @formatteddate=replace(@formatteddate,'NS',@nanoseconds)
set @formatteddate=replace(@formatteddate,'DAY',@dayname)
set @formatteddate=replace(@formatteddate,'TZ',@TZ)
set @formatteddate=replace(@formatteddate,'UNIXPOSIX',@UNIXPOSIX)

if charindex('ucase',@formatteddate)<>0
begin
set @formatteddate=replace(@formatteddate,'ucase','')
set @formatteddate=upper(@formatteddate)
end

if charindex('lcase',@formatteddate)<>0
begin
set @formatteddate=replace(@formatteddate,'lcase','')
set @formatteddate=lower(@formatteddate)
end


return @formatteddate
end


GO
