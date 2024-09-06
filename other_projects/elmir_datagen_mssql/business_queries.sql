USE elmir;

-- ==============================================================
-- Query 1
-- Obtain information about Elmir products
-- ==============================================================
SELECT 
	b.brand_name, 
	c.category_name, 
	MIN(p.price) min_price, 
	MAX(p.price) max_price, 
	CAST(AVG(p.price) AS DECIMAL(10,2)) AS avg_price, 
	COUNT(p.product_id) num_of_products,
	SUM(o_d.quantity) AS num_of_units_sold,
	SUM(p_i.quantity) AS inventory_stock_num
FROM products p
JOIN product_inventory p_i ON p_i.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON c.category_id = p.category_id
JOIN order_details o_d ON o_d.product_id = p.product_id
JOIN orders o ON o.order_id = o_d.order_id
GROUP BY b.brand_name, c.category_name WITH CUBE
ORDER BY num_of_units_sold DESC;



-- ==============================================================
-- Query 2
-- Obtain information about products whose stock needs to be replenished
-- ==============================================================
SELECT stock_tbl.brand_name,
	stock_tbl.category_name,
	stock_tbl.product_name,
	stock_tbl.prod_in_stock,
	stock_tbl.total_revenue,
	stock_tbl.num_of_units_sold,
	stock_tbl.pop_level
FROM (
	SELECT
		b.brand_name, 
		c.category_name,
		p.product_name,
		p_i.quantity AS prod_in_stock,
		SUM(p.price * o_d.quantity) AS total_revenue,
		SUM(o_d.quantity) AS num_of_units_sold,
		CASE 
			WHEN SUM(p.price * o_d.quantity) > 70000 THEN 'high_profit'
			WHEN SUM(p.price * o_d.quantity) > 25000 THEN 'moderate_profit'
			ELSE 'low_profit'
		END AS pop_level	
	FROM products p
	JOIN brands b ON p.brand_id = b.brand_id
	JOIN categories c ON c.category_id = p.category_id
	JOIN product_inventory p_i ON p_i.product_id = p.product_id
	JOIN order_details o_d ON p.product_id = o_d.product_id
	JOIN orders o ON o.order_id = o_d.order_id
	WHERE o.order_date >= '2024-07-01' AND o.order_date <= '2024-07-31'
	GROUP BY b.brand_name, c.category_name, p.product_name, p_i.quantity
	HAVING p_i.quantity < SUM(o_d.quantity)
	) AS stock_tbl
ORDER BY stock_tbl.pop_level;


-- Query 2 v1
--SELECT stock_tbl.brand_name,
--	stock_tbl.category_name,
--	stock_tbl.product_name,
--	stock_tbl.prod_in_stock,
--	stock_tbl.total_revenue,
--	stock_tbl.total_sold,
--	grps.pop_level
--FROM 
--	(SELECT
--		b.brand_name, 
--		c.category_name,
--		p.product_name,
--		p_i.quantity prod_in_stock,
--		SUM(p.price * o_d.quantity) total_revenue,
--		SUM(o_d.quantity) total_sold
--	FROM brands b
--	JOIN products p ON p.brand_id = b.brand_id
--	JOIN categories c ON c.category_id = p.category_id
--	JOIN product_inventory p_i ON p_i.product_id = p.product_id
--	JOIN order_details o_d ON p.product_id = o_d.product_id
--	GROUP BY b.brand_name, c.category_name, p.product_name, p_i.quantity
--	HAVING p_i.quantity < SUM(o_d.quantity)) stock_tbl
--INNER JOIN 
--	(SELECT 'high_profit' pop_level, 70000 min_limit , 999999 max_limit 
--	UNION ALL
--	SELECT 'moderate_profit' pop_level, 25000 min_limit , 69999 max_limit 
--	UNION ALL
--	SELECT 'low_profit' pop_level, 1 min_limit , 24999 max_limit) grps
--ON stock_tbl.total_revenue BETWEEN grps.min_limit AND grps.max_limit
--ORDER BY grps.pop_level;



-- ==============================================================
-- Query 3
-- Identify top 20 products by total revenue. 
-- ==============================================================
SELECT TOP(20)
	b.brand_name, 
	c.category_name,
	p.product_name,
	p.price AS product_price,
	SUM(p.price * o_d.quantity) AS total_revenue,
	SUM(o_d.quantity) AS num_of_units_sold
