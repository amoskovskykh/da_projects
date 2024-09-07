USE elmir;

-- Changing default db collation
ALTER DATABASE elmir COLLATE Ukrainian_CI_AS;


-- ==============================================================
-- Procedure: add_categories
-- Inserts a predefined list of categories into the 'categories' table
-- # of entries: 25
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_categories
AS 
BEGIN
    INSERT INTO categories(category_name) VALUES
    ('Суперціни'),
    ('Конфігуратор ПК'),
    ('Енергія'),
    ('Квадрокоптери та аксесуари'),
    ('Комп’ютерна техніка, комплектуючі'),
    ('Побутова техніка'),
    ('Мобільний зв’язок'),
    ('Портативна техніка'),
    ('Товари для геймерів'),
    ('Телевізори та розваги'),
    ('Аудіо'),
    ('Фото і відео техніка'),
    ('Все для офісу'),
    ('Авто'),
    ('Дитячий світ'),
    ('Сантехніка та ремонт'),
    ('Все для дому'),
    ('Дача, сад, город'),
    ('Спорт, відпочинок та туризм'),
    ('Сувеніри, годинники, сумки'),
    ('Краса і здоров’я'),
    ('Зоотовари'),
    ('Послуги'),
    ('Apple'),
    ('Уцінка');
END;
GO

--DELETE FROM categories DBCC CHECKIDENT ('categories', RESEED, 0)
--EXEC add_categories;
--SELECT * FROM categories;


-- ==============================================================
-- Procedure: add_brands
-- Inserts a predefined list of brands into the 'brands' table
-- # of entries: 125
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_brands
AS 
BEGIN
	INSERT INTO brands(brand_name) VALUES
	('Apple'),
	('Samsung'),
	('Sony'),
	('LG'),
	('Dell'),
	('HP'),
	('Lenovo'),
	('Asus'),
	('Acer'),
	('Microsoft'),
	('Xiaomi'),
	('Huawei'),
	('OnePlus'),
	('Nikon'),
	('Canon'),
	('Bosch'),
	('Whirlpool'),
	('Haier'),
	('Siemens'),
	('Panasonic'),
	('Philips'),
	('Sharp'),
	('Toshiba'),
	('Beko'),
	('Electrolux'),
	('Hitachi'),
	('JBL'),
	('Bose'),
	('Sennheiser'),
	('Beats'),
	('Harman Kardon'),
	('Logitech'),
	('AMD'),
	('Intel'),
	('NVIDIA'),
	('Kingston'),
	('Seagate'),
	('Western Digital'),
	('Corsair'),
	('SanDisk'),
	('DJI'),
	('GoPro'),
	('Polaroid'),
	('Epson'),
	('Brother'),
	('Pioneer'),
	('Yamaha'),
	('Roland'),
	('Fujifilm'),
	('Olympus'),
	('Pentax'),
	('Zeiss'),
	('Leica'),
	('Tamron'),
	('Sigma'),
	('Celestron'),
	('Garmin'),
	('Fitbit'),
	('Suunto'),
	('Puma'),
	('Nike'),
	('Adidas'),
	('Under Armour'),
	('Reebok'),
	('Columbia'),
	('North Face'),
	('Patagonia'),
	('Timberland'),
	('Asolo'),
	('Wilson'),
	('Spalding'),
	('Easton'),
	('Bauer'),
	('Stihl'),
	('Husqvarna'),
	('Black & Decker'),
	('DeWalt'),
	('Makita'),
	('Ryobi'),
	('Milwaukee'),
	('Craftsman'),
	('Karcher'),
	('Bissell'),
	('Dyson'),
	('Roomba'),
	('Oreck'),
	('Miele'),
	('Zanussi'),
	('Armani'),
	('Versace'),
	('Louis Vuitton'),
	('Gucci'),
	('Chanel'),
	('Prada'),
	('Hermes'),
	('Burberry'),
	('Cartier'),
	('Omega'),
	('Rolex'),
	('Tissot'),
	('Casio'),
	('Swatch'),
	('Fossil'),
	('Coach'),
	('Michael Kors'),
	('Kate Spade'),
	('Tiffany & Co.'),
	('L’Oreal'),
	('Estee Lauder'),
	('Clinique'),
	('Shiseido'),
	('NARS'),
	('MAC'),
	('Bobbi Brown'),
	('La Mer'),
	('Sephora'),
	('Neutrogena'),
	('Olay'),
	('Aveeno'),
	('Lancome'),
	('Chewy'),
	('PetSmart'),
	('Royal Canin'),
	('Pedigree'),
	('Purina');
