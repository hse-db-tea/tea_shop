set search_path = project, public;

-- доступное количество товаров по всем складам

drop view if exists product_total_quantity;
create or replace view product_total_quantity as (
	select 
		product_id, 
		sum(quantity) as total_quantity
	from product_x_warehouse
	where current_timestamp between valid_from and valid_to
	group by product_id
	order by sum(quantity) desc
);

select *
from product_total_quantity;

-- востробованность каждого склада по количеству запросов и товаров

drop view if exists warehouse_relevance;
create or replace view warehouse_relevance as (
	select distinct 
		warehouse_id,
		count(*) over (partition by warehouse_id) as orders_amount,
		sum(quantity) over (partition by warehouse_id) as products_amount
	from product_x_warehouse
	order by products_amount desc
);

select *
from warehouse_relevance;

-- статичтика по дням за последние 30 дней

drop view if exists statistics_by_month;
create or replace view statistics_by_month as (
	with relevant_order_data as (
		with relevant_orders as (
			select 
				order_id,
				"date",
				"cost"
			from "order"
			where "date" >= current_timestamp - interval '30 days'
		)
		select 
			ro.order_id,
			ro."date",
			ro."cost",
			op.product_id,
			op.quantity
		from relevant_orders ro
		inner join order_x_product op
		on ro.order_id = op.order_id
	)
	select distinct
		rod."date",
		count(rod.order_id) as order_amount,
		sum(rod."cost") as total_revenue,
		count(rod.product_id * rod.quantity) as product_amount
	from relevant_order_data rod
	inner join product p
	on p.product_id = rod.product_id
	where rod."date" between p.valid_from and p.valid_to
	group by rod."date"
	order by rod."date"
);

select *
from statistics_by_month;