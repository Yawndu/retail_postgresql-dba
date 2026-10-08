-- V1: Product sales (units and revenue per product)
CREATE OR REPLACE VIEW v_product_sales AS
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- V2: Customer spending (includes customers with no orders)
CREATE OR REPLACE VIEW v_customer_spending AS
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer,
       COUNT(DISTINCT o.order_id)         AS orders,
       COALESCE(SUM(oi.subtotal), 0)      AS total_spent
FROM customers c
LEFT JOIN orders o       ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- V3: Low-stock products (at or below reorder level)
CREATE OR REPLACE VIEW v_low_stock AS
SELECT p.product_id,
       p.product_name,
       w.warehouse_name,
       i.quantity AS current_stock,
       i.reorder_level
FROM inventory i
JOIN products p   ON p.product_id = i.product_id
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
WHERE i.quantity <= i.reorder_level;

-- V4: Monthly sales (cancelled orders excluded)
CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT date_trunc('month', o.order_date)::date AS month,
       COUNT(*)                                AS orders,
       SUM(o.total_amount)                     AS revenue
FROM orders o
WHERE o.status <> 'Cancelled'
GROUP BY date_trunc('month', o.order_date);

-- V5: Revenue by product category
CREATE OR REPLACE VIEW v_category_revenue AS
SELECT cat.category_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN products p     ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
GROUP BY cat.category_name;

-- V6: Inventory value per warehouse
CREATE OR REPLACE VIEW v_inventory_value AS
SELECT w.warehouse_name,
       SUM(i.quantity)                AS units_on_hand,
       SUM(i.quantity * p.unit_price) AS inventory_value
FROM inventory i
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
JOIN products p   ON p.product_id = i.product_id
GROUP BY w.warehouse_name;


SELECT * FROM v_product_sales    ORDER BY revenue DESC;
SELECT * FROM v_customer_spending ORDER BY total_spent DESC;
SELECT * FROM v_low_stock         ORDER BY current_stock;
SELECT * FROM v_monthly_sales     ORDER BY month;
SELECT * FROM v_category_revenue  ORDER BY revenue DESC;
SELECT * FROM v_inventory_value   ORDER BY inventory_value DESC;

-- List all views in the database:
SELECT table_name FROM information_schema.views
WHERE table_schema = 'public' ORDER BY table_name;
