-- Lista el nombre de la ciudad, nombre del país, región 
-- y forma de gobierno de las 10 ciudades más pobladas del mundo.
SELECT co.name,region,governmentForm, ci.population, ci.name
FROM country AS co
INNER JOIN city AS ci ON co.code = ci.countryCode
ORDER BY ci.population DESC
LIMIT 10 ;

-- Listar los 10 países con menor población del mundo, junto a sus ciudades capitales
SELECT co.name, ci.name, co.capital
FROM country AS co
LEFT JOIN city AS ci ON co.code = ci.countryCode AND co.capital = ci.id
ORDER BY co.population
LIMIT 10 ;

-- Listar el nombre, continente y todos los lenguajes oficiales de cada país. 
--(Hint: habrá más de una fila por país si tiene varios idiomas oficiales).

SELECT co.name, co.continent, cl.language
FROM countrylanguage AS cl
INNER JOIN country AS co ON cl.countryCode = co.code AND cl.isOfficial = "T";

-- Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.

SELECT co.name, ci.name 
FROM country AS co
INNER JOIN city AS ci ON ci.id = co.capital 
ORDER BY surfaceArea DESC
LIMIT 20; 

-- Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) 
-- y el porcentaje de hablantes del idioma.

SELECT ci.name, cl.language
FROM city AS ci
INNER JOIN country AS co ON ci.countryCode = co.code
INNER JOIN countrylanguage AS cl ON cl.countryCode = co.code AND cl.isOfficial = "T"
ORDER BY ci.population DESC, cl.percentage DESC;   

-- Listar los 10 países con mayor población y los 10 países con menor población
-- (que tengan al menos 100 habitantes) en la misma consulta.

(SELECT name,population FROM country
WHERE country.population >= 100 
ORDER BY population DESC
LIMIT 10)
UNION ALL
(SELECT name,population FROM country
WHERE country.population >= 100 
ORDER BY population
LIMIT 10);

-- Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
(
    SELECT co.name
    FROM countrylanguage AS cl
    INNER JOIN country AS co ON co.code = cl.countryCode
    WHERE cl.isOfficial = 'T' AND cl.language = 'English')
INTERSECT
(
    SELECT co.name
    FROM countrylanguage AS cl
    INNER JOIN country AS co ON co.code = cl.countryCode
    WHERE cl.isOfficial = 'T' AND cl.language = 'French'
);

--Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
(
    SELECT co.name
    FROM countrylanguage AS cl
    INNER JOIN country AS co ON co.code = cl.countryCode
    WHERE cl.language = 'English'
)
EXCEPT
(
    SELECT co.name
    FROM countrylanguage AS cl
    INNER JOIN country AS co ON co.code = cl.countryCode
    WHERE cl.language = 'Spanish'
);


-- explicar si esto funciona igual, por qué?
SELECT city.Name, country.Name
FROM city
INNER JOIN country ON city.CountryCode = country.Code AND country.Name = 'Argentina';

SELECT city.Name, country.Name
FROM city
INNER JOIN country ON city.CountryCode = country.Code
WHERE country.Name = 'Argentina';

-- Creo que son iguales porque es lo mismo, traer toda la data y filtrarla por argentina, que filtrar la data por arg y traerla
-- por lo menos en el inner join, ya que como traer la parte central

-- y si en vez de un inner join fuer un left join
-- En el caso de LEFT JOIN si afecta ya que lo que esta en el ON si afecta a la union de las tablas, cambia para el lado
-- si a la izq o derecha, el where afecta al filtrado luego de juntar, podria tener filas nulas :)



