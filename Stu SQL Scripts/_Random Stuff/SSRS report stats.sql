USE ReportServer;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

WITH REPORTSTATS
AS
(
	SELECT	 c.name
			,REPLACE(c.[path],'/{28bcc5da-0987-44e4-9088-f38f08cae3f5}/','') AS ReportLocation
			,dsc.Name AS DataSource
			,MAX(el.timeStart) AS lastRunDate
			,AVG(el.timeDataRetrieval) AS avgTimeDataRetrieval
			,AVG(el.timeProcessing) AS avgTimeProcessing
			,AVG(el.timeRendering) AS avgTimeRendering
			,AVG(el.timeDataRetrieval + el.timeProcessing + el.timeRendering) AS avgReportCreation
			,MAX(el.timeDataRetrieval + el.timeProcessing + el.timeRendering) AS MaxReportCreation
			,MIN(el.timeDataRetrieval + el.timeProcessing + el.timeRendering) AS MinReportCreation
			,AVG(el.[rowCount]) AS avgRowCount
			,SUM(CASE WHEN el.status = 'rsSuccess' THEN 1 ELSE 0 END) AS rsSuccessY
			,SUM(CASE WHEN el.status = 'rsSuccess' THEN 0 ELSE 1 END) AS rsSuccessN
			,ISNULL(COUNT(c.itemID),0) AS totalEntries
	
	FROM dbo.Catalog AS c
	JOIN DataSource AS ds ON c.ItemID = ds.ItemID
	JOIN dbo.Catalog AS dsc ON ds.Link = dsc.ItemID
	LEFT OUTER JOIN dbo.ExecutionLog AS el ON c.itemID = el.reportID

	WHERE c.[Type] = 2
	AND c.[Path] NOT LIKE '/{28bcc5da-0987-44e4-9088-f38f08cae3f5}/it/IT Reports/%'
	AND c.[Path] NOT LIKE '/{28bcc5da-0987-44e4-9088-f38f08cae3f5}/reporting/Test Reports/%'
	AND c.[Path] NOT LIKE '/{28bcc5da-0987-44e4-9088-f38f08cae3f5}/reporting/Autobill3/%'
	GROUP BY c.name, c.[path], dsc.Name
)
SELECT name
			,DataSource
			,lastRunDate
			,avgTimeDataRetrieval
			,avgTimeProcessing
			,avgTimeRendering
			,avgReportCreation
			,CONVERT(TIME,DATEADD (ms, MinReportCreation, 0)) AS MinReportCreation
			,CONVERT(TIME,DATEADD (ms, avgReportCreation, 0)) AS avgReportCreationMins
			,CONVERT(TIME,DATEADD (ms, MaxReportCreation, 0)) AS MaxReportCreation
			,avgRowCount
			,rsSuccessY
			,rsSuccessN
			,totalEntries 
			,ReportLocation
FROM REPORTSTATS 
ORDER BY avgRowCount DESC

SELECT COUNT(UserName), UserName FROM dbo.ExecutionLog3 AS el GROUP BY UserName ORDER BY COUNT(UserName) DESC

SELECT * 
FROM dbo.ExecutionLog3 AS el 
WHERE (ItemPath LIKE '%Projection Of Future Billing.rdl%' OR ItemPath LIKE '%Commission And Credit Control Analysis.rdl%')
AND TimeStart > CAST (GETDATE() AS DATE)
