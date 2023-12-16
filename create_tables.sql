drop SCHEMA IF EXISTS project CASCADE;
create SCHEMA project;
set search_path = project, public;

DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
	customer_id Integer, 
  	first_name varchar(100),
    last_name varchar(100),
  	phone_number varchar(15) check(regexp_match(phone_number, '^((8|\+7)[\-]?)?(\(?\d{3}\)?[\-]?)?[\d\-]{7,10}$') is not null),
  	PRIMARY KEY(customer_id)
);

DROP TABLE IF EXISTS delivery_service CASCADE;
CREATE TABLE delivery_service (
	delivery_service_id Integer, 
  	"name" varchar(100),
    contact_number varchar(15) check(regexp_match(contact_number, '^((8|\+7)[\-]?)?(\(?\d{3}\)?[\-]?)?[\d\-]{7,10}$') is not null),
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
	product_id Integer UNIQUE NOT NULL,
  	valid_from TIMESTAMP,
  	valid_to TIMESTAMP,
  	"name" varchar(100),
  	contents text,
  	price Integer check (price >= 0),
  	PRIMARY KEY (product_id, valid_from)
);

drop TABLE IF EXISTS "order" CASCADE;
CREATE TABLE "order" (
	order_id Integer,
  	customer_id Integer REFERENCES customer(customer_id),
  	delivery_service_id Integer REFERENCES delivery_service(delivery_service_id),
  	status varchar(20) check(status IN ('Принят', 'В сборке', 'Ожидает доставки', 'Передан курьеру', 'Доставлен')),
  	"date" date,
  	"cost" Integer,
  	address text,
  	delivery_period Integer,
  	delivery_type varchar(15) CHECK(delivery_type IN('Самовывоз', 'Курьером', 'Экспресс')),
  	PRIMARY KEY(order_id)
);

DROP TABLE IF EXISTS order_x_product CASCADE;
CREATE TABLE order_x_product(
	order_id Integer REFERENCES "order"(order_id),
  	product_id Integer REFERENCES product(product_id),
  	warehouse_id Integer REFERENCES warehouse(warehouse_id),
  	quantity INTEGER CHECK(quantity > 0),
  	PRIMARY KEY(order_id, product_id, warehouse_id)
);

DROP TABLE IF EXISTS product_x_warehouse CASCADE;
CREATE TABLE product_x_warehouse(
  	product_id Integer REFERENCES product(product_id),
  	warehouse_id Integer REFERENCES warehouse(warehouse_id),
  	valid_from TIMESTAMP,
 	valid_to TIMESTAMP,
  	quantity INTEGER CHECK(quantity > 0),
  	PRIMARY KEY(product_id, warehouse_id, valid_from)
); 

