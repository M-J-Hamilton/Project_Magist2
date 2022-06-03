
-- DB is Magist
USE magist;

CREATE TABLE products_Tech AS SELECT * FROM products;
ALTER TABLE products_tech
	RENAME COLUMN product_category_name_english TO product_category;

UPDATE products_tech pt
SET product_category = 	CASE 
		WHEN product_category_name IN ("audio", "cine_foto", "consoles_games", "pcs", "informatica_acessorios", "eletronicos", "pc-gamer", "sinalizacao_e_seguranca", "tablets_impressao_imagem", "telefonia") THEN "Tech"
        ELSE "Non_Tech"
	END;

SELECT *
FROM product_category_name_translation 
;

-- 1. Count of number of orders from orders
SELECT COUNT(order_id) "Total Orders"
FROM orders;

SELECT COUNT(order_item_id) "Total Orders"
FROM orders
Left Join order_items oi
USING (order_id)
LefT Join products
USING (product_id)
Where order_status IN ('delivered', "approved", "invoiced", "processing", "shipped")
; 

-- 2. Orders by Status numbers & percentage
SELECT order_status "Status", COUNT(order_status) "Total Status", 
ROUND(COUNT(order_status) * 100 / (SELECT COUNT(order_id) FROM orders),2)'% of Orders'
FROM orders
GROUP BY order_status;

-- 3. Orders over time by Yr & Month
SELECT YEAR(order_purchase_timestamp) Ord_Yr, MONTH(order_purchase_timestamp) Ord_Mon, COUNT(order_id) "Total Orders"
FROM orders
GROUP BY Ord_Yr, Ord_Mon
ORDER BY Ord_Yr DESC;

-- 4. Distinct Count of Products
SELECT DISTINCT COUNT(product_id) "Total Products", COUNT(DISTINCT(product_category_name)) "Total Categories"
FROM products
Where product_category_name = "pc_gamer" ;

SELECT  COUNT(DISTINCT(product_category_name)) "Total Categories"
FROM products;


-- 5. Which are the categories with most products?
SELECT ct.product_category_name_english Category, COUNT(DISTINCT(product_id)) "Total Products"
FROM products p
LEFT JOIN product_category_name_translation ct
USING (product_category_name)
GROUP BY Category
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6. How many of those products were present in actual transactions? 
SELECT o.order_status Status, p.product_id, COUNT(oi.product_id) 'No. of Products'
FROM order_items oi
LEFT JOIN products p
USING (product_id)
LEFT JOIN orders o 
USING (order_id)
-- WHERE o.order_status <> "delivered"
GROUP BY Status, p.product_id
ORDER BY COUNT(oi.product_id) DESC;

-- 7. What’s the price for the most expensive and cheapest products? 
SELECT MAX(price) 'Max Product Price', MIN(price) 'Min Product Price', ROUND(AVG(price),2) 'Avg Product Price'
FROM order_items
WHERE price  > 0;

-- 8. What are the highest and lowest payment values?
SELECT MAX(payment_value) Max_Value, MIN(payment_value) Min_Value, ROUND(AVG(payment_value),2) Avg_Value
FROM order_payments
WHERE payment_value  > 0;

SELECT COUNT(payment_value)
FROM order_payments
WHERE payment_value < 1.00
ORDER BY payment_value ASC;

-- Q1 Is Magist suitable platform for High End Tech products?
SELECT *
FROM product_category_name_translation;

-- Q2 What is the TRT on delivery? Only looking at TRT for orders with an order_status = delivered (over 97% of orders)
SELECT *, DATEDIFF(order_delivered_customer_date, order_purchase_timestamp ) Delivered_TRT,
DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) Estimated_TRT,

(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) Diff,
CASE 
		WHEN (DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) > 2 THEN 'Prompt'
		WHEN (DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) <= 2 AND (DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) > -2 THEN 'On Time'
		WHEN (DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) <= -2 AND (DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) >= -10 THEN 'Delay'
        WHEN (DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp ) - DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) < -10 THEN 'Severe Delay'
		ELSE 'No_Value'
    END "Delivery_Expectation",
COUNT("Delivery_Expectation")
FROM orders
WHERE order_status = 'delivered'
GROUP BY Delivery_Expectation
ORDER BY Diff DESC;

-- Average, Shortest & Longest TRT
SELECT 
COUNT(*) "Number of Orders",
ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp ))) Average_TRT_days,
MIN(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) Shortest_TRT_days,
MAX(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp )) Longest_TRT_days
FROM orders
WHERE order_status = 'delivered';
