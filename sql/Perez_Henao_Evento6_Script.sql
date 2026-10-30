-- =====================================================================
-- SECCIÓN 3 — IMPLEMENTACIÓN DDL
-- Caso: Melodía (Evento Evaluativo VI — Modelo de Datos)
-- Orden de creación: primero las tablas referenciadas, luego las que
-- tienen FK hacia ellas. SEDE y EMPLEADO se referencian mutuamente, por
-- eso la FK del administrador se agrega al final con ALTER TABLE.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 3.0 Limpieza: permite ejecutar el script desde cero varias veces.
-- Se borra en orden inverso a la creación (primero las tablas con FK).
-- CASCADE elimina también la FK circular sede ↔ empleado y las vistas.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS matricula               CASCADE;
DROP TABLE IF EXISTS alumno                  CASCADE;
DROP TABLE IF EXISTS grupo                   CASCADE;
DROP TABLE IF EXISTS instructor_sede         CASCADE;
DROP TABLE IF EXISTS instructor_especialidad CASCADE;
DROP TABLE IF EXISTS instructor              CASCADE;
DROP TABLE IF EXISTS instrumento             CASCADE;
DROP TABLE IF EXISTS linea_venta             CASCADE;
DROP TABLE IF EXISTS venta                   CASCADE;
DROP TABLE IF EXISTS cliente                 CASCADE;
DROP TABLE IF EXISTS inventario              CASCADE;
DROP TABLE IF EXISTS producto                CASCADE;
DROP TABLE IF EXISTS categoria               CASCADE;
DROP TABLE IF EXISTS empleado                CASCADE;
DROP TABLE IF EXISTS sede                    CASCADE;


-- ---------------------------------------------------------------------
-- 3.1 SEDE  (entidad fuerte · R1 · dirección compuesta aplanada R2)
-- ---------------------------------------------------------------------
CREATE TABLE sede (
    id_sede           VARCHAR(10)   PRIMARY KEY,
    nombre            VARCHAR(80)   NOT NULL UNIQUE,
    ciudad            VARCHAR(50)   NOT NULL,
    calle             VARCHAR(60)   NOT NULL,
    numero            VARCHAR(15)   NOT NULL,
    barrio            VARCHAR(60),
    telefono          VARCHAR(15)   NOT NULL,
    id_administrador  VARCHAR(10)   UNIQUE      -- FK → empleado (se agrega al final, relación 1:1 R7)
);

-- ---------------------------------------------------------------------
-- 3.2 EMPLEADO  (entidad fuerte · R1 · nombre compuesto R2 · 1:N con SEDE R6)
-- ---------------------------------------------------------------------
CREATE TABLE empleado (
    id_empleado     VARCHAR(10)    PRIMARY KEY,
    documento       VARCHAR(20)    NOT NULL UNIQUE,
    primer_nombre   VARCHAR(50)    NOT NULL,
    apellidos       VARCHAR(100)   NOT NULL,
    cargo           VARCHAR(20)    NOT NULL
                    CHECK (cargo IN ('administrador', 'vendedor')),
    fecha_ingreso   DATE           NOT NULL DEFAULT CURRENT_DATE,
    salario         NUMERIC(12,2)  NOT NULL CHECK (salario > 0),
    correo          VARCHAR(120)   UNIQUE,
    id_sede         VARCHAR(10)    NOT NULL REFERENCES sede(id_sede)
    -- antigüedad: DERIVADO (R3), se calcula con AGE(fecha_ingreso)
);

-- ---------------------------------------------------------------------
-- 3.3 CATEGORIA  (entidad fuerte · R1)
-- ---------------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria  VARCHAR(10)  PRIMARY KEY,
    nombre        VARCHAR(40)  NOT NULL UNIQUE,
    descripcion   TEXT
);

-- ---------------------------------------------------------------------
-- 3.4 PRODUCTO  (entidad fuerte · R1 · 1:N con CATEGORIA R6)
-- ---------------------------------------------------------------------
CREATE TABLE producto (
    id_producto          VARCHAR(10)    PRIMARY KEY,
    referencia           VARCHAR(30)    NOT NULL UNIQUE,     -- referencia interna (clave candidata)
    nombre               VARCHAR(100)   NOT NULL,
    marca                VARCHAR(50)    NOT NULL,
    tipo                 VARCHAR(15)    NOT NULL DEFAULT 'instrumento'
                         CHECK (tipo IN ('instrumento', 'accesorio')),
    precio_venta         NUMERIC(12,2)  NOT NULL CHECK (precio_venta > 0),
    descripcion_tecnica  TEXT,                               -- opcional según el enunciado
    id_categoria         VARCHAR(10)    NOT NULL REFERENCES categoria(id_categoria)
);

-- ---------------------------------------------------------------------
-- 3.5 INVENTARIO  (entidad asociativa SEDE × PRODUCTO · R9)
-- ---------------------------------------------------------------------
CREATE TABLE inventario (
    id_sede      VARCHAR(10)  NOT NULL REFERENCES sede(id_sede),
    id_producto  VARCHAR(10)  NOT NULL REFERENCES producto(id_producto),
    stock        INT          NOT NULL DEFAULT 0 CHECK (stock >= 0),
    PRIMARY KEY (id_sede, id_producto)
);

-- ---------------------------------------------------------------------
-- 3.6 CLIENTE  (entidad fuerte · R1 · nombre compuesto R2)
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
    documento      VARCHAR(20)   PRIMARY KEY,
    primer_nombre  VARCHAR(50)   NOT NULL,
    apellidos      VARCHAR(100)  NOT NULL,
    correo         VARCHAR(120)  UNIQUE,
    telefono       VARCHAR(15)   NOT NULL
);

-- ---------------------------------------------------------------------
-- 3.7 VENTA  (entidad fuerte · R1 · tres relaciones 1:N R6)
-- ---------------------------------------------------------------------
CREATE TABLE venta (
    id_venta           SERIAL        PRIMARY KEY,
    fecha              DATE          NOT NULL DEFAULT CURRENT_DATE,
    forma_pago         VARCHAR(15)   NOT NULL
                       CHECK (forma_pago IN ('efectivo', 'tarjeta', 'transferencia')),
    documento_cliente  VARCHAR(20)   NOT NULL REFERENCES cliente(documento),
    id_sede            VARCHAR(10)   NOT NULL REFERENCES sede(id_sede),
    id_vendedor        VARCHAR(10)   NOT NULL REFERENCES empleado(id_empleado)
    -- total de la venta: DERIVADO (R3) = SUM(cantidad * precio_unitario) de sus líneas
);

