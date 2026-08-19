DO
$$
DECLARE
    oldest_pages       BIGINT;
    free_seats         BIGINT;
    longest_ids        BIGINT[];
    min_duration       INTERVAL;
    max_duration       INTERVAL;
    minsk_london_count BIGINT;
    ivan_count         BIGINT;
BEGIN
    -- Library assignment checks after 16sql.sql has been executed.
    IF (SELECT count(*) FROM author) <> 4 THEN
        RAISE EXCEPTION 'Expected 4 authors after deleting the author of the largest book';
    END IF;

    IF EXISTS (SELECT 1 FROM author WHERE last_name = 'Хорстманн') THEN
        RAISE EXCEPTION 'The author of the largest book should have been deleted';
    END IF;

    IF (SELECT count(*) FROM book) <> 8 THEN
        RAISE EXCEPTION 'Expected 8 books after deleting the target author books';
    END IF;

    SELECT sum(pages)
    INTO oldest_pages
    FROM (
             SELECT pages
             FROM book
             ORDER BY year ASC, id ASC
             LIMIT 5
         ) oldest;

    IF oldest_pages <> 2028 THEN
        RAISE EXCEPTION 'Unexpected page total for five oldest books: %', oldest_pages;
    END IF;

    IF (SELECT count(*)
        FROM book b
                 JOIN author a ON a.id = b.author_id
        WHERE a.last_name = 'Роббинс') <> 2 THEN
        RAISE EXCEPTION 'Expected two books for Роббинс';
    END IF;

    -- Airport schema constraints.
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'aircraft_model_uk') THEN
        RAISE EXCEPTION 'aircraft.model must be unique';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'flight_status_chk') THEN
        RAISE EXCEPTION 'flight.status check constraint is missing';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ticket_flight_seat_uk') THEN
        RAISE EXCEPTION 'ticket flight/seat uniqueness constraint is missing';
    END IF;

    IF EXISTS (SELECT 1 FROM flight WHERE arrival_date <= departure_date) THEN
        RAISE EXCEPTION 'All seeded flights must arrive after departure';
    END IF;

    -- Airport query checks.
    WITH selected_flight AS (
        SELECT id, aircraft_id
        FROM flight
        WHERE flight_no = 'MN3002'
          AND departure_date::DATE = DATE '2020-06-14'
        LIMIT 1
    )
    SELECT count(*) FILTER (WHERE t.id IS NULL)
    INTO free_seats
    FROM selected_flight f
             JOIN seat s ON s.aircraft_id = f.aircraft_id
             LEFT JOIN ticket t ON t.flight_id = f.id AND t.seat_no = s.seat_no;

    IF free_seats <> 2 THEN
        RAISE EXCEPTION 'Expected 2 free seats on MN3002, got %', free_seats;
    END IF;

    SELECT array_agg(id ORDER BY duration DESC)
    INTO longest_ids
    FROM (
             SELECT id, arrival_date - departure_date AS duration
             FROM flight
             ORDER BY duration DESC
             LIMIT 2
         ) longest;

    IF longest_ids <> ARRAY[6::BIGINT, 5::BIGINT] THEN
        RAISE EXCEPTION 'Unexpected longest flights: %', longest_ids;
    END IF;

    SELECT min(arrival_date - departure_date),
           max(arrival_date - departure_date),
           count(*)
    INTO min_duration, max_duration, minsk_london_count
    FROM flight
    WHERE (departure_airport_code = 'MNK' AND arrival_airport_code = 'LDN')
       OR (departure_airport_code = 'LDN' AND arrival_airport_code = 'MNK');

    IF min_duration <> INTERVAL '3 hours 11 minutes'
        OR max_duration <> INTERVAL '3 hours 45 minutes'
        OR minsk_london_count <> 5 THEN
        RAISE EXCEPTION 'Unexpected Minsk/London flight statistics: min %, max %, count %',
            min_duration, max_duration, minsk_london_count;
    END IF;

    SELECT count(*)
    INTO ivan_count
    FROM ticket
    WHERE split_part(passenger_name, ' ', 1) = 'Иван';

    IF ivan_count <> 9 THEN
        RAISE EXCEPTION 'Expected first name Иван to occur 9 times, got %', ivan_count;
    END IF;
END
$$;
