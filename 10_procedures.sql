set search_path = project, public;

-- adds a product to an order
drop procedure if exists order_product(in o_id int, in p_id int, in q int);
create procedure order_product(in o_id int, in p_id int, in q int)
    language plpgsql as
$$
declare
    dt  timestamp;
    row RECORD;
begin
    if o_id not in (select order_id from project.order) then
        raise exception 'ORDER NOT FOUND';
    end if;
    if p_id not in (select product_id from project.product) then
        raise exception 'PRODUCT NOT FOUND';
    end if;

    dt := (select date from project.order where order_id = o_id)::timestamp;

    if q > (select sum(quantity)
            from project.product_x_warehouse as pxw
            where pxw.product_id = p_id
              and (dt between pxw.valid_from and pxw.valid_to)) then
        raise exception 'NOT ENOUGH PRODUCT IN STOCK';
    end if;

    for row in select *
               from project.product_x_warehouse as pxw
               where pxw.product_id = p_id
                 and (dt between pxw.valid_from and pxw.valid_to)
               order by quantity
        loop
            insert into project.order_x_product values (o_id, p_id, row.warehouse_id, least(q, row.quantity));
            q := q - row.quantity;
            if q <= 0 then
                exit;
            end if;
        end loop;
end;
$$;

call order_product(3, 1, 200);


-- generates a slice for a certain time period
drop procedure if exists timeslice(in t_from timestamp, in t_to timestamp, in t_name text);
create procedure timeslice(in t_from timestamp, in t_to timestamp, in t_name text)
    language plpgsql as
$$
declare

begin
    execute format('create schema if not exists %I;', t_name);
    execute format(
            'create table if not exists %I.order as select * from project.order as o where o.date between ''%I'' and ''%I'';',
            t_name, t_from, t_to);
    execute format('create table if not exists %I.customer as select * from project.customer', t_name);
    execute format(
            'create table if not exists %I.order_x_product as select * from project.order_x_product as oxp where oxp.order_id in (select order_id from %I.order)',
            t_name, t_name);
    execute format(
            'create table if not exists %I.product as select * from project.product as p where (p.valid_from < ''%I'' and p.valid_to > ''%I'') or (p.valid_from >= ''%I'' and p.valid_from <= ''%I'')',
            t_name, t_from, t_from, t_from, t_to);
    execute format(
            'create table if not exists %I.product_x_warehouse as select * from project.product_x_warehouse as pxw where pxw.product_id in (select product_id from %I.product) and ((pxw.valid_from < ''%I'' and pxw.valid_to > ''%I'') or (pxw.valid_from >= ''%I'' and pxw.valid_from <= ''%I''))',
            t_name, t_name, t_from, t_from, t_from, t_to);
end;
$$;


drop schema if exists test cascade;
call timeslice('2023-01-01 00:00:00.000000', '2024-01-01 00:00:000000', 'this_year');