-- ---------------------------------------------------------------------
-- 3.8 LINEA_VENTA  (entidad débil de VENTA · R5 · PK = id_venta + num_linea)
-- ---------------------------------------------------------------------
CREATE TABLE linea_venta (
    id_venta         INT            NOT NULL REFERENCES venta(id_venta)
                                     ON DELETE CASCADE,   -- la línea no existe sin su venta (R5)
    num_linea        SMALLINT       NOT NULL CHECK (num_linea > 0),
    id_producto      VARCHAR(10)    NOT NULL REFERENCES producto(id_producto),
    cantidad         INT            NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(12,2)  NOT NULL CHECK (precio_unitario > 0),  -- precio histórico (D4)
    PRIMARY KEY (id_venta, num_linea),
    UNIQUE (id_venta, id_producto)          -- un producto no se repite en dos líneas de la misma venta
);

-- ---------------------------------------------------------------------
-- 3.9 INSTRUMENTO  (entidad fuerte · R1 · catálogo de disciplinas, D1)
-- ---------------------------------------------------------------------
CREATE TABLE instrumento (
    id_instrumento  VARCHAR(10)  PRIMARY KEY,
    nombre          VARCHAR(40)  NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------
-- 3.10 INSTRUCTOR  (entidad fuerte · R1 · nombre compuesto R2)
-- ---------------------------------------------------------------------
CREATE TABLE instructor (
    id_instructor      VARCHAR(10)    PRIMARY KEY,
    documento          VARCHAR(20)    NOT NULL UNIQUE,
    primer_nombre      VARCHAR(50)    NOT NULL,
    apellidos          VARCHAR(100)   NOT NULL,
    telefono           VARCHAR(15),
    tarifa_hora        NUMERIC(10,2)  NOT NULL CHECK (tarifa_hora > 0),
    fecha_vinculacion  DATE           NOT NULL DEFAULT CURRENT_DATE
    -- antigüedad: DERIVADO (R3), se calcula con AGE(fecha_vinculacion)
);

-- ---------------------------------------------------------------------
-- 3.11 INSTRUCTOR_ESPECIALIDAD  (relación M:N sin atributos "domina" · R8)
--      Sustituye al atributo multivaluado "especialidades" (decisión D1)
-- ---------------------------------------------------------------------
CREATE TABLE instructor_especialidad (
    id_instructor   VARCHAR(10)  NOT NULL REFERENCES instructor(id_instructor),
    id_instrumento  VARCHAR(10)  NOT NULL REFERENCES instrumento(id_instrumento),
    PRIMARY KEY (id_instructor, id_instrumento)
);

-- ---------------------------------------------------------------------
-- 3.12 INSTRUCTOR_SEDE  (relación M:N sin atributos "dicta en" · R8)
-- ---------------------------------------------------------------------
CREATE TABLE instructor_sede (
    id_instructor  VARCHAR(10)  NOT NULL REFERENCES instructor(id_instructor),
    id_sede        VARCHAR(10)  NOT NULL REFERENCES sede(id_sede),
    PRIMARY KEY (id_instructor, id_sede)
);

-- ---------------------------------------------------------------------
-- 3.13 GRUPO  (entidad fuerte · R1 · horario compuesto R2 · tres 1:N R6)
-- ---------------------------------------------------------------------
CREATE TABLE grupo (
    id_grupo          VARCHAR(10)    PRIMARY KEY,
    nivel             VARCHAR(15)    NOT NULL
                      CHECK (nivel IN ('iniciacion', 'intermedio', 'avanzado')),
    dia_semana        VARCHAR(10)    NOT NULL
                      CHECK (dia_semana IN ('lunes', 'martes', 'miercoles', 'jueves',
                                            'viernes', 'sabado', 'domingo')),
    hora_inicio       TIME           NOT NULL,
    hora_fin          TIME           NOT NULL,
    cupo_maximo       SMALLINT       NOT NULL CHECK (cupo_maximo BETWEEN 1 AND 20),
    precio_matricula  NUMERIC(12,2)  NOT NULL CHECK (precio_matricula > 0),
    estado            VARCHAR(10)    NOT NULL DEFAULT 'activo'
                      CHECK (estado IN ('activo', 'cerrado')),
    id_sede           VARCHAR(10)    NOT NULL REFERENCES sede(id_sede),
    id_instructor     VARCHAR(10)    NOT NULL REFERENCES instructor(id_instructor),
    id_instrumento    VARCHAR(10)    NOT NULL REFERENCES instrumento(id_instrumento),
    CHECK (hora_fin > hora_inicio)
    -- cupos disponibles: DERIVADO (R3) = cupo_maximo - matrículas activas
);

-- ---------------------------------------------------------------------
-- 3.14 ALUMNO  (entidad fuerte · R1 · nombre compuesto R2)
-- ---------------------------------------------------------------------
CREATE TABLE alumno (
    documento         VARCHAR(20)   PRIMARY KEY,
    primer_nombre     VARCHAR(50)   NOT NULL,
    apellidos         VARCHAR(100)  NOT NULL,
    fecha_nacimiento  DATE          NOT NULL,
    correo            VARCHAR(120)  UNIQUE,
    telefono          VARCHAR(15)   NOT NULL
    -- edad: DERIVADO (R3), se calcula con AGE(fecha_nacimiento)
);

-- ---------------------------------------------------------------------
-- 3.15 MATRICULA  (entidad asociativa ALUMNO × GRUPO · R9, con PK propia D6)
-- ---------------------------------------------------------------------
CREATE TABLE matricula (
    id_matricula        SERIAL         PRIMARY KEY,
    documento_alumno    VARCHAR(20)    NOT NULL REFERENCES alumno(documento),
    id_grupo            VARCHAR(10)    NOT NULL REFERENCES grupo(id_grupo),
    fecha_inicio        DATE           NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin_estimada  DATE           NOT NULL,
    estado              VARCHAR(10)    NOT NULL DEFAULT 'activa'
                        CHECK (estado IN ('activa', 'pausada', 'finalizada')),
    valor_pagado        NUMERIC(12,2)  NOT NULL CHECK (valor_pagado > 0),    -- valor histórico (D4)
    CHECK (fecha_fin_estimada > fecha_inicio)
);

-- ---------------------------------------------------------------------
-- 3.16 FK circular: el administrador de cada sede (relación 1:1 · R7)
-- La FK va en SEDE porque SEDE tiene participación total en "administra".
-- Se agrega después de crear EMPLEADO porque EMPLEADO ya referencia a SEDE.
-- ---------------------------------------------------------------------
ALTER TABLE sede
    ADD CONSTRAINT fk_sede_administrador
    FOREIGN KEY (id_administrador) REFERENCES empleado(id_empleado);


-- =====================================================================
-- SECCIÓN 4 — DATOS DE PRUEBA
-- Datos coherentes con el caso Melodía. Se incluyen a propósito casos
-- que hacen que las consultas devuelvan resultados no triviales:
--   · clientes que nunca han comprado (LEFT JOIN)
--   · una persona que es cliente y alumna a la vez (FULL OUTER JOIN)
--   · productos que nunca se han vendido (subconsulta)
--   · instructores que dominan el mismo instrumento (Self-JOIN)
--   · un grupo activo sin alumnos y una instructora sin grupos
--   · columnas opcionales en NULL y una reinscripción
-- =====================================================================


-- ---------------------------------------------------------------------
-- 4.1 SEDE (sin administrador todavía: se asigna después con UPDATE,
--     porque el administrador es un empleado que aún no existe)
-- ---------------------------------------------------------------------
INSERT INTO sede (id_sede, nombre, ciudad, calle, numero, barrio, telefono) VALUES
    ('SED-MED', 'Melodía Laureles',  'Medellín',     'Circular 73',  '39-45',  'Laureles',  '6044112233'),
    ('SED-BOG', 'Melodía Chapinero', 'Bogotá',       'Carrera 13',   '54-20',  'Chapinero', '6013456789'),
    ('SED-CAL', 'Melodía Granada',   'Cali',         'Avenida 9 Norte', '15-32', 'Granada', '6026678899'),
    ('SED-BAQ', 'Melodía El Prado',  'Barranquilla', 'Carrera 54',   '70-110', 'El Prado',  '6053581122'),
    ('SED-BUC', 'Melodía Cabecera',  'Bucaramanga',  'Calle 52',     '35-18',  NULL,        '6076345566');

-- ---------------------------------------------------------------------
-- 4.2 EMPLEADO (un administrador por sede + vendedores)
-- ---------------------------------------------------------------------
INSERT INTO empleado (id_empleado, documento, primer_nombre, apellidos, cargo, fecha_ingreso, salario, correo, id_sede) VALUES
    ('EMP-01', '43876543', 'Claudia',  'Ríos Montoya',     'administrador', '2018-03-01', 4800000, 'claudia.rios@melodia.co',   'SED-MED'),
    ('EMP-02', '1037612345', 'Sebastián', 'Gil Ochoa',     'vendedor',      '2021-06-15', 2100000, 'sebastian.gil@melodia.co',  'SED-MED'),
    ('EMP-03', '52987321', 'Ricardo',  'Mora Salazar',     'administrador', '2019-01-10', 4700000, 'ricardo.mora@melodia.co',   'SED-BOG'),
    ('EMP-04', '1019876543', 'Paula',  'Becerra Niño',     'vendedor',      '2022-02-01', 2000000, 'paula.becerra@melodia.co',  'SED-BOG'),
    ('EMP-05', '31456987', 'Gloria',   'Cuéllar Lozano',   'administrador', '2020-08-03', 4500000, 'gloria.cuellar@melodia.co', 'SED-CAL'),
    ('EMP-06', '1144098765', 'Andrés', 'Quintero Paz',     'vendedor',      '2023-04-17', 1900000, NULL,                        'SED-CAL'),
    ('EMP-07', '72198456', 'Jorge',    'Barrios De la Hoz', 'administrador', '2020-11-23', 4500000, 'jorge.barrios@melodia.co', 'SED-BAQ'),
    ('EMP-08', '1045123987', 'Melissa', 'Charris Ortega',  'vendedor',      '2024-01-08', 1850000, 'melissa.charris@melodia.co', 'SED-BAQ'),
    ('EMP-09', '91234876', 'Hernán',   'Duarte Rueda',     'administrador', '2026-02-02', 4200000, 'hernan.duarte@melodia.co',  'SED-BUC'),
    ('EMP-10', '1000987123', 'Mateo',  'Zapata Correa',    'vendedor',      '2026-08-01', 1800000, NULL,                        'SED-MED');

-- Ahora que los empleados existen, se asigna el administrador de cada sede (1:1)
UPDATE sede SET id_administrador = 'EMP-01' WHERE id_sede = 'SED-MED';
UPDATE sede SET id_administrador = 'EMP-03' WHERE id_sede = 'SED-BOG';
UPDATE sede SET id_administrador = 'EMP-05' WHERE id_sede = 'SED-CAL';
UPDATE sede SET id_administrador = 'EMP-07' WHERE id_sede = 'SED-BAQ';
UPDATE sede SET id_administrador = 'EMP-09' WHERE id_sede = 'SED-BUC';

-- ---------------------------------------------------------------------
-- 4.3 CATEGORIA (las cinco que nombra el enunciado)
-- ---------------------------------------------------------------------
INSERT INTO categoria (id_categoria, nombre, descripcion) VALUES
    ('CAT-CUE', 'Cuerdas',     'Guitarras, violines, bajos y sus accesorios'),
    ('CAT-VIE', 'Vientos',     'Flautas, saxofones, clarinetes y trompetas'),
    ('CAT-PER', 'Percusión',   'Baterías, cajones, bongós y baquetas'),
    ('CAT-TEC', 'Teclas',      'Pianos digitales, teclados y sintetizadores'),
    ('CAT-ELE', 'Electrónica', NULL);

-- ---------------------------------------------------------------------
-- 4.4 PRODUCTO (descripcion_tecnica es opcional: varios quedan en NULL)
-- ---------------------------------------------------------------------
INSERT INTO producto (id_producto, referencia, nombre, marca, tipo, precio_venta, descripcion_tecnica, id_categoria) VALUES
    ('PRD-01', 'YAM-C40',       'Guitarra acústica C40',           'Yamaha',     'instrumento',  650000, 'Tapa de abeto, cuerdas de nailon, 4/4',            'CAT-CUE'),
    ('PRD-02', 'FEN-SQ-STRAT',  'Guitarra eléctrica Squier Strat', 'Fender',     'instrumento', 1890000, 'Tres pastillas single coil, puente trémolo',     'CAT-CUE'),
    ('PRD-03', 'STE-STU1-44',   'Violín Student I 4/4',            'Stentor',    'instrumento',  980000, 'Incluye arco y estuche',                          'CAT-CUE'),
    ('PRD-04', 'DAD-EJ16',      'Juego de cuerdas EJ16',           'D''Addario', 'accesorio',     45000, 'Bronce fosforado, calibre light 12-53',          'CAT-CUE'),
    ('PRD-05', 'YAM-YFL222',    'Flauta traversa YFL-222',         'Yamaha',     'instrumento', 2850000, NULL,                                              'CAT-VIE'),
    ('PRD-06', 'JUP-JAS500',    'Saxofón alto JAS500',             'Jupiter',    'instrumento', 4200000, 'Afinación en Mi bemol, lacado dorado',           'CAT-VIE'),
    ('PRD-07', 'MEI-CAJ1',      'Cajón peruano',                   'Meinl',      'instrumento',  520000, NULL,                                              'CAT-PER'),
    ('PRD-08', 'PEA-RS525',     'Batería acústica Roadshow',       'Pearl',      'instrumento', 3600000, 'Cinco cuerpos, platillos y herrajes incluidos',  'CAT-PER'),
    ('PRD-09', 'VIC-5A',        'Baquetas 5A',                     'Vic Firth',  'accesorio',     55000, NULL,                                              'CAT-PER'),
    ('PRD-10', 'YAM-PSRE373',   'Teclado PSR-E373',                'Yamaha',     'instrumento', 1250000, '61 teclas sensibles, 622 voces',                 'CAT-TEC'),
    ('PRD-11', 'CAS-CDPS110',   'Piano digital CDP-S110',          'Casio',      'instrumento', 2100000, '88 teclas con acción de martillo',               'CAT-TEC'),
    ('PRD-12', 'BOS-TU3',       'Pedal afinador TU-3',             'Boss',       'accesorio',    480000, NULL,                                              'CAT-ELE'),
    ('PRD-13', 'FOC-2I2-G4',    'Interfaz de audio Scarlett 2i2',  'Focusrite',  'accesorio',    950000, 'Dos entradas, 24 bits / 192 kHz',                'CAT-ELE');

-- ---------------------------------------------------------------------
-- 4.5 INVENTARIO (cada sede decide qué productos tiene y cuántos)
--     · stock 0 = la sede maneja el producto pero está agotado
--     · PRD-06 (saxofón) no tiene fila: se vendió el último y se dejó de manejar
--     · PRD-13 (interfaz) es nuevo en el catálogo y aún no llega a ninguna sede
-- ---------------------------------------------------------------------
INSERT INTO inventario (id_sede, id_producto, stock) VALUES
    ('SED-MED', 'PRD-01', 4), ('SED-MED', 'PRD-02', 2), ('SED-MED', 'PRD-04', 30),
    ('SED-MED', 'PRD-07', 3), ('SED-MED', 'PRD-08', 1), ('SED-MED', 'PRD-09', 20),
    ('SED-MED', 'PRD-10', 2), ('SED-MED', 'PRD-11', 1), ('SED-MED', 'PRD-12', 0),
    ('SED-BOG', 'PRD-01', 3), ('SED-BOG', 'PRD-02', 1), ('SED-BOG', 'PRD-03', 2),
    ('SED-BOG', 'PRD-04', 25), ('SED-BOG', 'PRD-08', 2), ('SED-BOG', 'PRD-10', 0),
    ('SED-BOG', 'PRD-12', 2),
    ('SED-CAL', 'PRD-01', 2), ('SED-CAL', 'PRD-03', 1), ('SED-CAL', 'PRD-04', 15),
    ('SED-CAL', 'PRD-05', 1),
    ('SED-BAQ', 'PRD-04', 10), ('SED-BAQ', 'PRD-05', 0), ('SED-BAQ', 'PRD-07', 2),
    ('SED-BAQ', 'PRD-09', 12),
    ('SED-BUC', 'PRD-01', 2), ('SED-BUC', 'PRD-04', 10), ('SED-BUC', 'PRD-10', 1);

-- ---------------------------------------------------------------------
-- 4.6 CLIENTE (Juan Pablo Mesa y Tomás Arango están registrados pero nunca han
--     comprado; Patricia Londoño es clienta y también alumna de piano)
-- ---------------------------------------------------------------------
INSERT INTO cliente (documento, primer_nombre, apellidos, correo, telefono) VALUES
    ('43512876',   'Mariana',     'López Henao',     'mariana.lopez@gmail.com',   '3104567890'),
    ('71234589',   'Santiago',    'Pérez Gil',       NULL,                        '3001234567'),
    ('1020456789', 'Daniela',     'Castro Mejía',    'daniela.castro@hotmail.com', '3157894561'),
    ('16789234',   'Felipe',      'Ramírez Torres',  'felipe.ramirez@gmail.com',  '3182345678'),
    ('32456781',   'Carolina',    'Díaz Salcedo',    'caro.diaz@yahoo.com',       '3014567321'),
    ('1036987654', 'Tomás',       'Arango Vélez',    NULL,                        '3206549873'),
    ('52345678',   'Natalia',     'Suárez Pinto',    'natalia.suarez@gmail.com',  '3112223344'),
    ('1001234567', 'Juan Pablo',  'Mesa Ríos',       'jp.mesa@gmail.com',         '3045556677'),
    ('43987123',   'Patricia',    'Londoño Gómez',   'patricia.londono@gmail.com', '3189990011');  -- también es alumna

-- ---------------------------------------------------------------------
-- 4.7 VENTA (id_venta lo asigna SERIAL: 1, 2, 3… en el orden de inserción)
--     El vendedor de cada venta trabaja en la sede donde se hizo la venta.
-- ---------------------------------------------------------------------
INSERT INTO venta (fecha, forma_pago, documento_cliente, id_sede, id_vendedor) VALUES
    ('2026-01-15', 'tarjeta',       '43512876',   'SED-MED', 'EMP-02'),   -- 1
    ('2026-02-03', 'efectivo',      '71234589',   'SED-MED', 'EMP-02'),   -- 2
    ('2026-02-20', 'transferencia', '1020456789', 'SED-BOG', 'EMP-04'),   -- 3
    ('2026-03-11', 'tarjeta',       '43512876',   'SED-BOG', 'EMP-04'),   -- 4  misma clienta, otra sede
    ('2026-04-05', 'efectivo',      '16789234',   'SED-CAL', 'EMP-06'),   -- 5
    ('2026-04-22', 'tarjeta',       '32456781',   'SED-BAQ', 'EMP-08'),   -- 6
    ('2026-05-14', 'transferencia', '43987123',   'SED-MED', 'EMP-02'),   -- 7  alumna de piano compra un piano
    ('2026-06-09', 'efectivo',      '71234589',   'SED-MED', 'EMP-02'),   -- 8
    ('2026-07-18', 'tarjeta',       '52345678',   'SED-BOG', 'EMP-04'),   -- 9
    ('2026-08-25', 'transferencia', '1020456789', 'SED-CAL', 'EMP-06'),   -- 10
    ('2026-09-30', 'tarjeta',       '16789234',   'SED-BAQ', 'EMP-08'),   -- 11
    ('2026-10-20', 'efectivo',      '43512876',   'SED-MED', 'EMP-02');   -- 12

-- ---------------------------------------------------------------------
-- 4.8 LINEA_VENTA (entidad débil: num_linea se reinicia en cada venta)
--     precio_unitario = precio al momento de la venta. En las ventas 1 y 5
--     el precio era menor que el actual del catálogo (D4: dato histórico).
-- ---------------------------------------------------------------------
INSERT INTO linea_venta (id_venta, num_linea, id_producto, cantidad, precio_unitario) VALUES
    (1,  1, 'PRD-01', 1,  600000),
    (1,  2, 'PRD-04', 2,   45000),
    (2,  1, 'PRD-07', 1,  520000),
    (3,  1, 'PRD-02', 1, 1890000),
    (3,  2, 'PRD-12', 1,  480000),
    (4,  1, 'PRD-10', 1, 1250000),
    (5,  1, 'PRD-03', 1,  950000),
    (5,  2, 'PRD-04', 1,   45000),
    (6,  1, 'PRD-06', 1, 4200000),
    (7,  1, 'PRD-11', 1, 2100000),
    (8,  1, 'PRD-09', 3,   55000),
    (8,  2, 'PRD-04', 3,   45000),
    (9,  1, 'PRD-01', 2,  650000),
    (10, 1, 'PRD-05', 1, 2850000),
    (11, 1, 'PRD-07', 1,  520000),
    (11, 2, 'PRD-09', 2,   55000),
    (12, 1, 'PRD-12', 1,  480000),
    (12, 2, 'PRD-04', 1,   45000);

-- ---------------------------------------------------------------------
-- 4.9 INSTRUMENTO (catálogo de disciplinas; Flauta y Bajo aún sin grupos)
-- ---------------------------------------------------------------------
INSERT INTO instrumento (id_instrumento, nombre) VALUES
    ('INS-GUI', 'Guitarra'),
    ('INS-PIA', 'Piano'),
    ('INS-VIO', 'Violín'),
    ('INS-BAT', 'Batería'),
    ('INS-SAX', 'Saxofón'),
    ('INS-FLA', 'Flauta traversa'),
    ('INS-BAJ', 'Bajo eléctrico');

-- ---------------------------------------------------------------------
-- 4.10 INSTRUCTOR (INT-06 es nuevo: está habilitado en Bucaramanga
--      pero todavía no tiene grupos; INT-04 no registró teléfono)
-- ---------------------------------------------------------------------
INSERT INTO instructor (id_instructor, documento, primer_nombre, apellidos, telefono, tarifa_hora, fecha_vinculacion) VALUES
    ('INT-01', '98765432',   'Andrés',    'Restrepo Uribe',  '3001112233', 65000, '2017-02-01'),
    ('INT-02', '43219876',   'Laura',     'Gómez Arbeláez',  '3014445566', 70000, '2019-07-15'),
    ('INT-03', '80123456',   'Camilo',    'Vargas León',     '3127778899', 60000, '2020-01-20'),
    ('INT-04', '1018456123', 'Sofía',     'Martínez Rojas',  NULL,         75000, '2021-09-01'),
    ('INT-05', '72345987',   'Julián',    'Ospina Navarro',  '3156663322', 68000, '2022-03-14'),
    ('INT-06', '1098765432', 'Valentina', 'Rojas Cárdenas',  '3174441100', 55000, '2026-06-01');

-- ---------------------------------------------------------------------
-- 4.11 INSTRUCTOR_ESPECIALIDAD (multivaluado: un instructor domina varios)
-- ---------------------------------------------------------------------
INSERT INTO instructor_especialidad (id_instructor, id_instrumento) VALUES
    ('INT-01', 'INS-GUI'), ('INT-01', 'INS-BAJ'),
    ('INT-02', 'INS-PIA'), ('INT-02', 'INS-VIO'),
    ('INT-03', 'INS-BAT'),
    ('INT-04', 'INS-VIO'),
    ('INT-05', 'INS-SAX'), ('INT-05', 'INS-FLA'),
    ('INT-06', 'INS-GUI'), ('INT-06', 'INS-PIA');

-- ---------------------------------------------------------------------
-- 4.12 INSTRUCTOR_SEDE (sedes donde cada instructor puede dictar)
-- ---------------------------------------------------------------------
INSERT INTO instructor_sede (id_instructor, id_sede) VALUES
    ('INT-01', 'SED-MED'),
    ('INT-02', 'SED-MED'), ('INT-02', 'SED-CAL'),
    ('INT-03', 'SED-BOG'), ('INT-03', 'SED-BAQ'),
    ('INT-04', 'SED-BOG'),
    ('INT-05', 'SED-BAQ'), ('INT-05', 'SED-CAL'),
    ('INT-06', 'SED-BUC');

-- ---------------------------------------------------------------------
-- 4.13 GRUPO
--     · GR-07 es nuevo y aún no tiene alumnos · GR-08 ya está cerrado
-- ---------------------------------------------------------------------
INSERT INTO grupo (id_grupo, nivel, dia_semana, hora_inicio, hora_fin, cupo_maximo, precio_matricula, estado, id_sede, id_instructor, id_instrumento) VALUES
    ('GR-01', 'iniciacion', 'lunes',     '16:00', '18:00',  8, 280000, 'activo',  'SED-MED', 'INT-01', 'INS-GUI'),
    ('GR-02', 'intermedio', 'miercoles', '18:00', '20:00',  6, 320000, 'activo',  'SED-MED', 'INT-02', 'INS-PIA'),
    ('GR-03', 'iniciacion', 'sabado',    '09:00', '11:00', 10, 250000, 'activo',  'SED-BOG', 'INT-03', 'INS-BAT'),
    ('GR-04', 'avanzado',   'martes',    '17:00', '19:00',  4, 380000, 'activo',  'SED-BOG', 'INT-04', 'INS-VIO'),
    ('GR-05', 'intermedio', 'jueves',    '15:00', '17:00',  6, 300000, 'activo',  'SED-CAL', 'INT-02', 'INS-VIO'),
    ('GR-06', 'iniciacion', 'viernes',   '16:00', '18:00',  8, 290000, 'activo',  'SED-BAQ', 'INT-05', 'INS-SAX'),
    ('GR-07', 'intermedio', 'lunes',     '18:00', '20:00',  6, 300000, 'activo',  'SED-MED', 'INT-01', 'INS-GUI'),
    ('GR-08', 'iniciacion', 'sabado',    '10:00', '12:00',  8, 260000, 'cerrado', 'SED-BAQ', 'INT-03', 'INS-BAT');

-- ---------------------------------------------------------------------
-- 4.14 ALUMNO (los alumnos más jóvenes no registran correo propio)
-- ---------------------------------------------------------------------
INSERT INTO alumno (documento, primer_nombre, apellidos, fecha_nacimiento, correo, telefono) VALUES
    ('1001456789', 'Isabella',  'Henao Mejía',     '2010-05-14', NULL,                        '3101239876'),
    ('1023987456', 'Samuel',    'Ortiz Galeano',   '2004-11-02', 'samuel.ortiz@gmail.com',    '3008887766'),
    ('1034567812', 'Valeria',   'Quiroga Ruiz',    '2012-08-23', NULL,                        '3135554433'),
    ('43987123',   'Patricia',  'Londoño Gómez',   '1978-02-09', 'patricia.londono@gmail.com', '3189990011'),
    ('1012345678', 'Emiliano',  'Rincón Suárez',   '2011-03-30', NULL,                        '3206667788'),
    ('1015678934', 'Martina',   'Cárdenas Peña',   '2013-12-05', NULL,                        '3112224466'),
    ('1032789456', 'Nicolás',   'Bermúdez Sierra', '2001-07-19', 'nico.bermudez@hotmail.com', '3045671234'),
    ('1143987654', 'Gabriela',  'Lozada Vidal',    '1999-10-11', 'gaby.lozada@gmail.com',     '3168889900'),
    ('1048765123', 'Daniel',    'Fontalvo Rada',   '2008-01-27', NULL,                        '3013332211');

-- ---------------------------------------------------------------------
-- 4.15 MATRICULA (id_matricula lo asigna SERIAL)
--     · Isabella está en dos grupos (guitarra y piano): practica dos instrumentos
--     · Gabriela terminó GR-05 en 2025 y se reinscribió en 2026 (D6)
--     · las matrículas de GR-08 quedaron finalizadas cuando el grupo cerró
-- ---------------------------------------------------------------------
INSERT INTO matricula (documento_alumno, id_grupo, fecha_inicio, fecha_fin_estimada, estado, valor_pagado) VALUES
    ('1001456789', 'GR-01', '2026-02-02', '2026-11-30', 'activa',     280000),
    ('1023987456', 'GR-01', '2026-02-02', '2026-11-30', 'activa',     250000),
    ('1034567812', 'GR-01', '2026-03-02', '2026-12-15', 'pausada',    280000),
    ('43987123',   'GR-02', '2026-01-19', '2026-12-15', 'activa',     320000),
    ('1001456789', 'GR-02', '2026-07-06', '2027-01-30', 'activa',     320000),
    ('1012345678', 'GR-03', '2026-02-07', '2026-11-28', 'activa',     250000),
    ('1015678934', 'GR-03', '2026-02-07', '2026-11-28', 'activa',     250000),
    ('1032789456', 'GR-04', '2026-04-07', '2026-12-15', 'activa',     380000),
    ('1143987654', 'GR-05', '2025-07-01', '2025-12-05', 'finalizada', 280000),
    ('1143987654', 'GR-05', '2026-05-07', '2026-12-10', 'activa',     300000),
    ('1048765123', 'GR-06', '2026-08-07', '2027-02-26', 'activa',     290000),
    ('1012345678', 'GR-08', '2025-08-02', '2025-12-13', 'finalizada', 240000),
    ('1015678934', 'GR-08', '2025-08-02', '2025-12-13', 'finalizada', 260000);

-- ---------------------------------------------------------------------
-- Verificación: filas por tabla
-- ---------------------------------------------------------------------
SELECT 'sede' AS tabla, COUNT(*) AS filas FROM sede
UNION ALL SELECT 'empleado',                COUNT(*) FROM empleado
UNION ALL SELECT 'categoria',               COUNT(*) FROM categoria
UNION ALL SELECT 'producto',                COUNT(*) FROM producto
UNION ALL SELECT 'inventario',              COUNT(*) FROM inventario
UNION ALL SELECT 'cliente',                 COUNT(*) FROM cliente
UNION ALL SELECT 'venta',                   COUNT(*) FROM venta
UNION ALL SELECT 'linea_venta',             COUNT(*) FROM linea_venta
UNION ALL SELECT 'instrumento',             COUNT(*) FROM instrumento
UNION ALL SELECT 'instructor',              COUNT(*) FROM instructor
UNION ALL SELECT 'instructor_especialidad', COUNT(*) FROM instructor_especialidad
UNION ALL SELECT 'instructor_sede',         COUNT(*) FROM instructor_sede
UNION ALL SELECT 'grupo',                   COUNT(*) FROM grupo
UNION ALL SELECT 'alumno',                  COUNT(*) FROM alumno
UNION ALL SELECT 'matricula',               COUNT(*) FROM matricula;

-- =====================================================================
-- SECCIÓN 4 — CONSULTAS DML
-- Cada consulta empieza con la pregunta de negocio que responde.
-- Cobertura: INNER, LEFT, FULL OUTER, Self-JOIN y CROSS JOIN ·
-- GROUP BY + HAVING · subconsultas en WHERE y en FROM · funciones
-- nativas de texto, numéricas y de fecha.
-- =====================================================================


-- ---------------------------------------------------------------------
-- C1 · INNER JOIN
-- Pregunta de negocio (enunciado): ¿cuál es el historial de compras de
-- cada cliente? (fecha, sede y forma de pago de cada compra)
-- ---------------------------------------------------------------------
SELECT c.primer_nombre,
       c.apellidos,
       v.id_venta,
       v.fecha,
       s.nombre AS sede,
       v.forma_pago
FROM cliente c
INNER JOIN venta v ON v.documento_cliente = c.documento
INNER JOIN sede  s ON s.id_sede          = v.id_sede
ORDER BY c.apellidos, v.fecha;


-- ---------------------------------------------------------------------
-- C2 · LEFT JOIN
-- Pregunta de negocio: ¿cuántas compras ha hecho cada cliente registrado,
-- incluidos los que nunca han comprado? (Mercadeo quiere contactar a los
-- que tienen 0 compras.) Con INNER JOIN esos clientes no aparecerían.
-- ---------------------------------------------------------------------
SELECT c.primer_nombre,
       c.apellidos,
       COUNT(v.id_venta) AS numero_compras
FROM cliente c
LEFT JOIN venta v ON v.documento_cliente = c.documento
GROUP BY c.documento, c.primer_nombre, c.apellidos
ORDER BY numero_compras;


-- ---------------------------------------------------------------------
-- C3 · FULL OUTER JOIN
-- Pregunta de negocio: para el boletín de Melodía, ¿quiénes están
-- registrados solo como clientes, solo como alumnos o como ambos?
-- El FULL OUTER JOIN conserva las personas de las dos tablas, aunque no
-- tengan pareja en la otra (en ese lado aparecen NULL).
-- ---------------------------------------------------------------------
SELECT c.documento AS documento_cliente,
       c.primer_nombre AS nombre_cliente,
       a.documento AS documento_alumno,
       a.primer_nombre AS nombre_alumno
FROM cliente c
FULL OUTER JOIN alumno a ON a.documento = c.documento
ORDER BY c.documento, a.documento;


-- ---------------------------------------------------------------------
-- C4 · Self-JOIN (instructor_especialidad con ella misma)
-- Pregunta de negocio: si un instructor se incapacita, ¿qué otro
-- instructor domina el mismo instrumento y podría reemplazarlo?
-- ---------------------------------------------------------------------
SELECT e1.id_instructor  AS instructor,
       e2.id_instructor  AS puede_reemplazarlo,
       e1.id_instrumento AS instrumento
FROM instructor_especialidad e1
INNER JOIN instructor_especialidad e2
        ON e2.id_instrumento = e1.id_instrumento
       AND e2.id_instructor <> e1.id_instructor
ORDER BY e1.id_instructor;


-- ---------------------------------------------------------------------
-- C5 · CROSS JOIN + subconsulta en FROM + función numérica ROUND
-- Pregunta de negocio: ¿qué productos cuestan más que el precio promedio
-- del catálogo? (Productos de gama alta para la vitrina.)
-- La subconsulta devuelve una sola fila (el promedio) y el CROSS JOIN la
-- pega a cada producto para poder compararlos.
-- ---------------------------------------------------------------------
SELECT p.nombre,
       p.precio_venta,
       ROUND(prom.precio_promedio, 0) AS precio_promedio_catalogo
FROM producto p
CROSS JOIN (SELECT AVG(precio_venta) AS precio_promedio
            FROM producto) AS prom
WHERE p.precio_venta > prom.precio_promedio
ORDER BY p.precio_venta DESC;


-- ---------------------------------------------------------------------
-- C6 · GROUP BY + HAVING
-- Pregunta de negocio: ¿qué sedes han hecho más de 2 ventas en 2026?
-- WHERE filtra las ventas del año con BETWEEN; HAVING filtra grupos
-- (sedes) según un total, porque WHERE no puede usar COUNT.
-- ---------------------------------------------------------------------
SELECT s.nombre          AS sede,
       COUNT(v.id_venta) AS numero_ventas
FROM venta v
INNER JOIN sede s ON s.id_sede = v.id_sede
WHERE v.fecha BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY s.nombre
HAVING COUNT(v.id_venta) > 2
ORDER BY numero_ventas DESC;


-- ---------------------------------------------------------------------
-- C7 · INNER JOIN
-- Pregunta de negocio (enunciado): ¿cuáles son los grupos activos de cada
-- sede y qué instructor dicta cada uno?
-- ---------------------------------------------------------------------
SELECT s.nombre AS sede,
       i.primer_nombre,
       i.apellidos,
       g.id_grupo,
       g.nivel,
       g.dia_semana,
       g.hora_inicio
FROM grupo g
INNER JOIN sede       s ON s.id_sede       = g.id_sede
INNER JOIN instructor i ON i.id_instructor = g.id_instructor
WHERE g.estado = 'activo'
ORDER BY s.nombre, i.apellidos;


-- ---------------------------------------------------------------------
-- C8 · Subconsulta en WHERE (NOT IN)
-- Pregunta de negocio: ¿qué productos del catálogo nunca se han vendido?
-- (Mercancía quieta: candidata a promoción.)
-- ---------------------------------------------------------------------
SELECT id_producto,
       nombre,
       precio_venta
FROM producto
WHERE id_producto NOT IN (SELECT id_producto
                          FROM linea_venta);

-- ---------------------------------------------------------------------
-- C9 · Subconsultas dentro del SELECT
-- Pregunta de negocio (enunciado): ¿cuánto ingresó la empresa por ventas
-- y por matrículas en un período dado? (Aquí: primer semestre de 2026;
-- para otro período se cambian las fechas.)
-- Supuesto: la matrícula se paga en su fecha de inicio.
-- ---------------------------------------------------------------------
SELECT
    (SELECT SUM(l.cantidad * l.precio_unitario)
     FROM venta v
     INNER JOIN linea_venta l ON l.id_venta = v.id_venta
     WHERE v.fecha BETWEEN '2026-01-01' AND '2026-06-30')        AS ingresos_ventas,
    (SELECT SUM(valor_pagado)
     FROM matricula
     WHERE fecha_inicio BETWEEN '2026-01-01' AND '2026-06-30')   AS ingresos_matriculas;

-- =====================================================================
-- SECCIÓN 5 — VISTAS
-- Una vista es un SELECT guardado con nombre: no almacena datos, cada vez
-- que se consulta trae la información actualizada de las tablas base.
-- =====================================================================

DROP VIEW IF EXISTS v_inventario_disponible;
DROP VIEW IF EXISTS v_horario_clases;
DROP VIEW IF EXISTS v_directorio_empleados;


-- ---------------------------------------------------------------------
-- V1 · v_inventario_disponible  (consulta compleja reutilizable)
-- Propósito: el enunciado pide consultar "fácilmente el inventario
-- disponible por sede". Esta vista junta 4 tablas (inventario, sede,
-- producto y categoría), muestra solo lo que tiene stock y calcula el
-- valor de la mercancía. Así los vendedores y administradores no tienen
-- que escribir los JOINs cada vez.
-- ---------------------------------------------------------------------
CREATE VIEW v_inventario_disponible AS
SELECT s.nombre                              AS sede,
       s.ciudad,
       c.nombre                              AS categoria,
       p.marca,
       p.nombre                              AS producto,
       p.tipo,
       p.precio_venta,
       inv.stock,
       inv.stock * p.precio_venta            AS valor_en_stock
