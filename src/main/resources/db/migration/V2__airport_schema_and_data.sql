CREATE TABLE airport
(
    code    CHAR(3) PRIMARY KEY,
    country VARCHAR(255) NOT NULL,
    city    VARCHAR(128) NOT NULL
);

CREATE TABLE aircraft
(
    id    SERIAL PRIMARY KEY,
    model VARCHAR(128) NOT NULL,
    CONSTRAINT aircraft_model_uk UNIQUE (model)
);

CREATE TABLE seat
(
    aircraft_id INT NOT NULL REFERENCES aircraft (id),
    seat_no     VARCHAR(4) NOT NULL,
    PRIMARY KEY (aircraft_id, seat_no)
);

CREATE TABLE flight
(
    id                     BIGSERIAL PRIMARY KEY,
    flight_no              VARCHAR(16) NOT NULL,
    departure_date         TIMESTAMP NOT NULL,
    departure_airport_code CHAR(3) NOT NULL REFERENCES airport (code),
    arrival_date           TIMESTAMP NOT NULL,
    arrival_airport_code   CHAR(3) NOT NULL REFERENCES airport (code),
    aircraft_id            INT NOT NULL REFERENCES aircraft (id),
    status                 VARCHAR(32) NOT NULL,
    CONSTRAINT flight_status_chk CHECK (status IN ('CANCELED', 'ARRIVED', 'DEPARTED', 'SCHEDULED')),
    CONSTRAINT flight_dates_chk CHECK (arrival_date > departure_date)
);

CREATE TABLE ticket
(
    id             BIGSERIAL PRIMARY KEY,
    passenger_no   VARCHAR(32) NOT NULL,
    passenger_name VARCHAR(128) NOT NULL,
    flight_id      BIGINT NOT NULL REFERENCES flight (id),
    seat_no        VARCHAR(4) NOT NULL,
    cost           NUMERIC(8, 2) NOT NULL,
    CONSTRAINT ticket_flight_seat_uk UNIQUE (flight_id, seat_no),
    CONSTRAINT ticket_cost_chk CHECK (cost >= 0)
);

INSERT INTO airport (code, country, city)
VALUES ('MNK', 'Беларусь', 'Минск'),
       ('LDN', 'Англия', 'Лондон'),
       ('MSK', 'Россия', 'Москва'),
       ('BSL', 'Испания', 'Барселона');

INSERT INTO aircraft (model)
VALUES ('Боинг 777-300'),
       ('Боинг 737-300'),
       ('Аэробус A320-200'),
       ('Суперджет-100');

INSERT INTO seat (aircraft_id, seat_no)
SELECT id, seat_no
FROM aircraft
         CROSS JOIN (VALUES ('A1'), ('A2'), ('B1'), ('B2'), ('C1'), ('C2'), ('D1'), ('D2')) AS s(seat_no);

INSERT INTO flight(flight_no, departure_date, departure_airport_code, arrival_date, arrival_airport_code, aircraft_id,
                   status)
VALUES ('MN3002', '2020-06-14T14:30', 'MNK', '2020-06-14T18:07', 'LDN', 1, 'ARRIVED'),
       ('MN3002', '2020-06-16T09:15', 'LDN', '2020-06-16T13:00', 'MNK', 1, 'ARRIVED'),
       ('BC2001', '2020-07-20T23:25', 'MNK', '2020-07-21T02:43', 'LDN', 2, 'ARRIVED'),
       ('BC2001', '2020-08-01T11:00', 'LDN', '2020-08-01T14:15', 'MNK', 2, 'DEPARTED'),
       ('TR3103', '2020-05-03T13:10', 'MSK', '2020-05-03T18:38', 'BSL', 3, 'ARRIVED'),
       ('TR3103', '2020-05-10T07:15', 'BSL', '2020-05-10T12:44', 'MSK', 3, 'CANCELED'),
       ('CV9827', '2020-09-09T18:00', 'MNK', '2020-09-09T19:15', 'MSK', 4, 'SCHEDULED'),
       ('CV9827', '2020-09-19T08:55', 'MSK', '2020-09-19T10:05', 'MNK', 4, 'SCHEDULED'),
       ('QS8712', '2020-12-18T03:35', 'MNK', '2020-12-18T06:46', 'LDN', 2, 'ARRIVED');

