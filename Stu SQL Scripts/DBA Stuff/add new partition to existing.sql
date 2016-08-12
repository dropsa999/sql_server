select * from maintenance.view_partition_file_group_detail


-- Add new Filegroup and file
--ALTER DATABASE [PartitionTest] ADD FILEGROUP [FG5];
--ALTER DATABASE [PartitionTest] ADD FILE
--( NAME = N'PartitionTest_5', FILENAME = N'D:\Temp\PartitionTest_5.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB )
--TO FILEGROUP [FG5]
--go

ALTER PARTITION SCHEME [ps_company_storage_image_personal] 
NEXT USED fg_company_storage_image_personal_12 -- New File Group for the Partition
go

ALTER PARTITION FUNCTION [pf_company_storage_image_personal]() 
SPLIT RANGE (1100000) -- New Range
GO

