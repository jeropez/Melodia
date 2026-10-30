# Vistas, roles y usuarios

## Vistas

Las vistas se consultan igual que una tabla (`SELECT ... FROM nombre_vista`).

### v_inventario_disponible

Solo incluye productos con stock mayor que 0.

| Columna | Tipo | Origen |
|---|---|---|
| sede | VARCHAR | sede.nombre |
| ciudad | VARCHAR | sede.ciudad |
| categoria | VARCHAR | categoria.nombre |
| marca | VARCHAR | producto.marca |
| producto | VARCHAR | producto.nombre |
| tipo | VARCHAR | producto.tipo |
| precio_venta | NUMERIC | producto.precio_venta |
| stock | INTEGER | inventario.stock |
| valor_en_stock | NUMERIC | precio_venta × stock (calculado) |

### v_horario_clases

Solo incluye grupos con estado 'activo'.

| Columna | Tipo | Origen |
|---|---|---|
| id_grupo | VARCHAR | grupo.id_grupo |
| instrumento | VARCHAR | instrumento.nombre |
| nivel | VARCHAR | grupo.nivel |
| dia_semana | VARCHAR | grupo.dia_semana |
| hora_inicio | TIME | grupo.hora_inicio |
| hora_fin | TIME | grupo.hora_fin |
| sede | VARCHAR | sede.nombre |
| nombre_instructor | VARCHAR | instructor.primer_nombre |
| apellidos_instructor | VARCHAR | instructor.apellidos |
| precio_matricula | NUMERIC | grupo.precio_matricula |
| cupo_maximo | SMALLINT | grupo.cupo_maximo |
| cupos_disponibles | BIGINT | cupo_maximo − matrículas activas (calculado) |

### v_directorio_empleados

No incluye documento ni salario.

| Columna | Tipo | Origen |
|---|---|---|
| id_empleado | VARCHAR | empleado.id_empleado |
| primer_nombre | VARCHAR | empleado.primer_nombre |
| apellidos | VARCHAR | empleado.apellidos |
| cargo | VARCHAR | empleado.cargo |
| sede | VARCHAR | sede.nombre |
| ciudad | VARCHAR | sede.ciudad |
| correo | VARCHAR | empleado.correo ('sin correo registrado' si es NULL) |

## Roles y permisos

| Tabla o vista | rol_admin_general | rol_vendedor | rol_coordinador_academico |
|---|---|---|---|
| sede | Todos | SELECT | SELECT |
| empleado | Todos | — | — |
| categoria | Todos | SELECT | — |
| producto | Todos | SELECT | — |
| inventario | Todos | SELECT, UPDATE | — |
| cliente | Todos | SELECT, INSERT, UPDATE | — |
| venta | Todos | SELECT, INSERT | — |
| linea_venta | Todos | SELECT, INSERT | — |
| instrumento | Todos | — | SELECT |
| instructor | Todos | — | SELECT |
| instructor_especialidad | Todos | — | SELECT |
| instructor_sede | Todos | — | SELECT |
| grupo | Todos | — | SELECT, INSERT, UPDATE |
| alumno | Todos | — | SELECT, INSERT, UPDATE |
| matricula | Todos | — | SELECT, INSERT, UPDATE |
| v_inventario_disponible | Todos | SELECT | — |
| v_horario_clases | Todos | SELECT | SELECT |
| v_directorio_empleados | Todos | SELECT | SELECT |

"Todos" = SELECT, INSERT, UPDATE, DELETE (y demás privilegios de tabla).

## Usuarios

| Usuario | Rol |
|---|---|
| u_admin_melodia | rol_admin_general |
| u_sebastian_gil | rol_vendedor |
| u_paula_becerra | rol_vendedor |
| u_coordinacion | rol_coordinador_academico |

Para probar como un usuario dentro de pgAdmin (conectados como `postgres`): `SET ROLE nombre_usuario;` y para volver: `RESET ROLE;`
