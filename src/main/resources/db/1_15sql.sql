CREATE DATABASE company_repository; -- Создание базы данных

DROP DATABASE company_repository; -- Удаление базы данных

CREATE SCHEMA company_storage; -- Создание схемы(пакета)

DROP SCHEMA company_storage; -- Удаление схемы(пакета)

CREATE TABLE company -- Создание таблицы -- CREATE TABLE company_storage.company();
(
    id   INT PRIMARY KEY,
    name VARCHAR(128) UNIQUE NOT NULL,
    -- VARCHAR(128) (128) - ограничение размера
    date DATE                NOT NULL CHECK ( date > '1995-01-01' AND date < '2020-01-01'),
    -- DATE(только дата), TIMESTAMP(дата и время), TIME(только время)
    UNIQUE (name, date)
    -- UNIQUE (name, date) - указываем что первичный ключ должен идти на основании двух колонок
);

------------------------------------------------------------------------------------------------------------------------
-- Constraints/Ограничение:
-- NOT NULL - не дает создавать пустое поле в таблице
-- UNIQUE - уникальность колонки
-- CHECK - ограничение
-- PRIMARY KEY - первичный ключ (может быть только один)  == UNIQUE NOT NULL
-- FOREIGN KEY - вторичный ключ
------------------------------------------------------------------------------------------------------------------------
-- AND == &&
-- OR == ||
------------------------------------------------------------------------------------------------------------------------
-- Типы данных. Числовые типы:
-- SMALLINT - 2 байта (short) - целое в небольшом диапазоне
-- INTEGER - 4 байта (int) - типичный выбор для целых чисел
-- BIGINT - 8 байт (long) - целое в большом диапазоне
-- DECIMAL - переменный вещественное число с указанной точностью
-- NUMERIC - переменный вещественное число с указанной точностью
-- REAL - 4 байта - вещественное число с переменной точностью
-- DOUBLE PRECISION - 8 байт - вещественное число с переменной точностью
-- SMALLSERIAL - 2 байта - небольшое целое число с авто увеличением
-- SERIAL - 4 байта - целое число с авто увеличением
-- BIGSERIAL - 8 байт - большое целое число с авто увеличением
------------------------------------------------------------------------------------------------------------------------

INSERT INTO company(id, name, date) -- Вставляем данные в таблицу -- INSERT INTO company_storage.company() VALUES ('');
VALUES (1, 'Google', '2001-01-01'), -- Прописываем те значения которые вставляем
       (2, 'Apple', '2002-10-29'),
       (3, 'Facebook', '1998-09-13');

DROP TABLE company; -- Удаление таблицы -- DROP TABLE company_storage.company();

CREATE TABLE employee -- Создание таблицы -- CREATE TABLE company_storage.employee();
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    company_id INT REFERENCES company (id) ON DELETE CASCADE,
    -- company_id INT REFERENCES company_storage.company (id)
    -- ON DELETE CASCADE во время удаления компании с таким айди так же удалим и сотрудника
    -- ON DELETE NO ACTION ничего не изменится (по умолчанию)
    -- ON DELETE SET DEFAULT во время удаления компании установится значение
    -- ON DELETE SET NULL во время удаления компании установится значение NULL || Не должно быть NOT NULL
    salary     INT,
    UNIQUE (first_name, last_name) -- (first_name, last_name) == конкатенация
    -- FOREIGN KEY (company_id) REFERENCES company(можно не указывать так как ссылается на первичный ключ)
);

INSERT INTO employee(first_name, last_name, salary, company_id)
    -- Вставляем данные в таблицу -- INSERT INTO company_storage.employee() VALUES ('');
VALUES ('Ivan', 'Ivanov', 1000, 1),
       ('Petr', 'Petrov', 2000, 2),
       ('Sveta', 'Svetikova', 1500, NULL),
       ('Arni', 'Paramonov', NULL, 2),
       ('Ivan', 'Sidorov', 500, 3);

DROP TABLE employee; -- Удаление таблицы -- DROP TABLE company_storage.employee();

SELECT DISTINCT -- Выборка уникальных значений == Set
                id,                   -- Best practice писать с новой строки
                first_name AS f_name, -- AS (ALIAS) название для столбца или таблицы || в PostgresSQL можно не указывать
                last_name  AS l_name,
                salary
FROM employee AS empl -- Откуда -- FROM company_storage.employee();
WHERE last_name LIKE '%ov%' -- Фильтрация выборки
------------------------------------------------------------------------------------------------------------------------
      -- Для чисел WHERE salary > 1000 || (все математические операции сравнения)
      -- <> == !=
      -- WHERE salary BETWEEN 1000 AND 1500 || строгое равенство (промежуток)
      -- WHERE salary IN(1000, 1100, 2000) || точное значение

      -- WHERE salary IN(1000, 1100, 2000) AND first_name LIKE 'Iv%'
      -- || комбинирование запросов где оба условия true происходит склеивание выборки
      -- || Best practice каждое условие с новой строки и объединять в скобки условия

      -- AND first_name LIKE 'Iv%' - все только по условию
      -- OR first_name LIKE 'Iv%' - все не только по условию
