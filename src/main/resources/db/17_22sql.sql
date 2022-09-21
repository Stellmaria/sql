SELECT company.name, -- Старый способ соединения запросов
       employee.first_name || ' ' || employee.last_name fio
FROM employee,
     company
WHERE employee.company_id = company.id;

-- INNER JOIN == JOIN (отсекает NULL)
-- CROSS JOIN
-- LEFT OUTER JOIN == LEFT JOIN (все записи таблицы слева должны быть)
-- RIGHT OUTER JOIN == RIGHT JOIN (все записи таблицы справа должны быть)
-- FULL OUTER JOIN == FULL JOIN

SELECT c.name,
       employee.first_name || ' ' || employee.last_name fio
FROM employee
         JOIN company c
              ON employee.company_id = c.id;

-- SELECT c.name,
--        employee.first_name || ' ' || employee.last_name fio
--        ec.contact_id,
--        c2.number
-- FROM employee
--          JOIN company c
--               ON employee.company_id = c.id;
--          JOIN employee_contact ec
--               ON employee.id = ec.employee_id
--          JOIN contact c2
--               ON ec.contact_id = c2.id;

SELECT * -- Используется редко
FROM employee
         CROSS JOIN company;

SELECT *
FROM company
         CROSS JOIN (SELECT count(*) FROM employee) t;

SELECT c.name,
       e.first_name
FROM company c
         LEFT JOIN employee e
                   ON c.id = e.company_id;

SELECT c.name,
       e.first_name
FROM employee e
         LEFT JOIN company c
                   ON e.company_id = c.id;

SELECT c.name,
       e.first_name
FROM company c
         RIGHT JOIN employee e
                    ON c.id = e.company_id;

SELECT c.name,
       e.first_name
FROM employee e
         RIGHT JOIN company c
                    ON e.company_id = c.id
                        AND c.date > '2001-01-01';

SELECT c.name,
       e.first_name
FROM employee e
         FULL JOIN company c
                   ON e.company_id = c.id;

SELECT c.name,
       e.first_name
FROM employee e
         CROSS JOIN company c;

SELECT company.name, -- Группировка запросов || Выводит все компании и количество сотрудников в компании
       count(e.id)
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
-- WHERE company.name = 'Google' -- Для каждой из строки в запросе
GROUP BY company.id
HAVING count(e.id) > 0; -- Отсекаем компании без сотрудников (после группировки)

SELECT count(*) -- Количество компаний
FROM company;

SELECT count(*) -- Количество сотрудников в компании || если использовать count(*) то посчитается и NULL
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
WHERE company.name = 'Facebook';

SELECT company.name,
       e.last_name
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
WHERE company.name = 'Facebook';

SELECT count(e.last_name) -- Best practice делать счетчик на поле
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
WHERE company.name = 'Facebook'; -- Выведет только количество сотрудников

SELECT company.name,
       count(e.last_name) -- Best practice делать счетчик на поле
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
-- WHERE company.name = 'Facebook' -- C GROUP BY можно убрать WHERE И отобразятся все компании и количество сотрудников
-- GROUP BY company.name; -- Выведет и количество сотрудников и название компании
GROUP BY company.id; -- Лучше по id

SELECT company.name,
       e.last_name
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
ORDER BY company.name;

-- CREATE VIEW employee_view AS -- Не кэшируется
-- CREATE MATERIALIZED VIEW m_employee AS -- Кэшируется -- REFRESH MATERIALIZED VIEW - обновление
-- SELECT company.name,
--        e.first_name,
--        e.salary,
--        count(e.id) OVER (),                                           -- Оконная функция
--        max(e.salary) OVER (PARTITION BY company.name),
--        avg(e.salary) OVER (PARTITION BY company.name),
--        row_number() OVER (PARTITION BY company.name),
--        rank() OVER (ORDER BY salary NULLS LAST),-- Сортировка NULL в конце
--        dense_rank()
--        OVER (PARTITION BY company.name ORDER BY e.salary NULLS LAST), -- Нумерация зарплат ограничивается компанией
--        lag(e.salary) OVER (ORDER BY e.salary) - e.salary
-- FROM company
--          LEFT JOIN employee e
--                    ON company.id = e.company_id
-- ORDER BY company.name;

-- SELECT *
-- FROM employee_view
-- WHERE name = 'Facebook';


