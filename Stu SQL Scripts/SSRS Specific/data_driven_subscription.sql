/*
 DATE CREATED:   12/21/2006
 AUTHOR:         Jason L. Selburg
            
 PURPOSE: 
    This procedure extends the functionality of the subscription feature in 
  Microsoft SQL Reporting Services 2005, allowing the subscriptions to be triggered
  via code. 
    The code supplied will function with reports that have one parameter. Reports
  that have multiple parameters must be addressed individually or with another method.
  There are many possible ways to handle multi-parameter reports, which is why it is not addressed here.
  However, one suggestion:
    - Create a subscription table that will hold subscription names and IDs. 
    - Create a table to hold subscription IDs mapped to the previous table and hold the parameter names and
      values. 
    - These tables would be queried and looped through to populate the parameter XML string below.

 NOTES:
   This procedure does not address "File Server Share" subscriptions.

 PARAMETERS:
   @scheduleName   = This is the NAME that is put into the subject line of the subscription when created.
                     It is STRONGLY suggested that you use a naming convention that will prevent
                     duplicate names.
   @emailTO        = The TO of the email  (not required.)  \
   @emailCC        = The CC of the email  (not required.)  |---One of these are REQUIRED!
   @emailBCC       = The BCC of the email (not required.)  /
   @emailReplyTO   = The reply to address that will appear in the email.
   @emailBODY      = The text in the body of the email.
   @parameterName  = The paramerter name. This MUST match the parameter name in the report definition.
   @parameterValue = The parameter value.
   @sub            = The subject line of the email.

   @renderFormat   = The rendering format of the report.
      VALID VALUES : May be different depending on the installation and configuration 
                     of your server,  but these are listed in the "reportServer.config" file. 
                     This file is located in a folder similar to
                     "C:\Program Files\Microsoft SQL Server\MSSQL.2\Reporting Services\ReportServer\"
                     XML
                     IMAGE
                     PDF
                     EXCEL
                     CSV

   @exitCode       = The returned integer value of the procedure's execution result. 
                   -1  'A recipient is required.'
                   -2  'The subscription does not exist.'
                   -3  'No delivery settings were supplied.'
                   -4  'A data base error occurred inserting the subscription history record.'
                   -5  'A data base error occurred clearing the previous subscription settings.'
                   -6  'A data base error occurred retrieving the TEXT Pointer of the Delivery Values.'	
                   -7  'A data base error occurred updating the Delivery settings.'
                   -8  'A data base error occurred retrieving the TEXT Pointer of the Parameter Values.'
                   -9  'A data base error occurred updating the Parameter settings.'
                   -10 'A data base error occurred updating the subscription history record.'
                   -11 'A data base error occurred resetting the previous subscription settings.'

  @exitMessage    = The text description of the failure or success of the procedure.

 PRECONDITIONS:
    The subscription being called must exist and the SUBJECT line of the subscription MUST contain
  the exact name that is passed into this procedure.
    If any of the recipients email address are outside of the report server's domain, then you may
  need to contact your Network Administrator to allow email forwarding from your email server.

 POST CONDITIONS:
    The report is delivered or an error code and message is returned.

 SECURITY REQUIREMENTS:
    The user which calls this stored procedure must have execute permissions.

 DEPENDANCES:
   Tables:
       ReportSchedule       = Installed with SQL RS 2005
       Subscription_History = Must be created using the following script.
                            ---------------------------------------------------------------------
                            CREATE TABLE [dbo].[Subscription_History](
                            [nDex] [int] IDENTITY(1,1) NOT NULL,
                            [SubscriptionID] [uniqueidentifier] NULL,
                            [ScheduleName] [nvarchar](260) COLLATE Latin1_General_CI_AS_KS_WS NULL,
                            [parameterSettings] [varchar](8000) COLLATE Latin1_General_CI_AS_KS_WS NULL,
                            [deliverySettings] [varchar](8000) COLLATE Latin1_General_CI_AS_KS_WS NULL,
                            [dateExecuted] [datetime] NULL,
                            [executeStatus] [nvarchar] (260) NULL,
                            [dateCompleted] [datetime] NULL,
                            [executionTime] AS (datediff(second,[datecompleted],[dateexecuted])),
                            CONSTRAINT [PK_Subscription_History] PRIMARY KEY CLUSTERED 
                              (
	                           [nDex] ASC
                              )WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
                             ) ON [PRIMARY]
                            ---------------------------------------------------------------------

       Subscriptions           = Installed with SQL RS 2005
       Schedule                = Installed with SQL RS 2005            

*/
ALTER     procedure [dbo].[data_driven_subscription]
	( @scheduleName nvarchar(255),
        @emailTO nvarchar (2000) = NULL,
        @emailCC nvarchar (2000) = NULL,
        @emailBCC nvarchar (2000) = NULL,
        @emailReplyTO nvarchar (2000) = NULL,
        @emailBODY nvarchar (4000) = NULL,
        @parameterName nvarchar(4000) = NULL,
        @parameterValue nvarchar (256) = NULL,
        @sub nvarchar(1000) = NULL,
        @renderFormat nvarchar(50) = 'PDF',
        @exitCode int output,
        @exitMessage nvarchar(255) output
	)
