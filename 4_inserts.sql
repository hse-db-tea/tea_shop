set search_path = project, public;

-- customer
INSERT INTO customer (customer_id, first_name, last_name, phone_number)
VALUES
    (1, 'Сергей', 'Федчин', '+79123456789'),
    (2, 'Ксения', 'Золина', '8-912-345-67-89'),
    (3, 'Кирилл', 'Плешивцев', '88005553535'),
    (4, 'Артем', 'Батыгин', '+79998887766'),
    (5, 'Александр', 'Халяпов', '8-915-987-65-43'),
    (6, 'Илон', 'Маск', '89045006070');

-- delivery_service
INSERT INTO delivery_service (delivery_service_id, "name", contact_number, email, address)
VALUES
    (1, 'Быстрая Доставка', '+79991234567', 'fast@example.com', 'ул. Главная, Дом 123'),
    (2, 'Экспресс-Шиппинг', '8-911-223-34-45', 'quick@ship.com', 'ул. Высокая, Дом 456'),
    (3, 'Спешный Курьер', '88005553535', 'swift@example.com', 'ул. Широкая, Дом 789'),
    (4, 'Экспресс-Доставка', '+79881234567', 'express@example.com', 'ул. Центральная, Дом 987'),
    (5, 'Блиц-Шиппинг', '8-911-333-44-55', 'blitz@ship.com', 'ул. Новая, Дом 111'),
    (6, 'Гарантированная Доставка', '88005554444', 'guaranteed@example.com', 'пер. Зеленый, Дом 222');

-- warehouse
INSERT INTO warehouse (warehouse_id, address)
VALUES
    (1, 'Склад А, Промзона'),
    (2, 'Склад Б, Коммерческий Район'),
    (3, 'Склад В, Жилой Квартал'),
    (4, 'Склад Г, Офисный Центр'),
    (5, 'Склад Д, Пригород');

-- product
INSERT INTO product (product_id, valid_from, valid_to, "name", contents, price)
VALUES
    (1, '2023-01-01', '2023-12-31', 'Зелёный чай "Сенча"', 'Японский зелёный чай с нежным вкусом и свежим ароматом, полученный путём обработки молодых листьев паром.', 500),
    (2, '2023-01-01', '2023-12-31', 'Чёрный чай "Ассам"', 'Крепкий и насыщенный чёрный чай с интенсивным мальтийским вкусом, выращенный в регионе Ассам в Индии.', 750),
    (3, '2023-01-01', '2023-12-31', 'Улун "Тянь Гуань Инь"', 'Традиционный китайский улун с нежным вкусом персика и цветочными нотками, созданный методом полуферментации.', 1000),
    (4, '2023-01-01', '2023-12-31', 'Пуэр "Шу"', 'Ферментированный пуэр с гладким, насыщенным вкусом и уникальными землистыми оттенками, который со временем приобретает богатство вкуса.', 1200),
    (5, '2023-01-01', '2023-12-31', 'Белый чай "Серебряный Иглы"', 'Элитный белый чай с нежным вкусом и ароматом цветущих бутонов, представляющий высший стандарт в мире чайного искусства.', 1500),
    (6, '2023-01-01', '2023-12-31', 'Ройбуш с лавандой', 'Африканский чай ройбуш, ароматизированный лавандой, предоставляющий нежный и успокаивающий напиток без кофеина.', 800);

-- order
INSERT INTO "order" (order_id, customer_id, delivery_service_id, status, "date", "cost", address, delivery_period, delivery_type)
VALUES
    (1, 1, 1, 'Принят', '2023-01-15', 1200, 'ул. Пушкина, Дом 1', 2, 'Курьером'),
    (2, 2, 2, 'В сборке', '2023-02-20', 850, 'пр. Ленина, Дом 34', 3, 'Самовывоз'),
    (3, 3, 3, 'Ожидает доставки', '2023-03-10', 500, 'ул. Гагарина, Дом 56', 1, 'Экспресс'),
    (4, 2, 2, 'Ожидает доставки', '2023-03-25', 950, 'ул. Лермонтова, Дом 78', 2, 'Курьером'),
    (5, 3, 1, 'Передан курьеру', '2023-04-05', 700, 'пр. Пушкина, Дом 56', 1, 'Экспресс'),
    (6, 1, 3, 'Доставлен', '2023-04-18', 1300, 'ул. Толстого, Дом 90', 3, 'Самовывоз');

-- order_x_product
INSERT INTO order_x_product (order_id, product_id, warehouse_id, quantity)
VALUES
    (1, 3, 1, 2),
    (2, 1, 2, 4),
    (2, 3, 1, 1),
    (3, 2, 3, 3),
    (3, 3, 2, 2),
    (4, 1, 3, 5),
    (4, 2, 2, 2),
    (5, 3, 1, 3),
    (5, 1, 2, 4),
    (5, 2, 3, 1);

-- product_x_warehouse
INSERT INTO product_x_warehouse (product_id, warehouse_id, valid_from, valid_to, quantity)
VALUES
    (1, 1, '2023-01-01', '2023-12-31', 10),
    (1, 2, '2023-01-01', '2023-12-31', 20),
    (2, 2, '2023-01-01', '2023-12-31', 15),
    (2, 3, '2023-01-01', '2023-12-31', 8),
    (3, 1, '2023-01-01', '2023-12-31', 5),
    (3, 3, '2023-01-01', '2023-12-31', 12),
    (4, 1, '2023-01-01', '2023-12-31', 18),
    (4, 2, '2023-01-01', '2023-12-31', 10),
    (5, 2, '2023-01-01', '2023-12-31', 14),
    (5, 3, '2023-01-01', '2023-12-31', 7);
