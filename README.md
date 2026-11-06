# ICN292 · Laboratorio 4: Entregable SQL

**Estudiante:** Igor Rios · **Fecha:** noviembre de 2026
**Curso:** ICN-292 Sistemas de Información para la Gestión · Segundo Semestre 2026 · Campus Vitacura

Reconstrucción de la base de datos `austral` de Austral Editores en MySQL 8. El script crea las cuatro tablas (`autores`, `libros`, `colecciones` y `pagos`) con sus claves primarias y foráneas, carga los datos oficiales y ejecuta las diez consultas pedidas.

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `ICN292-Lab4-Rios-Igor.pdf` | Informe: portada y las 10 consultas, cada una con su código y su captura |
| `ICN292-Lab4-Rios-Igor.docx` | El mismo informe en Word |
| `ICN292-Lab4-Rios-Igor.sql` | Script completo: creación de tablas, carga oficial y consultas 1 a 10 |
| `ICN292-Lab4-Rios-Igor-diagrama.png` | Modelo entidad–relación obtenido con *Database > Reverse Engineer* |

## Cómo reproducir

Probado en **MySQL Server 8.0** con **MySQL Workbench 8.0**.

1. Abrir MySQL Workbench y conectarse a la instancia local.
2. Abrir el script con *File → Open SQL Script* y elegir `ICN292-Lab4-Rios-Igor.sql`.
3. Ejecutar el script completo con *Query → Execute (All or Selection)* (`Ctrl + Shift + Enter`). El script empieza con `DROP DATABASE IF EXISTS austral;`, así que se puede correr varias veces desde cero.
4. Revisar los resultados en las pestañas de *Result Grid*. Las consultas 1 a 6 se ejecutan antes que las modificaciones 7 y 8.
5. Para ver el diagrama: *Database → Reverse Engineer…*, elegir la base `austral` y terminar el asistente.

**Nota:** el script incluye `SET SQL_SAFE_UPDATES = 0;` antes de las consultas 7 y 8, porque el modo seguro de Workbench no permite `UPDATE` ni `DELETE` filtrando por título. Al final se vuelve a activar.
