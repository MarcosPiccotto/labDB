use sakila;

DROP TABLE directors;

-- Crear tabla de directores
CREATE TABLE directors (
    first_name varchar(100),
    last_name varchar(100),
    num_films BIGINT,
    director_id int primary key AUTO_INCREMENT
);

-- inserte los 5 actores con mas peliculas como directores
INSERT INTO
    directors (
        first_name,
        last_name,
        num_films
    )
SELECT a.first_name, last_name, COUNT(fa.film_id) as films_count
from actor as a
    INNER JOIN film_actor as fa ON fa.actor_id = a.actor_id
GROUP BY
    a.first_name,
    a.last_name
ORDER BY films_count DESC
LIMIT 5;

SELECT * FROM directors

-- Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de
-- acuerdo a si el cliente es "premium" o no. Por defecto ningún cliente será premium.

ALTER TABLE customer ADD premium_customer varchar(1) DEFAULT 'F';

DESCRIBE customer;

-- Modifique la tabla customer. Marque con 'T' en la columna `premium_customer`
-- de los 10 clientes con mayor dinero gastado en la plataforma.

UPDATE customer AS cu
JOIN (
    SELECT customer_id
    FROM payment py
    GROUP BY
        customer_id
    ORDER BY COUNT(amount) DESC
    LIMIT 10
) top_customers ON cu.customer_id = top_customers.customer_id
SET
    cu.premium_customer = 'T';

SELECT customer_id, COUNT(amount) AS am
from payment as py
GROUP BY
    customer_id
ORDER BY am DESC
LIMIT 10;

SELECT * FROM customer where premium_customer = 'T';

-- Listar, ordenados por cantidad de películas (de mayor a menor), l
--os distintos ratings de las películas existentes (Hint: rating se refiere en
--este caso a la clasificación según edad: G, PG, R, etc).

SELECT rating, COUNT(film_id) as co
from film
GROUP BY
    rating
ORDER BY co DESC;

--¿Cuáles fueron la primera y última fecha donde hubo pagos?

SELECT min(payment_date), MAX(payment_date) FROM payment;

--Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el nombre del mes de una fecha).
SELECT MONTHNAME(payment_date) as mon, AVG(amount)
FROM payment
GROUP BY
    mon;
--Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total de alquileres).

SELECT COUNT(rental_id), cu.customer_id
FROM rental as re
    join customer as cu on re.customer_id = cu.customer_id
GROUP BY
    cu.customer_id;

SELECT a.district, COUNT(r.rental_id) AS total_rentals
FROM
    rental r
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN address a ON c.address_id = a.address_id
GROUP BY
    a.district
ORDER BY total_rentals DESC
LIMIT 10;

--Modifique la table `inventory_id` agregando una columna `stock` que sea un número
--entero y representa la cantidad de copias de una misma película que tiene determinada
--tienda. El número por defecto debería ser 5 copias.

ALTER TABLE inventory ADD stock int DEFAULT 5;

DESCRIBE inventory

UPDATE inventory i
JOIN (
    SELECT
        film_id,
        store_id,
        COUNT(*) AS total_copias
    FROM inventory
    GROUP BY
        film_id,
        store_id
) AS resumen ON i.film_id = resumen.film_id
AND i.store_id = resumen.store_id
SET
    i.stock = resumen.total_copias;

--Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro
--a la tabla rental, haga un update en la tabla `inventory` restando una copia
--al stock de la película rentada (Hint: revisar que el rental no tiene información
--directa sobre la tienda, sino sobre el cliente, que está asociado a una tienda en particular).

-- CREATE TRIGGER trigger_name trigger_time trigger_event
-- ON table_name FOR EACH ROW
-- BEGIN
-- [trigger_order]
-- trigger_body
-- END;

-- trigger_time: {BEFORE | AFTER}
-- trigger_event: {INSERT | UPDATE | DELETE}
-- trigger_order: {FOLLOWS| PRECEDES} other_trigger_name

CREATE TRIGGER update_stock AFTER INSERT 
ON rental
FOR EACH ROW
BEGIN
    UPDATE inventory AS i
    JOIN store AS s ON i.store_id = s.store_id
    JOIN customer AS c ON s.store_id = c.store_id
    SET stock = stock - 1
    WHERE NEW.customer_id = c.customer_id AND c.store_id = i.store_id;
END;

SELECT * FROM inventory WHERE inventory.store_id = 1;
--Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.
CREATE TABLE fines (
    rental_id int,
    amount decimal(10, 2),
    FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
);

--Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree
-- un registro en la tabla `fines` por cada `rental` cuya devolución (return_date)
--haya tardado más de 3 días (comparación con rental_date). El valor de la multa
--será el número de días de retraso multiplicado por 1.5.
DELIMITER CREATE

PROCEDURE check_date_and_fine () BEGIN
INSERT INTO
    fines (rental_id, amount)
SELECT r.rental_id, (
        DATEDIFF(r.return_date, r.rental_date) * 1.5
    )
FROM rental as r
WHERE
    DATEDIFF(r.return_date, r.rental_date) > 3;

END $$

CALL check_date_and_fine ();

use sakila;

select * from fines;

SELECT r.rental_id, (
        DATEDIFF(r.return_date, r.rental_date) * 1.5
    )
FROM rental as r
WHERE
    DATEDIFF(r.return_date, r.rental_date) > 3;

--Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización
--a la tabla `rental`.

CREATE ROLE employee;

GRANT INSERT , DELETE, UPDATE ON rental TO employee;

CREATE USER 'employee' @'172.17.0.1' IDENTIFIED BY '1234';

FLUSH PRIVILEGES;

--Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios sobre la BD `sakila`.
REVOKE DELETE ON rental FROM employee;

CREATE ROLE administrator;

GRANT ALL PRIVILEGES ON sakila.* to administrator;

--Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al
--otro de `administrator`.

CREATE ROLE employeeB;

CREATE ROLE employeeC;

GRANT employee TO employeeB;

GRANT administrator to employeeC;

-- instalar mysql shell y conectar al servidor MySQL
--1. Instalar mysql shell
--$ sudo apt install mysql-client

--2. Conectar al servidor mysql
--$ mysql --host 172.17.0.2 -u root -p