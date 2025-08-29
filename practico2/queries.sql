use world;

DROP Table country;
DROP TABLE countrylanguage;
drop TABLE city;
drop TABLE continent;

create TABLE country (
    code varchar(3) primary key,
    name varchar(100),
    continent varchar(100),
    region varchar(100),
    surfaceArea int,
    indepYear int,
    population int,
    lifeExpectancy int,
    gnp int,
    gnpOld int,
    localName varchar(100),
    governmentForm varchar(100),
    headOfState varchar(100),
    capital int,
    code2 varchar(100)
);

create TABLE countrylanguage (
    countryCode varchar(32),
    language varchar(32),
    isOfficial varchar(32),
    percentage float,
    primary key (countryCode, language),
    foreign key (countryCode) references country (code)
);

create TABLE city (
    id int primary key,
    name varchar(100),
    countryCode varchar(100),
    district varchar(100),
    population int,
    foreign key (countryCode) references country (code)
);

CREATE TABLE continent (
    name VARCHAR(100) PRIMARY KEY,
    area BIGINT,
    percent_total_mass FLOAT,
    most_populous_city_id INT UNIQUE,
    CONSTRAINT fk_city FOREIGN KEY (most_populous_city_id) REFERENCES city(id)
);

INSERT INTO continent (name, area, percent_total_mass, most_populous_city_id) VALUES
('Africa', 30370000, 20.4, 1),
('Antarctica', 14000000, 9.2, 2),
('Asia', 44579000, 29.5, 3),
('Europe', 10180000, 6.8, 4),
('North America', 24709000, 16.5, 5),
('Oceania', 8600000, 5.9, 6),
('South America', 17840000, 12.0, 7);

-- 6) Modificar la tabla "country" de manera que el campo "Continent" pase a ser una clave externa (o foreign key) a la tabla Continent.
ALTER TABLE country
ADD CONSTRAINT fk_country_continent
FOREIGN KEY (continent) REFERENCES continent(name);

-- Part 2 Query
--Devuelva una lista de los nombres y las regiones a las que pertenece cada país ordenada alfabéticamente.
SELECT name,region FROM country ORDER BY name,region;
--Liste el nombre y la población de las 10 ciudades más pobladas del mundo.
SELECT name,population From country
ORDER BY population DESC 
LIMIT 10;
--Liste el nombre, región, superficie y forma de gobierno de los 10 países con menor superficie.
SELECT name, region, surfaceArea, governmentForm FROM country
ORDER BY surfaceArea
LIMIT 10;
--Liste todos los países que no tienen independencia (hint: ver que define la independencia de un país en la BD).
SELECT name, indepYear FROM country
WHERE indepYear IS NULL;
--Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas declarados oficiales.
SELECT language, percentage FROM countrylanguage
WHERE isOfficial = 'T';

SELECT country.name, language, percentage FROM countrylanguage
JOIN country ON `countryCode` = country.code
WHERE isOfficial = 'T';

-- Adicionales
--Actualizar el valor de porcentaje del idioma inglés en el país con código 'AIA' a 100.0
UPDATE countrylanguage 
SET percentage = 100
WHERE countryCode = "AIA";

SELECT * FROM countrylanguage WHERE countryCode = "AIA";
--Listar las ciudades que pertenecen a Córdoba (District) dentro de Argentina.
SELECT name From city 
WHERE district = "Córdoba" AND countryCode = "ARG";
--Eliminar todas las ciudades que pertenezcan a Córdoba fuera de Argentina.
DELETE From city 
WHERE district = "Córdoba" AND countryCode != "ARG";
--Listar los países cuyo Jefe de Estado se llame John.
SELECT name, headOfState FROM country
WHERE headOfState LIKE "%John%";
--Listar los países cuya población esté entre 35 M y 45 M ordenados por población de forma descendente.
SELECT population from country
WHERE population <= 45000 AND population <= 35000
ORDER BY population; 