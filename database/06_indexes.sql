-- Orders for a customer (order history lookups)
CREATE INDEX idx_orders_customer_id
    ON orders (customer_id);

-- Sales for a product. The primary key of order_items is
-- (order_id, product_id), so it cannot serve lookups by product_id alone.
CREATE INDEX idx_order_items_product_id
    ON order_items (product_id);

-- Recent stock movements for a product in a warehouse, newest first
CREATE INDEX idx_stock_movements_product_wh_date
    ON stock_movements (product_id, warehouse_id, movement_date DESC);

ANALYZE;

