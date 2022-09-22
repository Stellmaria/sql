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