FROM inventario inv
INNER JOIN sede      s ON s.id_sede      = inv.id_sede
INNER JOIN producto  p ON p.id_producto  = inv.id_producto
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
WHERE inv.stock > 0;

-- Uso 1: ¿qué productos hay disponibles en la sede Laureles?
SELECT categoria, marca, producto, precio_venta, stock
FROM v_inventario_disponible
WHERE sede = 'Melodía Laureles'
ORDER BY categoria, producto;

-- Uso 2: ¿cuántas unidades y cuánto dinero en mercancía tiene cada sede?
SELECT sede,
       SUM(stock)          AS unidades_disponibles,
       SUM(valor_en_stock) AS valor_total_inventario
FROM v_inventario_disponible
GROUP BY sede
ORDER BY valor_total_inventario DESC;


-- ---------------------------------------------------------------------
-- V2 · v_horario_clases  (consulta compleja reutilizable)
-- Propósito: es lo que más se consulta en la parte académica. Quien quiere
-- inscribirse pregunta "¿cuándo hay clases de guitarra y quedan cupos?",
-- y cada instructor necesita ver su propio horario. La vista junta grupo,
-- sede, instructor, instrumento y matrículas, muestra solo los grupos
-- activos y calcula los cupos disponibles (dato DERIVADO: cupo máximo
-- menos matrículas activas). También responde la consulta del enunciado
-- "grupos activos por sede e instructor".
-- ---------------------------------------------------------------------
CREATE VIEW v_horario_clases AS
SELECT g.id_grupo,
       ins.nombre                                           AS instrumento,
       g.nivel,
       g.dia_semana,
       g.hora_inicio,
       g.hora_fin,
       s.nombre                                             AS sede,
       i.primer_nombre                                      AS nombre_instructor,
       i.apellidos                                          AS apellidos_instructor,
       g.precio_matricula,
       g.cupo_maximo,
       g.cupo_maximo - COUNT(m.id_matricula)                AS cupos_disponibles
