
--calalog reports

SELECT     
	c.Name, 
	c.Type, 
	c.Description, 
	u.UserName AS CreatedBy, 
	c.CreationDate, 
	c.ModifiedDate, 
	s.Description AS Subscription, 
    s.DeliveryExtension AS SubscriptionDelivery, 
    d.Name AS DataSource, 
    s.LastStatus, 
    s.LastRunTime, 
    s.Parameters, 
    sch.StartDate AS ScheduleStarted, 
    sch.LastRunTime AS LastSubRun, 
    sch.NextRunTime, 
    c.Path
FROM Catalog c 

LEFT OUTER JOIN Subscriptions s 
ON c.ItemID = s.Report_OID 

INNER JOIN DataSource d 
ON c.ItemID = d.ItemID 

LEFT OUTER JOIN Users u 
ON u.UserID = c.CreatedByID 

LEFT OUTER JOIN ReportSchedule rs 
ON c.ItemID = rs.ReportID 

LEFT OUTER JOIN Schedule sch 
ON rs.ScheduleID = sch.ScheduleID

WHERE (c.Type = 2)

ORDER BY c.Name