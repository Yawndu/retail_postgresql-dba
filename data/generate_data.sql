TRUNCATE TABLE order_items, orders, stock_movements, inventory,
               employees, products, customers, categories,
               suppliers, warehouses
RESTART IDENTITY;

-- Reference data -------------------------------------------------
INSERT INTO categories (category_name, description)
SELECT 'Category ' || g, 'Generated category'
FROM generate_series(1, 10) g;

INSERT INTO suppliers (supplier_name, contact_name, email, phone)
SELECT 'Supplier ' || g, 'Contact ' || g,
       'supplier' || g || '@example.com',
       '0917' || lpad(g::text, 7, '0')
FROM generate_series(1, 50) g;

INSERT INTO warehouses (warehouse_name, location)
SELECT 'Warehouse ' || g, 'Location ' || g
FROM generate_series(1, 5) g;

INSERT INTO employees (warehouse_id, first_name, last_name, position, email, hire_date)
SELECT 1 + (g % 5), 'Emp' || g, 'Surname' || g,
       (ARRAY['Warehouse Manager','Inventory Clerk','Picker','Driver'])[1 + (g % 4)],
       'employee' || g || '@retail.example',
       DATE '2020-01-01' + ((g * 17) % 1800)
FROM generate_series(1, 50) g;

-- Customers and products -----------------------------------------
INSERT INTO customers (first_name, last_name, email, phone, address, created_at)
SELECT 'First' || g, 'Last' || g,
       'customer' || g || '@example.com',
       '09' || lpad(((random() * 999999999)::bigint)::text, 9, '0'),
       g || ' Sample Street',
       now() - make_interval(days => (random() * 730)::int)
FROM generate_series(1, 50000) g;

INSERT INTO products (category_id, supplier_id, product_name, sku, description, unit_price)
SELECT 1 + (g % 10), 1 + (g % 50),
       'Product ' || g,
       'SKU-' || lpad(g::text, 6, '0'),
       'Generated product',
       round((100 + random() * 60000)::numeric, 2)
FROM generate_series(1, 2000) g;

-- Inventory: every product in every warehouse ---------------------
INSERT INTO inventory (warehouse_id, product_id, quantity, reorder_level)
SELECT w.warehouse_id, p.product_id,
       (random() * 200)::int,
       10 + (random() * 20)::int
FROM warehouses w
CROSS JOIN products p;

-- Orders ---------------------------------------------------------
INSERT INTO orders (customer_id, order_date, status, total_amount)
SELECT 1 + (random() * 49999)::int,
       now() - make_interval(days => (random() * 730)::int,
                             secs => (random() * 86400)::int),
       (ARRAY['Pending','Processing','Shipped','Delivered','Cancelled'])[1 + (random() * 4)::int],
       0
FROM generate_series(1, 300000);

-- Order items: 1 to 4 distinct products per order -----------------
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
SELECT x.order_id, x.product_id, x.qty, p.unit_price, x.qty * p.unit_price
FROM (
    SELECT o.order_id,
           1 + ((o.order_id * 7 + k * 37) % 2000) AS product_id,
           1 + (random() * 4)::int                AS qty
    FROM orders o
    CROSS JOIN LATERAL generate_series(1, 1 + (o.order_id % 4)) AS k
) x
JOIN products p ON p.product_id = x.product_id;

-- Make order totals match their items
UPDATE orders o
SET total_amount = s.total
FROM (SELECT order_id, SUM(subtotal) AS total
      FROM order_items
      GROUP BY order_id) s
WHERE s.order_id = o.order_id;

-- Stock movements (sales and transfers out are negative) ----------
INSERT INTO stock_movements (warehouse_id, product_id, movement_type, quantity, movement_date)
SELECT s.wh, s.pr, s.mt,
       CASE WHEN s.mt IN ('SALE','TRANSFER_OUT') THEN -s.q ELSE s.q END,
       s.d
FROM (
    SELECT 1 + (random() * 4)::int    AS wh,
           1 + (random() * 1999)::int AS pr,
           (ARRAY['PURCHASE','SALE','RETURN','ADJUSTMENT','TRANSFER_IN','TRANSFER_OUT'])[1 + (random() * 5)::int] AS mt,
           1 + (random() * 20)::int   AS q,
           now() - make_interval(days => (random() * 730)::int) AS d
    FROM generate_series(1, 300000)
) s;

-- Refresh planner statistics so EXPLAIN results are accurate ------
ANALYZE;

-- Verify ---------------------------------------------------------
SELECT 'customers' AS tbl, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'products',        COUNT(*) FROM products
UNION ALL SELECT 'inventory',       COUNT(*) FROM inventory
UNION ALL SELECT 'orders',          COUNT(*) FROM orders
UNION ALL SELECT 'order_items',     COUNT(*) FROM order_items
UNION ALL SELECT 'stock_movements', COUNT(*) FROM stock_movements;

SELECT indexname FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE 'idx_%';