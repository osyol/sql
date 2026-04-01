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





--1 вывод employee.id, employee.name, department.name, и no department
SELECT
	e.id AS employee_id,
	e.name AS employee_name,
	COALESCE(d.name, 'No department') AS department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;

--2 сотрудники с менеджерем
SELECT
	e.name AS employee_name,
	m.name AS manager_name
FROM employees e
JOIN employees m ON e.manager_id = m.id;

--3 отделы без сотрудников
SELECT 
	d.name AS department_name
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
WHERE e.id IS NULL;

--4 Все заказы с именем сотрудника и именем клиента
-- — если employee или customer отсутствует, 
-- показывать No Employee / No Customer.
SELECT 
    o.id AS order_id,
    o.order_date,
    o.amount,
    COALESCE(e.name, 'No Employee') AS employee_name,
    COALESCE(c.name, 'No Customer') AS customer_name
FROM orders o
LEFT JOIN employees e ON o.employee_id = e.id
LEFT JOIN customers c ON o.customer_id = c.id;

--5 Список заказов с товарами:
-- для каждого заказа вывести order_id, product_name, quantity.
-- Показать также заказы без позиций.

SELECT 
    o.id AS order_id,
    COALESCE(p.name, 'No Product') AS product_name,
    COALESCE(oi.quantity, 0) AS quantity
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
ORDER BY o.id;

--6 Для каждого отдела — все заказы (через сотрудников этого отдела);
-- включать отделы с нулём заказов.

SELECT 
    d.name AS department_name,
    o.id AS order_id,
    o.order_date,
    o.amount
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
LEFT JOIN orders o ON e.id = o.employee_id
ORDER BY d.name, o.id;

--7 Найти пары клиентов и продуктов, которые этот клиент никогда не покупал 
-- (т.е. построить Cartesian клиент×продукт и исключить реальные покупки).

SELECT 
    c.name AS customer_name,
    p.name AS product_name
FROM customers c
CROSS JOIN products p
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    WHERE o.customer_id = c.id
      AND oi.product_id = p.id
)
ORDER BY c.name, p.name;

--8 Показать, какие продукты никогда не продавались.

SELECT 
    p.id,
    p.name AS product_name,
    p.price
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.product_id IS NULL;

--9 Для каждого менеджера — 
-- показать суммарную сумму заказов, оформленных его подчинёнными.

SELECT 
    m.name AS manager_name,
    COALESCE(SUM(o.amount), 0) AS total_orders_amount
FROM employees e
JOIN employees m ON e.manager_id = m.id
LEFT JOIN orders o ON e.id = o.employee_id
GROUP BY m.id, m.name
ORDER BY m.name;

--10 Общее количество заказов и суммарная выручка (amount).

SELECT
    COUNT(*) AS total_orders,
    COALESCE(SUM(amount), 0) AS total_revenue
FROM orders;

--11 Средняя и максимальная зарплата по отделам.

SELECT 
    d.name AS department_name,
    COALESCE(AVG(e.salary), 0) AS average_salary,
    COALESCE(MAX(e.salary), 0) AS max_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
ORDER BY d.name;

--12 Для каждого заказа — общее количество товаров (sum quantity) и 
-- уникальных позиций (count distinct product_id).

SELECT
    o.id AS order_id,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity,
    COUNT(DISTINCT oi.product_id) AS distinct_products
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id
ORDER BY o.id;

--13 Топ-3 продукта по суммарной выручке(price*quantity).

SELECT
    p.name AS product_name,
    SUM(p.price * oi.quantity) AS total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY total_revenue DESC
LIMIT 3;

--14 Количество клиентов, 
-- у которых есть хотя бы один заказ.

SELECT
    COUNT(DISTINCT o.customer_id) AS customers_with_orders
FROM orders o
WHERE o.customer_id IS NOT NULL;

--15 Для каждого отдела — количество сотрудников,
-- средняя зарплата, суммарная сумма заказов 
-- (через сотрудников этого отдела).

SELECT
    d.name AS department_name,
    COUNT(e.id) AS employee_count,
    COALESCE(AVG(e.salary), 0) AS average_salary,
    COALESCE(SUM(o.amount), 0) AS total_orders_amount
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
LEFT JOIN orders o ON e.id = o.employee_id
GROUP BY d.id, d.name
ORDER BY d.name;

--16 Найти клиентов, чья средняя сумма заказа
-- выше средней по всем заказам

SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    AVG(o.amount) AS avg_order_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING AVG(o.amount) > (
    SELECT AVG(amount) 
    FROM orders
);

--17 Сформировать полное имя сотрудника
SELECT 
    id,
    name AS full_name
FROM employees;

--18 Вывести дату заказа в
-- формате DD.MM.YYYY HH24:MI.

SELECT 
    id AS order_id,
    TO_CHAR(order_date, 'DD.MM.YYYY HH24:MI') AS formatted_date
FROM orders;

--19 Найти заказы старше N дней (параметр)

-- Тут N = 2
SELECT
    id AS order_id,
    order_date,
    amount
FROM orders
WHERE order_date < CURRENT_DATE - INTERVAL '2 days'
ORDER BY order_date;

--20 Для таблицы employees: 
-- заменить NULL в salary на 0 в вычислениях
-- и вывести salary + bonus
-- (bonus = 10% для определённой позиции).

SELECT
    id,
    name AS full_name,
    COALESCE(salary, 0) AS salary,
    CASE 
        WHEN position = 'Sales Manager' THEN COALESCE(salary, 0) * 0.10
        ELSE 0
    END AS bonus,
    COALESCE(salary, 0) + 
    CASE 
        WHEN position = 'Sales Manager' THEN COALESCE(salary, 0) * 0.10
        ELSE 0
    END AS total_compensation
FROM employees;