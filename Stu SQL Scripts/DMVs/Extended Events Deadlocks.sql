--drop table #ring_buffer_data

--SELECT CAST(xest.target_data as XML) xml_data, * 
--INTO #ring_buffer_data 
--FROM  
--   sys.dm_xe_session_targets xest 
--   INNER JOIN sys.dm_xe_sessions xes on xes.[address] = xest.event_session_address 
--WHERE  
--   xest.target_name = 'ring_buffer' AND  
--   xes.name = 'system_health' 
--GO 
--;WITH CTE( event_name, event_time, deadlock_graph ) 
--AS 
--( 
--   SELECT 
--       event_xml.value('(./@name)', 'varchar(1000)') as event_name, 
--       event_xml.value('(./@timestamp)', 'datetime') as event_time, 
--       event_xml.value('(./data[@name="xml_report"]/value)[1]', 'varchar(max)') as deadlock_graph 
--   FROM #ring_buffer_data 
--       CROSS APPLY xml_data.nodes('//event[@name="xml_deadlock_report"]') n (event_xml) 
--   WHERE event_xml.value('@name', 'varchar(4000)') = 'xml_deadlock_report' 
--) 
----select * from cte

--SELECT event_name, event_time,  
--    CAST( 
--       CASE  
--           WHEN CHARINDEX('<victim-list/>', deadlock_graph) > 0 THEN 
--               REPLACE ( 
--                   REPLACE(deadlock_graph, '<victim-list/>', '<deadlock><victim-list>'), 
--                   '<process-list>', '</victim-list><process-list>')  
--           ELSE 
--               REPLACE ( 
--                   REPLACE(deadlock_graph, '<victim-list>', '<deadlock><victim-list>'), 
--                   '<process-list>', '</victim-list><process-list>')  
--       END  
--   AS XML) AS DeadlockGraph 
--FROM CTE 
--ORDER BY event_time DESC 
--go




--select CAST(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)'),'<victimProcess', '</victimProcess><victimProcess'),'<victim-list>', '<deadlock><victim-list><victimProcess>'),'<process-list>', '</victim-list><process-list>'),'<victim-list/>', '<deadlock><victim-list>'),'<victimProcess>' + CHAR(10) + SPACE(2) + '</victimProcess>', '') AS XML) AS DeadLockGraph
--FROM
--(
--	SELECT CAST(target_data as XML) AS TargetData
--	FROM sys.dm_xe_session_targets st
--	JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
--	WHERE name = 'system_health'
--) AS Data
--CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
--WHERE XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report'



select event_xml.value('(./@name)', 'varchar(1000)') as event_name, 
	event_xml.value('(./@timestamp)', 'datetime') as event_time, 
	event_xml.value('(./data[@name="xml_report"]/value)[1]', 'varchar(max)') as deadlock_graph 
from
(
	SELECT CAST(xest.target_data as XML) xml_data, *  
	from sys.dm_xe_session_targets xest 
	INNER JOIN sys.dm_xe_sessions xes on xes.[address] = xest.event_session_address 
	WHERE xest.target_name = 'ring_buffer' AND xes.name = 'system_health' 
) as x
CROSS APPLY xml_data.nodes('//event[@name="xml_deadlock_report"]') n (event_xml) 
WHERE event_xml.value('@name', 'varchar(4000)') = 'xml_deadlock_report' 



declare @deadlock xml
set @deadlock = '<deadlock>
 <victim-list>
  <victimProcess id="process5a7c988"/>
 </victim-list>
 <process-list>
  <process id="process5a7c988" taskpriority="0" logused="132" waitresource="KEY: 22:72057594045595648 (ffffffffffff)" waittime="35" ownerId="442265" transactionname="user_transaction" lasttranstarted="2015-08-18T13:20:13.163" XDES="0x8003b970" lockMode="RangeI-N" schedulerid="7" kpid="2476" status="suspended" spid="58" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2015-08-18T13:20:28.083" lastbatchcompleted="2015-08-18T13:20:17.763" clientapp="Microsoft SQL Server Management Studio - Query" hostname="SVSH03NZ" hostpid="13324" loginname="SPENDV\sholms" isolationlevel="serializable (4)" xactid="442265" currentdb="22" lockTimeout="4294967295" clientoption1="671090784" clientoption2="390200">
   <executionStack>
    <frame procname="" line="1" sqlhandle="0x02000000bf19c826034d29a560c38c04b188773880ee9d5a">
    </frame>
    <frame procname="" line="1" sqlhandle="0x020000002b157327c35dd7f1fced1123fcd0dd3dfad06493">
    </frame>
   </executionStack>
   <inputbuf>
