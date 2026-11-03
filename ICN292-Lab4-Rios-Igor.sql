DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;

-- =====================================================================
-- ICN-292 Sistemas de Información para la Gestión — Laboratorio 4 (SQL)
-- Base: austral (Austral Editores)
-- Autor: Igor Rios
-- =====================================================================


-- =====================================================================
-- ENTREGABLE 1: CREACIÓN DE LAS TABLAS
-- Primero se crean las cuatro tablas y después se agregan las
-- claves foráneas con ALTER TABLE.
-- =====================================================================

-- Autores de la editorial
CREATE TABLE autores (
    id_autor  INT          NOT NULL AUTO_INCREMENT,
    nombre    VARCHAR(80)  NOT NULL,
    pais      VARCHAR(60)  NULL,           -- puede quedar vacío (NULL)
    genero    ENUM('Cómic', 'Ensayo', 'Infantil', 'Novela', 'Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Colecciones (tabla que faltaba; la necesita la consulta 9)
CREATE TABLE colecciones (
    id_coleccion       INT          NOT NULL AUTO_INCREMENT,
    titulo             VARCHAR(120) NOT NULL,
    fecha_publicacion  DATE         NOT NULL,
    PRIMARY KEY (id_coleccion)
);

-- Libros: cada libro tiene un solo autor y pertenece a una sola colección
CREATE TABLE libros (
    id_libro             INT          NOT NULL AUTO_INCREMENT,
    id_autor             INT          NOT NULL,
    id_coleccion         INT          NULL,  -- la carga oficial no trae colecciones
    titulo               VARCHAR(120) NOT NULL,
    paginas              INT,
    ejemplares_vendidos  INT,
    anio                 INT,
    PRIMARY KEY (id_libro)
);

-- Pagos a los autores (tabla que faltaba; la necesita la consulta 10)
CREATE TABLE pagos (
    id_pago     INT            NOT NULL AUTO_INCREMENT,
    id_autor    INT            NOT NULL,
    fecha_pago  DATE           NOT NULL,
    monto       DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (id_pago)
);

-- Relaciones (claves foráneas), igual que en la Sesión 08
ALTER TABLE libros
    ADD CONSTRAINT fk_libros_autores
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
    ON UPDATE RESTRICT;

ALTER TABLE libros
    ADD CONSTRAINT fk_libros_colecciones
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
    ON UPDATE RESTRICT;

ALTER TABLE pagos
    ADD CONSTRAINT fk_pagos_autores
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
    ON UPDATE RESTRICT;


-- =====================================================================
-- CARGA OFICIAL
-- El id no se escribe: lo asigna AUTO_INCREMENT en el orden de la carga.
-- Por eso: 1 Elena Pizarro, 2 Harold Finch, 3 Rodrigo Bahamonde,
--          4 Valentina Correa, 5 Nora Keller, 6 Kenji Arakawa.
-- =====================================================================

INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),
    ('Harold Finch',      'Inglaterra',     'Ensayo'),
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),
    ('Valentina Correa',  'Argentina',      'Infantil'),
    ('Nora Keller',       'Estados Unidos', 'Novela'),
    ('Kenji Arakawa',     NULL,             'Cómic');

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
    (1, 'Cielo de Enero',      210, 1500, 2024),
    (1, 'Marea Baja',          185,  800, 2023),
    (1, 'El Norte',            200, 2200, 2024),
    (2, 'Estrellas que Caen',  240, 3000, 2022),
    (2, 'Máquinas',            215,  450, 2024),
    (3, 'Luz Artificial',      300, 1200, 2024),
    (3, 'Ruido Blanco',        280,  600, 2023),
    (4, 'El Barrio de Lila',   190, 5000, 2024),
    (4, 'Antes del Amanecer',  205, 2700, 2024),
    (4, 'La Calle 8',          175,  900, 2023),
    (5, 'Flor de Hierro',      195, 4100, 2024),
    (5, 'Hora Dorada',         220, 1800, 2022);


-- =====================================================================
-- ENTREGABLE 2: CONSULTAS
-- Las consultas 1 a 6 corren sobre la carga oficial (antes de la 7 y la 8).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Consulta 1: autores cuyo país no es Chile, incluido quien no tiene país
-- ---------------------------------------------------------------------
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- ---------------------------------------------------------------------
-- Consulta 2: libros entre 190 y 220 páginas (incluidos ambos valores)
-- ---------------------------------------------------------------------
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas ASC;

