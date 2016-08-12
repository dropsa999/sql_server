SELECT     (CASE   MONTH(GETDATE())
                WHEN 1 THEN 31
                WHEN 2 THEN (CASE YEAR(GETDATE())%4 WHEN 0 THEN 29 ELSE 28 END)
                WHEN 3 THEN 31
                WHEN 4 THEN 30
                WHEN 5 THEN 31
                WHEN 6 THEN 30
                WHEN 7 THEN 31
                WHEN 8 THEN 31
                WHEN 9 THEN 30
                WHEN 10 THEN 31
                WHEN 11 THEN 30
                WHEN 12 THEN 31
        END) AS LastDayOfMonth 