INSERT INTO Production.Product (Name, ProductNumber, SafetyStockLevel, ReorderPoint, StandardCost, ListPrice, DaysToManufacture, SellStartDate, SellEndDate)
VALUES (&apos;fake&apos;, &apos;HM-0001&apos;, 1, 1, 1, 1, 1, GETDATE(), GETDATE());
   </inputbuf>
  </process>
  <process id="process5a63048" taskpriority="0" logused="132" waitresource="KEY: 22:72057594045595648 (ffffffffffff)" waittime="4751" ownerId="442110" transactionname="user_transaction" lasttranstarted="2015-08-18T13:20:01.027" XDES="0xe2959410" lockMode="RangeI-N" schedulerid="6" kpid="992" status="suspended" spid="57" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2015-08-18T13:20:23.367" lastbatchcompleted="2015-08-18T13:20:08.867" clientapp="Microsoft SQL Server Management Studio - Query" hostname="SVSH03NZ" hostpid="13324" loginname="SPENDV\sholms" isolationlevel="serializable (4)" xactid="442110" currentdb="22" lockTimeout="4294967295" clientoption1="671090784" clientoption2="390200">
   <executionStack>
    <frame procname="" line="2" stmtstart="4" sqlhandle="0x02000000bf19c826034d29a560c38c04b188773880ee9d5a">
    </frame>
    <frame procname="" line="2" stmtstart="4" sqlhandle="0x02000000022eb72b1ef99a8281030722f3768b758ee3a3c6">
    </frame>
   </executionStack>
   <inputbuf>

INSERT INTO Production.Product (Name, ProductNumber, SafetyStockLevel, ReorderPoint, StandardCost, ListPrice, DaysToManufacture, SellStartDate, SellEndDate)
VALUES (&apos;fake&apos;, &apos;HM-0002&apos;, 1, 1, 1, 1, 1, GETDATE(), GETDATE());
   </inputbuf>
  </process>
 </process-list>
 <resource-list>
  <keylock hobtid="72057594045595648" dbid="22" objectname="" indexname="" id="lockac6a0500" mode="RangeS-S" associatedObjectId="72057594045595648">
   <owner-list>
    <owner id="process5a63048" mode="RangeS-S"/>
   </owner-list>
   <waiter-list>
    <waiter id="process5a7c988" mode="RangeI-N" requestType="convert"/>
   </waiter-list>
  </keylock>
  <keylock hobtid="72057594045595648" dbid="22" objectname="" indexname="" id="lockac6a0500" mode="RangeS-S" associatedObjectId="72057594045595648">
   <owner-list>
    <owner id="process5a7c988" mode="RangeS-S"/>
   </owner-list>
   <waiter-list>
    <waiter id="process5a63048" mode="RangeI-N" requestType="convert"/>
   </waiter-list>
  </keylock>
 </resource-list>
</deadlock>

'

select 
 [PagelockObject] = @deadlock.value('/deadlock[1]/resource-list[1]/pagelock[1]/@objectname', 'varchar(200)'),
 [DeadlockObject] = @deadlock.value('/deadlock[1]/resource-list[1]/objectlock[1]/@objectname', 'varchar(200)'),
 [KeyLockObject] = @deadlock.value('/deadlock[1]/resource-list[1]/keylock[1]/@objectname', 'varchar(200)'),
 [KeyLockIndex] = @deadlock.value('/deadlock[1]/resource-list[1]/keylock[1]/@indexname', 'varchar(200)'),
 [Victim] = case when Deadlock.Process.value('@id', 'varchar(50)') = @deadlock.value('/deadlock[1]/victim-list[1]/victimProcess[1]/@id', 'varchar(50)') then 1 else 0 end,
 [ProcessID] = Deadlock.Process.value('@id', 'varchar(50)'),
 [Procedure] = Deadlock.Process.value('executionStack[1]/frame[1]/@procname[1]', 'varchar(200)'),
 [LockMode] = Deadlock.Process.value('@lockMode', 'char(5)'),
 [Code] = Deadlock.Process.value('executionStack[1]/frame[1]', 'varchar(1000)'),
 --[ClientApp] = Deadlock.Process.value('@clientapp', 'varchar(100)'),
 [HostName] = Deadlock.Process.value('@hostname', 'varchar(20)'),
 [LoginName] = Deadlock.Process.value('@loginname', 'varchar(20)'),
 [TransactionTime] = Deadlock.Process.value('@lasttranstarted', 'datetime'),
 [BatchTime] = Deadlock.Process.value('@lastbatchstarted', 'datetime'),
 [InputBuffer] = Deadlock.Process.value('inputbuf[1]', 'varchar(1000)')
 from @deadlock.nodes('/deadlock/process-list/process') as Deadlock(Process)