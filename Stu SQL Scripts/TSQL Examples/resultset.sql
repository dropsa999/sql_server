/* use dynamic SQL / force a data type without explicit conversion */

EXEC(N'SELECT a = 2; SELECT b = 1')
WITH RESULT SETS
(
	(a TINYINT),
	(b BIT)
);
GO


/* 
	rename columns
	different apps can adapt to schema changes at different rates
*/

EXEC [master].dbo.sp_who2
WITH RESULT SETS
(
	(
		[SPID]         INT,          -- <-- fixed the data type
		[Status]       NVARCHAR(32),
		[Login]        SYSNAME,
		HostName       SYSNAME,
		Blocker	       CHAR(5),      -- <-- renamed this column
		[Database]     SYSNAME,
		Command        NVARCHAR(32),
		CPUTime        VARCHAR(30),
		DiskIO         VARCHAR(30),
		LastBatch      VARCHAR(48),
		ProgramName    NVARCHAR(255),
		Redundant_SPID INT,      -- <-- renamed this column & changed datatype
		RequestID      INT
	)
);
GO
--  No, you can't use this to drop or add columns


-- sys.sp_server_diagnostics with more usable output

EXEC sys.sp_server_diagnostics
WITH RESULT SETS
(
	(
		ct   DATETIME,
		type varchar(32),
		area SYSNAME,
		st   INT,
		sd   VARCHAR(32),
		data XML
	)
);

--Structure conformance
EXEC(N'SELECT a = 2, b = 1, c = 3')
WITH RESULT SETS
(
	(a TINYINT, b BIT)
);
GO

-- Datatype conformance
EXEC(N'SELECT GETDATE() AS DATETIME2')
WITH RESULT SETS
(
	(a INT)
);
GO
