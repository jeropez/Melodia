# Esquema de datos

Base de datos PostgreSQL con 15 tablas: 13 entidades (10 fuertes, 1 débil y 2 asociativas) y 2 tablas de unión. Hay 19 claves foráneas.

Convenciones:

- **PK**: clave primaria. **FK**: clave foránea. **UQ**: valor único.
- Los códigos de texto siguen un prefijo fijo: `SED-`, `EMP-`, `CAT-`, `PRD-`, `INS-`, `INT-`, `GR-`.
- Clientes y alumnos se identifican por su documento, no por un código.
- Los datos derivados (total de venta, subtotal, edad, antigüedad, cupos disponibles) **no** se guardan en ninguna tabla.

## Resumen

```
SEDE          (id_sede, nombre, ciudad, calle, numero, barrio, telefono,
               id_administrador FK → EMPLEADO, UNIQUE)
               5 sedes: SED-MED, SED-BOG, SED-CAL, SED-BAQ, SED-BUC
               id_administrador se agrega al final con ALTER TABLE (relación 1:1)
               SED-BUC (Melodía Cabecera) tiene barrio = NULL

EMPLEADO      (id_empleado, documento UNIQUE, primer_nombre, apellidos, cargo,
               fecha_ingreso, salario, correo UNIQUE, id_sede FK)
               cargo: 'administrador' | 'vendedor'
               EMP-06 y EMP-10 tienen correo = NULL

CATEGORIA     (id_categoria, nombre UNIQUE, descripcion)
               5 categorías: Cuerdas, Vientos, Percusión, Teclas, Electrónica

PRODUCTO      (id_producto, referencia UNIQUE, nombre, marca, tipo,
               precio_venta, descripcion_tecnica, id_categoria FK)
               tipo: 'instrumento' | 'accesorio'
               descripcion_tecnica es opcional (puede ser NULL)
               PRD-06 (saxofón) y PRD-13 (interfaz de audio) no están en ninguna sede
               PRD-08 (batería) y PRD-13 nunca se han vendido

INVENTARIO    (id_sede FK, id_producto FK, stock)
               PK compuesta (id_sede, id_producto)
               stock >= 0; tres registros tienen stock = 0 (producto agotado)

CLIENTE       (documento, primer_nombre, apellidos, correo UNIQUE, telefono)
               Juan Pablo y Tomás no tienen ninguna compra
               Patricia (43987123) es cliente y también alumna

VENTA         (id_venta SERIAL, fecha, forma_pago, documento_cliente FK,
               id_sede FK, id_vendedor FK → EMPLEADO)
               forma_pago: 'efectivo' | 'tarjeta' | 'transferencia'
               12 ventas entre enero y octubre de 2026
               El total de la venta NO se guarda: se calcula sumando sus líneas

LINEA_VENTA   (id_venta FK, num_linea, id_producto FK, cantidad, precio_unitario)
               PK compuesta (id_venta, num_linea); entidad débil
               ON DELETE CASCADE: si se borra la venta, se borran sus líneas
               UNIQUE (id_venta, id_producto): un producto no se repite en la venta
               precio_unitario es el precio cobrado ese día (histórico)
               El ingreso de una línea = cantidad × precio_unitario

INSTRUMENTO   (id_instrumento, nombre UNIQUE)
               7 instrumentos: Guitarra, Piano, Violín, Batería, Saxofón,
               Flauta traversa, Bajo eléctrico

INSTRUCTOR    (id_instructor, documento UNIQUE, primer_nombre, apellidos,
               telefono, tarifa_hora, fecha_vinculacion)
               INT-06 (Valentina) no dirige ningún grupo

INSTRUCTOR_ESPECIALIDAD (id_instructor FK, id_instrumento FK)
               PK compuesta; relación M:N "domina"
               Un instructor puede dominar varios instrumentos

INSTRUCTOR_SEDE (id_instructor FK, id_sede FK)
               PK compuesta; relación M:N "dicta en"
               Un instructor puede dar clases en varias sedes

GRUPO         (id_grupo, nivel, dia_semana, hora_inicio, hora_fin, cupo_maximo,
               precio_matricula, estado, id_sede FK, id_instructor FK,
               id_instrumento FK)
               nivel: 'iniciacion' | 'intermedio' | 'avanzado'
               estado: 'activo' | 'cerrado'
               cupo_maximo entre 1 y 20; hora_fin > hora_inicio
               GR-08 está cerrado; GR-07 está activo pero sin alumnos
               Los cupos disponibles NO se guardan: se calculan con COUNT

ALUMNO        (documento, primer_nombre, apellidos, fecha_nacimiento,
               correo UNIQUE, telefono)
               La edad NO se guarda: se calcula desde fecha_nacimiento

MATRICULA     (id_matricula SERIAL, documento_alumno FK, id_grupo FK,
               fecha_inicio, fecha_fin_estimada, estado, valor_pagado)
               estado: 'activa' | 'pausada' | 'finalizada'
               fecha_fin_estimada > fecha_inicio
               PK propia para permitir reinscripciones: el alumno 1143987654
               terminó GR-05 en 2025 y volvió a matricularse en 2026
               El alumno 1034567812 tiene su matrícula pausada en GR-01
```

