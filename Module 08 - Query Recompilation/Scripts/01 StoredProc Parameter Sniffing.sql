use AdventureWorks2008R2
go

-- Enable Time and IO Statistics
set statistics time on
set statistics io on
go

-- Clear Buffer and Procedure Caches
checkpoint
go
dbcc dropcleanbuffers
dbcc freeproccache
go

-- Each Query Has a Different Execution Plan
select * from Sales.SalesOrderDetail where ProductID = 897		-- 2 Rows / 0.242163 Estimated Cost / 10 Logical Reads
select * from Sales.SalesOrderDetail where ProductID = 870		-- 4688 Rows / 1.13256 Estimated Cost / 1240 Logical Reads

go
create schema Test
go

-- Create Stored Proc
create procedure Test.spSalesOrderDetailsByProductID
	@ProductID as int
as
select * from Sales.SalesOrderDetail where ProductID = @ProductID
go

exec Test.spSalesOrderDetailsByProductID 897					-- 2 Rows / 0.242163 Estimated Cost / 10 Logical Reads			
exec Test.spSalesOrderDetailsByProductID 870					-- 4688 Rows / 0.242163 Estimated Cost / 14378 Logical Reads :(


-- Fixes

-- Recompile on Exec, Recompiles all statements in StoredProc
exec Test.spSalesOrderDetailsByProductID 870 with recompile		-- 4688 Rows / 1.13256 Estimated Cost / 1240 Logical Reads :)


-- Recompile on StoredProc, Recompiles all statements in StoredProc every execution
drop procedure Test.spSalesOrderDetailsByProductID
go
create procedure Test.spSalesOrderDetailsByProductID
	@ProductID as int
	with recompile
as
select * from Sales.SalesOrderDetail where ProductID = @ProductID
go

exec Test.spSalesOrderDetailsByProductID 897					-- 2 Rows / 0.242163 Estimated Cost / 10 Logical Reads
exec Test.spSalesOrderDetailsByProductID 870					-- 4688 Rows / 1.13256 Estimated Cost / 1240 Logical Reads :)


-- Recompile Hint on Query, Only Recompiles Statement
drop procedure Test.spSalesOrderDetailsByProductID
go
create procedure Test.spSalesOrderDetailsByProductID
	@ProductID as int
as
select * from Sales.SalesOrderDetail where ProductID = @ProductID
option (recompile)
go

exec Test.spSalesOrderDetailsByProductID 897					-- 2 Rows / 0.242163 Estimated Cost / 10 Logical Reads
exec Test.spSalesOrderDetailsByProductID 870					-- 4688 Rows / 1.13256 Estimated Cost / 1240 Logical Reads :)


-- Optimize for on Query, Doesn't recompile but fixes what Execution Plan it Uses
drop procedure Test.spSalesOrderDetailsByProductID
go
create procedure Test.spSalesOrderDetailsByProductID
	@ProductID as int
as
select * from Sales.SalesOrderDetail where ProductID = @ProductID
option (optimize for (@ProductID = 870))
go

exec Test.spSalesOrderDetailsByProductID 897					-- 2 Rows / 1.13256 Estimated Cost / 1240 Logical Reads :(
exec Test.spSalesOrderDetailsByProductID 870					-- 4688 Rows / 1.13256 Estimated Cost / 1240 Logical Reads 



-- Clean Up
drop procedure Test.spSalesOrderDetailsByProductID
drop schema Test
	
-- Disable Time and IO Statistics
set statistics time off
set statistics io off
go