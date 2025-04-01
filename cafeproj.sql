CREATE DATABASE CafeDB;
USE CafeDB;


-- 1 Find total sales per hour
SELECT HOUR(Time) AS hour, COUNT(*) AS sales_count
FROM sales_orderly
GROUP BY hour
ORDER BY sales_count DESC;

-- 2 Find peak sales hour (highest orders)
SELECT HOUR(Time) AS peak_hour, COUNT(*) AS total_orders
FROM sales_orderly
GROUP BY peak_hour
ORDER BY total_orders DESC
LIMIT 1;

-- 3 Find the total revenue per hour
SELECT HOUR(Time) AS hour, SUM(Order_Total) AS revenue
FROM sales_orderly
GROUP BY hour
ORDER BY revenue DESC;

-- 4 Find the busiest day of the week for sales
SELECT DAYNAME(Date) AS day, COUNT(*) AS total_orders
FROM sales_orderly
GROUP BY day
ORDER BY total_orders DESC;

-- 5 Find peak sales day for revenue
SELECT Date, SUM(Order_Total) AS total_revenue
FROM sales_orderly
GROUP BY Date
ORDER BY total_revenue DESC
LIMIT 1;

-- 6 Compare Dine-in vs. Takeaway vs. Online orders
SELECT Order_Type, COUNT(*) AS total_orders
FROM sales_orderly
GROUP BY Order_Type
ORDER BY total_orders DESC;

-- 7 Revenue generated by each order type
SELECT Order_Type, SUM(Order_Total) AS total_revenue
FROM sales_orderly
GROUP BY Order_Type
ORDER BY total_revenue DESC;

-- 8 Find the best-selling product
SELECT Product_ID, SUM(Quantity) AS total_sold
FROM sales_orderly
GROUP BY Product_ID
ORDER BY total_sold DESC
LIMIT 1;

-- 9 Find peak hour per order type (Dine-in, Takeaway, Online)
SELECT HOUR(Time) AS peak_hour, Order_Type, COUNT(*) AS total_orders
FROM sales_orderly
GROUP BY peak_hour, Order_Type
ORDER BY total_orders DESC;

-- 10 Find total raw materials used per day
SELECT s.Date, u.Material_ID, SUM(u.used_quantity) AS total_used
FROM used_materials u
JOIN sales_orderly s ON u.Sale_ID = s.Sale_ID  -- Ensuring we get the date from sales_orderly
GROUP BY s.Date, u.Material_ID
ORDER BY s.Date DESC;


-- 11 Find the most used raw material
SELECT Material_ID, SUM(used_quantity) AS total_usage
FROM used_materials
GROUP BY Material_ID
ORDER BY total_usage DESC
LIMIT 1;

-- 12 Find the best hour for dine-in orders
SELECT HOUR(Time) AS hour, COUNT(*) AS total_dinein_orders
FROM sales_orderly
WHERE Order_Type = 'Dine-in'
GROUP BY hour
ORDER BY total_dinein_orders DESC
LIMIT 1;

-- 13 Find the best hour for delivery orders
SELECT HOUR(Time) AS hour, COUNT(*) AS total_delivery_orders
FROM sales_orderly
WHERE Order_Type = 'Delivery'
GROUP BY hour
ORDER BY total_delivery_orders DESC
LIMIT 1;

--  14 Find total profit per day (assuming cost data exists)
SELECT Date, SUM(Order_Total - (Price * Quantity)) AS daily_profit
FROM sales_orderly
JOIN menu_raw ON sales_orderly.Product_ID = menu_raw.Product_ID
GROUP BY Date
ORDER BY daily_profit DESC;

-- 15 Find most profitable product
SELECT s.Product_ID, 
       SUM(s.Quantity * m.Margin) AS total_profit
FROM sales_orderly s
JOIN menu m ON s.Product_ID = m.Product_ID
GROUP BY s.Product_ID
ORDER BY total_profit DESC
LIMIT 1;

-- 16 Find total profit earned from all sales
SELECT SUM(m.Margin * s.Quantity) AS total_profit
FROM sales_orderly s
JOIN menu m ON s.Product_ID = m.Product_ID;

-- 17 Find total revenue, cost, and profit
SELECT 
    SUM(s.Order_Total) AS total_revenue, 
    SUM(m.Price * s.Quantity) AS total_cost,
    SUM(m.Margin * s.Quantity) AS total_profit
FROM sales_orderly s
JOIN menu m ON s.Product_ID = m.Product_ID;

-- 18 Find profit percentage for each product
SELECT Product_ID, 
       ((Margin / Price) * 100) AS profit_percentage
FROM menu;

-- 19 Find the most profitable product (highest margin per sale)
SELECT Product_ID, Margin 
FROM menu
ORDER BY Margin DESC
LIMIT 1;

-- 20 Find the least profitable product
SELECT Product_ID, Margin 
FROM menu
ORDER BY Margin ASC
LIMIT 1;

-- 21 Find the least valuable product in terms of total profit generated
SELECT s.Product_ID, SUM(s.Quantity * m.Margin) AS total_profit_generated
FROM sales_orderly s
JOIN menu m ON s.Product_ID = m.Product_ID
GROUP BY s.Product_ID
ORDER BY total_profit_generated ASC
LIMIT 1;

-- 22 Find products that are being sold at a loss (negative profit margin)
SELECT Product_ID, Product_id, Margin
FROM menu
WHERE Margin < 0;

-- 23 Find month-over-month sales growth rate
SELECT DATE_FORMAT(Date, '%Y-%m') AS month, 
       SUM(Order_Total) AS total_revenue, 
       (SUM(Order_Total) - LAG(SUM(Order_Total)) OVER (ORDER BY DATE_FORMAT(Date, '%Y-%m'))) / LAG(SUM(Order_Total)) OVER (ORDER BY DATE_FORMAT(Date, '%Y-%m')) * 100 AS growth_rate
FROM sales_orderly
GROUP BY month
ORDER BY month;

-- 24 Find the most expensive and cheapest order ever placed
SELECT Order_ID2, Order_Total
FROM sales_orderly
ORDER BY Order_Total DESC
LIMIT 1;  -- Most expensive order
SELECT Order_ID2, Order_Total
FROM sales_orderly
ORDER BY Order_Total ASC
LIMIT 1;  -- Cheapest order

-- 25 Find the busiest day and the least busy day (total orders placed)
SELECT Date, COUNT(*) AS total_orders
FROM sales_orderly
GROUP BY Date
ORDER BY total_orders DeSC -- Busiest day 
LIMIT 1;
SELECT Date, COUNT(*) AS total_orders
FROM sales_orderly
GROUP BY Date
ORDER BY total_orders ASC -- Least busiest day
LIMIT 1; 

	