## Detalle de columnas

### SEDE

| Columna | Tipo | Restricciones |
|---|---|---|
| id_sede | VARCHAR(10) | PK |
| nombre | VARCHAR(80) | NOT NULL, UQ |
| ciudad | VARCHAR(50) | NOT NULL |
| calle | VARCHAR(60) | NOT NULL |
| numero | VARCHAR(15) | NOT NULL |
| barrio | VARCHAR(60) | admite NULL |
| telefono | VARCHAR(15) | NOT NULL |
| id_administrador | VARCHAR(10) | UQ, FK → empleado(id_empleado), admite NULL |

### EMPLEADO

| Columna | Tipo | Restricciones |
|---|---|---|
| id_empleado | VARCHAR(10) | PK |
| documento | VARCHAR(20) | NOT NULL, UQ |
| primer_nombre | VARCHAR(50) | NOT NULL |
| apellidos | VARCHAR(100) | NOT NULL |
| cargo | VARCHAR(20) | NOT NULL, CHECK IN ('administrador', 'vendedor') |
| fecha_ingreso | DATE | NOT NULL, DEFAULT CURRENT_DATE |
| salario | NUMERIC(12,2) | NOT NULL, CHECK > 0 |
| correo | VARCHAR(120) | UQ, admite NULL |
| id_sede | VARCHAR(10) | NOT NULL, FK → sede(id_sede) |

### CATEGORIA

| Columna | Tipo | Restricciones |
|---|---|---|
| id_categoria | VARCHAR(10) | PK |
| nombre | VARCHAR(40) | NOT NULL, UQ |
| descripcion | TEXT | admite NULL |

### PRODUCTO

| Columna | Tipo | Restricciones |
|---|---|---|
| id_producto | VARCHAR(10) | PK |
| referencia | VARCHAR(30) | NOT NULL, UQ |
| nombre | VARCHAR(100) | NOT NULL |
| marca | VARCHAR(50) | NOT NULL |
| tipo | VARCHAR(15) | NOT NULL, DEFAULT 'instrumento', CHECK IN ('instrumento', 'accesorio') |
| precio_venta | NUMERIC(12,2) | NOT NULL, CHECK > 0 |
| descripcion_tecnica | TEXT | admite NULL |
| id_categoria | VARCHAR(10) | NOT NULL, FK → categoria(id_categoria) |

### INVENTARIO

| Columna | Tipo | Restricciones |
|---|---|---|
| id_sede | VARCHAR(10) | PK, FK → sede(id_sede) |
| id_producto | VARCHAR(10) | PK, FK → producto(id_producto) |
| stock | INT | NOT NULL, DEFAULT 0, CHECK >= 0 |

### CLIENTE

| Columna | Tipo | Restricciones |
|---|---|---|
| documento | VARCHAR(20) | PK |
| primer_nombre | VARCHAR(50) | NOT NULL |
| apellidos | VARCHAR(100) | NOT NULL |
| correo | VARCHAR(120) | UQ, admite NULL |
| telefono | VARCHAR(15) | NOT NULL |

### VENTA

| Columna | Tipo | Restricciones |
|---|---|---|
| id_venta | SERIAL | PK |
| fecha | DATE | NOT NULL, DEFAULT CURRENT_DATE |
| forma_pago | VARCHAR(15) | NOT NULL, CHECK IN ('efectivo', 'tarjeta', 'transferencia') |
| documento_cliente | VARCHAR(20) | NOT NULL, FK → cliente(documento) |
| id_sede | VARCHAR(10) | NOT NULL, FK → sede(id_sede) |
| id_vendedor | VARCHAR(10) | NOT NULL, FK → empleado(id_empleado) |

### LINEA_VENTA

