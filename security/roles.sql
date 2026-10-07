-- =====================================================
-- retail_operations: roles and least-privilege access
-- Run while connected to retail_operations as a superuser
-- (for example postgres).
--
-- NO PASSWORDS are stored in this file. Roles are created
-- without one, so they can't log in with a password yet.
-- To allow real logins, set passwords locally and never
-- commit them:   ALTER ROLE reporting_user PASSWORD '...';
-- =====================================================

-- 1. Create roles
CREATE ROLE database_admin    LOGIN;
CREATE ROLE application_user  LOGIN;
CREATE ROLE reporting_user    LOGIN;
CREATE ROLE readonly_user     LOGIN;

-- 2. Lock down the defaults
--    Nobody gets access unless it is granted explicitly.
REVOKE ALL ON DATABASE retail_operations FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

GRANT CONNECT ON DATABASE retail_operations
  TO database_admin, application_user, reporting_user, readonly_user;

GRANT USAGE ON SCHEMA public
  TO database_admin, application_user, reporting_user, readonly_user;

-- 3. database_admin: full control of the application objects
GRANT CREATE ON SCHEMA public TO database_admin;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO database_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO database_admin;

-- 4. application_user: day-to-day operations, no deletes, no DDL
--    Operational tables: read, add and change rows
GRANT SELECT, INSERT, UPDATE ON
  customers, orders, order_items, inventory, stock_movements
  TO application_user;
--    Reference tables: read only
GRANT SELECT ON
  products, categories, suppliers, warehouses
  TO application_user;
--    (no access to employees, no DELETE or TRUNCATE anywhere)

-- 5. reporting_user: reporting views only, no table access
GRANT SELECT ON
  v_product_sales, v_customer_spending, v_low_stock,
  v_monthly_sales, v_category_revenue, v_inventory_value
  TO reporting_user;

-- 6. readonly_user: can read everything, change nothing
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- =====================================================
-- VERIFY
-- =====================================================
-- Roles that now exist:
SELECT rolname, rolcanlogin, rolsuper
FROM pg_roles
WHERE rolname IN ('database_admin','application_user','reporting_user','readonly_user')
ORDER BY rolname;

-- Table-level privileges granted to each role:
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('application_user','reporting_user','readonly_user')
ORDER BY grantee, table_name, privilege_type;