------------------------------------------------------------------------------------------------------------------------
      -- Для дат WHERE data BETWEEN
------------------------------------------------------------------------------------------------------------------------
      -- Для строк WHERE first_name = 'Ivan'
      -- LIKE без % = равенство(=) || чувствителен к регистру
      -- ILIKE не чувствителен к регистру (PostgresSQL only)
      -- % ставится где значения неважны
      -- LIKE 'Pet%' префикс
      -- LIKE '%ov' постфикс
      -- LIKE '%va%' по постфиксу и по префиксу
------------------------------------------------------------------------------------------------------------------------
ORDER BY first_name, salary DESC -- Сортировка по возрастанию -- DESC - по убыванию -- ASC - по возрастанию
LIMIT 20 -- Ограничиваем количество записей || порядок не гарантируется (нужна сортировка)
    OFFSET 0; -- Пропускает записи и после этого сработает LIMIT || порядок не гарантируется (нужна сортировка)

SELECT count(salary) -- SELECT count(*) - * все значения
       -- sum() - сумма всех зарплат
       -- avg() - среднее арифметическое
       -- max() - максимальное значение
       -- min() - минимальное значение
       -- count() - количество строк || если SELECT count(salary) то убирает все значения NULL
       -- upper(first_name) - к верхнему регистру
       -- lower(first_name) - к нижнему регистру
       -- concat(first_name, ' ', last_name) - объединяет строки или first_name || ' ' || last_name
       -- now() - возвращает текущую дату и время
FROM employee; -- Откуда -- FROM company_storage.employee();

SELECT now(), 1 * 2 + 3; -- Можно вызывать просто функции

SELECT id, first_name
FROM employee
WHERE company_id IS NOT NULL -- IS NULL если нужна колонка которая равна NULL или IS NOT NULL - не равна NULL
UNION
-- UNION ALL - выводит все значения
-- должны иметь одинаковое количество колонок для сравнения и одинаковый тип и совпадать логически
-- UNION - обрезает дублирующие значения (Set)
-- Для удаления дубликатов из одного SELECT можно использовать ключевое слово DISTINCT
SELECT id, first_name
FROM employee
WHERE salary IS NULL;

SELECT avg(salary) -- SELECT avg(empl.salary) - желательно использовать если нужно поля разграничивать не указывать ALIAS
       -- Объединение подзапросов нахождение минимальных зарплат и их среднее арифметическое
FROM (SELECT *
      FROM employee
      ORDER BY salary
      LIMIT 2) empl;

SELECT *,
       (SELECT avg(salary) FROM employee)          avg,
       -- Подзапрос с создаем колонки со значением средней арифметической зарплат сотрудников
       (SELECT max(salary) FROM employee)          max,
       -- Подзапрос с создаем колонки со значением максимальной зарплатой сотрудников
       (SELECT max(salary) FROM employee) - salary diff
       -- Подзапрос с создаем колонки с разницей от максимальной зарплаты сотрудника и текущей зарплатой сотрудника
FROM employee;

SELECT * --Выборка с подзапросом из таблицы company с условиями что компания не основа раньше указанной даты
FROM employee
WHERE company_id IN (SELECT company.id FROM company WHERE date > '2000-01-01');
-- Подзапрос должен возвращать одну колонку

SELECT * -- Пример вложенных подзапросов
FROM (SELECT
      FROM (VALUES ('Ivan', 'Ivanov', 1000, 1),
                   ('Petr', 'Petrov', 2000, 2),
                   ('Sveta', 'Svetikova', 1500, NULL),
                   ('Arni', 'Paramonov', NULL, 2),
                   ('Ivan', 'Sidorov', 500, 3)) t) y;

DELETE
FROM employee -- Удалит все записи из таблицы
WHERE salary IS NULL; -- Удалит сотрудника с зарплатой NULL

DELETE -- Удалит сотрудника с максимальной зарплатой
FROM employee
WHERE salary = (SELECT max(salary) FROM employee);

DELETE -- Не выполнится так как в компании есть сотрудники
FROM company
WHERE id = 1;

DELETE -- Прежде чем удалять копанию нужно удалить сотрудников которые там работают
FROM employee
WHERE company_id = 1;

UPDATE employee -- Обновление значений  в таблице || Не возвращают данные которые обновили
SET company_id = 2,
    salary     = 1700
WHERE id = 3;

UPDATE employee -- Обновление значений  в таблице
SET company_id = 2,
    salary     = 1700
WHERE id = 3
   OR id = 5
RETURNING *;
-- Возвращаем данные после обновления
-- RETURNING id, first_name || ' ' last_name fio;
-- RETURNING можно использовать как в UPDATE так и в DELETE
-- Используется как логирование
