-- Q1: Top-selling products by revenue
-- Sample result: ASUS Vivobook 15 (55,000), Monitor (24,000), Keyboard (5,000), SSD (4,500)
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- Q2: Customer spending (customers with at least one order)
-- Sample result: Ana Cruz 60,000 (1 order), Jose Reyes 28,500 (1 order)
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer,
       COUNT(DISTINCT o.order_id)         AS orders,
       SUM(oi.subtotal)                   AS total_spent
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Q3: Customer spending including customers with no orders (LEFT JOIN)
-- Sample result: same as Q2 plus Maria Santos with 0 orders and 0 spent
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer,
       COUNT(DISTINCT o.order_id)         AS orders,
       COALESCE(SUM(oi.subtotal), 0)      AS total_spent
FROM customers c
LEFT JOIN orders o       ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Q4: Low-stock products (at or below the reorder level)
-- Sample result: no rows, since every product is above its reorder level
SELECT p.product_name,
       w.warehouse_name,
       i.quantity      AS current_stock,
       i.reorder_level
FROM inventory i
JOIN products p   ON p.product_id = i.product_id
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
WHERE i.quantity <= i.reorder_level
ORDER BY i.quantity - i.reorder_level, p.product_name;

-- Q5: Monthly sales (cancelled orders excluded)
-- Sample result: one row for the current month, 2 orders, 88,500
SELECT date_trunc('month', o.order_date)::date AS month,
       COUNT(*)                                AS orders,
       SUM(o.total_amount)                     AS revenue
FROM orders o
WHERE o.status <> 'Cancelled'
GROUP BY date_trunc('month', o.order_date)
ORDER BY month;

-- Q6: Revenue by product category
-- Sample result: Laptops 55,000; Monitors 24,000; Keyboards 5,000; Components 4,500
SELECT cat.category_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN products p    ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
GROUP BY cat.category_name
ORDER BY revenue DESC;

-- Q7: Inventory value per warehouse (stock on hand x current unit price)
-- Sample result: Main Warehouse 2,215,000; North Warehouse 260,000
SELECT w.warehouse_name,
       SUM(i.quantity)                    AS units_on_hand,
       SUM(i.quantity * p.unit_price)     AS inventory_value
FROM inventory i
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
JOIN products p   ON p.product_id = i.product_id
GROUP BY w.warehouse_name
ORDER BY inventory_value DESC;

-- Q8: Data-quality check, orders whose total does not match their items
-- Sample result: no rows (all totals match)
SELECT o.order_id,
       o.total_amount            AS recorded_total,
       SUM(oi.subtotal)          AS items_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(oi.subtotal);