AS
DECLARE
    @ptrval binary(16), 
    @PARAMptrval binary(16), 
    @subscriptionID uniqueidentifier,
    @scheduleID uniqueidentifier,
    @starttime datetime,
    @lastruntime datetime,
    @execTime datetime,
    @dVALUES  nvarchar (4000),
    @pVALUES  nvarchar (4000),
    @previousDVALUES  nvarchar (4000),
    @previousPVALUES  nvarchar (4000),
    @lerror int,
    @insertID int,
    @lretval int,
    @rowcount int

SET @starttime = DATEADD(second, -2, getdate())
SET @emailTO = rtrim(IsNull(@emailTO, ''))
SET @emailCC = rtrim(IsNull(@emailCC, ''))
SET @emailBCC = rtrim(IsNull(@emailBCC, ''))
SET @emailReplyTO = rtrim(IsNull(@emailReplyTO, ''))
SET @emailBODY = rtrim(IsNull(@emailBODY, ''))
SET @parameterValue = rtrim(IsNull(@parameterValue, ''))
SET @lerror = 0
SET @rowcount = 0

IF @emailTO = '' AND @emailCC = '' 
   AND @emailBCC = ''
 BEGIN
   SET @exitCode = -1
   SET @exitMessage = 'A recipient is required.'
   RETURN 0
 END


-- get the subscription ID
SELECT 
  @subscriptionID = rs.subscriptionID,
  @scheduleID = rs.ScheduleID
 FROM 
  ReportSchedule rs
 INNER JOIN subscriptions s
  ON rs.subscriptionID = s.subscriptionID
 WHERE
  extensionSettings like '%' + @scheduleName + '%'

IF @subscriptionID Is Null
 BEGIN
   SET @exitCode = -2
   SET @exitMessage = 'The subscription does not exist.'
   RETURN 0
 END
	
/* just to be safe */
SET @dVALUES  = ''
SET @pVALUES  = ''
SET @previousDVALUES  = ''
SET @previousPVALUES  = ''

/* apply the settings that are defined */
IF IsNull(@emailTO, '') <> ''  
  SET @dVALUES  = @dVALUES  + '<ParameterValue><Name>TO</Name><Value>' 
                  + @emailTO + '</Value></ParameterValue>'  
	
IF IsNull(@emailCC, '') <> ''  
  SET @dVALUES  = @dVALUES  + '<ParameterValue><Name>CC</Name><Value>' 
                  + @emailCC + '</Value></ParameterValue>'  
		
IF IsNull(@emailBCC, '') <> ''  
  SET @dVALUES  = @dVALUES  + '<ParameterValue><Name>BCC</Name><Value>' 
                  + @emailBCC + '</Value></ParameterValue>' 
	
IF IsNull(@emailReplyTO, '') <> ''  
  SET @dVALUES  = @dVALUES  + '<ParameterValue><Name>ReplyTo</Name><Value>' 
                  + @emailReplyTO + '</Value></ParameterValue>'
		
IF IsNull(@emailBODY, '') <> ''  
  SET @dVALUES  = @dVALUES  + '<ParameterValue><Name>Comment</Name><Value>' 
                  + @emailBODY + '</Value></ParameterValue>'

IF IsNull(@sub, '') <> ''  
  SET @dVALUES  = @dVALUES  + '<ParameterValue><Name>Subject</Name><Value>' 
                  + @sub + '</Value></ParameterValue>'  
		
IF IsNull(@dVALUES , '') <> ''
  SET @dVALUES  = '<ParameterValues>' + @dVALUES  
                  + '<ParameterValue><Name>IncludeReport</Name><Value>True</Value></ParameterValue>'

IF IsNull(@dVALUES , '') <> ''
  SET @dVALUES  = @dVALUES  +	'<ParameterValue><Name>RenderFormat</Name><Value>' +
      @renderFormat + '</Value></ParameterValue>' +  
	  '<ParameterValue><Name>IncludeLink</Name><Value>False</Value></ParameterValue></ParameterValues>'

IF IsNull(@parameterName, '') <> '' and IsNull(@parameterValue, '') <> ''
  SET @pVALUES  = '<ParameterValues><ParameterValue><Name>' + 
      @parameterName + 
      '</Name><Value>' + 
      @parameterValue + 
	  '</Value></ParameterValue></ParameterValues>'

/* verify that some delivery settings where passed in */
-- @pVALUES are not checked as they may all be defaults
IF IsNull(@dVALUES , '') = '' 
 BEGIN
   SET @exitCode = -3
   SET @exitMessage = 'No delivery settings were supplied.'
   RETURN 0
 END
				
/* get the current parameter values and delivery settings */
SELECT @previousDVALUES  = extensionSettings 
  FROM Subscriptions 
  WHERE SubscriptionID = @SubscriptionID
