-- trigger to update quantity of the product when a new row is 
-- added to the order_x_product table
CREATE OR REPLACE FUNCTION warehouse_update()
RETURNS TRIGGER AS $$
DECLARE 
	order_date timestamp;
	old_product_quantity Integer;
BEGIN
	order_date := (SELECT "date" FROM "order" WHERE order_id = NEW.order_id)::timestamp;
	old_product_quantity := coalesce((SELECT quantity FROM product_x_warehouse WHERE product_id = NEW.product_id AND valid_to = '5999-12-31 23:59:59' AND warehouse_id = NEW.warehouse_id), 0);
	IF old_product_quantity < NEW.quantity
    THEN
    	RAISE EXCEPTION 'Not enough of this product in this warehouse.';
    ELSE
		UPDATE 
    		product_x_warehouse
    	SET 
    		valid_to = order_date 
    	WHERE 
    		product_id = NEW.product_id
    		AND warehouse_id = NEW.warehouse_id
    		AND valid_to = '5999-12-31 23:59:59';

    	INSERT INTO product_x_warehouse (product_id, warehouse_id, valid_from, valid_to, quantity)
    	VALUES (NEW.product_id, NEW.warehouse_id, (select order_date + interval '1 second'), '5999-12-31 23:59:59', (select old_product_quantity - new.quantity));
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE  TRIGGER warehouse_update_trigger
BEFORE INSERT ON order_x_product
FOR EACH ROW
EXECUTE FUNCTION warehouse_update();

-- trigger to update order cost when a new row is added to 
-- the order_x_product table
CREATE OR REPLACE FUNCTION order_update()
RETURNS TRIGGER AS $$
DECLARE 
	order_date timestamp;
	product_price Integer;
	old_cost Integer;
BEGIN
	order_date := (SELECT "date" FROM "order" WHERE order_id = NEW.order_id)::timestamp;
	product_price := (SELECT price FROM product WHERE product_id = NEW.product_id AND order_date BETWEEN valid_from AND valid_to);
	old_cost := (select "cost" from "order" where order_id = new.order_id);
	UPDATE 
    	"order"
    SET 
    	"cost" = (select old_cost + product_price * new.quantity)
    WHERE 
    	order_id = new.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER order_update_trigger
AFTER INSERT ON order_x_product
FOR EACH ROW
EXECUTE FUNCTION order_update();