FROM grupo g
INNER JOIN sede        s   ON s.id_sede          = g.id_sede
INNER JOIN instructor  i   ON i.id_instructor    = g.id_instructor
INNER JOIN instrumento ins ON ins.id_instrumento = g.id_instrumento
LEFT  JOIN matricula   m   ON m.id_grupo         = g.id_grupo
                          AND m.estado           = 'activa'
WHERE g.estado = 'activo'
GROUP BY g.id_grupo, ins.nombre, g.nivel, g.dia_semana, g.hora_inicio, g.hora_fin,
         s.nombre, i.primer_nombre, i.apellidos, g.precio_matricula, g.cupo_maximo;

-- Uso 1: ¿en qué horarios hay clases de guitarra con cupos disponibles?
SELECT sede, nivel, dia_semana, hora_inicio, hora_fin,
       nombre_instructor, apellidos_instructor, cupos_disponibles
FROM v_horario_clases
WHERE instrumento = 'Guitarra'
  AND cupos_disponibles > 0;

-- Uso 2: ¿cuál es el horario semanal de la instructora Laura Gómez?
SELECT dia_semana, hora_inicio, hora_fin, sede, instrumento, nivel
FROM v_horario_clases
WHERE nombre_instructor    = 'Laura'
  AND apellidos_instructor = 'Gómez Arbeláez';


