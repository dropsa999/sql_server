--Exec Copy_Goodlife_Current_Clients


DECLARE @CurrentDate DATETIME
SET @CurrentDate = DATEADD(d, DATEDIFF(d, 0, GETDATE()-1), 0)

--SELECT @CurrentDate	--2014-01-22 00:00:00.000

--SELECT GETDATE()
--SELECT GETDATE()-1

        --INSERT  INTO [link.ardentleisure.com,48652].DebitSuccess.dbo.DS_Goodlife_Current_Members
        --        ( CurrentDate ,
        --          Adfitno ,
        --          Address1 ,
        --          Suburb ,
        --          State ,
        --          Postcode ,
        --          NameFirstName ,
        --          NameLastName ,
        --          Contact ,
        --          WitnessDate ,
        --          Finishdate ,
        --          Term ,
        --          PayType ,
        --          Frequency ,
        --          Instalment ,
        --          FacilityName ,
        --          FacilityAccount ,
        --          ContractPrefix ,
        --          SetToTerm ,
        --          StartDate ,
        --          LoadDate ,
        --          SuspensionStartDate ,
        --          SuspensionEndDate ,
        --          SuspensionFee ,
        --          [Est Fee Status] ,
        --          [Est Fee Value] ,
        --          FirstInstalmentDate
        --        )
                SELECT DISTINCT
						
                        @CurrentDate AS CurrentDate ,
                        a.Adfitno ,
                        RTRIM(ISNULL(AD.Address1, '')) AS Address1 ,
                        AD.Suburb ,
                        AD.State ,
                        AD.Postcode ,
                        CL.NameFirstName ,
                        NameLastName ,
                        CASE WHEN LEN(ISNULL(CO.STD, '')) > 1
                             THEN REPLACE(CO.STD, '+61', '0') + ' '
                             ELSE ''
                        END + LTRIM(RTRIM(CO.Detail)) AS Contact ,
                        a.WitnessDate ,
						a.finishdate ,
                        CASE WHEN a.TermType = 'P'
                             THEN CASE WHEN ISNULL(a.Pmts, 0) > 0
                                       THEN CAST(CAST(( ISNULL(( SELECT
                                                              Paid
                                                              FROM
                                                              Processing
                                                              WHERE
                                                              Processing.Account = a.Account
                                                              AND Processing.Transcode = 'PY'
                                                              ), 0)
                                                        / CASE
                                                              WHEN ISNULL(a.MinSubAmount,
                                                              0) = 0 THEN '1'
                                                              ELSE ( a.MinSubAmount
                                                              / a.Pmts )
                                                          END ) AS INT) AS VARCHAR)
                                       ELSE '0'
                                  END + '/' + CAST(a.Pmts AS VARCHAR)
                                  + ' Pmts'
                             --ELSE CASE WHEN a.StartDate >= GETDATE() THEN '0'
							 ELSE CASE WHEN a.StartDate >= @CurrentDate THEN '0'
                                       --ELSE CAST(DATEDIFF(month, a.StartDate, GETDATE()) AS VARCHAR)
									   ELSE CAST(DATEDIFF(month, a.StartDate, @CurrentDate) AS VARCHAR)
                                  END + '/' + CAST(a.Term AS VARCHAR)
                                  + ' Mths'
                        END AS Term ,
                        CASE PS.PayType
                          WHEN 'DD' THEN 'Direct Debit'
                          WHEN 'CC' THEN 'Credit Card'
                          WHEN 'CH' THEN 'Cash'
                          WHEN 'CQ' THEN 'Cheque'
                          WHEN 'AP' THEN 'Automatic Payment'
                        END AS PayType ,
                        CASE PS.Frequency
                          WHEN 'WK' THEN 'Weekly'
                          WHEN 'FN' THEN 'Fortnightly'
                          WHEN 'FW' THEN 'Four Weekly'
                          WHEN 'MN' THEN 'Monthly'
                          WHEN 'BM' THEN 'Bi Monthly'
                          WHEN 'QT' THEN 'Quarterly'
                          WHEN 'OF' THEN 'One Off'
                        END AS Frequency ,
                        PS.Installment AS Instalment ,
                        F.Name AS FacilityName ,
                        RTRIM(fa.[Desc]) AS FacilityAccount ,
                        fa.ContractPrefix ,
                        a.Isterm AS SetToTerm ,
                        a.StartDate ,
                        a.LoadDate ,
                        SS.StartDate AS SuspensionStartDate ,
                        SS.EndDate AS SuspensionEndDate ,
                        SS.Installment AS SuspensionFee ,
                        CASE WHEN ISNULL(a.estfeestatus, 1) = 1
                                  AND ISNULL(fa.estfeeamount, 0) = 0 THEN 3
                             WHEN ISNULL(a.estfeestatus, 1) = 1
                                  AND psest.installment IS NULL THEN 2
                             ELSE ISNULL(a.estfeestatus, 1)
                        END AS [Est Fee Status] ,
                        CASE WHEN CASE WHEN ISNULL(a.estfeestatus, 1) = 1
                                            AND ISNULL(fa.estfeeamount, 0) = 0
                                       THEN 3
                                       WHEN ISNULL(a.estfeestatus, 1) = 1
                                            AND psest.installment IS NULL
                                       THEN 2
                                       ELSE ISNULL(a.estfeestatus, 1)
                                  END = 2 THEN -10
                             ELSE CASE WHEN ISNULL(fa.estfeeamount, 0) > 0
                                       THEN ISNULL(fa.estfeeamount, 0) - 10
                                       ELSE 0
                                  END
                        END AS [Est Fee Value] ,
                        PSFirst.FirstRegularPaymentDate
                FROM    Account a WITH ( NOLOCK )
                        INNER JOIN dbo.Client CL WITH ( NOLOCK ) ON a.Client = CL.Client
                        INNER JOIN dbo.Customer CU WITH ( NOLOCK ) ON CL.Client = CU.Customer
                        INNER JOIN dbo.Facility F WITH ( NOLOCK ) ON a.Facility = F.Facility
                        INNER JOIN dbo.FacilityGroup FG WITH ( NOLOCK ) ON F.FacilityGroup = FG.FacilityGroup
                        INNER JOIN dbo.FacilityAccount fa WITH ( NOLOCK ) ON a.FacilityAccount = fa.FacilityAccount
                        LEFT JOIN dbo.Address AD WITH ( NOLOCK ) ON CU.PrefAddress = AD.Address
                        LEFT JOIN dbo.Contacts CO WITH ( NOLOCK ) ON CU.PrefContact = CO.Contacts
                        LEFT JOIN dbo.Payschedule PS WITH ( NOLOCK ) ON PS.Payschedule = a.ActiveSchedule
                        LEFT JOIN ( SELECT  Account ,
                                            SUM(Installment) AS Installment
                                    FROM    dbo.PaySchedule WITH ( NOLOCK )
                                    WHERE   PaymentType = 'EF'
                                    GROUP BY Account
                                  ) AS psest ON a.Account = psest.Account
                        LEFT JOIN ( SELECT  *
                                    FROM    dbo.PaySchedule PS WITH ( NOLOCK )
                                            INNER JOIN dbo.ScheduleSuspense SS
                                            WITH ( NOLOCK ) ON PS.Payschedule = SS.ScheduleSuspense
                                  ) AS SS ON SS.Account = a.Account
                                             AND SS.Startdate <= @CurrentDate
                                             AND ( SS.EndDate IS NULL
                                                   OR SS.Enddate >= @CurrentDate
                                                 )
                        LEFT JOIN ( SELECT  account ,
                                            MIN(StartDate) AS FirstRegularPaymentDate
                                    FROM    Payschedule PS WITH ( NOLOCK )
                                            INNER JOIN SchedulePayment SP WITH ( NOLOCK ) ON PS.Payschedule = SP.SchedulePayment
                                    GROUP BY Account
                                  ) AS PSFirst ON PSFirst.Account = a.Account
                WHERE   FG.GroupName = 'Goodlife'
                        --AND a.FinishDate IS NULL
						AND (a.FinishDate IS NULL OR a.FinishDate = @CurrentDate)
						
 