FROM brands b
JOIN products p ON p.brand_id = b.brand_id
JOIN categories c ON c.category_id = p.category_id
JOIN order_details o_d ON o_d.product_id = p.product_id
GROUP BY b.brand_name, c.category_name, p.product_name, p.price 
ORDER BY total_revenue DESC;



-- ==============================================================
-- Query 4
-- Obtain information about the product that generates the highest revenue within each brand's listing
-- ==============================================================
WITH brand_prod_cte AS (
	SELECT
		b.brand_id,
		b.brand_name, 
		p.product_name,
		SUM(o_d.quantity*p.price) AS total_revenue,
		SUM(o_d.quantity) AS total_prod_sold,
		dense_rank() OVER(partition by b.brand_id order by SUM(o_d.quantity*p.price) DESC) AS revenue_rank
	FROM brands b
	JOIN products p ON p.brand_id = b.brand_id
	JOIN order_details o_d ON o_d.product_id = p.product_id
	JOIN orders o ON o.order_id = o_d.order_id AND o.order_status = 'fulfilled'
	GROUP BY b.brand_id, b.brand_name, p.product_name
)
SELECT 
	brand_id, 
	brand_name, 
	product_name, 
	total_revenue, 
	total_prod_sold
FROM brand_prod_cte
WHERE revenue_rank = 1
ORDER BY total_revenue DESC


-- ==============================================================
-- Query 5
-- Obtain information about customers along with statistics on their orders
-- ==============================================================
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.city,
    COUNT(o.order_id) AS order_count,
    SUM(o_d.quantity) AS num_of_prod_purchased,
    SUM(p.price*o_d.quantity) AS total_spent,
    FORMAT(MAX(o.order_date), 'yyyy-MM-dd %H:%mm') AS last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details o_d ON o.order_id = o_d.order_id
JOIN products p ON p.product_id = o_d.product_id
GROUP BY 
	c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.city
ORDER BY total_spent DESC



-- ==============================================================
-- Query 6
-- Obtain information about employees along with statistics on their completed orders
-- ==============================================================
GO
CREATE OR ALTER VIEW employee_performance 
AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    e.salary,
	s.store_name,
    COUNT(DISTINCT o.order_id) AS order_count, -- order_id joined with order_details result in repeating groups. Use DISTINCT
    SUM(p.price*o_d.quantity) AS total_revenue,
    FORMAT(MAX(o.order_date), 'yyyy-MM-dd %H:%mm')  AS last_order_date,
	FORMAT(MIN(o.order_date), 'yyyy-MM-dd %H:%mm')  AS first_order_date,
	DATEDIFF(day, MIN(o.order_date), MAX(o.order_date)) AS performance_review_period
FROM employees e
JOIN stores s ON e.store_id = s.store_id
JOIN orders o ON e.employee_id = o.employee_id AND o.order_status = 'fulfilled'
JOIN order_details o_d ON o.order_id = o_d.order_id
JOIN products p ON p.product_id = o_d.product_id
GROUP BY
     e.employee_id, e.first_name, e.last_name, e.job_title, e.salary, s.store_name
HAVING DATEDIFF(day, MIN(o.order_date), MAX(o.order_date)) > 7
-- ORDER BY order_count DESC;
GO

--Helper Query: get number of top employees in each store using previously crated view
--SELECT TOP 10
--	store_name, 
--	count(*) num_top_employees 
--FROM employee_performance 
--GROUP BY store_name 
--ORDER BY num_top_employees DESC


--Helper Query: get number of orders for each employee
--SELECT
--    e.employee_id,
--    e.first_name,
--    e.last_name,
--    e.job_title,
--    e.salary,
--	COUNT(o.order_id) AS order_count
--FROM employees e
--JOIN orders o ON e.employee_id = o.employee_id AND o.order_status = 'fulfilled'
--GROUP BY e.employee_id, e.first_name, e.last_name, e.job_title, e.salary --WITH CUBE
--ORDER BY order_count DESC


--Helper Query: find total_revenue from orders processed by the specific employee
--SELECT
--	o.employee_id,
--	SUM(p.price * o_d.quantity) AS total_revenue
--FROM orders o
--JOIN order_details o_d ON o_d.order_id = o.order_id
--JOIN products p ON p.product_id = o_d.product_id
--WHERE employee_id = 622
--AND o.order_status = 'fulfilled'
--GROUP BY o.employee_id