-- ---------------------------------------------------------------------
-- V3 · v_directorio_empleados  (restringe columnas sensibles)
-- Propósito: los vendedores necesitan saber quién trabaja en cada sede,
-- su cargo y su correo (por ejemplo, para escalar algo al administrador),
-- pero NO deben ver el documento de identidad ni el salario de sus
-- compañeros. La vista expone solo los datos necesarios; en la Sección 6
-- el rol de vendedor recibe permiso sobre esta vista y no sobre la tabla
-- empleado.
-- ---------------------------------------------------------------------
CREATE VIEW v_directorio_empleados AS
SELECT e.id_empleado,
       e.primer_nombre,
       e.apellidos,
       e.cargo,
       s.nombre                                    AS sede,
       s.ciudad,
       COALESCE(e.correo, 'sin correo registrado') AS correo
FROM empleado e
INNER JOIN sede s ON s.id_sede = e.id_sede;
-- Columnas ocultas a propósito: documento, salario, fecha_ingreso.

-- Uso 1: ¿quién trabaja en la sede Laureles y cuál es su cargo?
SELECT primer_nombre, apellidos, cargo, correo
FROM v_directorio_empleados
WHERE sede = 'Melodía Laureles';

-- Uso 2: ¿quién es el administrador de cada sede?
SELECT sede, ciudad, primer_nombre, apellidos, correo
FROM v_directorio_empleados
WHERE cargo = 'administrador'
ORDER BY sede;

