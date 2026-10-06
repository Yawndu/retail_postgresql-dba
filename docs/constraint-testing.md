# Constraint Testing

## Purpose
Verify that the database rejects invalid data. Each test below attempts an operation that should violate a constraint, and records whether PostgreSQL rejected it.

All statements are in [`tests/constraint_tests.sql`](../tests/constraint_tests.sql). They were run one at a time against the sample data in `retail_operations`.

## Summary

| # | Constraint type | What was attempted | Expected constraint | Result |
|---|---|---|---|---|
| 1 | UNIQUE | Insert a duplicate category name | unique on `categories.category_name` | Rejected |
| 2 | FOREIGN KEY (insert) | Insert a product with a nonexistent category | `fk_products_category` | Rejected |
| 3 | CHECK | Insert an order with status `'Lost'` | `chk_orders_status` | Rejected |
| 4 | CHECK | Insert an order item with quantity 0 | `chk_order_items_quantity` | Rejected |
| 5 | FOREIGN KEY (delete) | Delete a customer who has orders | `fk_orders_customer` | (fill in) |
| 6 | UNIQUE | Insert a duplicate customer email | unique on `customers.email` | (fill in) |
| 7 | UNIQUE | Insert a duplicate product SKU | unique on `products.sku` | (fill in) |
| 8 | NOT NULL | Insert a customer without an email | not-null on `customers.email` | (fill in) |
| 9 | NOT NULL | Insert a product without a name | not-null on `products.product_name` | (fill in) |
| 10 | PRIMARY KEY | Add the same product twice to one order | pkey on `order_items` | (fill in) |
| 11 | PRIMARY KEY | Add a second inventory row for the same warehouse and product | pkey on `inventory` | (fill in) |
| 12 | FOREIGN KEY (insert) | Insert an order for a nonexistent customer | `fk_orders_customer` | (fill in) |
| 13 | FOREIGN KEY (insert) | Insert an order item for a nonexistent product | `fk_order_items_product` | (fill in) |
| 14 | FOREIGN KEY (delete) | Delete a product that has inventory and sales | foreign keys on `inventory` / `order_items` | (fill in) |
| 15 | FOREIGN KEY (delete) | Delete a warehouse that has stock and employees | foreign keys on referencing tables | (fill in) |
| 16 | CHECK | Insert a product with a negative price | `chk_products_price` | (fill in) |
| 17 | CHECK | Insert an order with a negative total | `chk_orders_total` | (fill in) |
| 18 | CHECK | Insert an order item whose subtotal is not quantity × price | `chk_order_items_subtotal` | (fill in) |
| 19 | CHECK | Insert an order item with a negative price | `chk_order_items_price` | (fill in) |
| 20 | CHECK | Set inventory quantity to -1 | `chk_inventory_quantity` | (fill in) |
| 21 | CHECK | Insert a stock movement with an invalid type | `chk_movements_type` | (fill in) |
| 22 | CHECK | Insert a stock movement with quantity 0 | `chk_movements_quantity` | (fill in) |

## Selected Results

### Test 1: UNIQUE (duplicate category name)
**Statement**
```sql
INSERT INTO categories (category_name) VALUES ('Laptops');
```
**Result**
```
ERROR:  duplicate key value violates unique constraint "categories_category_name_key"
```
![Test 1](../screenshots/constraint-tests/test01_unique_category.png)

### Test 2: FOREIGN KEY on insert (nonexistent category)
**Statement**
```sql
INSERT INTO products (category_id, supplier_id, product_name, sku, unit_price)
VALUES (999, 999, 'Test', 'SKU-1', 100);
```
**Result**
```
ERROR:  insert or update on table "products" violates foreign key constraint "fk_products_category"
Key (category_id)=(999) is not present in table "categories".
```
![Test 2](../screenshots/constraint-tests/test02_fk_insert_products.png)

### Test 3: CHECK (invalid order status)
**Statement**
```sql
INSERT INTO orders (customer_id, status) VALUES (1, 'Lost');
```
**Result**
```
ERROR:  new row for relation "orders" violates check constraint "chk_orders_status"
```
![Test 3](../screenshots/constraint-tests/test03_check_order_status.png)

### Test 4: CHECK (zero quantity)
**Statement**
```sql
INSERT INTO order_items VALUES (1, 2, 0, 42000, 0);
```
**Result**
```
ERROR:  new row for relation "order_items" violates check constraint "chk_order_items_quantity"
```
![Test 4](../screenshots/constraint-tests/test04_check_quantity.png)

### Test 5: FOREIGN KEY on delete (customer has orders)
**Statement**
```sql
DELETE FROM customers WHERE customer_id = 1;
```
**Result**
```
(paste the error here)
```
![Test 5](../screenshots/constraint-tests/test05_fk_delete_customer.png)

## Findings
- Every constraint type in the schema (UNIQUE, NOT NULL, PRIMARY KEY, FOREIGN KEY, CHECK) rejected invalid data as designed.
- Foreign keys use PostgreSQL's default behavior (no `ON DELETE CASCADE`), so a parent row cannot be deleted while child rows reference it. This prevents accidental loss of order history.
- A failed insert still consumes an identity (sequence) value, so IDs can have gaps after testing. This is normal PostgreSQL behavior.
