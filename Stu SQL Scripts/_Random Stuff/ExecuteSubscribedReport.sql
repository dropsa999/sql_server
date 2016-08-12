/*
    ExecuteSubscribedReport
 
      PROCEDURE DESCRIPTION:
      Creates the effect of a data driven subscription by replacing the fields in 
      an existing subscription with the supplied values, executing the report
      and then replacing the original values.
 
      INPUT:
        @ScheduleID     The Job Name in SQL Server
        @EmailTo      The TO address of the email
        @EmailCC      The Carbon Copy address of the email
        @EmailBCC        The Blind Copy address of the email
        @EmailReplyTo  The Reply TO address of the email
        @EmailBody       Any text that you want in the email body
        @ParameterList The parameters for the report in the format 'Parameter1Token,Parameter1Value,Parameter2Token,Parameter2Value...'
                     Example: '|StartDate|,20071231,|Salesperson|,GE,|Region|,NW'
      OUTPUT:
        None
 
      WRITTEN BY:
      Greg Low based on a concept from Jason L. Selburg at CodeProject.com
 
    LIMITATIONS:
      ParameterTokens and ParameterValues are limited to 1000 characters
      EmailBody is limited to 8000 characters
      ParameterList is limited to 8000 characters total
*/
 
CREATE PROCEDURE dbo.ExecuteSubscribedReport
( @ScheduleID uniqueidentifier,
  @EmailTo varchar (1000) = NULL,
  @EmailCC varchar (1000) = NULL,
  @EmailBCC varchar (1000) = NULL,
  @EmailReplyTo varchar (1000) = NULL,
  @EmailBody varchar (8000) = NULL,
  @ParameterList varchar (8000) = NULL
)
AS BEGIN
 
  DECLARE @extensionSettingsPointer binary(16), 
          @parametersPointer binary(16),
          @tokenPosition int, 
          @tokenLength int,
          @subscriptionID uniqueidentifier,
          @parameterToken varchar(1000),
          @parameterValue varchar(1000),
          @parameterPosition int,
          @numberOfParameters int,
          @parameterCounter int,
          @character varchar(1),
          @parseStatus varchar(1), -- 0 ready for another token, 1 in a token, 2 in a value
          @originalExtensionSettings varchar(8000),
          @originalParameters varchar(8000),
          @newExtensionSettings varchar(8000),
          @newParameters varchar(8000);
  DECLARE @parameters TABLE (ParameterID int IDENTITY(1,1), 
                             ParameterToken varchar(1000), 
                             ParameterValue varchar(1000));
 
  -- first we need to unpack the parameter list
  IF @ParameterList IS NOT NULL BEGIN
    SET @parameterPosition = 1;
    SET @parseStatus = 0;
    SET @parameterToken = '';
    SET @parameterValue = '';
    SET @numberOfParameters = 0;
    WHILE @parameterPosition <= LEN(@ParameterList) BEGIN
      SET @character = SUBSTRING(@ParameterList,@parameterPosition,1);
      IF @character = ',' BEGIN
        IF @parseStatus = 0 BEGIN -- we had two commas in a row or the first character was a comma
          PRINT 'ParameterList has incorrect format';
          RETURN 1;
        END
        ELSE IF @parseStatus = 1 BEGIN -- we are at the end of the token
          SET @parseStatus = 2;
          SET @parameterValue = '';
        END
        ELSE BEGIN -- we are at the end of a value
          INSERT @parameters (ParameterToken,ParameterValue)
            VALUES (@ParameterToken,@ParameterValue);
          SET @numberOfParameters = @numberOfParameters + 1;
          SET @parseStatus = 0;
          SET @parameterToken = '';
        END;         
      END ELSE BEGIN
        IF @parseStatus = 0 BEGIN -- we have the first character of a token
          SET @parseStatus = 1;
          SET @parameterToken = @parameterToken + @character;
        END
        ELSE IF @parseStatus = 1 BEGIN -- we have another character in a token
          SET @parameterToken = @parameterToken + @character;
        END
        ELSE BEGIN -- we have another character in a value
          SET @parameterValue = @parameterValue + @character;
        END;
      END;
      SET @parameterPosition = @parameterPosition + 1;
    END;
    IF @parseStatus = 2 BEGIN-- we were still collecting a value
      INSERT @parameters (ParameterToken,ParameterValue)
        VALUES (@ParameterToken,@ParameterValue);
      SET @numberOfParameters = @numberOfParameters + 1;
    END;
  END;
 
  -- we need to wait for our turn at using the subscription system
  WHILE EXISTS(SELECT 1 FROM tempdb.sys.objects WHERE name = '##ReportInUse')
    WAITFOR DELAY '00:00:30';
  CREATE TABLE ##ReportInUse (ReportID int);
 
  -- once we have the parameters unpacked, we now need to find the subscriptionID
  SELECT @subscriptionID = SubscriptionID
    FROM dbo.ReportSchedule 
    WHERE ScheduleID = @ScheduleID;
 
  -- next we save away the original values of ExtensionSettings and Parameters
  -- (we use them to make it easy put the values back later)
  -- they are actually xml but it'll be easier to work with them as strings
 
  SELECT @originalExtensionSettings = CAST(ExtensionSettings AS varchar(8000)),
         @originalParameters = CAST(Parameters AS varchar(8000))
    FROM dbo.Subscriptions 
    WHERE SubscriptionID = @subscriptionID;
 
  SET @newExtensionSettings = @originalExtensionSettings;
  SET @newParameters = @originalParameters;
 
  -- if they have supplied arguments ie: not NULL and not blank, process them
  IF COALESCE(@EmailTo,'') <> '' 
    SET @newExtensionSettings = REPLACE(@newExtensionSettings,'|TO|',@EmailTo);
  IF COALESCE(@EmailCC,'') <> ''
    SET @newExtensionSettings = REPLACE(@newExtensionSettings,'|CC|',@EmailCC);
  IF COALESCE(@EmailBCC,'') <> ''
    SET @newExtensionSettings = REPLACE(@newExtensionSettings,'|BC|',@EmailBC);
  IF COALESCE(@EmailReplyTo,'') <> ''
    SET @newExtensionSettings = REPLACE(@newExtensionSettings,'|RT|',@EmailReplyTo);
  IF COALESCE(@EmailBody,'') <> ''
    SET @newExtensionSettings = REPLACE(@newExtensionSettings,'|BD|',@EmailBody);
 
  IF @numberOfParameters > 0 BEGIN
    -- process each parameter in turn
    SET @parameterCounter = 1;
    WHILE @parameterCounter <= @numberOfParameters BEGIN
      SELECT @parameterToken = ParameterToken, 
             @parameterValue = ParameterValue,
             @tokenLength = LEN(ParameterToken)
        FROM @parameters
        WHERE ParameterID = @parameterCounter;
      SET @newParameters = REPLACE(@newParameters,@ParameterToken,@ParameterValue);
      SET @parameterCounter = @parameterCounter + 1;
    END;
  END;
 
  -- Temporarily update the values
  UPDATE dbo.Subscriptions 
    SET ExtensionSettings = CAST(@newExtensionSettings AS ntext),
        Parameters = CAST(@newParameters AS ntext)
  WHERE SubscriptionID = @subscriptionID;
 
  -- run the job
  EXEC msdb..sp_start_job @job_name = @ScheduleID
 
  -- make enough delay for the report to have started
  WAITFOR DELAY '00:00:30'
 
  -- put the original extensionsettings and parameter values back
  UPDATE dbo.Subscriptions 
    SET ExtensionSettings = CAST(@originalExtensionSettings AS ntext),
        Parameters = CAST(@originalParameters AS ntext)
  WHERE SubscriptionID = @subscriptionID;
  -- finally we free up the subscription system for another person to use
  DROP TABLE ##ReportInUse;
END;
GO
EXEC dbo.ExecuteSubscribedReport
   @ScheduleID = '4CE38C83-6A03-4780-895A-92FD6F8FD5B0',
   @EmailTo = 'glow@solidq.com',
   @EmailCC = 'ozinfo@solidq.com',
   @EmailBCC = 'info@solidq.com',
   @EmailReplyTo = 'glow@solidq.com',
   @EmailBody = 'Hello Greg',
   @ParameterList = '|StartDate|,20071231,|Salesperson|,GE,|Region|,NW';
