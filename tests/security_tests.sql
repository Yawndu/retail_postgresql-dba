-- Test S1: readonly_user tries to delete data
-- Expected: permission denied for table products
SET ROLE readonly_user;
DELETE FROM products;
RESET ROLE;

-- Test S2: readonly_user tries to insert data
-- Expected: permission denied for table categories
SET ROLE readonly_user;
INSERT INTO categories (category_name) VALUES ('Hacked');
RESET ROLE;

-- Test S3: readonly_user reads data (should succeed)
-- Expected: rows returned
SET ROLE readonly_user;
SELECT * FROM products LIMIT 3;
RESET ROLE;

-- Test S4: reporting_user reads a raw table
-- Expected: permission denied for table customers
SET ROLE reporting_user;
SELECT * FROM customers;
RESET ROLE;

-- Test S5: reporting_user reads a reporting view (should succeed)
-- Expected: rows returned, even though it has no access to the underlying tables
SET ROLE reporting_user;
SELECT * FROM v_customer_spending ORDER BY total_spent DESC;
RESET ROLE;

-- Test S6: application_user tries to delete orders
-- Expected: permission denied for table orders
SET ROLE application_user;
DELETE FROM orders WHERE order_id = 1;
RESET ROLE;

-- Test S7: application_user tries to wipe a table
-- Expected: permission denied for table inventory
SET ROLE application_user;
TRUNCATE inventory;
RESET ROLE;

-- Test S8: application_user tries to read employee records
-- Expected: permission denied for table employees
SET ROLE application_user;
SELECT * FROM employees;
RESET ROLE;

-- Test S9: application_user tries to change the schema
-- Expected: must be owner of table customers
SET ROLE application_user;
DROP TABLE customers;
RESET ROLE;

-- Test S10: application_user does normal work (should succeed, then undo)
-- Expected: UPDATE 1, then the ROLLBACK discards it
BEGIN;
SET LOCAL ROLE application_user;
UPDATE inventory SET quantity = quantity - 1 WHERE warehouse_id = 1 AND product_id = 1;
ROLLBACK;

-- Test S11: database_admin has full access (should succeed)
-- Expected: row count returned
SET ROLE database_admin;
SELECT COUNT(*) FROM orders;
RESET ROLE;

