use AdventureWorks2008R2
go

-- Clear Buffer and Procedure Caches
checkpoint
go
dbcc dropcleanbuffers
dbcc freeproccache
go

-- Execute Entire Query Window and view Cached Plans Queries at the Bottom
go
select * from Person.Address where StateProvinceID = 32
go
select * from Person.Address where StateProvinceID = 42
go
select * from Person.Address where StateProvinceID = 9
go
select * from Person.Address where AddressID = 42
go
select * from Person.Address where AddressID = 52
go

-- Cached Plans Queries
select usecounts, cacheobjtype, objtype, [text], query_plan
from sys.dm_exec_cached_plans
	cross apply sys.dm_exec_query_plan(plan_handle)
	cross apply sys.dm_exec_sql_text(plan_handle)

select execution_count, total_logical_reads, [text], query_plan, query_hash, query_plan_hash
from sys.dm_exec_query_stats
	cross apply sys.dm_exec_query_plan(plan_handle)
	cross apply sys.dm_exec_sql_text(plan_handle)