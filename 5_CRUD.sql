-- product table
-- adding new tea
   INSERT INTO product (product_id, valid_from, valid_to, "name", contents, price)
VALUES
    (7, '2023-01-01', '2023-06-30', 'Ясность Утра', 'Насладитесь чаем "Ясность Утра" — зеленый чай с акцентами жасмина и персика, наполняющий моментами спокойствия под утренним солнцем.', 900);
   INSERT INTO product (product_id, valid_from, valid_to, "name", contents, price)
VALUES
    (8, '2023-07-01', '2023-12-31', 'Ясность Утра', 'Насладитесь чаем "Ясность Утра" — зеленый чай с акцентами жасмина и персика, наполняющий моментами спокойствия под утренним солнцем.', 900);
   
-- oops, the same tea was added twice, let's delete the duplicate 
   DELETE
FROM
	PRODUCT
WHERE
	PRODUCT_ID = 8;
-- let's lower the price on that tea until the 2024
UPDATE PRODUCT
SET
	VALID_TO = '2023-12-31',
	PRICE = 600
WHERE
	PRODUCT_ID = 7;
-- see which tea is more expensive than the new one
SELECT "name", price
FROM
	PRODUCT
WHERE
	PRICE >= 600;

   
-- customer table
-- adding a new one
INSERT INTO customer (customer_id, first_name, last_name, phone_number)
	VALUES (7, 'X Æ A-12', 'Маск', '8-915-987-65-43');

-- change someone's phone number
UPDATE customer
	SET phone_number = '+78126226393'
WHERE customer_id = 5;

-- this customer looks like a fake, let's delete it
DELETE FROM customer
WHERE customer_id = 7;  

-- looks like there is no Musk family among customers now
SELECT * FROM customer
WHERE last_name = 'Маск';   
