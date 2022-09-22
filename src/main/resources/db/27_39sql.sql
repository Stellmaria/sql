VALUES (1, 2),
       (3, 4),
       (5, 6),
       (7, 8)
EXCEPT
-- UNION При объединении повторы игнорируются
-- UNION ALL не игнорируются
-- INTERSECT пересечение повторяющих множеств
-- EXCEPT убирает пересечение повторяющих множеств
VALUES (1, 2),
       (3, 4),
       (5, 6),
       (7, 8);

EXPLAIN -- Скан = 1.55
SELECT *
FROM ticket;

-- Стоимость - план выполнения
-- синтаксический (rule-based) - не используется
-- стоимостной (cost-based):
-- page_cost (input-output) = 1.0
-- cpu_cost 0,01

-- 55 (reltuples) * 0,01 = 0,55 (cpu_cost)
-- 1 (relpages) * 1.0 = 1.0 (page_cost)
-- 1.55 суммарная стоимость запроса

EXPLAIN -- Фильтрация = 1.69
SELECT *
FROM ticket
WHERE passenger_name LIKE 'Иван%'
  AND seat_no = 'B1';

EXPLAIN
SELECT flight_id,
       count(*),
       sum(cost)
FROM ticket
GROUP BY flight_id;

SELECT reltuples,
       relkind,
       relpages
FROM pg_class -- Запрос
WHERE relname = 'ticket';
-- reltuples - количество строк в таблице
-- relkind строки в таблице
-- relpages сколько страниц занимает страница на hdd

-- 8 + 6 (passenger_no) + 28 (passenger_name) + 8 + 2 (seat_no) + 8 = 60 байт - размер каждой строчки на диске

SELECT avg(bit_length(passenger_no) / 8), -- узнаем количество байт
       avg(bit_length(passenger_name) / 8),
       avg(bit_length(seat_no) / 8)
FROM ticket;

EXPLAIN
SELECT * -- Не оптимально
FROM ticket
WHERE id = 25;

CREATE TABLE test_1
(
    id      SERIAL PRIMARY KEY,
    number1 INT         NOT NULL,
    number2 INT         NOT NULL,
    value   VARCHAR(32) NOT NULL
);

INSERT INTO test_1 (number1, number2, value)
SELECT random() * generate_series,
       random() * generate_series,
       generate_series
FROM generate_series(1, 100000);

CREATE INDEX test_1_number1_idx
    ON test_1 (number1);

CREATE INDEX test_1_number2_idx
    ON test_1 (number2);

SELECT relname,
       reltuples,
       relkind,
       relpages
FROM pg_class -- Запрос
WHERE relname LIKE 'test_1%';

ANALYSE test_1; -- Анализ статистики

EXPLAIN ANALYSE -- ANALYSE - так же выполняет сам запрос
SELECT number1
FROM test_1
WHERE number1 = 1000
  AND value = '24234';
-- При OR используется фул скан

-- index only scan - не требует запрос на таблицу и сразу возвращает поля из индекса (самый лучший)
-- index scan - несколько операций считывания для возвращений нескольких операций из селекта

-- bitmap scan -- (index scan, heap scan) -- index_scan использует для определения количество страниц
-- оптимизируем и делаем считывание

-- 0 1 0 0 1 0 1 1 0 0 0 ... 636 times
-- 2 5 7 8

-- 0 1 0 0 1 0 1 1 0 0 0 ... 636 times
-- 0 0 0 1 1 0 0 1 0 0 0 ... 636 times

-- 0 1 0 1 1 0 1 1 0 0 0 ... 636 times OR
-- 0 0 0 0 1 0 0 1 0 0 0 ... 636 times AND

CREATE TABLE test_2
(
    id       SERIAL PRIMARY KEY,
    test1_id INT REFERENCES test_1 (id) NOT NULL,
    number1  INT                        NOT NULL,
    number2  INT                        NOT NULL,
    value    VARCHAR(32)                NOT NULL
);

INSERT INTO test_2 (test1_id, number1, number2, value)
SELECT id,
       random() * number1,
       random() * number2,
       value
FROM test_1;

CREATE INDEX test_2_number1_idx
    ON test_2 (number1);

CREATE INDEX test_2_number2_idx
    ON test_2 (number2);

CREATE INDEX test_2_test1_id_idx
    ON test_2 (test1_id);

EXPLAIN ANALYSE
SELECT *
FROM test_1 t1
         JOIN test_2 t2
              ON t1.id = t2.test1_id;

-- nested loop -- используется когда не много записей когда есть ограничение (LIMIT 100)
-- hash join -- без ограничения полностью сканирует одну таблицу а на основании второй таблицы создает хэш таблицу
-- merge join -- (лучший) используется после сортировки

-- before

INSERT INTO aircraft (model)
VALUES ('new model');

-- after

CREATE TABLE audit
(
    id         INT,
    table_name TEXT,
    date       TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_function() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
begin
    INSERT INTO audit(id, table_name, date) VALUES (new.id, tg_table_name, now());
    RETURN null;
end;
$$;

CREATE TRIGGER audit_aircraft_trigger
    AFTER UPDATE OR INSERT OR DELETE
    ON aircraft
    FOR EACH ROW
EXECUTE FUNCTION audit_function();

INSERT INTO aircraft (model)
VALUES ('новый боинг');

SELECT *
FROM audit;