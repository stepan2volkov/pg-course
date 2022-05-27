-- Сервис бронирования отелей:
-- Воронка:
-- 1. Пользователь регистрируется 
-- (потенциально отдельный сервис, здесь для упрощения введена таблица "guest")
-- 
-- 2. Пользователь получает список отелей
-- 3. Пользователь выбирает подходящий отель
-- 4. Пользователь получает список вариантов комнат
-- 5. Пользователь выбирает резервирует требуемый тип комнаты

CREATE DATABASE hotel;
CREATE USER hotel_service PASSWORD '1qaz';

-- \c hotel hotel_service

-- Содержит основную информацию по отелю
CREATE TABLE hotel (
    id          UUID,
    star_count  INTEGER NOT NULL DEFAULT 0,
    title       TEXT NOT NULL,
    address     TEXT NOT NULL,
    CONSTRAINT hotel_pk PRIMARY KEY(id),
    CONSTRAINT hotel_star_count_check CHECK (
        star_count >= 0 AND
        star_count <= 5
    )
);

-- Содержит основную информацию по типам комнат
CREATE TABLE room_type (
    id              UUID,
    hotel_id        UUID NOT NULL,
    title           TEXT NOT NULL,
    description     TEXT NOT NULL,
    CONSTRAINT room_type_pk PRIMARY KEY(id),
    CONSTRAINT room_type_hotel_fk FOREIGN KEY(hotel_id)
        REFERENCES hotel(id)
);

-- Содержит информацию о кол-ве доступных и зарезервированных мест 
-- в конкретный день
CREATE TABLE room_type_inventory (
    hotel_id            UUID,
    room_type_id        UUID,
    reservation_date    DATE,
    total_inventory     INTEGER NOT NULL,
    total_reserved      INTEGER NOT NULL,
    CONSTRAINT room_type_inventory_pk PRIMARY KEY(
        hotel_id, room_type_id, reservation_date),
    CONSTRAINT room_type_inventory_hotel_fk FOREIGN KEY(hotel_id)
        REFERENCES hotel(id),
    CONSTRAINT room_type_inventory_room_type_fk FOREIGN KEY(room_type_id)
        REFERENCES room_type(id),
    CONSTRAINT room_type_inventory_total_inventory_fk CHECK (
        total_inventory >= 0 AND
        total_inventory >= total_reserved
    ),
    CONSTRAINT room_type_inventory_total_reserved_fk CHECK (
        total_reserved >= 0 AND
        total_reserved <= total_inventory
    )
);


-- Содержит информацию о постояльце. 
-- Предположительно должна быть в отдельном микросервисе и своей базе
-- Здесь введена в качестве упрощения задачи
CREATE TABLE guest (
    id              UUID,
    first_name      TEXT NOT NULL,
    last_name       TEXT NOT NULL,
    middle_name     TEXT NOT NULL,
    email           TEXT NOT NULL,
    CONSTRAINT guest_pk PRIMARY KEY(id)
);

-- Содержит информацию о конкретном резервировании комнаты
CREATE TABLE reservation (
    id              UUID,
    hotel_id        UUID NOT NULL,
    room_type_id    UUID NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    guest_id        UUID NOT NULL,
    commentary      TEXT NOT NULL,
    CONSTRAINT reservation_pk PRIMARY KEY(id),
    CONSTRAINT reservation_hotel_fk FOREIGN KEY(hotel_id)
        REFERENCES hotel(id),
    CONSTRAINT reservation_room_type_fk FOREIGN KEY(room_type_id)
        REFERENCES room_type(id),
    CONSTRAINT reservation_guest_fk FOREIGN KEY(guest_id)
        REFERENCES guest(id),
    CONSTRAINT reservation_date_fk CHECK (
        start_date <= end_date
    )
);

-- Пример запроса на вставку:
-- 
-- INSERT INTO hotel (id, star_count, title, address) VALUES
--     (
--         '40e6215d-b5c6-4896-987c-f30f3678f608', 
--         3, 
--         'ibis Москва Киевская',
--         'ул. Киевская, 2, Москва, Россия'
--     ''),
--     (
--         '6ecd8c99-4036-403d-bf84-cf8400f67836', 
--         4,
--         'Эрмитаж',
--         'Дурасовский переулок, 7, Москва, Россия'
--     ),
--     (
--         '3f333df6-90a4-4fda-8dd3-9485d27cee36', 
--         5,
--         'Hilton Москва Ленинградская',
--         'Каланчевская улица, 21/40, Москва, Россия'
--     );

-- Таблицы в базе:
-- 
-- \dt
--                   List of relations
--  Schema |        Name         | Type  |     Owner     
-- --------+---------------------+-------+---------------
--  public | guest               | table | hotel_service
--  public | hotel               | table | hotel_service
--  public | reservation         | table | hotel_service
--  public | room_type           | table | hotel_service
--  public | room_type_inventory | table | hotel_service

-- Индексы в базе:
-- 
-- \di
--                                List of relations
--  Schema |          Name          | Type  |     Owner     |        Table        
-- --------+------------------------+-------+---------------+---------------------
--  public | guest_pk               | index | hotel_service | guest
--  public | hotel_pk               | index | hotel_service | hotel
--  public | reservation_pk         | index | hotel_service | reservation
--  public | room_type_inventory_pk | index | hotel_service | room_type_inventory
--  public | room_type_pk           | index | hotel_service | room_type
