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


drop procedure if exists cancel_order(in o_id int);
create procedure cancel_order(in o_id int)
    language plpgsql as
$$
declare
    row  RECORD;
    prev integer;
    cur  timestamp;
begin
    if o_id not in (select order_id from project.order) then
        raise exception 'ORDER NOT FOUND';
    end if;
    if (select status from project.order where order_id = o_id) = 'Доставлен' then
        raise exception 'ORDER IS ALREADY DELIVERED';
    end if;
    update project.order set status = 'Отменен' where order_id = o_id;
    for row in select * from order_x_product as oxp where oxp.order_id = o_id
        loop
            prev := (select quantity
                     from product_x_warehouse
                     where product_id = row.product_id
                       and valid_to = '5999-12-31 23:59:59.000000'
                       and warehouse_id = row.warehouse_id);

            cur = CURRENT_TIMESTAMP;

            update product_x_warehouse
            set valid_to = cur
            where product_id = row.product_id
              and valid_to = '5999-12-31 23:59:59.000000';

            insert into product_x_warehouse(product_id, warehouse_id, valid_from, valid_to, quantity)
            values (row.product_id, row.warehouse_id, cur, '5999-12-31 23:59:59.000000',
                    prev + row.quantity);
        end loop;
    delete from order_x_product where order_id = o_id;
end;
$$;

call cancel_order(5);
