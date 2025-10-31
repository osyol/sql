DROP TABLE IF EXISTS grades CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS groups CASCADE;

CREATE TABLE students (
   student_id INT PRIMARY KEY,
   full_name VARCHAR(100),
   age INT,
   group_id INT
);

CREATE TABLE groups (
   group_id INT PRIMARY KEY,
   group_name VARCHAR(50)
);

CREATE TABLE subjects (
   subject_id INT PRIMARY KEY,
   subject_name VARCHAR(50)
);

CREATE TABLE grades (
   grade_id INT PRIMARY KEY,
   student_id INT,
   subject_id INT,
   grade INT,
   FOREIGN KEY (student_id) REFERENCES students(student_id),
   FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- 1 Студенты
INSERT INTO students (student_id, full_name, age, group_id) VALUES
(1, 'Aybek Karimov', 21, 1),
(2, 'Kevin de Bruyne', 34, 1),
(3, 'Lionel Messi', 38, 2),
(4, 'Hernandez Hernandez', 41, 2),
(5, 'Lutfulla Torayev', 69, 3),
(6, 'Karim Benzema', 15, 3);

-- 2 Предметы
INSERT INTO subjects (subject_id, subject_name) VALUES
(1, 'CopyPasting'),
(2, 'Art'),
(3, 'Logics'),
(4, 'History');

-- 3 Оценки
INSERT INTO grades (grade_id, student_id, subject_id, grade) VALUES
(1, 1, 1, 69),
(2, 1, 2, 90),
(3, 2, 1, 78),
(4, 2, 2, 88),
(5, 1, 3, 92),
(6, 3, 3, 80),
(7, 1, 4, 70),
(8, 4, 4, 75),
(9, 5, 3, 89),
(10, 5, 4, 82),
(11, 6, 2, 15),
(12, 6, 3, 15);

-- 4 группы
INSERT INTO groups (group_id, group_name) VALUES
(1, 'DD-69'),
(2, 'MATH-202'),
(3, 'ART-303');

SELECT * FROM students;

-- подсчёт количества студентов
SELECT COUNT(student_id) 
FROM students;

-- срединй возраст студентов
SELECT AVG(age) 
FROM students;

-- минимальный возраст
SELECT MIN(age) 
FROM students;

-- максимальный возраст
SELECT MAX(age)
FROM students;

-- сколько всего оценок выставлено
SELECT COUNT(grade_id)
FROM grades;

-- сколько студентов в каждой группе
SELECT COUNT(student_id)
FROM students
GROUP BY group_id;

-- средний возраст студентов в каждой группе
SELECT AVG(age) 
FROM students
GROUP BY group_id;

-- средний балл по каждому предмету
SELECT AVG(grade)
FROM grades
GROUP BY subject_id;

-- студент у которого есть оценки по каждому предмету
SELECT s.student_id, s.full_name
FROM students s
JOIN grades g ON s.student_id = g.student_id
GROUP BY s.student_id, s.full_name
HAVING COUNT (DISTINCT g.subject_id) = 
(SELECT COUNT (*) FROM subjects);

-- группы где больше одного студента
SELECT g.group_name
FROM groups g
JOIN students s ON g.group_id = s.group_id
GROUP BY g.group_name
HAVING COUNT(s.student_id) > 1;

-- предмет со средним баллом выше 8
-- SELECT sub.subject_name
-- FROM subjects sub
-- JOIN grades g ON sub.subject_id = g.subject_id
-- GROUP BY sub.subject_name
-- HAVING AVG(g.grade) > 8;