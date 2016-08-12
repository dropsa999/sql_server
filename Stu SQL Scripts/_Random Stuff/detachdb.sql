DECLARE @Path varchar(400)
SET @Path = "D:\MSSQL\Data\"
use [master]
--STEP 1 
--Keep the output of this script aside
Select "EXEC sp_attach_db @dbname = ''"+ [name] +"''," +
     "@filename1 = ''" + @Path +  [name] +"_Data.mdf''," + 
     "@filename2 = ''"+ @Path + [name] +"_Log.ldf''" from sysdatabases 
	 	where dbid > 4

--STEP 2
--Generate this script and run
Select ''EXEC sp_detach_db '' + [name]  from sysdatabases where dbid > 4

--After Successful run from Output of STEP 2 RUN Output of STEP 2
