SET search_path = project, PUBLIC;

-- Выведите для каждого клиента в алфавитном порядке (Фамилия, Имя), не используя 
-- поле cost, максимальную сумму заказа.

select distinct 
	c.customer_id, 
	c.last_name || ' ' || c.first_name as customer_name,
	coalesce(max(p.price * op.quantity) over (partition by c.customer_id), 0) as total_spent
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
order by 
	c.customer_id;

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

-- Выведите всех клиентов, имена которых содержат букву "р", но которые не заказывали чай Пуэр "Шу"
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

-- Вывести нарастающим итогом сумму заказов для каждого покупателя за последний год. 
-- В итоге на каждую дату в таблице для каждого покупателя должна быть одна строка, в которой 
-- отражена сумма его заказов на эту дату.
select distinct
    d."date",
    c.customer_id as customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    coalesce(sum(o.cost) over (partition by c.customer_id order by d."date"), 0)
from
    (select distinct "date" from "order") d
cross join
    customer c
left join
    "order" o on d."date" = o."date" and c.customer_id = o.customer_id
where 
	d."date" >= current_timestamp - interval '1 year'
order by
    d."date", c.customer_id;

-- Для каждой службы доставки вывести сумму стоимостей доставленных заказов, процент суммы доставленных
-- от суммы стоимостей доставленных заказов во всем магазине и максимальный по стоимости доставленный заказ
with sum_by_delivery as (select distinct 
	ds.delivery_service_id,
	ds."name" as delivery_name,
	coalesce(sum(o."cost") over (partition by ds.delivery_service_id), 0) as total_sum_delivered,
	coalesce(max(o."cost") over (partition by ds.delivery_service_id), 0) as max_order_delivered
from 
	delivery_service ds 
left join
	"order" o 
		on o.delivery_service_id = ds.delivery_service_id and o.status = 'Доставлен')
select 
	sbd.delivery_service_id,
	sbd.delivery_name,
	sbd.total_sum_delivered,
	sbd.max_order_delivered,
	round((sbd.total_sum_delivered / greatest(sum(sbd.total_sum_delivered) over (), 1)) * 100, 3) as percent_of_total
from 
	sum_by_delivery as sbd
order by
	percent_of_total desc;