INSERT INTO ticket(passenger_no, passenger_name, flight_id, seat_no, cost)
VALUES ('112345', 'Иван Иванов', 1, 'A1', 200),
       ('898123', 'Олег Рубцов', 1, 'A2', 198),
       ('23234A', 'Петр Петро', 1, 'B1', 180),
       ('SS988D', 'Света Светикова', 1, 'B2', 175),
       ('AYASDI', 'Андрей Андреев', 1, 'C2', 175),
       ('POQ234', 'Иван Кожемякин', 1, 'D1', 160),
       ('555321', 'Екатерина Петренко', 2, 'A1', 250),
       ('QO2300', 'Иван Розмаринов', 2, 'B2', 225),
       ('9883IO', 'Иван Кожемякин', 2, 'C2', 217),
       ('123UI2', 'Андрей Буйнов', 2, 'C1', 227),
       ('SS988D', 'Света Светикова', 2, 'D2', 277),
       ('EE2344', 'Дмитрий Трусов', 3, 'A1', 300),
       ('AS23PP', 'Максим Комсомольцев', 3, 'A2', 285),
       ('322349', 'Эдуард Щеглов', 3, 'B1', 99),
       ('DL123S', 'Игорь Беркутов', 3, 'B2', 199),
       ('MVM111', 'Алексей Щербин', 3, 'C1', 299),
       ('ZZZ111', 'Денис Колобков', 3, 'C2', 230),
       ('234444', 'Иван Старовойтов', 3, 'D1', 180),
       ('LULL12', 'Людмила Бойко', 3, 'D2', 224),
       ('RT34TR', 'Степан Дор', 4, 'A1', 129),
       ('999666', 'Анастасия Шепелява', 4, 'A2', 152),
       ('234578', 'Иван Старовойтов', 4, 'B1', 140),
       ('LULL12', 'Людмила Бойко', 4, 'B2', 140),
       ('12LILI', 'Роман Дронов', 4, 'D2', 109),
       ('112233', 'Иван Иванов', 5, 'C2', 170),
       ('RT34T4', 'Лариса Ельникова', 5, 'C1', 185),
       ('DSA586', 'Лариса Привольная', 5, 'A1', 204),
       ('DSA583', 'Артур Мирный', 5, 'B1', 189),
       ('DSA581', 'Евгений Кудрявцев', 6, 'A1', 204),
       ('EE2344', 'Дмитрий Трусов', 6, 'A2', 214),
       ('AS23PP', 'Максим Комсомольцев', 6, 'B2', 176),
       ('112233', 'Иван Иванов', 6, 'B1', 135),
       ('309623', 'Татьяна Крот', 6, 'C2', 155),
       ('319623', 'Юрий Щеглов', 6, 'D1', 125),
       ('322349', 'Эдуард Щеглов', 7, 'A1', 69),
       ('D6OP4R', 'Евгения Бузова', 7, 'A2', 58),
       ('F4FDS4', 'Константин Швец', 7, 'D1', 65),
       ('D7SF45', 'Юлия Швец', 7, 'D2', 65),
       ('FG89F6', 'Никита Гавриленко', 7, 'C2', 73),
       ('4544WE', 'Анастасия Герой', 7, 'B1', 66),
       ('454876', 'Петр Петров', 7, 'C1', 80),
       ('564548', 'Андрей Андреев', 8, 'A1', 100),
       ('547988', 'Лариса Потемкина', 8, 'A2', 89),
       ('456795', 'Карл Хмелев', 8, 'B2', 79),
       ('789134', 'Жанна Мажор', 8, 'C2', 77),
       ('898656', 'Светлана Хмурая', 8, 'D2', 94),
       ('789FG6', 'Кирил Сарычев', 8, 'D1', 81),
       ('SS988D', 'Света Светикова', 9, 'A2', 222),
       ('565795', 'Андрей Желудь', 9, 'A1', 198),
       ('466876', 'Дмитрий Васнецов', 9, 'B1', 243),
       ('466579', 'Максим Гребцов', 9, 'C1', 251),
       ('112233', 'Иван Иванов', 9, 'C2', 135),
       ('454985', 'Лариса Ельникова', 9, 'B2', 217),
       ('23234A', 'Петр Петров', 9, 'D1', 189),
       ('123594', 'Полина Зверева', 9, 'D2', 234);
