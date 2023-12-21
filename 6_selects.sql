SET search_path = project, PUBLIC;

-- Выведите для каждого клиента в алфавитном порядке (Фамилия, Имя), не используя 
-- поле cost, суммарное количество потраченных денег.

select 
	c.last_name,
	c.first_name,
	coalesce(sum(p.price), 0) as total_spent
from 
	"order" o
right join 
	customer c
		on o.customer_id = c.customer_id
left join 
	order_x_product op
		on o.order_id = op.order_id
left join 
	product p
		on op.product_id = p.product_id 
		and o.date between p.valid_from and p.valid_to
group by 
	c.first_name, 
	c.last_name
order by 
	c.last_name, 
	c.first_name;

-- Выведите те товары, которых на данный момент доступно больше 200 
-- единиц суммарно на всех складах.
select 
	p.product_id, 
	p."name", 
	sum(pw.quantity) as total_quantity
from 
	product p
left join 
	product_x_warehouse pw
		on p.product_id = pw.product_id 
		and current_timestamp between pw.valid_from and pw.valid_to
where 
	current_timestamp between p.valid_from and p.valid_to
group by 
	p.product_id, p."name"
having 
	sum(pw.quantity) > 200
order by 
	product_id;

-- Для каждого человека, у которого есть заказы, вывести его самый 
-- маленький заказ по количеству единиц товара.
select distinct
	os.customer_id,
	os.first_name, 
	os.last_name, 
	min(os.order_size) over (partition by os.customer_id) as min_order_size
from 
	(select distinct
		c.customer_id,
		c.first_name,
		c.last_name,
		o.order_id,
		sum(op.quantity) over (partition by o.order_id) as order_size
	from customer c
	left join "order" o
		on o.customer_id = c.customer_id
	left join order_x_product op
		on op.order_id = o.order_id
	group by c.customer_id, c.first_name, c.last_name, o.order_id, op.quantity
	order by c.customer_id
	) as os
where order_id is not null 
order by customer_id;

-- Выведите всех клиентов, имена которых содержат букву "А", но которые не заказывали чай Пуэр "Шу"
with client_teas as (
(
select distinct 
	c.customer_id, 
	c.first_name, 
	c.last_name, 
	p."name"
from 
	customer c
	inner join "order" o
		on o.customer_id = c.customer_id
	inner join order_x_product op
		on op.order_id = o.order_id
	inner join product p
		on p.product_id = op.product_id 
		and current_timestamp between p.valid_from and p.valid_to
where 
	c.first_name like '%р%'
group by 
	c.customer_id, 
	c.first_name, 
	c.last_name,  
	p."name"
)
except 
(
select distinct
	c.customer_id, 
	c.first_name, 
	c.last_name, 
	p."name"
from 
	customer c
	inner join "order" o
		on o.customer_id = c.customer_id
	inner join order_x_product op
		on op.order_id = o.order_id
	inner join product p
		on p.product_id = op.product_id 
		and current_timestamp between p.valid_from and p.valid_to
where 
	p."name" = 'Пуэр "Шу"'
group by 
	c.customer_id, 
	c.first_name, 
	c.last_name, 
	p."name"
)
order by customer_id
)
select distinct
	first_name,
	last_name
from
	client_teas;