END
GO

--EXEC add_brands;
--SELECT * FROM brands;
--DELETE FROM brands DBCC CHECKIDENT ('brands', RESEED, 0)



-- ==============================================================
-- Procedure: add_products
-- Generates data to populate 'products' table
-- # of entries: 15000
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_products (@MaxProducts INT)
AS 
BEGIN

	DECLARE @TotalCategories INT = (SELECT COUNT(*) FROM categories);
	DECLARE @TotalBrands INT = (SELECT COUNT(*) FROM brands);
	-- SELECT COUNT(*) FROM sys.all_views;

	-- Nums CTE represents a base sequence of consecutive numbers from 1 to @MaxProducts.
	WITH Nums AS (
		SELECT TOP (@MaxProducts)
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
		FROM sys.all_views a
		CROSS JOIN sys.all_views b
	)
	INSERT INTO products (product_name, category_id, brand_id, price)
	SELECT
		CONCAT('Product ', n) AS product_name,
		--'Product ' + CAST(ROW_NUMBER() OVER(order by (SELECT NULL)) AS NVARCHAR(255)) AS product_name,
		CAST((RAND(CHECKSUM(NEWID())) * @TotalCategories) + 1 AS INT) AS category_id,
		ABS(CHECKSUM(NEWID()) % @TotalBrands) + 1 AS brand_id, -- using different approach here
		CAST((RAND(CHECKSUM(NEWID())) * 5000 + 10) AS DECIMAL(10, 2)) AS price
	FROM Nums
END
GO

--DELETE FROM products DBCC CHECKIDENT ('products', RESEED, 0)
--EXEC add_products @MaxProducts = 15000
--SELECT * FROM products;




-- Create '#TempCities" temporary table with a predefined list of 97 Ukrainian cities
-- Used to specify city in stores and customers tables
CREATE TABLE #TempCities(
	ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	city_name NVARCHAR(50)
);

INSERT INTO #TempCities(city_name) VALUES
('Київ'),
('Харків'),
('Одеса'),
('Дніпро'),
('Донецьк'),
('Запоріжжя'),
('Львів'),
('Кривий Ріг'),
('Миколаїв'),
('Маріуполь'),
('Вінниця'),
('Полтава'),
('Чернігів'),
('Черкаси'),
('Житомир'),
('Суми'),
('Івано-Франківськ'),
('Кам`янське'),
('Кропивницький'),
('Херсон'),
('Тернопіль'),
('Луцьк'),
('Біла Церква'),
('Кременчук'),
('Краматорськ'),
('Мелітополь'),
('Нікополь'),
('Марганець'),
('Слов`янськ'),
('Євпаторія'),
('Бердянськ'),
('Ужгород'),
('Бровари'),
('Хмельницький'),
('Кам`янець-Подільський'),
('Рівне'),
('Керч'),
('Ізмаїл'),
('Коломия'),
('Мукачево'),
('Сєвєродонецьк'),
('Красноармійськ'),
('Червоноград'),
('Кам`янка-Бузька'),
('Стрий'),
('Шостка'),
('Краснодон'),
('Нова Каховка'),
('Коростень'),
('Енергодар'),
('Острог'),
('Дрогобич'),
('Хуст'),
('Ірпінь'),
('Бердичів'),
('Долина'),
('Дунаївці'),
('Калуш'),
('Боярка'),
('Трускавець'),
('Чорноморськ'),
('Кременець'),
('Торецьк'),
('Старокостянтинів'),
('Бориспіль'),
('Новоград-Волинський'),
('Камінь-Каширський'),
('Прилуки'),
('Лисичанськ'),
('Славута'),
('Новояворівськ'),
('Малин'),
('Тульчин'),
('Бершадь'),
('Підгайці'),
('Кам`янка'),
('Скадовськ'),
('Вугледар'),
('Лиман'),
('Судак'),
('Радомишль'),
('Корець'),
('Прип`ять'),
('Кривопілля'),
('Новодружеськ'),
('Кам`янка-Дніпровська'),
('Красноперекопськ'),
('Монастирище'),
('Лозова'),
('Судова Вишня'),
('Шпола'),
('Белз'),
('Міусинськ'),
('Ічня'),
('Оратів'),
('Теофіполь'),
('Помічна');