--SELECT 
--	order_id
--FROM orders
--WHERE employee_id = 4378


--Helper Query: calculate the total number of orders placed in a specific store
--SELECT 
--	store_name,
--	COUNT(o.order_id) AS num_orders
--FROM stores s
--JOIN employees e ON s.store_id = e.store_id --AND e.employee_id = 4884
--JOIN orders o ON o.employee_id = e.employee_id
--WHERE store_name = 'Store497'
--GROUP BY store_name



-- ==============================================================
-- Query 7
-- Obtain information about the top 10 product categories along with their sales statistics.
-- ==============================================================
SELECT TOP 10
	c.category_id,
	c.category_name, 
	CAST(AVG(p.price) AS decimal(10,2)) avg_prod_price_in_categ, 
	SUM(o_d.quantity*p.price) AS total_revenue,
	SUM(o_d.quantity) AS num_prod_sold
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_details o_d ON o_d.product_id = p.product_id
JOIN orders o ON o.order_id = o_d.order_id AND o.order_status = 'fulfilled'
GROUP BY c.category_id, c.category_name
ORDER BY num_prod_sold DESC;

-- Query 7 across brands
--SELECT
--	b.brand_id,
--	b.brand_name, 
--	p.product_name,
--	SUM(o_d.quantity*p.price) AS total_revenue,
--	SUM(o_d.quantity) AS total_prod_sold
--FROM brands b
--JOIN products p ON p.brand_id = b.brand_id
--JOIN product_inventory p_i ON p_i.product_id = p.product_id
--JOIN order_details o_d ON o_d.product_id = p_i.product_id
--JOIN orders o ON o.order_id = o_d.order_id AND o.order_status = 'fulfilled'
--GROUP BY b.brand_id, b.brand_name, p.product_name
--ORDER BY total_revenue DESC;



-- Query 4 -- other implementation ideas
-- joining each brand with MAX(total_revenue) cte
--WITH RevenueCalc AS (
--	SELECT
--		b.brand_id,
--		b.brand_name, 
--		p.product_name,
--		SUM(o_d.quantity*p.price) AS total_revenue,
--		SUM(o_d.quantity) AS total_prod_sold
--	FROM brands b
--	JOIN products p ON p.brand_id = b.brand_id
--	JOIN product_inventory p_i ON p_i.product_id = p.product_id
--	JOIN order_details o_d ON o_d.product_id = p_i.product_id
--	JOIN orders o ON o.order_id = o_d.order_id AND o.order_status = 'fulfilled'
--	GROUP BY b.brand_id, b.brand_name, p.product_name
--),
--MaxRevenue AS (
--    SELECT 
--        brand_id,
--        MAX(total_revenue) AS max_revenue
--    FROM RevenueCalc
--    GROUP BY brand_id
--)
--SELECT 
--    rc.brand_id,
--	rc.brand_name,
--    rc.product_name,
--    rc.total_revenue,
--	rc.total_prod_sold
--FROM RevenueCalc rc
--JOIN 
--    MaxRevenue mr ON rc.brand_id = mr.brand_id AND rc.total_revenue = mr.max_revenue
--ORDER BY total_revenue DESC;



-- Rewritten with analytical functions 
-- Overcomplicated, matches brand with each product
-- requires filtering out NULL values 
--WITH brand_product AS (
--	SELECT DISTINCT
--		b.brand_id,
--		b.brand_name, 
--		CASE SUM(o_d.quantity*p.price) 
--			WHEN MAX(SUM(o_d.quantity*p.price)) over(partition by brand_name) THEN p.product_name
--			ELSE NULL
--		END AS product_name,
--		MAX(SUM(o_d.quantity*p.price)) over(partition by brand_name) AS total_revenue,
--		SUM(o_d.quantity) AS total_prod_sold
--	FROM brands b
--	JOIN products p ON p.brand_id = b.brand_id
--	JOIN order_details o_d ON o_d.product_id = p.product_id
--	JOIN orders o ON o.order_id = o_d.order_id --AND o.order_status = 'fulfilled'
--	GROUP BY b.brand_id, b.brand_name, p.product_name
--)
--SELECT * FROM brand_product
--WHERE product_name IS NOT NULL
--ORDER BY total_revenue DESC;
