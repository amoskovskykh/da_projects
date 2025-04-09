USE elmir;

CREATE TABLE stores (
    store_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    store_name NVARCHAR(100),
    email NVARCHAR(100),
    phone NVARCHAR(20),
    store_city NVARCHAR(50),
    store_address NVARCHAR(100)
);

CREATE TABLE employees (
    employee_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    job_title NVARCHAR(255),
    dob DATE,
    salary DECIMAL(10, 2),
	store_id INT REFERENCES stores(store_id)
);

CREATE TABLE customers (
    customer_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    email NVARCHAR(100),
    phone NVARCHAR(13),
    city NVARCHAR(50),
    address NVARCHAR(255)
);

CREATE TABLE orders (
    order_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    employee_id INT,
    customer_id INT,
    order_date DATETIME,
    order_status NVARCHAR(50),
    fulfillment_date DATETIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE categories (
    category_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    category_name NVARCHAR(100)
);

CREATE TABLE brands (
    brand_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    brand_name NVARCHAR(100)
);

CREATE TABLE products (
    product_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    product_name NVARCHAR(100),
    price DECIMAL(10, 2),
    brand_id INT,
    category_id INT,
	FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);

CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE repair_services (
    repair_service_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    repair_service_name NVARCHAR(255),
    price DECIMAL(10, 2)
);

CREATE TABLE repair_orders (
    repair_order_id INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATE,
    order_status NVARCHAR(50),
    fulfillment_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE repair_order_details (
    repair_order_id INT,
    repair_service_id INT,
    quantity INT,
    cost_modifier DECIMAL(6, 2),
    PRIMARY KEY (repair_order_id, repair_service_id),
    FOREIGN KEY (repair_order_id) REFERENCES repair_orders(repair_order_id),
    FOREIGN KEY (repair_service_id) REFERENCES repair_services(repair_service_id)
);

CREATE TABLE product_inventory (
	product_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	quantity INT,
	updated_at DATETIME
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);





--DROP TABLE IF EXISTS repair_order_details;
--DROP TABLE IF EXISTS repair_orders;
--DROP TABLE IF EXISTS repair_services;
--DROP TABLE IF EXISTS order_details;
--DROP TABLE IF EXISTS product_inventory;
--DROP TABLE IF EXISTS products;
--DROP TABLE IF EXISTS brands;
--DROP TABLE IF EXISTS categories;
--DROP TABLE IF EXISTS orders;
--DROP TABLE IF EXISTS customers;
--DROP TABLE IF EXISTS employees;
--DROP TABLE IF EXISTS stores;