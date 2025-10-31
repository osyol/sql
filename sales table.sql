
DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
   id SERIAL PRIMARY KEY,
   region VARCHAR(20),
   amount BIGINT,
   sale_date DATE
);

INSERT INTO sales (region, amount, sale_date) VALUES
('North', 1000, '2024-01-01'),
('South', 700, '2024-01-02'),
('North', 500, '2024-01-03'),
('West', NULL, '2024-01-04'),
('South', 900, '2024-01-05'),
('North', 1500, '2024-01-06');

SELECT * FROM sales;

-- сумма продаж по региону
SELECT region, SUM(amount) AS total_sum
from sales 
GROUP BY region;

-- средняя сумма по продажам по региону где больше одной
SELECT region, SUM(amount) AS average_region
FROM sales
GROUP BY region
HAVING COUNT(amount) > 1;

-- регион с максимальной суммой продаж
SELECT region, COALESCE(SUM(amount), 0)  as max_more_one
FROM sales
GROUP BY region
ORDER BY max_more_one DESC
LIMIT 1;

-- общее количество продаж и сколько из них имеет ненулёвую сумму
SELECT 
COUNT(*) as total_sales,
COUNT(amount) as sales_with_no_null
FROM sales;

-- регионы с продажей выше среднего
SELECT
region, AVG(amount) as avg_sales
FROM sales
GROUP BY region
HAVING AVG(amount) > 
(SELECT AVG(amount)
FROM sales
);
