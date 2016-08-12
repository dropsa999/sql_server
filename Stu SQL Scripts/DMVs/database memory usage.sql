--List the Number of pages in the buffer pool by database and page type
SELECT DB_NAME(database_id),
page_type,
COUNT(page_id) AS number_pages
FROM sys.dm_os_buffer_descriptors
WHERE database_id! = 32767
GROUP BY database_id, page_type
ORDER BY number_pages DESC
GO
--List the number of pages in the buffer pool by database
SELECT DB_NAME(database_id),
COUNT(page_id) AS number_pages
FROM sys.dm_os_buffer_descriptors
WHERE database_id! =32767
GROUP BY database_id
ORDER BY database_id
go


--List the number of pages in the buffer pool by page type
SELECT page_type, COUNT(page_id) AS number_pages
FROM sys.dm_os_buffer_descriptors
GROUP BY page_type
ORDER BY number_pages DESC
GO
--List the number of dirty pages in the buffer pool
SELECT COUNT(page_id) AS number_pages
FROM sys.dm_os_buffer_descriptors
WHERE is_modified = 1
GO