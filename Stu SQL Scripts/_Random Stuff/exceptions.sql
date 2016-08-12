use AdventureWorks2008R2;
GO

-- Old
BEGIN TRY
	BEGIN TRANSACTION ;

	-- Delete the Customer
	DELETE FROM Customers
	WHERE EmployeeID = 'CACTU' ;

	COMMIT TRANSACTION ;
END TRY
BEGIN CATCH
	-- There is an error
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION ;

	-- Raise an error with the details of the exception
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int ;
	SELECT @ErrMsg = ERROR_MESSAGE(),
		@ErrSeverity = ERROR_SEVERITY() ;

	RAISERROR(@ErrMsg, @ErrSeverity, 1) ;
END CATCH


-- 2012
BEGIN TRY
	BEGIN TRANSACTION ;

	-- Delete the Customer
	DELETE FROM Customers
	WHERE EmployeeID = 'CACTU' ;

	COMMIT TRANSACTION ;
END TRY
BEGIN CATCH
	-- There is an error
	ROLLBACK TRANSACTION ;

	-- Re throw the exception
	THROW ;
END CATCH



THROW 51000, 'The record does not exist.', 1;