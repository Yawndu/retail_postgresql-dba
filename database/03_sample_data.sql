INSERT INTO categories (category_name, description) VALUES
 ('Laptops', 'Portable computers'),
 ('Monitors', 'Display screens'),
 ('Keyboards', 'Input devices'),
 ('Components', 'SSDs, RAM and other parts');

INSERT INTO suppliers (supplier_name, contact_name, email) VALUES
 ('TechSource Trading', 'Mark Reyes', 'mark@techsource.example'),
 ('PixelWorks Distribution', 'Lia Santos', 'lia@pixelworks.example'),
 ('CorePart Supply', 'Ben Cruz', 'ben@corepart.example');

INSERT INTO warehouses (warehouse_name, location) VALUES
 ('Main Warehouse', 'Tuguegarao City'),
 ('North Warehouse', 'Aparri');

INSERT INTO customers (first_name, last_name, email, phone) VALUES
 ('Ana', 'Cruz', 'ana.cruz@example.com', '0917-000-0001'),
 ('Jose', 'Reyes', 'jose.reyes@example.com', '0917-000-0002'),
 ('Maria', 'Santos', 'maria.santos@example.com', '0917-000-0003');

INSERT INTO employees (warehouse_id, first_name, last_name, position, email, hire_date) VALUES
 (1, 'Paolo', 'Garcia', 'Warehouse Manager', 'paolo.garcia@retail.example', '2024-03-01'),
 (1, 'Liza',  'Ramos',  'Inventory Clerk',   'liza.ramos@retail.example',   '2024-06-15'),
 (2, 'Ken',   'Diaz',   'Warehouse Manager', 'ken.diaz@retail.example',     '2025-01-10');

INSERT INTO products (category_id, supplier_id, product_name, sku, unit_price) VALUES
 (1, 1, 'ASUS Vivobook 15',     'LAP-0001', 55000.00),
 (1, 1, 'Lenovo IdeaPad 3',     'LAP-0002', 42000.00),
 (2, 2, '24-inch IPS Monitor',  'MON-0001', 12000.00),
 (3, 3, 'Mechanical Keyboard',  'KEY-0001',  2500.00),
 (4, 3, '1TB NVMe SSD',         'CMP-0001',  4500.00),
 (4, 3, '16GB DDR4 RAM',        'CMP-0002',  3200.00);

INSERT INTO inventory (warehouse_id, product_id, quantity, reorder_level) VALUES
 (1, 1, 20, 5), (1, 2, 15, 5), (1, 3, 30, 10),
 (1, 4, 50, 15), (2, 5, 40, 10), (2, 6, 25, 10);

INSERT INTO orders (customer_id, status, total_amount) VALUES
 (1, 'Delivered', 60000.00),
 (2, 'Pending',   28500.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
 (1, 1, 1, 55000.00, 55000.00),
 (1, 4, 2,  2500.00,  5000.00),
 (2, 3, 2, 12000.00, 24000.00),
 (2, 5, 1,  4500.00,  4500.00);

INSERT INTO stock_movements (warehouse_id, product_id, movement_type, quantity, reference_id, notes) VALUES
 (1, 1, 'PURCHASE',  25, NULL, 'Initial stock'),
 (1, 1, 'SALE',      -1, 1,    'Order 1'),
 (1, 4, 'SALE',      -2, 1,    'Order 1'),
 (1, 3, 'SALE',      -2, 2,    'Order 2'),
 (2, 5, 'SALE',      -1, 2,    'Order 2');