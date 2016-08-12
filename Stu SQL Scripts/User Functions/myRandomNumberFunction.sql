CREATE VIEW dbo.myRandomNumberView
AS
  SELECT randomNumber = RAND();
go

CREATE FUNCTION dbo.myRandomNumberFunction()
RETURNS DECIMAL(12,11)
AS
BEGIN
    RETURN (SELECT randomNumber FROM dbo.myRandomNumberView);
END
go


CREATE FUNCTION dbo.myRandomNumberFunction2()
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN (SELECT randomNumber*100 FROM dbo.myRandomNumberView);
END
GO