-- Airport assignment solution.
-- Schema and seed data are implemented by:
-- src/main/resources/db/migration/V2__airport_schema_and_data.sql

-- 1. Who flew the day before yesterday from Minsk (MNK) to London (LDN) in seat B1?
SELECT t.passenger_no,
       t.passenger_name,
       f.flight_no,
       t.seat_no
FROM ticket t
         JOIN flight f ON f.id = t.flight_id
WHERE t.seat_no = 'B1'
  AND f.departure_airport_code = 'MNK'
  AND f.arrival_airport_code = 'LDN'
  AND f.departure_date::DATE = (CURRENT_DATE - INTERVAL '2 days')::DATE;

-- 2. How many seats were free on 2020-06-14 on flight MN3002?
WITH selected_flight AS (
    SELECT id, aircraft_id
    FROM flight
    WHERE flight_no = 'MN3002'
      AND departure_date::DATE = DATE '2020-06-14'
    ORDER BY departure_date
    LIMIT 1
)
SELECT count(*) FILTER (WHERE t.id IS NULL) AS free_seats
FROM selected_flight f
         JOIN seat s ON s.aircraft_id = f.aircraft_id
         LEFT JOIN ticket t
                   ON t.flight_id = f.id
                       AND t.seat_no = s.seat_no;

-- 3. The two longest flights.
SELECT id,
       flight_no,
       departure_airport_code,
       arrival_airport_code,
       arrival_date - departure_date AS duration
FROM flight
ORDER BY duration DESC
LIMIT 2;

-- 4. Maximum/minimum duration and total number of flights between Minsk and London in both directions.
SELECT max(arrival_date - departure_date) AS max_duration,
       min(arrival_date - departure_date) AS min_duration,
       count(*) AS flight_count
FROM flight
WHERE (departure_airport_code = 'MNK' AND arrival_airport_code = 'LDN')
   OR (departure_airport_code = 'LDN' AND arrival_airport_code = 'MNK');

-- 5. Most common first names and their share of all passenger records.
WITH passenger_first_names AS (
    SELECT split_part(passenger_name, ' ', 1) AS first_name
    FROM ticket
),
name_counts AS (
    SELECT first_name,
           count(*) AS occurrences
    FROM passenger_first_names
    GROUP BY first_name
)
SELECT first_name,
       occurrences,
       round(100.0 * occurrences / (SELECT count(*) FROM passenger_first_names), 2) AS percentage
FROM name_counts
ORDER BY occurrences DESC, first_name;

-- 6. Tickets bought by passengers with each first name, and the difference from the leading first name.
WITH name_counts AS (
    SELECT split_part(passenger_name, ' ', 1) AS first_name,
           count(*) AS ticket_count
    FROM ticket
    GROUP BY split_part(passenger_name, ' ', 1)
)
SELECT first_name,
       ticket_count,
       max(ticket_count) OVER () - ticket_count AS behind_leader
FROM name_counts
ORDER BY ticket_count DESC, first_name;

-- 7. Total ticket revenue for every directional route, descending by revenue.
-- Also show the differences to the neighboring routes in the sorted list.
WITH route_costs AS (
    SELECT f.departure_airport_code,
           f.arrival_airport_code,
           sum(t.cost) AS total_cost
    FROM ticket t
             JOIN flight f ON f.id = t.flight_id
    GROUP BY f.departure_airport_code, f.arrival_airport_code
),
ranked_routes AS (
    SELECT route_costs.*,
           lag(total_cost) OVER (ORDER BY total_cost DESC) AS previous_cost,
           lead(total_cost) OVER (ORDER BY total_cost DESC) AS next_cost
    FROM route_costs
)
SELECT departure_airport_code,
       arrival_airport_code,
       total_cost,
       previous_cost - total_cost AS difference_to_previous,
       total_cost - next_cost AS difference_to_next
FROM ranked_routes
ORDER BY total_cost DESC;
