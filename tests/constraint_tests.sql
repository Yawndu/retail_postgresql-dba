-- Test 1: UNIQUE (duplicate category name)
-- Expected: violates unique constraint on category_name
INSERT INTO categories (category_name) VALUES ('Laptops');

-- Test 2: FOREIGN KEY on insert (nonexistent category)
-- Expected: violates fk_products_category
INSERT INTO products (category_id, supplier_id, product_name, sku, unit_price)
VALUES (999, 999, 'Test', 'SKU-1', 100);

-- Test 3: CHECK (invalid order status)
-- Expected: violates chk_orders_status
INSERT INTO orders (customer_id, status) VALUES (1, 'Lost');

-- Test 4: CHECK (zero quantity)
-- Expected: violates chk_order_items_quantity
INSERT INTO order_items VALUES (1, 2, 0, 42000, 0);

-- Test 5: FOREIGN KEY on delete (customer has orders)
-- Expected: violates fk_orders_customer
DELETE FROM customers WHERE customer_id = 1;

-- Test 6: UNIQUE (duplicate customer email)
-- Expected: violates unique constraint on customers.email
INSERT INTO customers (first_name, last_name, email)
VALUES ('Test', 'User', 'ana.cruz@example.com');

-- Test 7: UNIQUE (duplicate product SKU)
-- Expected: violates unique constraint on products.sku
INSERT INTO products (category_id, supplier_id, product_name, sku, unit_price)
VALUES (1, 1, 'Test Product', 'LAP-0001', 100);

-- Test 8: NOT NULL (customer without email)
-- Expected: violates not-null constraint on customers.email
INSERT INTO customers (first_name, last_name, email)
VALUES ('Test', 'User', NULL);

-- Test 9: NOT NULL (product without a name)
-- Expected: violates not-null constraint on products.product_name
INSERT INTO products (category_id, supplier_id, product_name, sku, unit_price)
VALUES (1, 1, NULL, 'TEST-0001', 100);

-- Test 10: PRIMARY KEY (same product twice in the same order)
-- Expected: violates primary key on order_items (order_id, product_id)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
VALUES (1, 1, 1, 55000.00, 55000.00);

-- Test 11: PRIMARY KEY (second inventory row for same warehouse and product)
-- Expected: violates primary key on inventory (warehouse_id, product_id)
INSERT INTO inventory (warehouse_id, product_id, quantity, reorder_level)
VALUES (1, 1, 10, 5);

-- Test 12: FOREIGN KEY on insert (order for nonexistent customer)
-- Expected: violates fk_orders_customer
INSERT INTO orders (customer_id) VALUES (999);

-- Test 13: FOREIGN KEY on insert (order item for nonexistent product)
-- Expected: violates fk_order_items_product
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
VALUES (1, 999, 1, 100.00, 100.00);

-- Test 14: FOREIGN KEY on delete (product has inventory and sales)
-- Expected: violates a foreign key on inventory or order_items
DELETE FROM products WHERE product_id = 1;

-- Test 15: FOREIGN KEY on delete (warehouse has stock and employees)
-- Expected: violates a foreign key on inventory, employees or stock_movements
DELETE FROM warehouses WHERE warehouse_id = 1;

-- Test 16: CHECK (negative product price)
-- Expected: violates chk_products_price
INSERT INTO products (category_id, supplier_id, product_name, sku, unit_price)
VALUES (1, 1, 'Test Product', 'TEST-0003', -500);

-- Test 17: CHECK (negative order total)
-- Expected: violates chk_orders_total
INSERT INTO orders (customer_id, total_amount) VALUES (1, -1);

-- Test 18: CHECK (subtotal does not equal quantity * unit_price)
-- Expected: violates chk_order_items_subtotal
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
VALUES (1, 2, 1, 42000.00, 1.00);

-- Test 19: CHECK (negative unit price on an order item)
-- Expected: violates chk_order_items_price
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
VALUES (1, 2, 1, -5.00, -5.00);

-- Test 20: CHECK (negative stock level)
-- Expected: violates chk_inventory_quantity
UPDATE inventory SET quantity = -1 WHERE warehouse_id = 1 AND product_id = 1;

-- Test 21: CHECK (invalid stock movement type)
-- Expected: violates chk_movements_type
INSERT INTO stock_movements (warehouse_id, product_id, movement_type, quantity)
VALUES (1, 1, 'DAMAGED', -1);

-- Test 22: CHECK (zero-quantity stock movement)
-- Expected: violates chk_movements_quantity
INSERT INTO stock_movements (warehouse_id, product_id, movement_type, quantity)
VALUES (1, 1, 'ADJUSTMENT', 0);