SELECT @previousPVALUES  = parameters 
  FROM Subscriptions 
  WHERE SubscriptionID = @SubscriptionID

UPDATE Subscriptions 
  SET extensionSettings = '', parameters = '' 
  WHERE SubscriptionID = @SubscriptionID
    						
SELECT @lerror=@@error, @rowCount=@@rowCount
    		
IF @lerror <> 0 OR IsNull(@rowCount, 0) = 0
 BEGIN
   SET @exitcode = -5
   SET @exitMessage = 'A data base error occurred clearing the previous subscription settings.'		
   RETURN IsNull(@lerror, 0)
 END

-- set the text point for this record
SELECT @ptrval = TEXTPTR(ExtensionSettings) 
  FROM Subscriptions 
  WHERE SubscriptionID = @SubscriptionID
						
SELECT @lerror=@@error
    		
IF @lerror <> 0 OR @ptrval Is NULL
 BEGIN
   SET @exitcode = -6
   SET @exitMessage = 'A data base error occurred retrieving the TEXT Pointer of the Delivery Values.'		
   RETURN IsNull(@lerror, 0)
 END

UPDATETEXT Subscriptions.ExtensionSettings 
	@ptrval 
	null
	null
	@dVALUES
		
SELECT @lerror=@@error
    		
IF @lerror <> 0 
 BEGIN
   SET @exitcode = -7
   SET @exitMessage = 'A data base error occurred updating the Delivery settings.'		
   RETURN IsNull(@lerror, 0)
 END 

-- set the text point for this record
SELECT @PARAMptrval = TEXTPTR(Parameters) 
  FROM Subscriptions 
  WHERE SubscriptionID = @SubscriptionID
    						
SELECT @lerror=@@error
    		
IF @lerror <> 0 OR @ptrval Is NULL
 BEGIN
   SET @exitcode = -8
   SET @exitMessage = 'A data base error occurred retrieving the TEXT Pointer of the Parameter Values.'		
   RETURN IsNull(@lerror, 0)
 END

UPDATETEXT Subscriptions.Parameters 
   @PARAMptrval 
   null
   null
   @pVALUES 
						
SELECT @lerror=@@error
    		
IF @lerror <> 0 
 BEGIN
   SET @exitcode = -9
   SET @exitMessage = 'A data base error occurred updating the Parameter settings.'		
   RETURN IsNull(@lerror, 0)
 END 

/* insert a record into the history table */
SET @execTime = getdate()
INSERT Subscription_History 
   (subscriptionID, scheduleName, ParameterSettings, DeliverySettings,  dateExecuted, executeStatus) 
 VALUES 
   (@subscriptionID, @scheduleName, @parameterValue, @dVALUES , @execTime, 'incomplete' )
    						
SELECT @lerror=@@error, @insertID=@@identity
    		
IF @lerror <> 0 OR IsNull(@insertID, 0) = 0
 BEGIN
   SET @exitcode = -4
   SET @exitMessage = 'A data base error occurred inserting the subscription history record.'		
   RETURN IsNull(@lerror, 0)
 END

-- run the job
EXEC msdb..sp_start_job @job_name = @scheduleID

-- this gives the report server time to execute the job
SELECT @lastruntime = LastRunTime FROM ReportServer..Schedule WHERE ScheduleID = @scheduleID
WHILE (@starttime > @lastruntime)
 BEGIN
   WAITFOR DELAY '00:00:01'
   SELECT @lastruntime = LastRunTime FROM ReportServer..Schedule WHERE ScheduleID = @scheduleID
 END

/* update the history table with the completion time */
UPDATE Subscription_History 
 SET dateCompleted = getdate()
 WHERE subscriptionID = @subscriptionID 
 and scheduleName = @scheduleName 
 and ParameterSettings = @parameterValue 
 and dateExecuted = @execTime
				
SELECT @lerror=@@error, @rowCount=@@rowCount
    		
IF @lerror <> 0 OR IsNull(@rowCount, 0) = 0
 BEGIN
   SET @exitcode = -10
   SET @exitMessage = 'A data base error occurred updating the subscription history record.'		
   RETURN IsNull(@lerror, 0)
 END

/* reset the previous delivery and parameter values  */		
UPDATE Subscriptions 
  SET extensionSettings = @previousDVALUES
    , parameters = @previousPVALUES 
  WHERE SubscriptionID = @SubscriptionID
						
SELECT @lerror=@@error, @rowCount=@@rowCount
    		
IF @lerror <> 0 OR IsNull(@rowCount, 0) = 0
 BEGIN
   SET @exitcode = -11
   SET @exitMessage = 'A data base error occurred resetting the previous subscription settings.'		
   RETURN IsNull(@lerror, 0)
 END

/* return the result of the subscription */
SELECT @exitMessage = LastStatus 
  FROM subscriptions 
  WHERE subscriptionID = @subscriptionID

SET @exitCode = 1
RETURN 0
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
