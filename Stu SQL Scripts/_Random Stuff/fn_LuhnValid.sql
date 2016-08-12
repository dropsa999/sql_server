USE DSELKTEST
GO

/*Tally Table Creation*/
create table tally_table
(
      id bigint not null
constraint[pk_tally_table] primary key clustered
(
      id
))
 
;WITH
  E1(N) AS (
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
           ),                          -- 1*10^1 or 10 rows
  E2(N) AS (SELECT 1 FROM E1 a, E1 b), -- 1*10^2 or 100 rows
  E4(N) AS (SELECT 1 FROM E2 a, E2 b), -- 1*10^4 or 10,000 rows
  E8(N) AS (SELECT 1 FROM E4 a, E4 b)  -- 1*10^8 or 100,000,000 rows 
insert into tally_table(id)
SELECT TOP (1000000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) 
FROM E8
/* Generate Some Test Credit Card Data and Store it in a Table Variable */
declare @cctable table 
(
      id bigint identity(1,1),
      cc_type varchar(25) not null,
      credit_card varchar(20) not null,
      primary key clustered(id)
)
GO

create function [dbo].[fn_LuhnValid]( @digits varchar(25) )
returns int
AS
Begin
declare @return int
      --((t.id+1)%2)+1 always gives us 1 or 2 depending upon whether the value is % 2 or not
      -- Results of 1 are considered Even, as the Luhn Algorithm starts from the right at 1 not 0
      -- our Odds are Even then and Evens are Odd then
      -- t.id = 1 = (1+1) = 2 % 2 = 0 + 1 = 1 --EVEN
      -- t.id = 2 = (2+1) = 3 % 2 = 1 + 1 = 2 --ODD
      -- t.id = 3 = (3+1) = 4 % 2 = 0 + 1 = 1 --EVEN
      -- t.id = 4 = (4+1) = 5 % 2 = 1 + 1 = 2 --ODD
      -- ...
      -- t.id = 13 = (13+1) = 14 % 2 = 0 + 1 = 1 --EVEN
Select
@return = ISNULL(NULLIF(sum(
      Case ((t.id+1)% 2) + 1
            When 2
            --ODD
            --Multiply the Digit by 2 as an Int so we drop the remainder, as we add the remainder in the LuhnAlgorithm
            Then (cast(Substring(reverse(@digits), t.id, 1) as int) * 2) / 10 + 
                        --Add the Remainder to the Product Above
                        (cast(Substring(reverse(@digits), t.id, 1) as int) * 2) % 10      Else
            --EVEN
            substring(reverse(@digits), t.id, 1)
            
            --If our Sum % 10 = 0, set our result to 0 ( Logically we would set this to 1, but we will take care of that in the
            --return statement, so we always ONLY get a 1 or 0 returned)
      End ) % 10, 0) , 0)
from dbo.tally_table t
Where t.id <= len(@digits)
--If our value in @return matches 0, meaning that it is valid, as we set it to 0 when valid from above
--then we will set the @return value to 1.  Otherwords any other value is invalid and nullif will return 0
--instead of the @return value
return ISNULL(NULLIF(0, @return),1)
End