--SELECT * FROM #TempCities;
--DROP TABLE #TempCities;



-- Create temp table '#UniqueNameCombs' to represent unique name surname combinations 
-- (importing a list of unique names and surnames from file)
CREATE TABLE #NamesData (
    first_name NVARCHAR(100),
    last_name NVARCHAR(100)
);

--SELECT * FROM #NamesData;
--DROP TABLE #NamesData;

BULK INSERT #NamesData
FROM 'C:\Users\user\academ_freelance\4TH_SEMESTER\DB\DB_elmir_2750\for_github\names.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2,
    TABLOCK
)

CREATE TABLE #UniqueNameCombs (
	ID INT NOT NULL IDENTITY(1,1)  PRIMARY KEY, 
    first_name NVARCHAR(255),
    last_name NVARCHAR(255)
);

INSERT INTO #UniqueNameCombs (first_name, last_name)
SELECT n.first_name, s.last_name
FROM #NamesData n
CROSS JOIN #NamesData s
ORDER BY NEWID(); -- randomizing the order for one use

DROP TABLE #NamesData

--SELECT * FROM #UniqueNameCombs;
--DROP TABLE #UniqueNameCombs;


-- Create 'RandomDigit' view to pass random digit to GeneratePhoneNumber() function
-- NEWID() can't be used directly within function as a side-effecting operator
GO
CREATE OR ALTER VIEW RandomDigit
AS
SELECT CAST(ABS(CHECKSUM(NEWID())) % 10 AS NVARCHAR(1)) AS Digit;
GO

-- Create a scalar function that generates a random phone number
GO
CREATE OR ALTER FUNCTION GeneratePhoneNumber()
RETURNS NVARCHAR(13)
AS
BEGIN
    DECLARE @phoneNumber NVARCHAR(13) = '+380';
    DECLARE @i INT = 1;

    WHILE @i <= 9
    BEGIN

        SET @phoneNumber += (SELECT Digit FROM RandomDigit);
        SET @i = @i + 1;
    END

    RETURN @phoneNumber;
END;
GO

--SELECT GeneratePhoneNumber();
--SELECT definition FROM sys.sql_modules




