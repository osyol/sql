DROP TABLE IF EXISTS students;

CREATE TABLE students (
                         student_id SERIAL PRIMARY KEY,
                         first_name VARCHAR(50) NOT NULL,
                         last_name VARCHAR(50) NOT NULL,
                         birth_date DATE NOT NULL,
                         email VARCHAR(100) UNIQUE,
                         group_id INT NOT NULL
);


-- insert для заполнения таблицы
INSERT INTO students (first_name, last_name, birth_date, email, group_id) VALUES
('Aybek', 'Karimov', '2004-06-28', 'karimov@gmail.com', 1),
('Alfredo', 'Di Stefano', '1940-05-15', 'distefano@gmail.com', 2),
('Kevin', 'De Bruyne', '1991-06-28', 'kdb@gmail.com', 1),
('Max', 'Verstappen', '1997-09-30', 'verstappen@gmail.com', 2),
('Carlos', 'Sainz', '1994-09-01', 'sainz@gmail.com', 3),
('Carlos', 'Sainz', '1999-09-09', 'pique@gmail.com', 2),
('Islom', 'Karimov', '1938-01-30', 'islamkarimov@gmail.com', 2);

SELECT * FROM students;

-- для повторяющихся значений 
SELECT first_name
FROM students
GROUP BY first_name
HAVING COUNT(*) > 1;

SELECT last_name
FROM students
GROUP BY last_name
HAVING COUNT(*) > 1;

SELECT first_name, last_name
FROM students
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;