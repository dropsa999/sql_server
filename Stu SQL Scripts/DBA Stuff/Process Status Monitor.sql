DECLARE @JOBDATE DATE = (SELECT GETDATE());
WITH jobs_to_run
AS 
(
    SELECT  ps.ProcessName + ' ' + ta.Name AS ProcessName
           ,ps.RunID
           ,ps.Country
           ,ps.TrustAccount
           ,ps.Started
           ,ps.Step
           ,ps.StepName
           ,ps.Completed
    FROM  dbo.ProcessStatus AS ps
	JOIN dbo.TrustAccount AS ta ON ps.TrustAccount = ta.TrustAccount
	WHERE [Started] > @JOBDATE
    
    ),
tf_5m
AS -- 5-minuute interval
(
 SELECT v.number
       ,DATEADD(SECOND, 300 * v.number, DATEDIFF(dd, 0, @JOBDATE)) AS timeInterval_FROM -- ,DATEADD(MINute,v.number,DATEDIFF(dd,0,GETDATE())) -- for 1minute timeframe
       ,DATEADD(SECOND, 300 * v.number + 299, DATEDIFF(dd, 0,@JOBDATE)) AS timeInterval_to
 FROM   master..spt_values AS v
 WHERE  v.type = 'P'
        AND v.number <= 288 -- <= 1440 -- for 1minute timeframe
),      timeset
          AS (
              SELECT    t.timeInterval_FROM AS timeInterval
                       ,ISNULL(j.ProcessName, '') AS ProcessName
                       ,ISNULL(j.Step, '') AS Step
                       ,j.Started
                       ,j.Completed
                       ,ROW_NUMBER() OVER (PARTITION BY ISNULL(j.ProcessName, ''), ISNULL(j.Step, ''), j.Started ORDER BY (
                                                                                                                        SELECT t.timeInterval_FROM
                                                                                                                       )) AS rn
              FROM      jobs_to_run AS j
              RIGHT JOIN tf_5m AS t ON (
                                        j.Started BETWEEN t.timeinterval_FROM
                                                   AND     t.timeinterval_to
                                        OR j.Completed BETWEEN t.timeinterval_FROM
                                                    AND     t.timeinterval_to
                                       )
             )
    -- Data "imputation" of empty rows for all jobs. To appear in SSRS as a continous block, when job is running for more than 5 minutes
SELECT  DATEADD(SECOND, 300 * s.number, DATEDIFF(dd, 0, @JOBDATE)) AS TimeInterval
       ,a.ProcessName AS JobName
       ,a.Step AS Outcome
FROM    (
         SELECT a.ProcessName
               ,a.Step
               ,a.Started
               ,MIN(a.TimeInterval) AS minTI
               ,MAX(a.TimeInterval) AS maxTI
         FROM   timeset AS a
         GROUP BY a.ProcessName
               ,a.Step
               ,a.Started
        ) AS a
INNER JOIN master.dbo.spt_values AS s ON DATEADD(SECOND, 300 * s.number, DATEDIFF(dd, 0, @JOBDATE)) BETWEEN a.minTI
                                                                                                     AND     a.maxTI
WHERE   s.type = 'P'
        AND s.number <= 288
ORDER BY TimeInterval