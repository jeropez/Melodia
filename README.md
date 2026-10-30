# Melodía · Modelo de datos

Trabajo Práctico 2 · Modelos de Datos · Universidad de Medellín
Jerónimo Pérez Macías y Mariana Henao Echeverri

Base de datos de Melodía, una empresa con sedes en cinco ciudades que vende instrumentos y accesorios y dicta clases de música en grupo.

## Contenido

| Archivo | Qué tiene |
|---|---|
| [docs/esquema.md](docs/esquema.md) | Las 15 tablas: columnas, tipos, restricciones, valores permitidos y notas sobre los datos |
| [docs/relaciones.md](docs/relaciones.md) | Diagrama, las 19 claves foráneas, columnas para unir tablas y caminos entre tablas |
| [docs/datos.md](docs/datos.md) | Todas las filas de prueba (161), tabla por tabla |
| [docs/vistas_y_accesos.md](docs/vistas_y_accesos.md) | Columnas de las 3 vistas, permisos de los 3 roles y los 4 usuarios |
| [sql/Perez_Henao_Evento6_Script.sql](sql/Perez_Henao_Evento6_Script.sql) | Script completo: tablas, datos, vistas y control de acceso |
| [diagrama/Perez_Henao_Evento6_Diagrama.drawio](diagrama/Perez_Henao_Evento6_Diagrama.drawio) | Diagrama relacional (abrir en draw.io) |
| [docs/Perez_Henao_Evento6_ModeloDatos.pdf](docs/Perez_Henao_Evento6_ModeloDatos.pdf) | Documento entregado |

## Cargar la base en pgAdmin

1. Crear una base de datos vacía (por ejemplo, `melodia`).
2. Abrir el Query Tool sobre esa base y ejecutar `sql/Perez_Henao_Evento6_Script.sql` completo.
3. El script se puede ejecutar varias veces: borra y vuelve a crear todo.

Requiere PostgreSQL y un usuario con permiso para crear roles (por ejemplo, `postgres`).

## Tablas

| Tabla | Tipo | Clave primaria | Filas |
|---|---|---|---|
| sede | Fuerte | id_sede | 5 |
| empleado | Fuerte | id_empleado | 10 |
| categoria | Fuerte | id_categoria | 5 |
| producto | Fuerte | id_producto | 13 |
| inventario | Asociativa (sede × producto) | id_sede, id_producto | 27 |
| cliente | Fuerte | documento | 9 |
| venta | Fuerte | id_venta | 12 |
| linea_venta | Débil (depende de venta) | id_venta, num_linea | 18 |
| instrumento | Fuerte | id_instrumento | 7 |
| instructor | Fuerte | id_instructor | 6 |
| instructor_especialidad | Unión M:N (domina) | id_instructor, id_instrumento | 10 |
| instructor_sede | Unión M:N (dicta en) | id_instructor, id_sede | 9 |
| grupo | Fuerte | id_grupo | 8 |
| alumno | Fuerte | documento | 9 |
| matricula | Asociativa (alumno × grupo) | id_matricula | 13 |

## Datos que no están en ninguna columna

Estos valores no se guardan; se obtienen a partir de otras columnas:

| Dato | Cómo se obtiene |
|---|---|
| Subtotal de una línea | linea_venta.cantidad × linea_venta.precio_unitario |
| Total de una venta | Suma de los subtotales de sus líneas |
| Cupos disponibles de un grupo | grupo.cupo_maximo − matrículas con estado 'activa' |
| Edad de un alumno | Desde alumno.fecha_nacimiento |
| Antigüedad | Desde empleado.fecha_ingreso o instructor.fecha_vinculacion |
| Valor del inventario | producto.precio_venta × inventario.stock |

Los precios de catálogo (producto.precio_venta, grupo.precio_matricula) pueden ser distintos de los precios cobrados (linea_venta.precio_unitario, matricula.valor_pagado).
