use mypcard00
go

 declare @demo_id int
declare @company_id int
declare @result int
declare @scenario_id int
declare @bank_id int
declare @currency_code int
declare @company_name nvarchar(100)
declare @username_seed nvarchar(20)
declare @password_raw nvarchar(100)
declare @password_crypt nvarchar(100)
declare @employee_num nvarchar(20)
declare @master_userid nvarchar(20)
declare @ai_reference int
  
 set @ai_reference = 271 -- "ai_reference" must be unique, use below script to find next available one (enter the Demo_Request)
-- select DEMO_REQUEST, DEMO_COMPANY_NAME, DEMO_COMPANY_ID, DEMO_DATABASE_ID from dbo.vw_demo_request
set @scenario_id = 1003
set @bank_id = 100
set @currency_code = 554
set @company_name = 'Spendvision Stu playpen' -- change company Name
set @username_seed = 'stu' -- Change seed (This is the username)
set @password_raw = 'River!Hotel5' --(password based on test or RC environment)
set @password_crypt = 'pbk$10000$64$CkiDLMBSRR9BVt97jGdnntN8xpWu7HLBmLs396uxvIe+Fx8n0/W+3MhEuZxgei5LlDnAC92rfl/aNx4hxPHCzQ==$PNfQD5fvfcGGWoEYOw3GCWk/63HioBP0r3fz5mH40UxlI/qHhUBWFOWG1gWpHHR22tWGNItF3sG5xuVptnrsLDvhPKiBD+/qL/wSA8UJ21wTcymkxyDdwc9m0KbTo3zAxUJ9+LBb9spcqdv29YmKmt2DrdhzSaXVszstjNUrm2DTG6xOhEP3cfNl6Bt/KxckF6GtG7sJkMPPYGJzxQIQSwsFbSSm0DuTGzrlcpF0WR7Qz31Dv4D4Z0a2Wh0nVD+UqqVMRovmzEI6nr7KJI1oJOpFzh7etkShk/SL+0vX3ojo5/r5bcpKIXzL0yObFE78zMYTkMSFUEW0ytqJeR1hhg==' 
--(this password crypt can be obtained from HashPassword tool in Q:\Test Tools\HashPasswordTool)
set @master_userid = 'svadmin'

 if not exists (select 1 from dbo.vw_demo_request where demo_request = @ai_reference)
begin
insert into dbo.vw_demo_request (FORENAME,SURNAME,COMPANY,ADDRESS_1,ADDRESS_2,CITY,COUNTRY,PHONE,EMAIL,REFERRED,DATE_APPLICATION,demo_status,DEMO_STATUS_DATE,DEMO_STATUS_USER,DEMO_COMPANY_NAME,DEMO_COMPANY_ID,DEMO_DATABASE_ID,DEMO_SCENARIO_ID,COMMENTS,DEMO_PRODUCT_ID)
values ('Spendvision', 'Administrator', 'Spendvision', 'Spendvision', null, 'Auckland', 'NZ', '+64 9 368 4919', 'help@spendvision.com', 'N/A', getdate(), 1, getdate(), null, null, null, null, null, null, 'PRODUCT_01')
set @ai_reference = @@IDENTITY
end

 if exists (select 1 from dbo.vw_demo_request where demo_request = @ai_reference and demo_company_id is not null)
begin
exec @result = dbo.xp_xmlsave_Delete_Company @master_userid, @ai_reference, 1
select @result
end
exec @result = dbo.xp_xmlsave_Demo_Scenario_Load @scenario_id, @ai_reference, @bank_id, @currency_code, @company_name, @username_seed, @master_userid, @password_raw, @password_crypt
select @result
set @company_id = (select demo_company_id from dbo.vw_demo_request where demo_request = @ai_reference)
if @company_id is null
begin
print 'An Error has Occurred'
end
else
begin
insert into vw_user_company_allocation values (@master_userid, db_name(), @company_id)
set @employee_num = (select employee_num from dbo.employee where company_id = @company_id and employee_num like '%ADMIN')
insert into dbo.emp_technical_settings ( employee_num, company_id, technical_option, opt_value ) select @employee_num, @company_id, technical_option.technical_option, 1 from dbo.technical_option where technical_option.technical_option between 3100 and 4302 and not exists ( select 1 from dbo.emp_technical_settings e2 where e2.company_id = @company_id and e2.employee_num = @employee_num and e2.technical_option = technical_option.technical_option )
delete from emp_technical_settings where technical_option = 4025 and employee_num = @employee_num and company_id = @company_id
end

go
