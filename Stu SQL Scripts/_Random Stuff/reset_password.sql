use myPCard01
go
update dbo.emp_authentication
set	 login_attempts = 0
	,account_locked = 0
	,account_locked_date = null
	,last_pass_change = getdate()-1
	,password = 'pbk$100$64$RZQPlha8aYPsO7n22h+8ZkVSyQzaMdnaIxrHoiwgmagIDaslXUOycJxtEnkPXtY6F05KbJrq/HI8jQ/QNP+GIg==$JG40HYEu3qlZB/PuWsK1SLXNVMuRubTiaz8TlWmE9IWQ8AkaSap7d3Owysu8FY5GY9wopxBzrp6HRToYOxHlMrzOVTVndtyL341gBzlZ8DSFrads65Xu5jn/fTAklBTbpzrRTjlq6Y1DdrGSILytdRnxYRaSm3J8cJ0Pi3rNJpXhxo4+UjTHx7CIkqCxkp+SC7R2c4C+zzemY5a5GD9Mxt77U1ibrueJ0NYj9EduoEiAU8f3PHCWgnUtPj5tH1O7YiGk++HojbRHZcASArcMI6vTs+LVa7IvUNaWxtwjzT+e/kBUV+FYVO/OfiIwW+PVRryXZCykxHCMDGEl95MNyA=='
	--River!Grass5
	
where userid='svadmin'

select * from dbo.emp_authentication where userid = 'svadmin'