-- =====================================================================
-- SECCIÓN 6 — CONTROL DE ACCESO (DCL)
-- Patrón del curso: roles → usuarios. Los permisos se dan a los ROLES
-- (funciones del negocio) y cada USUARIO recibe un rol. Si llega un nuevo
-- vendedor, basta con crear su usuario y darle rol_vendedor.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 6.0 Limpieza: permite volver a ejecutar el script.
-- Primero los usuarios y después los roles. (Los permisos viejos ya se
-- borraron con el DROP TABLE ... CASCADE de la Sección 3.)
-- ---------------------------------------------------------------------
DROP USER IF EXISTS u_admin_melodia;
DROP USER IF EXISTS u_sebastian_gil;
DROP USER IF EXISTS u_paula_becerra;
DROP USER IF EXISTS u_coordinacion;

DROP ROLE IF EXISTS rol_admin_general;
DROP ROLE IF EXISTS rol_vendedor;
DROP ROLE IF EXISTS rol_coordinador_academico;


-- ---------------------------------------------------------------------
-- 6.1 Roles (funciones del negocio)
-- ---------------------------------------------------------------------
CREATE ROLE rol_admin_general;          -- gerencia / administración central
CREATE ROLE rol_vendedor;               -- personal de ventas en las sedes
CREATE ROLE rol_coordinador_academico;  -- gestión de clases, grupos y matrículas


