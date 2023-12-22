DROP SCHEMA IF EXISTS project CASCADE;
CREATE SCHEMA project;
SET search_path = project, PUBLIC;

DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
	customer_id Integer, 
  	first_name varchar(100),
    	last_name varchar(100),
  	phone_number varchar(15) CHECK(regexp_match(phone_number, '^((8|\+7)[\-]?)?(\(?\d{3}\)?[\-]?)?[\d\-]{7,10}$') IS NOT NULL),
  	PRIMARY KEY(customer_id)
);

DROP TABLE IF EXISTS delivery_service CASCADE;
CREATE TABLE delivery_service (
	delivery_service_id Integer, 
  	"name" varchar(100),
	contact_number varchar(15) CHECK(regexp_match(contact_number, '^((8|\+7)[\-]?)?(\(?\d{3}\)?[\-]?)?[\d\-]{7,10}$') IS NOT NULL),
  	email varchar(100),
  	address text,
  	PRIMARY KEY(delivery_service_id)
);

DROP TABLE IF EXISTS warehouse CASCADE;
CREATE TABLE warehouse (
	warehouse_id Integer PRIMARY KEY,
  	address text
);

DROP TABLE IF EXISTS product CASCADE;
CREATE TABLE product(
	product_id Integer NOT NULL,
  	valid_from TIMESTAMP,
  	valid_to TIMESTAMP,
  	"name" varchar(100),
  	contents text,
  	price Integer CHECK(price >= 0),
  	PRIMARY KEY (product_id, valid_from)
);

DROP TABLE IF EXISTS "order" CASCADE;
CREATE TABLE "order" (
	order_id Integer,
  	customer_id Integer,
  	delivery_service_id Integer REFERENCES delivery_service(delivery_service_id),
  	status varchar(20) CHECK(status IN ('Принят', 'В сборке', 'Ожидает доставки', 'Передан курьеру', 'Доставлен')),
  	"date" timestamp,
  	"cost" Integer default 0, -- will be a trigger to automatically increment the price
  	address text,
  	delivery_period Integer,
  	delivery_type varchar(15) CHECK(delivery_type IN('Самовывоз', 'Курьером', 'Экспресс')),
  	PRIMARY KEY(order_id)
);

DROP TABLE IF EXISTS order_x_product CASCADE;
CREATE TABLE order_x_product(
	order_id Integer REFERENCES "order"(order_id),
  	product_id Integer,
  	warehouse_id Integer REFERENCES warehouse(warehouse_id),
  	quantity INTEGER CHECK(quantity > 0),
  	PRIMARY KEY(order_id, product_id, warehouse_id)
);

DROP TABLE IF EXISTS product_x_warehouse CASCADE;
CREATE TABLE product_x_warehouse(
  	product_id Integer,
  	warehouse_id Integer REFERENCES warehouse(warehouse_id),
  	valid_from TIMESTAMP,
 	valid_to TIMESTAMP,
  	quantity INTEGER CHECK(quantity >= 0),
  	PRIMARY KEY(product_id, warehouse_id, valid_from)
); 

