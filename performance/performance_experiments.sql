-- =====================================================
-- PHASE 0: confirm there are no extra indexes yet
-- Expected: no rows (primary keys and UNIQUE indexes are not listed)
-- =====================================================
SELECT indexname FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE 'idx_%';

-- If it lists any, drop them so the baseline is honest, for example:
-- DROP INDEX IF EXISTS idx_orders_customer_id;


-- =====================================================
-- PHASE 1: BASELINE (before indexes)  -> performance/before/
-- =====================================================

-- P1: all orders for one customer
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 15234;

-- P2: one customer's order history, newest first
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 15234 ORDER BY order_date DESC;

-- P3: sales of one product
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.product_name, SUM(oi.quantity) AS units, SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.product_id = 500
GROUP BY p.product_name;

-- P4: the 20 most recent stock movements for a product in a warehouse
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM stock_movements
WHERE product_id = 500 AND warehouse_id = 2
ORDER BY movement_date DESC
LIMIT 20;

-- P5: count of delivered orders
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM orders WHERE status = 'Delivered';


-- =====================================================
-- PHASE 2: add the indexes  -> rerun P1, P3, P4 into performance/after/
-- =====================================================
CREATE INDEX idx_orders_customer_id
    ON orders (customer_id);
CREATE INDEX idx_order_items_product_id
    ON order_items (product_id);
CREATE INDEX idx_stock_movements_product_wh_date
    ON stock_movements (product_id, warehouse_id, movement_date DESC);
ANALYZE;

-- Now rerun P1, P3 and P4 (the same statements as in Phase 1) and compare.
-- Look for: Seq Scan replaced by an Index Scan or Bitmap Index Scan,
-- and a much smaller Execution Time.


-- =====================================================
-- PHASE 3: does a composite index beat a single-column one?
-- Question: is (customer_id, order_date DESC) worth having
-- when idx_orders_customer_id already exists?
-- =====================================================

-- Step A: with only the single-column index, run P2 (this is your "A" result)
EXPLAIN (ANALYZE)
SELECT * FROM orders WHERE customer_id = 15234 ORDER BY order_date DESC;

-- Step B: add the composite index and run P2 again
CREATE INDEX idx_orders_customer_date
    ON orders (customer_id, order_date DESC);
ANALYZE orders;

EXPLAIN (ANALYZE)
SELECT * FROM orders WHERE customer_id = 15234 ORDER BY order_date DESC;

-- Compare the two Execution Times. Customers here have only a handful of
-- orders, so sorting them is trivial and the composite index may make
-- no measurable difference. If it does not, drop it:
DROP INDEX idx_orders_customer_date;


-- =====================================================
-- PHASE 4: an index on a low-selectivity column
-- status has only 5 distinct values, so each value matches ~20% of the table.
-- =====================================================
CREATE INDEX idx_orders_status ON orders (status);
ANALYZE orders;

-- Rerun P5 and compare with the baseline. Note how much it improves,
-- how large the index is (Phase 5), and that every order status change
-- (Pending -> Shipped -> Delivered) must also update this index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM orders WHERE status = 'Delivered';

-- Decide whether the gain justifies the cost. If not, drop it:
DROP INDEX idx_orders_status;


-- =====================================================
-- PHASE 5: what do the indexes cost?
-- =====================================================

-- Size of each index
SELECT indexrelname AS index_name,
       relname      AS table_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE indexrelname LIKE 'idx_%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- How often is each index actually used? (idx_scan = 0 means unused)
-- Usage counters can lag by a few seconds: if you just ran queries and
-- see 0, wait a moment and run this again before concluding it is unused.
SELECT indexrelname AS index_name, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
WHERE indexrelname LIKE 'idx_%'
ORDER BY idx_scan;

-- Table sizes for comparison
SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;