-- ---------------------------------------------------------------------
-- 6.2 Permisos de rol_admin_general: control total
-- Administra el sistema completo: catálogo, sedes, personal (incluidos
-- salarios), ventas y la parte académica.
-- ---------------------------------------------------------------------
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO rol_admin_general;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_admin_general;


-- ---------------------------------------------------------------------
-- 6.3 Permisos de rol_vendedor: solo lo que necesita para vender
-- ---------------------------------------------------------------------
-- Consulta el catálogo y las sedes, sin modificarlos
GRANT SELECT ON producto, categoria, sede TO rol_vendedor;

-- Registra clientes nuevos y actualiza sus datos de contacto
GRANT SELECT, INSERT, UPDATE ON cliente TO rol_vendedor;

-- Registra ventas y sus líneas (no puede modificarlas ni borrarlas)
GRANT SELECT, INSERT ON venta, linea_venta TO rol_vendedor;
GRANT USAGE ON SEQUENCE venta_id_venta_seq TO rol_vendedor;   -- para el SERIAL de venta

-- Consulta el inventario y lo actualiza al vender
GRANT SELECT, UPDATE ON inventario TO rol_vendedor;

-- Vistas: inventario disponible, horario de clases (para informar a los
-- clientes) y directorio de empleados SIN documento ni salario
GRANT SELECT ON v_inventario_disponible, v_horario_clases, v_directorio_empleados
      TO rol_vendedor;

