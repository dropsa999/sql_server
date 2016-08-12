Select CONVERT(int,'Just a string')
Select CAST('Just a string' as int)

Select
	 Try_Convert(int, 'Just a string') As Result1
	,Try_Convert(int, '100') As Result2
	,Try_Convert(int,null) As Result3
	,Try_Convert(Date,'18500412') As Result4
	,Try_Convert(DateTime,'18500412') As Result5
	,Try_Convert(Numeric(10,4),'18500412') As Result6 ;
GO



use AdventureWorks
GO

IF OBJECT_ID(N'tempdb..#tblDateTimeToConvert') IS NOT NULL
	DROP TABLE #tblDateTimeToConvert
GO
Create table #tblDateTimeToConvert (
	col1 varchar(25) null)
GO

-- Now lets populate our table 
Insert into #tblDateTimeToConvert
values('Some value'),
('Dec 20 1988 6:31PM'),
('Nov 15 1982 4:57AM'),
('Oct 10 1985 5:06PM'),
('Another value'),
('May 26 1971 8:34AM'),
('Jun 1 1973 6:28AM'),
('Jan 17 1976 10:16PM'),
('Sep 24 1977 12:34PM'),
('Yet another value'),
('Aug 11 1976 5:48PM'),
('Jan 13 1971 4:23AM'),
('Jan 26 1964 1:25AM'),
('This is not a date'),
('Apr 22 1973 9:34PM'),
('Oct 26 1963 6:35AM'),
('Sep 24 1954 5:32PM'),
('Aug 7 1981 2:28PM'),
('Dec 28 1979 8:47AM'),
('Mar 23 1972 1:06AM'),
('May 7 1978 3:46PM'),
('Jan 24 1957 10:47AM'),
('Apr 2 1986 6:40PM'),
('Feb 17 1967 6:00AM'),
('Jun 7 1983 9:13PM'),
('Feb 31 1984 00:00PM')

--You'll notice that these are mostly valid dates, 
--with a few records that are obviously not dates. 

Select convert(datetime, col1) from #tblDateTimeToConvert


-- Lets see what happens with Try_Convert:
Select try_convert(datetime, col1) from #tblDateTimeToConvert


-- identify the bad rows for data-cleaaning
IF OBJECT_ID(N'tempdb..#tblDateTime') IS NOT NULL
	DROP TABLE #tblDateTime
GO

Create table #tblDateTime (
	DT datetime null,
	OtherValue varchar(50) null)
GO

INSERT INTO #tblDateTime ([DT], [OtherValue])
	Select Case 
		when TRY_CONVERT(datetime, col1) is null then null
		else TRY_CONVERT(datetime, col1) 
		END [DT],
		
		Case when TRY_CONVERT(datetime, col1) is null then col1 
		END [OtherValue]
From #tblDateTimeToConvert ;

-- Check the results
Select *
from #tblDateTime ;


-- Report the bad values
Select DT, OtherValue
from #tblDateTime
Where DT is null
and OtherValue is not null ;


-- Parse
SELECT CONVERT(datetime,'06 September 2012');

SELECT PARSE('06 September 2012' AS datetime) AS Result

SELECT PARSE('14-Aug-2012' AS datetime USING 'en-us') AS Date
SELECT PARSE('August 14,2012' AS datetime USING 'en-us') AS Date

select parse('df23' as int using 'en-US')
select try_parse('df34' as int USING 'en-US')


IF OBJECT_ID(N'tempdb..#money') IS NOT NULL
	DROP TABLE #money
GO

CREATE TABLE #money (data varchar(16), culture varchar(16)) ;
GO

INSERT INTO #money (data, culture)
 VALUES ('$345.98', 'en-US')
 		,('€345,98', 'de-DE')
		,('345,98 €', 'fr') ;

SELECT CONVERT(money, data)
FROM #money ;

SELECT PARSE(data AS money USING culture) AS Result
FROM #money ;

select parse('125,00' as decimal using 'en-US')
select parse('125,00' as decimal USING 'fr-FR')

SELECT PARSE('13-04-2012' AS datetime USING 'en-us') AS Date
SELECT try_PARSE('13-04-2012' AS datetime USING 'en-us') AS Date

-- Format
DECLARE @Sales MONEY = 32182000.85;

SELECT    FORMAT(@Sales,'c','en-us') AS [US]
		, FORMAT(@Sales,'c','it-IT') AS  [Italy]
		, FORMAT(@Sales,'c','fr') AS [France]
		, FORMAT(@Sales,'c','ru-RU') AS [Russian];


DECLARE @Per DECIMAL(2,2) = 0.72;
SELECT    FORMAT(@Per,'p0','en-us')
		, FORMAT(@Per,'p2','en-us');


