BEGIN TRY
 
    -- RAISERROR with severity 0-10 will not cause execution to jump to the CATCH block.
 
      PRINT '1. Execution is in TRY Block with severity 0-10'
      WAITFOR DELAY '00:00:05'
 
     RAISERROR  ('2. Error raised in TRY block.', 5, 1) with NOWAIT
 
      PRINT '3. Control did not go to CATCH Block'
 
      WAITFOR DELAY '00:00:05'
      PRINT '4. It''s over now'
 
END TRY
 
begin catch
 
    -- Use RAISERROR inside the CATCH block to return error information about the original error that caused
    -- execution to jump to the CATCH block.
 
      WAITFOR DELAY '00:00:05'
      RAISERROR  ('5. Error raised in Catch block.',5, 1)
 
END CATCH;