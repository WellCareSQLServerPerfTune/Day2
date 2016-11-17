use AdventureWorks2008R2

-- Important: Before Running these Queries, Run Other User Script in 02 Update Transaction.sql

select @@SPID

-- Read Uncommitted
-- Least invasive concurrency model, but prone to the most data issues
-- No S locks with a select, but allows dirty reads because it essentially ignores X locks on modified rows
set transaction isolation level read uncommitted
select Name, ListPrice from Production.Product	


-- Query Hint with (nolock) Same as Read Uncommitted		
set transaction isolation level read committed
select Name, ListPrice from Production.Product with (nolock)				


-- Read Committed
-- Default Isolation level for SQL Server
-- Applies S locks with a select, but doesn't hold them until end of transaction
-- Avoids dirty reads, but because it doesn't hold the S locks its prone to non-repeatable reads
set transaction isolation level read committed				
select Name, ListPrice from Production.Product


-- Important: Rollback Other User Script

-- Repeatable Read
-- Holds S locks with a select until the end of a transaction
-- This prevents non-repeatable reads, but still allows Phantom Reads
-- More prone to deadlocks and other blocking issues
set transaction isolation level repeatable read	
begin transaction
	select Name, ListPrice from Production.Product

-- Important: Now try running Other User Script again, notice its blocked because of S Locks held on select trans	
rollback


-- Serializable
-- Prevents Phantom Reads by placing Range Locks with Selects instead of Individual Locks
-- Most prone to blocking / deadlock issues
set transaction isolation level serializable


-- Snapshot Options, offered as of SQL Server 2005
-- Keeps 2 copies of modified rows, the original version and the modified version
-- Extra copy kept in TempDB, so more overhead on that database

alter database AdventureWorks2008R2 set Read_Committed_Snapshot off


alter database AdventureWorks2008R2 set Allow_Snapshot_Isolation off
set transaction isolation level snapshot