-- La tabla empleado tiene documento y salario: el vendedor no la ve.
-- Se revoca de forma explícita para dejar documentada la restricción.
REVOKE ALL PRIVILEGES ON empleado FROM rol_vendedor;


-- ---------------------------------------------------------------------
-- 6.4 Permisos de rol_coordinador_academico: la parte de clases
-- ---------------------------------------------------------------------
-- Primero puede leer todas las tablas y vistas...
GRANT SELECT ON ALL TABLES IN SCHEMA public TO rol_coordinador_academico;

-- ...y luego se le QUITA lo que no le corresponde: la información
-- comercial (clientes, ventas, productos e inventario) y la tabla de
-- empleados (salarios). Conserva las vistas de horario y directorio.
REVOKE SELECT ON cliente, venta, linea_venta, empleado,
                 producto, categoria, inventario, v_inventario_disponible
       FROM rol_coordinador_academico;

-- Gestiona alumnos, grupos y matrículas
GRANT INSERT, UPDATE ON alumno, grupo, matricula TO rol_coordinador_academico;
GRANT USAGE ON SEQUENCE matricula_id_matricula_seq TO rol_coordinador_academico;


-- ---------------------------------------------------------------------
-- 6.5 Usuarios y asignación de roles
-- ---------------------------------------------------------------------
CREATE USER u_admin_melodia WITH PASSWORD 'Admin2026*';
CREATE USER u_sebastian_gil WITH PASSWORD 'Ventas2026*';   -- vendedor sede Laureles
CREATE USER u_paula_becerra WITH PASSWORD 'Ventas2026*';   -- vendedora sede Chapinero
CREATE USER u_coordinacion  WITH PASSWORD 'Clases2026*';

GRANT rol_admin_general         TO u_admin_melodia;
GRANT rol_vendedor              TO u_sebastian_gil;
GRANT rol_vendedor              TO u_paula_becerra;
GRANT rol_coordinador_academico TO u_coordinacion;


-- ---------------------------------------------------------------------
-- 6.6 Verificación: permisos que quedaron por rol (consulta del curso)
-- ---------------------------------------------------------------------
SELECT grantee        AS rol,
       table_name     AS tabla_o_vista,
       privilege_type AS privilegio
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('rol_vendedor', 'rol_coordinador_academico')
ORDER BY grantee, table_name, privilege_type;