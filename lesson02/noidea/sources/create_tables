CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name TEXT,
    customer_email TEXT,
    product_name TEXT,
    product_price NUMERIC(10,2)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    product_name TEXT,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT,
    city TEXT,
    region TEXT
);
