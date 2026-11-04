-- Creación de la base de datos
DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;


-- =====================================================================
-- ENTREGABLE 1: CREACIÓN DE TABLAS
-- =====================================================================

-- Tabla autores
CREATE TABLE autores (
    id_autor  INT          NOT NULL AUTO_INCREMENT,
    nombre    VARCHAR(80)  NOT NULL,
    pais      VARCHAR(60)  NULL,
    genero    ENUM('Cómic', 'Ensayo', 'Infantil', 'Novela', 'Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Tabla colecciones
CREATE TABLE colecciones (
    id_coleccion       INT          NOT NULL AUTO_INCREMENT,
    titulo             VARCHAR(120) NOT NULL,
    fecha_publicacion  DATE         NOT NULL,
    PRIMARY KEY (id_coleccion)
);

-- Tabla libros
CREATE TABLE libros (
    id_libro             INT          NOT NULL AUTO_INCREMENT,
    id_autor             INT          NOT NULL,
    id_coleccion         INT          NULL,
    titulo               VARCHAR(120) NOT NULL,
    paginas              INT,
    ejemplares_vendidos  INT,
    anio                 INT,
    PRIMARY KEY (id_libro)
);

-- Tabla pagos
CREATE TABLE pagos (
    id_pago     INT            NOT NULL AUTO_INCREMENT,
    id_autor    INT            NOT NULL,
    fecha_pago  DATE           NOT NULL,
    monto       DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (id_pago)
);

-- Claves foráneas
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
-- =====================================================================

-- Carga de autores
INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),
    ('Harold Finch',      'Inglaterra',     'Ensayo'),
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),
    ('Valentina Correa',  'Argentina',      'Infantil'),
    ('Nora Keller',       'Estados Unidos', 'Novela'),
    ('Kenji Arakawa',     NULL,             'Cómic');

-- Carga de libros
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
-- =====================================================================

-- Consulta 1: autores que no son de Chile, incluido el que no tiene país
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- Consulta 2: libros entre 190 y 220 páginas
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas ASC;

-- Consulta 3: resumen del catálogo
SELECT COUNT(*)                 AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares_vendidos,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares_un_libro
FROM libros;

-- Consulta 4: géneros distintos
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- Consulta 5: autores con más de un libro en 2024
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores AS a
JOIN libros  AS l ON a.id_autor = l.id_autor
WHERE l.anio = 2024
GROUP BY a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- Consulta 6: tres libros de 2024 con más de 2000 ejemplares
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- Desactiva el modo seguro para UPDATE y DELETE
SET SQL_SAFE_UPDATES = 0;

-- Consulta 7: insertar y eliminar 'Papel Mojado'
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

-- SELECT previo
SELECT *
FROM libros
WHERE titulo = 'Papel Mojado';

-- DELETE
DELETE FROM libros
WHERE titulo = 'Papel Mojado';

-- SELECT posterior
SELECT *
FROM libros
WHERE titulo = 'Papel Mojado';

-- Consulta 8: sumar 100 ejemplares a 'Cielo de Enero'
-- SELECT previo
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- UPDATE
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

-- SELECT posterior
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- Consulta 9: libros con su colección
-- Carga de colecciones
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Narrativa Austral',   '2022-03-15'),
    ('Pensamiento y Verso', '2023-08-01'),
    ('Austral Joven',       '2024-04-23');

-- Asignación de libros a colecciones
UPDATE libros SET id_coleccion = 1 WHERE id_autor IN (1, 5);
UPDATE libros SET id_coleccion = 2 WHERE id_autor IN (2, 3);
UPDATE libros SET id_coleccion = 3 WHERE id_autor = 4;

-- Activa el modo seguro
SET SQL_SAFE_UPDATES = 1;

-- Consulta de libros y colecciones
SELECT l.titulo            AS libro,
       c.titulo            AS coleccion,
       c.fecha_publicacion AS fecha_publicacion
FROM libros      AS l
JOIN colecciones AS c ON l.id_coleccion = c.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- Consulta 10: pagos a los autores
-- Carga de pagos
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (2, '2026-03-31', 350000.00),
    (2, '2026-06-30', 420500.50),
    (4, '2026-04-15', 780000.00),
    (5, '2026-05-20', 615250.75);

-- 10a: pagos con el nombre del autor
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
