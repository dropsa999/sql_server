declare @cmd varchar(255);
SET @cmd = 'bcp "select file_data from myPCard_Global_Interface.dbo.company_storage_file" queryout d:\test01.txt -T -N';
EXEC master..xp_cmdshell @cmd;

select file_data from myPCard_Global_Interface.dbo.company_storage_file