-- ==============================================================
-- Procedure: add_customers
-- Generates data to populate 'customers' table
-- # of entries: 13000
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_customers (@MaxCustomers INT)
AS
BEGIN

	DECLARE @TotalCities INT = (SELECT COUNT(*) FROM #TempCities);

	-- Using '#TempCustomers' table to store generated data before inserting
	SELECT TOP (@MaxCustomers)
		first_name,
		last_name,
		CONCAT(first_name, '_', last_name, ROW_NUMBER() OVER (ORDER BY NEWID()), '@example.com') AS email,
		CONCAT('ул. Велика Васильківська ', ROW_NUMBER() OVER (ORDER BY NEWID())) AS address,
		ABS(CHECKSUM(NEWID()) % @TotalCities) + 1 AS RandomCity
	INTO #TempCustomers
	FROM (SELECT TOP (@MaxCustomers) first_name, last_name FROM #UniqueNameCombs) AS un_names 
	ORDER BY NEWID()  -- Ensure random selection of addresses in combination with TOP (@MaxCustomers)

	INSERT INTO customers (first_name, last_name, email, phone, city, address)
	SELECT
		rc.first_name,
		rc.last_name,
		rc.email,
		dbo.GeneratePhoneNumber() AS phone,
		nc.city_name,
		rc.address
	FROM #TempCustomers rc
	JOIN #TempCities nc ON nc.ID = rc.RandomCity;

	DROP table #TempCustomers;

END 
GO

--DELETE FROM customers DBCC CHECKIDENT ('customers', RESEED, 0)
--EXEC add_customers @MaxCustomers = 13000
--SELECT * FROM customers;




-- ==============================================================
-- Procedure: add_stores
-- Generates data to populate 'stores' table
-- # of entries: 600
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_stores (@MaxStores INT)
AS
BEGIN
	DECLARE @TotalCities INT = (SELECT COUNT(*) FROM #TempCities);

	WITH Nums AS (
		SELECT TOP (@MaxStores)
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
		FROM sys.all_objects a
		CROSS JOIN sys.all_objects b
	),
	TempStores AS (
		SELECT TOP (@MaxStores)
            n AS RowNum,
            CONCAT('Store', n) AS store_name, -- using n so that random numbers in store_name and email are the same 
            CONCAT('Store', n, '@mail.com') AS email,
			CONCAT('вул. Михайлівська ', ROW_NUMBER() OVER (ORDER BY NEWID())) AS store_address, -- Randomize store_address
            dbo.GeneratePhoneNumber() AS phone
            --CAST(ABS(CHECKSUM(NEWID()) % @TotalCities) + 1 AS INT) AS RandomCity
        FROM Nums
		ORDER BY NEWID() -- Ensure random selection of store_address. TOP (@MaxCustomers) required
	)
	INSERT INTO stores (store_name, phone, store_city, store_address, email)
	SELECT
		ts.store_name,
		ts.phone,
		tc.city_name AS store_city,
		ts.store_address,
		ts.email
	FROM TempStores ts
	JOIN #TempCities tc ON tc.ID = (ts.RowNum % @TotalCities) + 1; -- (RandomCity + LEFT JOIN) == ((ts.RowNum % @TotalCities)) + 1 + INNER JOIN WHY?????????

END
GO

--DELETE FROM stores DBCC CHECKIDENT ('stores', RESEED, 0)
--EXEC add_stores @MaxStores = 600
--SELECT * FROM stores;




-- ==============================================================
-- Procedure: add_employees
-- Generates data to populate 'employees' table
-- # of entries: 7000
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_employees (@MaxEmployees INT)
AS
BEGIN

	DECLARE @TotalStores INT = (SELECT COUNT(*) FROM stores);  
	-- can create a trigger if one of the requirements isn't met

	WITH GenerateManagers AS (
		SELECT TOP (@TotalStores)
			t.first_name,
			t.last_name,
			'Менеджер' AS job_title,
			DATEADD(DAY, -(ABS(CHECKSUM(NEWID()) % 40*365) + 18 * 365), GETDATE()) AS dob,
			CAST(RAND(CHECKSUM(NEWID())) * 20000 + 40000 AS DECIMAL(10, 2)) AS salary, -- salary between 40000 and 60000
			(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1) % @TotalStores + 1 AS store_id -- generate a repeating range of consecutive numbers 
		FROM (
			SELECT TOP (@TotalStores) first_name, last_name 
			FROM #UniqueNameCombs 
			ORDER BY NEWID()
		) AS t
	),
	GenerateSalesperson AS (
		SELECT TOP (@MaxEmployees - @TotalStores)
			t.first_name,
			t.last_name,
			'Асистент із продажів' AS job_title,
			DATEADD(DAY, -(ABS(CHECKSUM(NEWID()) % 40*365) + 18 * 365), GETDATE()) AS dob,
			CAST(RAND(CHECKSUM(NEWID())) * 20000 + 20000 AS DECIMAL(10, 2)) AS salary, -- salary between 20000 and 40000
			(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1) % @TotalStores + 1 AS store_id -- generate a repeating range of consecutive numbers 
		FROM (
			SELECT TOP (@MaxEmployees - @TotalStores) first_name, last_name 
			FROM #UniqueNameCombs 
			ORDER BY NEWID()
		) AS t
	)
	INSERT INTO employees (first_name, last_name, job_title, dob, salary, store_id)
	SELECT 
		first_name,
		last_name,
		job_title,
		dob,
		salary,
		store_id
	FROM (
		SELECT * FROM GenerateManagers
		-- Just UNION leads to sorting by the first_name and then assigning employee_id. Assign id's manually.
		UNION ALL 
		SELECT * FROM GenerateSalesperson
	) AS t

END
GO


--DELETE FROM employees DBCC CHECKIDENT ('employees', RESEED, 0);
--EXEC add_employees @MaxEmployees = 7000
--SELECT * FROM employees;
--SELECT COUNT(DISTINCT store_id) FROM employees WHERE job_title = 'Менеджер'


-- check for the name intersect between employees and customers
--SELECT
--	first_name, last_name
--FROM customers
--INTERSECT 
--SELECT
--	first_name, last_name
--FROM employees


-- MySQL syntax, but SQL Server... PSQL, I choose you!
--SELECT first_name, last_name
--FROM customers
--WHERE (first_name, last_name) IN (SELECT first_name, last_name FROM employees);




-- ==============================================================
-- Procedure: add_orders
-- Generates data to populate 'orders' table
-- # of entries: 7000
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_orders (@MaxOrders INT)
AS
BEGIN
	DECLARE @TotalCustomers INT = (SELECT COUNT(customer_id) FROM customers);
	DECLARE @TotalEmployees INT =  (SELECT COUNT(employee_id) FROM employees);

	WITH Nums AS (
		SELECT TOP (@MaxOrders) 
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
		FROM sys.all_objects a
		CROSS JOIN sys.all_objects b
	)
	INSERT INTO orders (employee_id, customer_id, order_date, fulfillment_date, order_status)
	SELECT TOP(@MaxOrders) 
		(ABS(CHECKSUM(NEWID()) % @TotalEmployees) + 1) AS employee_id,
		(ABS(CHECKSUM(NEWID()) % @TotalCustomers) + 1) AS customer_id,
		DATEADD(HH, (ABS(CHECKSUM(NEWID())) % 24*15), '2024-07-01') AS order_date, 
		DATEADD(HH, (ABS(CHECKSUM(NEWID())) % 24*16) + 24*15, '2024-07-01') AS fulfillment_date,
		CASE WHEN ABS(CHECKSUM(NEWID()) % 2) = 0 THEN 'fulfilled' ELSE 'in progress' END AS order_status
	FROM Nums

	UPDATE orders
	SET fulfillment_date = NULL
	WHERE order_status = 'in progress'; 

END
GO

--SELECT COUNT(*) FROM sys.all_objects

--DELETE FROM orders DBCC CHECKIDENT ('orders', RESEED, 0);
--EXEC add_orders @MaxOrders = 7000
--SELECT * FROM orders;

--SELECT * FROM orders WHERE order_date >= fulfillment_date;

-- making sure no duplicates exists for (employee_id, customer_id, order_date) combinations
--SELECT
--	employee_id, customer_id, order_date
--FROM orders
--GROUP BY employee_id, customer_id, order_date
--HAVING COUNT(*) > 1;





-- Create 'RandomNumber' view to pass random number to GenerateOrderDetail() function
-- NEWID() can't be used directly within function as a side-effecting operator

GO 
CREATE OR ALTER VIEW RandomNumber
AS
	SELECT ABS(CHECKSUM(NEWID())) AS n
GO

-- InsertOrderDetail function. Returns a table with product_id, quantity records from 1 to 10
GO
CREATE OR ALTER FUNCTION InsertOrderDetail(@order_id INT, @TotalProduct INT)
RETURNS @ProuductsForOrder TABLE (order_id INT, product_id INT, quantity INT)
AS
BEGIN
	WITH Nums AS (
		SELECT TOP ((SELECT n FROM RandomNumber) % 9 + 1)
			ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
		FROM sys.all_views a
	)
	INSERT INTO @ProuductsForOrder
	SELECT 
		@order_id as order_id,
		(SELECT n FROM RandomNumber) % @TotalProduct + 1 AS product_id,
		(SELECT n FROM RandomNumber) % 10 + 1 AS quantity
	FROM Nums
	RETURN
END
GO


-- ==============================================================
-- Procedure: add_order_details
-- Generates data to populate 'order_details' table
-- # of entries: [@TotalOrders * 1, @TotalOrders * 10]
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_order_details
AS
BEGIN

	DECLARE @TotalOrders INT = (SELECT COUNT(order_id) FROM orders);
	DECLARE @TotalProduct INT = (SELECT COUNT(product_id) FROM products)
	DECLARE @OrderCount INT = 1;

	-- For each order_id generate from 1 to 10 (product, quantity) combination usiong TVF InsertOrderDetail
	WHILE @OrderCount <= @TotalOrders
		BEGIN
			INSERT INTO order_details(order_id, product_id, quantity)
				SELECT order_id, product_id, quantity
				FROM InsertOrderDetail(@OrderCount, @TotalProduct)
			SET @OrderCount = @OrderCount + 1
		END
END
GO


--DELETE FROM order_details;
--EXEC add_order_details;
--SELECT * FROM order_details;



-- ==============================================================
-- Procedure: add_prod_inventory
-- Generates data to populate 'product_inventory' table
-- # of entries: 15000
-- ==============================================================
GO
CREATE OR ALTER PROCEDURE add_prod_inventory
AS
BEGIN
	SET IDENTITY_INSERT product_inventory ON;

	INSERT INTO product_inventory(product_id, quantity, updated_at)
	SELECT
		p.product_id,
		ABS(CHECKSUM(NEWID())) % 100 AS quantity,
		last_upd.last_sale_date AS updated_at
	FROM products AS p
	LEFT JOIN (
		SELECT
			o_d.product_id,
			MAX(o.order_date) AS last_sale_date
		FROM order_details o_d
		INNER JOIN orders o ON o_d.order_id = o.order_id
		GROUP BY product_id
	) AS last_upd
	ON p.product_id = last_upd.product_id
END
GO


--DELETE FROM product_inventory DBCC CHECKIDENT ('product_inventory', RESEED, 0);
--EXEC add_prod_inventory;
--SELECT * FROM product_inventory;
--SELECT * FROM product_inventory WHERE updated_at IS NULL;




-- ==============================================================
-- Adding indexes:
-- customers (last_name, first_name) - for name-based searches
-- employees (last_name, first_name) - for name-based searches
-- products: product_name - for product searches
-- orders: order_date - for date range queries
-- ==============================================================

CREATE INDEX idx_cust_first_last_name ON customers(first_name, last_name);
CREATE INDEX idx_empl_first_last_name ON employees(first_name, last_name);
CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_order_date ON orders(order_date);


--DROP INDEX idx_cust_first_last_name ON customers;
--DROP INDEX idx_empl_first_last_name ON employee;
--DROP INDEX idx_product_name ON products;
--DROP INDEX idx_order_date ON orders;

-- Query optimization beyond the basic level requires a lot of knowledge about RDBMS functioning
-- I will just cover the basics here

-- Making sure that queries are sargable

-- Search time 5s
-- Execution plan shows that using non-clustered index idx_cust_first_last_name does improve the performance.
-- Index Seek is being used instead of index scan
-- But even for 5m rows in my example time difference is negligible

--SELECT a.order_id, b.customer_id, b.first_name, b.last_name 
--FROM orders a 
--INNER JOIN customers b 
--ON a.customer_id = b.customer_id 
--WHERE first_name LIKE '[A-H]%' AND last_name like '[I-Z]%'

--SELECT product_name FROM products WHERE product_name LIKE '12%';

--SELECT * FROM orders with(nolock, index=idx_order_date) WHERE order_date >= '2024-07-04' -- order by order_date 
 
--SELECT order_id, order_date FROM orders WHERE order_date >= '2024-07-04'


-- Script to list all indexes on tables from the current DB
--select 
--	i.[name] as index_name,
--    substring(column_names, 1, len(column_names)-1) as [columns],
--    case when i.[type] = 1 then 'Clustered index'
--        when i.[type] = 2 then 'Nonclustered unique index'
--        when i.[type] = 3 then 'XML index'
--        when i.[type] = 4 then 'Spatial index'
--        when i.[type] = 5 then 'Clustered columnstore index'
--        when i.[type] = 6 then 'Nonclustered columnstore index'
--        when i.[type] = 7 then 'Nonclustered hash index'
--        end as index_type,
--    case when i.is_unique = 1 then 'Unique'
--        else 'Not unique' end as [unique],
--    schema_name(t.schema_id) + '.' + t.[name] as table_view, 
--    case when t.[type] = 'U' then 'Table'
--        when t.[type] = 'V' then 'View'
--        end as [object_type]
--from sys.objects t
--    inner join sys.indexes i
--        on t.object_id = i.object_id
--    cross apply (select col.[name] + ', '
--                    from sys.index_columns ic
--                        inner join sys.columns col
--                            on ic.object_id = col.object_id
--                            and ic.column_id = col.column_id
--                    where ic.object_id = t.object_id
--                        and ic.index_id = i.index_id
--                            order by key_ordinal
--                            for xml path ('') ) D (column_names)
--where t.is_ms_shipped <> 1
--and index_id > 0
--order by i.[name]




-- ==============================================================
-- Trigger: trg_product_inventory
-- Updates inventory quantity of product when new order for a specific product is placed
-- ==============================================================
GO
CREATE OR ALTER TRIGGER trg_product_inventory ON order_details
AFTER INSERT
AS
BEGIN
    DECLARE @product_id INT;
    DECLARE @quantity INT;
    DECLARE @available_quantity INT;

    SELECT 
        @product_id = i.product_id,
        @quantity = i.quantity
    FROM inserted i;

    SELECT 
        @available_quantity = p_i.quantity 
    FROM product_inventory p_i
    WHERE p_i.product_id = @product_id;

    IF @quantity > @available_quantity
    BEGIN
        RAISERROR('Quantity ordered exceeds available stock for product_id: %d', -1, 1, @product_id);
        ROLLBACK;
    END
    ELSE
    BEGIN
        UPDATE product_inventory
        SET quantity = quantity - @quantity,
		updated_at = GETDATE()
        WHERE product_id = @product_id;
    END
END
GO

--DROP TRIGGER trg_product_inventory;

--SET IMPLICIT_TRANSACTIONS ON;
--BEGIN TRANSACTION

--	INSERT INTO orders(employee_id, customer_id, order_date, order_status)
--	VALUES(1,1,GETDATE(), 'in progress')

--	SELECT * FROM orders ORDER BY order_id DESC
--	SELECT TOP(5) * FROM product_inventory ORDER BY quantity DESC;

--	INSERT INTO order_details(order_id, product_id, quantity) VALUES
--	(7001, 39, 100); -- specify product_id here instead of 28

--	SELECT * FROM order_details ORDER BY order_id DESC

--	DELETE FROM order_details WHERE order_id = (SELECT MAX(order_id) FROM orders) 
--	DELETE FROM orders WHERE order_id = (SELECT MAX(order_id) FROM orders); -- didn't setup on delete cascade
--	DECLARE @max INT SELECT @max=ISNULL(MAX(order_id),0) FROM orders; DBCC CHECKIDENT ('orders', RESEED, @max );

--	SELECT TOP 1 * FROM orders ORDER BY order_date DESC;

--	SELECT  * FROM product_inventory WHERE product_id = 39;

--ROLLBACK;
--COMMIT;




EXEC add_categories;
EXEC add_brands;
EXEC add_stores @MaxStores = 600;
EXEC add_employees @MaxEmployees = 7000;
EXEC add_customers @MaxCustomers = 13000;
EXEC add_products @MaxProducts = 15000;
EXEC add_orders @MaxOrders = 7000
EXEC add_order_details;
EXEC add_prod_inventory;


SELECT * FROM categories;
SELECT * FROM brands;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM employees;
SELECT * FROM customers order by customer_id DESC;
SELECT * FROM orders;
SELECT * FROM order_details;
SELECT * FROM product_inventory;


DELETE FROM order_details;
DELETE FROM orders; DBCC CHECKIDENT ('orders', RESEED, 0);
DELETE FROM customers; DBCC CHECKIDENT ('customers', RESEED, 0);
DELETE FROM employees; DBCC CHECKIDENT ('employees', RESEED, 0);
DELETE FROM stores; DBCC CHECKIDENT ('stores', RESEED, 0);
DELETE FROM product_inventory; DBCC CHECKIDENT ('product_inventory', RESEED, 0);
DELETE FROM products; DBCC CHECKIDENT ('products', RESEED, 0);
DELETE FROM brands; DBCC CHECKIDENT ('brands', RESEED, 0);
DELETE FROM categories; DBCC CHECKIDENT ('categories', RESEED, 0);