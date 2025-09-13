-- Listar el nombre de la ciudad y el nombre del país de todas las ciudades
-- que pertenezcan a países con una población menor a 10000 habitantes.

SELECT co.name, ci.name
FROM country AS co
    INNER JOIN city AS ci ON co.code = ci.countryCode
    AND co.population < 10000;

-- Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.

/* SELECT city.name, avg.avg_population FROM (
SELECT avg(population) as avg_population FROM city
) as avg WHERE population > av_population */

--opcion1
SELECT city.name, city.population, avg.avg_population
FROM city, (
        SELECT avg(population) as avg_population
        FROM city
    ) as avg
WHERE
    city.population > avg.avg_population;

--opcion2
WITH
    avg_pop (value) AS (
        SELECT avg(population)
        FROM city
    )
SELECT name, population
FROM city, avg_pop
WHERE
    population > avg_pop.value;

--Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.

SELECT name, population
FROM city as ci
WHERE
    ci.countryCode NOT IN(
        SELECT code
        FROM country
        WHERE
            continent = "Asia"
    )
    AND ci.population >= SOME (
        SELECT population
        FROM country as co
        WHERE
            co.continent = "Asia"
    );

-- Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes
-- a cada uno de los idiomas oficiales del país.

SELECT name, language
FROM
    countrylanguage
    INNER JOIN country ON countryCode = country.code
WHERE
    isOfficial = "F"
    AND percentage > ALL (
        SELECT percentage
        FROM countrylanguage AS cl
        WHERE
            isOfficial = "T"
            AND cl.countryCode = country.code
    );

-- Listar (sin duplicados) aquellas regiones que tengan países con una superficie
-- menor a 1000 km2 y exista (en el país) al menos una ciudad con más de 100000 habitantes.
--(Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).

-- con subquery

-- DISTINCT = sin duplicados
-- SELECT 1 -> al exist no le importa los datos, sino, que haya al menos una fila
SELECT DISTINCT
    region
FROM country as co
WHERE
    surfaceArea < 1000
    AND EXISTS (
        SELECT 1
        FROM city AS ci
        WHERE
            ci.population > 100000
            AND co.code = ci.countryCode
    );

-- sin subquery
SELECT DISTINCT
    region
FROM country as co
    INNER JOIN city AS ci ON co.code = ci.countryCode
WHERE
    co.surfaceArea < 1000
    AND ci.population > 100000
GROUP BY
    region;

-- Recordar: el group by debe ser el mismo del select

/* Listar el nombre de cada país con la cantidad de habitantes de su ciudad más
poblada. (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas 
escalares o usando agrupaciones, encontrar ambas). */

-- usando escalar
SELECT co.name, (
        SELECT MAX(population)
        FROM city ci
        WHERE
            co.code = ci.countryCode
    ) AS max_population_city
FROM country co;

-- usando agrupaciones
SELECT co.name, Max(ci.population) AS max_population_city
from country co
    LEFT JOIN city ci ON co.code = ci.countryCode
GROUP BY
    co.name;

-- LEFT O INNER SUPONGO QUE ES CUESTION DE DISEÑO

/* Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de 
hablantes sea mayor al promedio de hablantes de los lenguajes oficiales. */

SELECT
    co.name AS country_name,
    cl.language AS non_official_language,
    cl.percentage AS non_official_percentage
FROM
    country AS co
    JOIN countrylanguage AS cl ON co.code = cl.countryCode
WHERE
    cl.isOfficial = 'F'
    AND cl.percentage > (
        SELECT AVG(cl2.percentage)
        FROM countrylanguage AS cl2
        WHERE
            cl2.countryCode = co.code
            AND cl2.isOfficial = 'T'
    );

/* Listar la cantidad de habitantes por continente ordenado en forma descendente. */

SELECT c.name, SUM(co.population)
FROM continent c
    INNER JOIN country co ON co.continent = c.name
GROUP BY
    c.name
ORDER BY SUM(co.population) DESC

/* Listar el promedio de esperanza de vida (LifeExpectancy) por continente con 
una esperanza de vida entre 40 y 70 años. */

SELECT continent, avg(lifeExpectancy) AS avg_life
FROM country
GROUP BY
    continent
HAVING
    avg_life BETWEEN 40 AND 70;

/* Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente. */

SELECT continent, MAX(population), MIN(population), AVG(population), SUM(population)
FROM country
GROUP BY
    continent
ORDER BY MAX(population) DESC;