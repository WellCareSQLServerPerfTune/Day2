use AdventureWorks2008R2
go

-- Create the Partition Function 
create partition function pfSales (date)
as range right for values ('2006-01-01', '2007-01-01', '2008-01-01')
--as range left for values ('2005-12-31', '2006-12-31', '2007-12-31')

-- Create the Partition Scheme
create partition scheme psSales
as partition pfSales all to ([Primary])
--as partition pfSales to (fgSales2005, fgSales2006, fgSales2007, fgSales2008)

-- Create the Partitioned Table (Heap) on the Partition Scheme
create table ptSales (
	SalesID int identity(1,1),
	SalesDate date,
	Quantity int,
	--RoundRobinColumn as SalesID % 4,

	-- Partitioning Column must be in Clustered Index
	constraint PK_ptSales_SalesID_SalesDate primary key (SalesID, SalesDate)
) on psSales(SalesDate)

-- Insert Data
insert into ptSales
	select soh.OrderDate, sod.OrderQty
	from Sales.SalesOrderDetail			as sod
		join Sales.SalesOrderHeader		as soh		on sod.SalesOrderID = soh.SalesOrderID

-- View Data
select * from ptSales

-- View Partition Info
select ps.name,pf.name,boundary_id,value
from sys.partition_schemes				as ps
	join sys.partition_functions		as pf		on pf.function_id=ps.function_id
	join sys.partition_range_values		as prf		on pf.function_id=prf.function_id

select o.name objectname,i.name indexname, partition_id, partition_number, [rows]
from sys.partitions						as p
	join sys.objects					as o		on o.object_id=p.object_id
	join sys.indexes					as i		on i.object_id=p.object_id and p.index_id=i.index_id
where o.name = 'ptSales'

-- Cleanup
drop table ptSales
drop partition scheme psSales
drop partition function pfSales