| Columna | Tipo | Restricciones |
|---|---|---|
| id_venta | INT | PK, FK → venta(id_venta) ON DELETE CASCADE |
| num_linea | SMALLINT | PK, CHECK > 0 |
| id_producto | VARCHAR(10) | NOT NULL, FK → producto(id_producto) |
| cantidad | INT | NOT NULL, CHECK > 0 |
| precio_unitario | NUMERIC(12,2) | NOT NULL, CHECK > 0 |

Restricción adicional: UNIQUE (id_venta, id_producto).

### INSTRUMENTO

| Columna | Tipo | Restricciones |
|---|---|---|
| id_instrumento | VARCHAR(10) | PK |
| nombre | VARCHAR(40) | NOT NULL, UQ |

### INSTRUCTOR

| Columna | Tipo | Restricciones |
|---|---|---|
| id_instructor | VARCHAR(10) | PK |
| documento | VARCHAR(20) | NOT NULL, UQ |
| primer_nombre | VARCHAR(50) | NOT NULL |
| apellidos | VARCHAR(100) | NOT NULL |
| telefono | VARCHAR(15) | admite NULL |
| tarifa_hora | NUMERIC(10,2) | NOT NULL, CHECK > 0 |
| fecha_vinculacion | DATE | NOT NULL, DEFAULT CURRENT_DATE |

### INSTRUCTOR_ESPECIALIDAD

| Columna | Tipo | Restricciones |
|---|---|---|
| id_instructor | VARCHAR(10) | PK, FK → instructor(id_instructor) |
| id_instrumento | VARCHAR(10) | PK, FK → instrumento(id_instrumento) |

### INSTRUCTOR_SEDE

| Columna | Tipo | Restricciones |
|---|---|---|
| id_instructor | VARCHAR(10) | PK, FK → instructor(id_instructor) |
| id_sede | VARCHAR(10) | PK, FK → sede(id_sede) |

### GRUPO

| Columna | Tipo | Restricciones |
|---|---|---|
| id_grupo | VARCHAR(10) | PK |
| nivel | VARCHAR(15) | NOT NULL, CHECK IN ('iniciacion', 'intermedio', 'avanzado') |
| dia_semana | VARCHAR(10) | NOT NULL, CHECK IN ('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo') |
| hora_inicio | TIME | NOT NULL |
| hora_fin | TIME | NOT NULL, CHECK hora_fin > hora_inicio |
| cupo_maximo | SMALLINT | NOT NULL, CHECK BETWEEN 1 AND 20 |
| precio_matricula | NUMERIC(12,2) | NOT NULL, CHECK > 0 |
| estado | VARCHAR(10) | NOT NULL, DEFAULT 'activo', CHECK IN ('activo', 'cerrado') |
| id_sede | VARCHAR(10) | NOT NULL, FK → sede(id_sede) |
| id_instructor | VARCHAR(10) | NOT NULL, FK → instructor(id_instructor) |
| id_instrumento | VARCHAR(10) | NOT NULL, FK → instrumento(id_instrumento) |

### ALUMNO

| Columna | Tipo | Restricciones |
|---|---|---|
| documento | VARCHAR(20) | PK |
| primer_nombre | VARCHAR(50) | NOT NULL |
| apellidos | VARCHAR(100) | NOT NULL |
| fecha_nacimiento | DATE | NOT NULL |
| correo | VARCHAR(120) | UQ, admite NULL |
| telefono | VARCHAR(15) | NOT NULL |

### MATRICULA

| Columna | Tipo | Restricciones |
|---|---|---|
| id_matricula | SERIAL | PK |
| documento_alumno | VARCHAR(20) | NOT NULL, FK → alumno(documento) |
| id_grupo | VARCHAR(10) | NOT NULL, FK → grupo(id_grupo) |
| fecha_inicio | DATE | NOT NULL, DEFAULT CURRENT_DATE |
| fecha_fin_estimada | DATE | NOT NULL, CHECK fecha_fin_estimada > fecha_inicio |
| estado | VARCHAR(10) | NOT NULL, DEFAULT 'activa', CHECK IN ('activa', 'pausada', 'finalizada') |
| valor_pagado | NUMERIC(12,2) | NOT NULL, CHECK > 0 |

## Valores con acento y mayúsculas

Los valores de los CHECK se guardan en minúscula y **sin tilde**: `'iniciacion'`, `'miercoles'`, `'sabado'`. Los nombres de sedes, productos, personas e instrumentos sí llevan tilde y mayúscula inicial (por ejemplo `'Melodía Laureles'`, `'Violín'`).
