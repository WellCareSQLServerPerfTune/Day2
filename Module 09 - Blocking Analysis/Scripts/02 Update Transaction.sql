use AdventureWorks2008R2

select @@SPID

-- Other User Script
begin transaction
	update Production.Product						
	set ListPrice = 1
--commit
   
rollback