-- ---------------------------------------------------------------------
-- Consulta 3: resumen del catálogo en una sola fila
-- ---------------------------------------------------------------------
SELECT COUNT(*)                 AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares_vendidos,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares_un_libro
FROM libros;

-- ---------------------------------------------------------------------
-- Consulta 4: géneros distintos, una vez cada uno, en orden alfabético
-- ---------------------------------------------------------------------
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- ---------------------------------------------------------------------
-- Consulta 5: autores con más de un libro publicado en 2024
-- ---------------------------------------------------------------------
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores AS a
JOIN libros  AS l ON a.id_autor = l.id_autor
WHERE l.anio = 2024
GROUP BY a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- ---------------------------------------------------------------------
-- Consulta 6: los tres libros de 2024 con más de 2000 ejemplares vendidos
-- ---------------------------------------------------------------------
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;


-- MySQL Workbench trae activado el "modo seguro" (safe updates), que no
-- deja hacer UPDATE ni DELETE filtrando por una columna que no es la clave
-- (aquí filtramos por titulo). Se apaga solo mientras se modifican datos.
SET SQL_SAFE_UPDATES = 0;

-- ---------------------------------------------------------------------
-- Consulta 7: insertar 'Papel Mojado' y luego eliminarlo
-- ---------------------------------------------------------------------
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);   -- 3 = Rodrigo Bahamonde

-- SELECT previo: la fila que se va a borrar
SELECT *
FROM libros
WHERE titulo = 'Papel Mojado';

DELETE FROM libros
WHERE titulo = 'Papel Mojado';

-- SELECT posterior: ya no debe aparecer ninguna fila
SELECT *
FROM libros
WHERE titulo = 'Papel Mojado';

-- ---------------------------------------------------------------------
-- Consulta 8: sumar 100 ejemplares vendidos a 'Cielo de Enero'
-- ---------------------------------------------------------------------
-- SELECT previo (debe mostrar 1500)
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- El valor nuevo se calcula a partir del actual
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

-- SELECT posterior (debe mostrar 1600)
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- ---------------------------------------------------------------------
-- Consulta 9: cada libro con su colección y la fecha de la colección
-- ---------------------------------------------------------------------
-- Filas de prueba: tres colecciones
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Narrativa Austral',   '2022-03-15'),   -- id 1
    ('Pensamiento y Verso', '2023-08-01'),   -- id 2
    ('Austral Joven',       '2024-04-23');   -- id 3

-- Se asignan los doce libros a una colección
UPDATE libros SET id_coleccion = 1 WHERE id_autor IN (1, 5);  -- Pizarro y Keller (novela)
UPDATE libros SET id_coleccion = 2 WHERE id_autor IN (2, 3);  -- Finch y Bahamonde (ensayo y poesía)
UPDATE libros SET id_coleccion = 3 WHERE id_autor = 4;        -- Correa (infantil)

-- Se vuelve a activar el modo seguro
SET SQL_SAFE_UPDATES = 1;

SELECT l.titulo            AS libro,
       c.titulo            AS coleccion,
       c.fecha_publicacion AS fecha_publicacion
FROM libros      AS l
JOIN colecciones AS c ON l.id_coleccion = c.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- ---------------------------------------------------------------------
-- Consulta 10: pagos a los autores (dos sentencias)
-- ---------------------------------------------------------------------
-- Filas de prueba: cuatro pagos, dos de ellos a Harold Finch
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (2, '2026-03-31', 350000.00),   -- Harold Finch
    (2, '2026-06-30', 420500.50),   -- Harold Finch
    (4, '2026-04-15', 780000.00),   -- Valentina Correa
    (5, '2026-05-20', 615250.75);   -- Nora Keller

-- 10a: lista de pagos con el nombre del autor
SELECT a.nombre AS autor,
       p.fecha_pago,
       p.monto
FROM pagos   AS p
JOIN autores AS a ON p.id_autor = a.id_autor
ORDER BY p.fecha_pago;

-- 10b: total pagado a cada autor
SELECT a.nombre     AS autor,
       SUM(p.monto) AS total_pagado
FROM pagos   AS p
JOIN autores AS a ON p.id_autor = a.id_autor
GROUP BY a.nombre
ORDER BY a.nombre;
