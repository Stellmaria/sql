-- Library assignment solution.
-- Tasks 1-3 (schema and seed data) are implemented by:
-- src/main/resources/db/migration/V1__library_schema_and_data.sql

-- Task 4. Books with publication year and author, ascending by year.
SELECT b.name,
       b.year,
       concat(a.first_name, ' ', a.last_name) AS author
FROM book b
         JOIN author a ON a.id = b.author_id
ORDER BY b.year ASC;

-- Task 4. The same result in descending order.
SELECT b.name,
       b.year,
       concat(a.first_name, ' ', a.last_name) AS author
FROM book b
         JOIN author a ON a.id = b.author_id
ORDER BY b.year DESC;

-- Task 5. Number of books written by the requested author.
SELECT count(*) AS book_count
FROM book b
         JOIN author a ON a.id = b.author_id
WHERE a.last_name = 'Роббинс';

-- Task 6. Books whose page count is above the average page count.
SELECT b.*
FROM book b
WHERE b.pages > (SELECT avg(pages) FROM book)
ORDER BY b.pages DESC;

-- Task 7. Five oldest books.
SELECT b.*
FROM book b
ORDER BY b.year ASC, b.id ASC
LIMIT 5;

-- Task 7. Total page count of the same five oldest books.
WITH oldest_books AS (
    SELECT pages
    FROM book
    ORDER BY year ASC, id ASC
    LIMIT 5
)
SELECT sum(pages) AS total_pages
FROM oldest_books;

-- Task 8. Change the page count for one book.
UPDATE book
SET pages = pages + 5
WHERE id = 2
RETURNING id, name, year, pages;

-- Task 9. Delete the author who wrote the largest book.
-- The target author is derived from the data instead of being hard-coded.
WITH target_author AS (
    SELECT author_id
    FROM book
    ORDER BY pages DESC, id ASC
    LIMIT 1
),
deleted_books AS (
    DELETE FROM book b
        USING target_author ta
        WHERE b.author_id = ta.author_id
        RETURNING b.author_id
)
DELETE FROM author a
    USING (SELECT DISTINCT author_id FROM deleted_books) d
WHERE a.id = d.author_id
RETURNING a.*;
