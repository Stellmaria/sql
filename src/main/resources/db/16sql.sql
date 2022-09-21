CREATE DATABASE book_repository;

CREATE TABLE author
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL
);

CREATE TABLE book
(
    id        BIGSERIAL PRIMARY KEY,
    name      VARCHAR(128) NOT NULL,
    year      SMALLINT     NOT NULL,
    pages     SMALLINT     NOT NULL,
    author_id INT REFERENCES author (id)
);

INSERT INTO author(first_name, last_name)
VALUES ('Кей', 'Хорстманн'),
       ('Стивен', 'Кови'),
       ('Тони', 'Роббинс'),
       ('Стивен', 'Кинг'),
       ('Дейл', 'Карнеги');

SELECT *
FROM author;

INSERT INTO book(name, year, pages, author_id)
VALUES ('Java. Библиотека профессионала. Том 1', 2010, 1102, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java. Библиотека профессионала. Том 2', 2012, 954, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java SE 8. Вводный курс', 2015, 203, (SELECT id FROM author WHERE last_name = 'Кови')),
       ('7 навыков высокоэффективных людей', 1989, 396, (SELECT id FROM author WHERE last_name = 'Кови')),
       ('Разбуди в себя исполина', 1991, 576, (SELECT id FROM author WHERE last_name = 'Роббинс')),
       ('Думай и богатей', 1937, 336, (SELECT id FROM author WHERE last_name = 'Роббинс')),
       ('Богатый папа, бедный папа', 1997, 352, (SELECT id FROM author WHERE last_name = 'Кинг')),
       ('Квадрант денежного потока', 1998, 368, (SELECT id FROM author WHERE last_name = 'Кинг')),
       ('Как перестать беспокоится и начать жить', 1948, 368, (SELECT id FROM author WHERE last_name = 'Карнеги')),
       ('Как завоевывать друзей и оказывать влияние на людей', 1936, 352,
        (SELECT id FROM author WHERE last_name = 'Карнеги'));

SELECT b.name,
       b.year,
       (SELECT concat(a.first_name, ' ', a.last_name) FROM author a WHERE a.id = b.author_id)
FROM book b
ORDER BY b.year;

SELECT b.name,
       b.year,
       (SELECT concat(a.first_name, ' ', a.last_name) FROM author a WHERE a.id = b.author_id)
FROM book b
ORDER BY b.year DESC;

SELECT count(*)
FROM book
WHERE author_id IN (SELECT id FROM author WHERE last_name = 'Роббинс');

SELECT *
FROM book
WHERE pages > (SELECT avg(pages)
               FROM book);

SELECT sum(t.pages)
FROM (SELECT pages
      FROM book
      ORDER BY year
      LIMIT 5) t;

UPDATE book
SET pages = pages + 5
WHERE id = 2
RETURNING name,year,pages;

DELETE
FROM book
WHERE author_id = (SELECT author_id
                   FROM book
                   WHERE pages = (SELECT max(pages) FROM book))
RETURNING *;

DELETE
FROM author
WHERE id = 1
RETURNING *;
