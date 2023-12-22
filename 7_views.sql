drop schema if exists project_views cascade;
create schema project_views;

set search_path = project_views, public;


-- представление складов
drop view if exists v_warehouse;
create view v_warehouse as
select address as "адрес"
from project.warehouse;


-- представление заказчиков, маскируются фамилия и номер телефона
drop view if exists v_customer;
create view v_customer as
select first_name                                                                              as "Имя",
       substr(last_name, 1, 1) || '.'                                                          as "Фамилия",
       repeat('*', length(phone_number) - 2) || substr(phone_number, length(phone_number) - 1) as "Телефон"
from project.customer;


-- представление заказов, маскируются фамилии заказчиков
drop view if exists v_order;
create view v_order as
select o.date                                                  as "Дата заказа",
       c.first_name || ' ' || substr(c.last_name, 1, 1) || '.' as "Заказчик",
       o.address                                               as "Адрес",
       o.cost                                                  as "Стоимость",
       d.name                                                  as "Служба доставки",
       o.delivery_period                                       as "Срок доставки",
       o.delivery_type                                         as "Тип доставки"
from project.order as o
         left join project.customer as c on o.customer_id = c.customer_id
         left join project.delivery_service as d on o.delivery_service_id = d.delivery_service_id;


-- представление продуктов, отображаются только актуальные записи
drop view if exists v_product;
create view v_product as
select p.name as "Название", p.contents as "Описание", p.price as "Цена", p.valid_from as "Последнее обновление"
from project.product as p
where valid_to = '5999-12-31 23:59:59.000000';


-- представление служб доставок, маскируются номера телефонов
drop view if exists v_delivery_service;
create view v_delivery_service as
select d.name                                                                                        as "Название",
       repeat('*', length(contact_number) - 2) || substr(contact_number, length(contact_number) - 1) as "Телефон",
       d.email                                                                                       as "email",
       d.address                                                                                     as "Адрес"
from project.delivery_service as d;


-- представление заказ_x_продукт
drop view if exists v_order_x_product;
create view v_order_x_product as
select o.date                                                  as "Дата заказа",
       c.first_name || ' ' || substr(c.last_name, 1, 1) || '.' as "Заказчик",
       p.name                                                  as "Товар",
       p.price                                                 as "Цена",
       oxp.quantity                                            as "Количество",
       p.price * oxp.quantity                                  as "Стоимость",
       w.address                                               as "Склад"
from project.order_x_product as oxp
         inner join project.order as o on o.order_id = oxp.order_id
         inner join project.customer as c on o.customer_id = c.customer_id
         inner join project.warehouse as w on oxp.warehouse_id = w.warehouse_id
         inner join project.product as p
                    on oxp.product_id = p.product_id and (o.date between p.valid_from and p.valid_to);


-- представление продукт_x_склад
drop view if exists v_product_x_warehouse;
create view v_product_x_warehouse as
select pxw.valid_from as "Дата обновления", p.name as "Товар", w.address as "Склад", pxw.quantity as "Количество"
from project.product_x_warehouse as pxw
         inner join project.product as p on pxw.product_id = p.product_id
         inner join project.warehouse as w on w.warehouse_id = pxw.warehouse_id
where pxw.valid_to = '5999-12-31 23:59:59.000000';
