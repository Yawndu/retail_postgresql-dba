
CREATE TABLE customers(
	customer_id		INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	first_name 		VARCHAR(50) 	NOT NULL,
	last_name		VARCHAR(50) 	NOT NULL,
	email			VARCHAR(100) 	NOT NULL UNIQUE,
	phone			varchar(20),
	address			TEXT,
	created_at		timestamp NOT NULL DEFAULT now()
);

CREATE TABLE categories(
	category_id 	INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category_name	VARCHAR(100) NOT NULL UNIQUE,
	description 	TEXT
);

CREATE TABLE suppliers(
	supplier_id 	INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	supplier_name	varchar(150) 	NULL,
	contact_name	varchar(100),
	email 			varchar(100),
	phone 			varchar(20),
	address			TEXT,
	created_at 		timestamp 		NOT NULL DEFAULT now()
);

CREATE TABLE warehouses(
	warehouse_id	INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	warehouse_name	VARCHAR(100) 	NOT NULL UNIQUE,
	location		varchar(200) 	NOT NULL,
	created_at 		timestamp    	NOT NULL DEFAULT now()
);


CREATE TABLE products (
	product_id 	INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category_id INTEGER			NOT NULL,
	supplier_id	INTEGER			NOT NULL,
	product_name VARCHAR(150)   NOT NULL,
	sku			VARCHAR(50)	    NOT NULL UNIQUE,
	description TEXT,
	unit_price  DECIMAL(10,2)   NOT NULL,
	created_at timestamp        NOT NULL DEFAULT now(),

	CONSTRAINT fk_products_category
		FOREIGN KEY (category_id) REFERENCES categories(category_id),
	CONSTRAINT fk_products_supplier
		FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
	CONSTRAINT chk_products_price CHECK (unit_price >=0)
);

CREATE TABLE employee (
	employee_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	warehouse_id INTEGER 		NOT NULL,
	first_name   VARCHAR(50)	NOT NULL,
	last_name	 VARCHAR(50)    NOT NULL,
	position     VARCHAR(100)   NOT NULL,
	email		 VARCHAR(100)   NOT NULL UNIQUE,
	hire_date    date			NOT NULL,

	CONSTRAINT fk_employee_warehouse
		FOREIGN KEY(warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE inventory (
	warehouse_id 	INTEGER		NOT NULL,
	product_id 		INTEGER		NOT NULL,
	quantity		INTEGER 	NOT NULL DEFAULT 0,
	reorder_level	INTEGER 	NOT NULL DEFAULT 0,
	last_updated	TIMESTAMP	NOT NULL DEFAULT now(),

	PRIMARY KEY( warehouse_id, product_id),
	CONSTRAINT fk_inventory_warehouse
		FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
	CONSTRAINT fk_inventory_product
		FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT chk_inventory_quantity		CHECK (quantity >=0),
	CONSTRAINT chk_inventory_reorder_level	CHECK (reorder_level >=0)
);

CREATE TABLE orders (
	order_id	INTEGER 		GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_id INTEGER 		NOT NULL,
	order_date	TIMESTAMP 		NOT NULL DEFAULT now(),
	status		VARCHAR(30)		NOT NULL DEFAULT 'Pending',
	total_amount  DECIMAL(12,2) NOT NULL DEFAULT 0,

	CONSTRAINT fk_orders_customer
		FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	CONSTRAINT chk_orders_status
		CHECK(status IN('Pending','Processing','Shipped','Delivered','Canceled')),
	CONSTRAINT chk_orders_total CHECK (total_amount >=0)
);

CREATE TABLE order_items (
	order_id 	INTEGER			NOT NULL,
	product_id	INTEGER			NOT NULL,
	quantity	INTEGER			NOT NULL,
	unit_price  DECIMAL(10,2)	NOT NULL,
	subtotal	DECIMAL (12,2)	NOT NULL,

	PRIMARY KEY (order_id, product_id),
	CONSTRAINT fk_order_items_order
		FOREIGN KEY (order_id) REFERENCES orders(order_id),
	CONSTRAINT fk_order_items_product
		FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT chk_order_items_quantity  CHECK (quantity >= 0),
	CONSTRAINT chk_order_items_price  	 CHECK (unit_price >= 0),
	CONSTRAINT chk_order_items_subtotal  CHECK (subtotal = quantity * unit_price)
);

CREATE TABLE stock_movements (
	movement_id		INTEGER 		GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	warehouse_id	INTEGER			NOT NULL,
	product_id		INTEGER			NOT NULL,
	movement_type   VARCHAR(30)		NOT NULL,
	quantity		INTEGER			NOT NULL,
	reference_id	INTEGER,
	movement_date	TIMESTAMP		NOT NULL DEFAULT now(),
	notes			TEXT,

	CONSTRAINT fk_movements_warehouse
		FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
	CONSTRAINT fk_momvement_product
		FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT chk_movements_type
		CHECK (movement_type IN ('PURCHASE', 'SALE', 'RETURN', 'ADJUSTMENT', 'TRANSFER IN', 'TRANSFER OUT')),
	CONSTRAINT chk_movements_quantity CHECK (quantity <> 0)
);


