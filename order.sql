DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
 id     SERIAL PRIMARY KEY,
 name   VARCHAR(50) NOT NULL,
 location VARCHAR(50)
);

CREATE TABLE employees (
 id           SERIAL PRIMARY KEY,
 name         VARCHAR(50) NOT NULL,
 position     VARCHAR(50),
 salary       NUMERIC(10,2),
 department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
 manager_id   INTEGER REFERENCES employees(id) ON DELETE SET NULL
);

CREATE TABLE customers (
 id   SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 city VARCHAR(50)
);

CREATE TABLE orders (
 id          SERIAL PRIMARY KEY,
 order_date  DATE NOT NULL,
 amount      NUMERIC(10,2),
 employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
 customer_id INTEGER REFERENCES customers(id) ON DELETE SET NULL
);

CREATE TABLE products (
 id    SERIAL PRIMARY KEY,
 name  VARCHAR(100) NOT NULL,
 price NUMERIC(10,2)
);

CREATE TABLE order_items (
 id         SERIAL PRIMARY KEY,
 order_id   INTEGER REFERENCES orders(id) ON DELETE CASCADE,
 product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
 quantity   INTEGER NOT NULL
);
-- insert-ы для вывода данных

INSERT INTO departments (name, location) VALUES
('Sales', 'Tashkent'),
('OF', 'Samarkand'),
('Children', 'Bukhara'),
('Slavery', 'Podval');

INSERT INTO employees (name, position, salary, department_id, manager_id) VALUES
('Aybek Karimov', 'Sales Manager', 1500.00, 1, NULL),
('Alfredo Di Stefano', 'IT Specialist', 2000.00, 2, NULL),
('Kevin De Bruyne', 'Sales Representative', 1800.00, 1, 1),
('Max Verstappen', 'System Administrator', 2200.00, 2, 2),
('Carlos Sainz', 'Driver', 1700.00, 3, NULL),
('Carlos Sainz Jr', 'Driver Assistant', 1200.00, 2, 4),
('Islom Karimov', 'Director', 5000.00, NULL, NULL);

INSERT INTO customers (name, city) VALUES
('Red Bull Rac', 'Salzburg'),
('Mercedes-AMG Petronas', 'Berlin'),
('Ferrari S.p.A', 'Maranello'),
('UzAuto Motors', 'Tashkent');

INSERT INTO orders (order_date, amount, employee_id, customer_id) VALUES
('2025-10-01', 1200.00, 1, 1),  
('2025-10-02', 3500.00, 2, 2),   
('2025-10-03', 500.00, 3, 3),    
('2025-10-05', 1000.00, NULL, 4),
('2025-10-06', 2500.00, 4, NULL);

INSERT INTO products (name, price) VALUES
('Steering Wheel', 250.00),
('Tire Set', 800.00),
('Gearbox', 1200.00),
('Engine Oil', 100.00),
('Racing seat', 650.00);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),  
(1, 4, 5),  
(2, 3, 1),  
(3, 2, 4);  

-- сотрудникий с зп выше средней

SELECT
    id,
    name AS full_name,
    salary
FROM employees
WHERE COALESCE(salary, 0) > (
    SELECT AVG(COALESCE(salary, 0)) 
    FROM employees
)
ORDER BY salary DESC;

-- продукты дороже среднего
SELECT 
	id, 
	name AS product_name,
	price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- отделы с 1 и более сотрудником с зп выше 10к

SELECT DISTINCT
	d.id AS departmend_id,
	d.name as department_name
FROM departments d
JOIN employees e ON d.id = e.department_id
WHERE COALESCE(e.salary, 0) > 10000
ORDER BY d.name;

-- продукты с высокой частотой

SELECT
    p.id AS product_id,
    p.name AS product_name,
    COUNT(oi.order_id) AS orders_count
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY orders_count DESC;
-- LIMIT N; -- для топа 

-- количество заказов каждого клиента

SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    COUNT(o.id) AS orders_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY orders_count DESC;

-- топ 3 отдела по зп

SELECT
    d.id AS department_id,
    d.name AS department_name,
    COALESCE(AVG(e.salary), 0) AS average_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
ORDER BY average_salary DESC
LIMIT 3;

-- клиенты без заказов

SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    c.city
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL
ORDER BY c.name;

-- сотрудник с зп больше всех менеджеров

SELECT
    e.id,
    e.name AS full_name,
    e.salary
FROM employees e
WHERE COALESCE(e.salary, 0) > (
    SELECT MAX(COALESCE(m.salary, 0))
    FROM employees m
    WHERE m.id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL)
)
ORDER BY e.salary DESC;

-- отделы с мин зп больше 5000

SELECT
    d.id AS department_id,
    d.name AS department_name
FROM departments d
JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING MIN(COALESCE(e.salary, 0)) > 5000
ORDER BY d.name;


