# Datos de prueba

Contenido completo de las 15 tablas después de ejecutar el script. Total: 161 filas. Las celdas con NULL no tienen valor.

## SEDE (5 filas)

| id_sede | nombre | ciudad | calle | numero | barrio | telefono | id_administrador |
|---|---|---|---|---|---|---|---|
| SED-BAQ | Melodía El Prado | Barranquilla | Carrera 54 | 70-110 | El Prado | 6053581122 | EMP-07 |
| SED-BOG | Melodía Chapinero | Bogotá | Carrera 13 | 54-20 | Chapinero | 6013456789 | EMP-03 |
| SED-BUC | Melodía Cabecera | Bucaramanga | Calle 52 | 35-18 | NULL | 6076345566 | EMP-09 |
| SED-CAL | Melodía Granada | Cali | Avenida 9 Norte | 15-32 | Granada | 6026678899 | EMP-05 |
| SED-MED | Melodía Laureles | Medellín | Circular 73 | 39-45 | Laureles | 6044112233 | EMP-01 |

## EMPLEADO (10 filas)

| id_empleado | documento | primer_nombre | apellidos | cargo | fecha_ingreso | salario | correo | id_sede |
|---|---|---|---|---|---|---|---|---|
| EMP-01 | 43876543 | Claudia | Ríos Montoya | administrador | 2018-03-01 | 4800000.00 | claudia.rios@melodia.co | SED-MED |
| EMP-02 | 1037612345 | Sebastián | Gil Ochoa | vendedor | 2021-06-15 | 2100000.00 | sebastian.gil@melodia.co | SED-MED |
| EMP-03 | 52987321 | Ricardo | Mora Salazar | administrador | 2019-01-10 | 4700000.00 | ricardo.mora@melodia.co | SED-BOG |
| EMP-04 | 1019876543 | Paula | Becerra Niño | vendedor | 2022-02-01 | 2000000.00 | paula.becerra@melodia.co | SED-BOG |
| EMP-05 | 31456987 | Gloria | Cuéllar Lozano | administrador | 2020-08-03 | 4500000.00 | gloria.cuellar@melodia.co | SED-CAL |
| EMP-06 | 1144098765 | Andrés | Quintero Paz | vendedor | 2023-04-17 | 1900000.00 | NULL | SED-CAL |
| EMP-07 | 72198456 | Jorge | Barrios De la Hoz | administrador | 2020-11-23 | 4500000.00 | jorge.barrios@melodia.co | SED-BAQ |
| EMP-08 | 1045123987 | Melissa | Charris Ortega | vendedor | 2024-01-08 | 1850000.00 | melissa.charris@melodia.co | SED-BAQ |
| EMP-09 | 91234876 | Hernán | Duarte Rueda | administrador | 2026-02-02 | 4200000.00 | hernan.duarte@melodia.co | SED-BUC |
| EMP-10 | 1000987123 | Mateo | Zapata Correa | vendedor | 2026-08-01 | 1800000.00 | NULL | SED-MED |

## CATEGORIA (5 filas)

| id_categoria | nombre | descripcion |
|---|---|---|
| CAT-CUE | Cuerdas | Guitarras, violines, bajos y sus accesorios |
| CAT-ELE | Electrónica | NULL |
| CAT-PER | Percusión | Baterías, cajones, bongós y baquetas |
| CAT-TEC | Teclas | Pianos digitales, teclados y sintetizadores |
| CAT-VIE | Vientos | Flautas, saxofones, clarinetes y trompetas |

## PRODUCTO (13 filas)

| id_producto | referencia | nombre | marca | tipo | precio_venta | descripcion_tecnica | id_categoria |
|---|---|---|---|---|---|---|---|
| PRD-01 | YAM-C40 | Guitarra acústica C40 | Yamaha | instrumento | 650000.00 | Tapa de abeto, cuerdas de nailon, 4/4 | CAT-CUE |
| PRD-02 | FEN-SQ-STRAT | Guitarra eléctrica Squier Strat | Fender | instrumento | 1890000.00 | Tres pastillas single coil, puente trémolo | CAT-CUE |
| PRD-03 | STE-STU1-44 | Violín Student I 4/4 | Stentor | instrumento | 980000.00 | Incluye arco y estuche | CAT-CUE |
| PRD-04 | DAD-EJ16 | Juego de cuerdas EJ16 | D'Addario | accesorio | 45000.00 | Bronce fosforado, calibre light 12-53 | CAT-CUE |
| PRD-05 | YAM-YFL222 | Flauta traversa YFL-222 | Yamaha | instrumento | 2850000.00 | NULL | CAT-VIE |
| PRD-06 | JUP-JAS500 | Saxofón alto JAS500 | Jupiter | instrumento | 4200000.00 | Afinación en Mi bemol, lacado dorado | CAT-VIE |
| PRD-07 | MEI-CAJ1 | Cajón peruano | Meinl | instrumento | 520000.00 | NULL | CAT-PER |
| PRD-08 | PEA-RS525 | Batería acústica Roadshow | Pearl | instrumento | 3600000.00 | Cinco cuerpos, platillos y herrajes incluidos | CAT-PER |
| PRD-09 | VIC-5A | Baquetas 5A | Vic Firth | accesorio | 55000.00 | NULL | CAT-PER |
| PRD-10 | YAM-PSRE373 | Teclado PSR-E373 | Yamaha | instrumento | 1250000.00 | 61 teclas sensibles, 622 voces | CAT-TEC |
| PRD-11 | CAS-CDPS110 | Piano digital CDP-S110 | Casio | instrumento | 2100000.00 | 88 teclas con acción de martillo | CAT-TEC |
| PRD-12 | BOS-TU3 | Pedal afinador TU-3 | Boss | accesorio | 480000.00 | NULL | CAT-ELE |
| PRD-13 | FOC-2I2-G4 | Interfaz de audio Scarlett 2i2 | Focusrite | accesorio | 950000.00 | Dos entradas, 24 bits / 192 kHz | CAT-ELE |

## INVENTARIO (27 filas)

| id_sede | id_producto | stock |
|---|---|---|
| SED-BAQ | PRD-04 | 10 |
| SED-BAQ | PRD-05 | 0 |
| SED-BAQ | PRD-07 | 2 |
| SED-BAQ | PRD-09 | 12 |
| SED-BOG | PRD-01 | 3 |
| SED-BOG | PRD-02 | 1 |
| SED-BOG | PRD-03 | 2 |
| SED-BOG | PRD-04 | 25 |
| SED-BOG | PRD-08 | 2 |
| SED-BOG | PRD-10 | 0 |
| SED-BOG | PRD-12 | 2 |
| SED-BUC | PRD-01 | 2 |
| SED-BUC | PRD-04 | 10 |
| SED-BUC | PRD-10 | 1 |
| SED-CAL | PRD-01 | 2 |
| SED-CAL | PRD-03 | 1 |
| SED-CAL | PRD-04 | 15 |
| SED-CAL | PRD-05 | 1 |
| SED-MED | PRD-01 | 4 |
| SED-MED | PRD-02 | 2 |
| SED-MED | PRD-04 | 30 |
| SED-MED | PRD-07 | 3 |
| SED-MED | PRD-08 | 1 |
| SED-MED | PRD-09 | 20 |
| SED-MED | PRD-10 | 2 |
| SED-MED | PRD-11 | 1 |
| SED-MED | PRD-12 | 0 |

## CLIENTE (9 filas)

| documento | primer_nombre | apellidos | correo | telefono |
|---|---|---|---|---|
| 1001234567 | Juan Pablo | Mesa Ríos | jp.mesa@gmail.com | 3045556677 |
| 1020456789 | Daniela | Castro Mejía | daniela.castro@hotmail.com | 3157894561 |
| 1036987654 | Tomás | Arango Vélez | NULL | 3206549873 |
| 16789234 | Felipe | Ramírez Torres | felipe.ramirez@gmail.com | 3182345678 |
| 32456781 | Carolina | Díaz Salcedo | caro.diaz@yahoo.com | 3014567321 |
| 43512876 | Mariana | López Henao | mariana.lopez@gmail.com | 3104567890 |
| 43987123 | Patricia | Londoño Gómez | patricia.londono@gmail.com | 3189990011 |
| 52345678 | Natalia | Suárez Pinto | natalia.suarez@gmail.com | 3112223344 |
| 71234589 | Santiago | Pérez Gil | NULL | 3001234567 |

## VENTA (12 filas)

| id_venta | fecha | forma_pago | documento_cliente | id_sede | id_vendedor |
|---|---|---|---|---|---|
| 1 | 2026-01-15 | tarjeta | 43512876 | SED-MED | EMP-02 |
| 2 | 2026-02-03 | efectivo | 71234589 | SED-MED | EMP-02 |
| 3 | 2026-02-20 | transferencia | 1020456789 | SED-BOG | EMP-04 |
| 4 | 2026-03-11 | tarjeta | 43512876 | SED-BOG | EMP-04 |
| 5 | 2026-04-05 | efectivo | 16789234 | SED-CAL | EMP-06 |
| 6 | 2026-04-22 | tarjeta | 32456781 | SED-BAQ | EMP-08 |
| 7 | 2026-05-14 | transferencia | 43987123 | SED-MED | EMP-02 |
| 8 | 2026-06-09 | efectivo | 71234589 | SED-MED | EMP-02 |
| 9 | 2026-07-18 | tarjeta | 52345678 | SED-BOG | EMP-04 |
| 10 | 2026-08-25 | transferencia | 1020456789 | SED-CAL | EMP-06 |
| 11 | 2026-09-30 | tarjeta | 16789234 | SED-BAQ | EMP-08 |
| 12 | 2026-10-20 | efectivo | 43512876 | SED-MED | EMP-02 |

## LINEA_VENTA (18 filas)

| id_venta | num_linea | id_producto | cantidad | precio_unitario |
|---|---|---|---|---|
| 1 | 1 | PRD-01 | 1 | 600000.00 |
| 1 | 2 | PRD-04 | 2 | 45000.00 |
| 2 | 1 | PRD-07 | 1 | 520000.00 |
| 3 | 1 | PRD-02 | 1 | 1890000.00 |
| 3 | 2 | PRD-12 | 1 | 480000.00 |
| 4 | 1 | PRD-10 | 1 | 1250000.00 |
| 5 | 1 | PRD-03 | 1 | 950000.00 |
| 5 | 2 | PRD-04 | 1 | 45000.00 |
| 6 | 1 | PRD-06 | 1 | 4200000.00 |
| 7 | 1 | PRD-11 | 1 | 2100000.00 |
| 8 | 1 | PRD-09 | 3 | 55000.00 |
| 8 | 2 | PRD-04 | 3 | 45000.00 |
| 9 | 1 | PRD-01 | 2 | 650000.00 |
| 10 | 1 | PRD-05 | 1 | 2850000.00 |
| 11 | 1 | PRD-07 | 1 | 520000.00 |
| 11 | 2 | PRD-09 | 2 | 55000.00 |
| 12 | 1 | PRD-12 | 1 | 480000.00 |
| 12 | 2 | PRD-04 | 1 | 45000.00 |

## INSTRUMENTO (7 filas)

| id_instrumento | nombre |
|---|---|
| INS-BAJ | Bajo eléctrico |
| INS-BAT | Batería |
| INS-FLA | Flauta traversa |
| INS-GUI | Guitarra |
| INS-PIA | Piano |
| INS-SAX | Saxofón |
| INS-VIO | Violín |

## INSTRUCTOR (6 filas)

| id_instructor | documento | primer_nombre | apellidos | telefono | tarifa_hora | fecha_vinculacion |
|---|---|---|---|---|---|---|
| INT-01 | 98765432 | Andrés | Restrepo Uribe | 3001112233 | 65000.00 | 2017-02-01 |
| INT-02 | 43219876 | Laura | Gómez Arbeláez | 3014445566 | 70000.00 | 2019-07-15 |
| INT-03 | 80123456 | Camilo | Vargas León | 3127778899 | 60000.00 | 2020-01-20 |
| INT-04 | 1018456123 | Sofía | Martínez Rojas | NULL | 75000.00 | 2021-09-01 |
| INT-05 | 72345987 | Julián | Ospina Navarro | 3156663322 | 68000.00 | 2022-03-14 |
| INT-06 | 1098765432 | Valentina | Rojas Cárdenas | 3174441100 | 55000.00 | 2026-06-01 |

## INSTRUCTOR_ESPECIALIDAD (10 filas)

| id_instructor | id_instrumento |
|---|---|
| INT-01 | INS-BAJ |
| INT-01 | INS-GUI |
| INT-02 | INS-PIA |
| INT-02 | INS-VIO |
| INT-03 | INS-BAT |
| INT-04 | INS-VIO |
| INT-05 | INS-FLA |
| INT-05 | INS-SAX |
| INT-06 | INS-GUI |
| INT-06 | INS-PIA |

## INSTRUCTOR_SEDE (9 filas)

| id_instructor | id_sede |
|---|---|
| INT-01 | SED-MED |
| INT-02 | SED-CAL |
| INT-02 | SED-MED |
| INT-03 | SED-BAQ |
| INT-03 | SED-BOG |
| INT-04 | SED-BOG |
| INT-05 | SED-BAQ |
| INT-05 | SED-CAL |
| INT-06 | SED-BUC |

## GRUPO (8 filas)

| id_grupo | nivel | dia_semana | hora_inicio | hora_fin | cupo_maximo | precio_matricula | estado | id_sede | id_instructor | id_instrumento |
|---|---|---|---|---|---|---|---|---|---|---|
| GR-01 | iniciacion | lunes | 16:00:00 | 18:00:00 | 8 | 280000.00 | activo | SED-MED | INT-01 | INS-GUI |
| GR-02 | intermedio | miercoles | 18:00:00 | 20:00:00 | 6 | 320000.00 | activo | SED-MED | INT-02 | INS-PIA |
| GR-03 | iniciacion | sabado | 09:00:00 | 11:00:00 | 10 | 250000.00 | activo | SED-BOG | INT-03 | INS-BAT |
| GR-04 | avanzado | martes | 17:00:00 | 19:00:00 | 4 | 380000.00 | activo | SED-BOG | INT-04 | INS-VIO |
| GR-05 | intermedio | jueves | 15:00:00 | 17:00:00 | 6 | 300000.00 | activo | SED-CAL | INT-02 | INS-VIO |
| GR-06 | iniciacion | viernes | 16:00:00 | 18:00:00 | 8 | 290000.00 | activo | SED-BAQ | INT-05 | INS-SAX |
| GR-07 | intermedio | lunes | 18:00:00 | 20:00:00 | 6 | 300000.00 | activo | SED-MED | INT-01 | INS-GUI |
| GR-08 | iniciacion | sabado | 10:00:00 | 12:00:00 | 8 | 260000.00 | cerrado | SED-BAQ | INT-03 | INS-BAT |

## ALUMNO (9 filas)

| documento | primer_nombre | apellidos | fecha_nacimiento | correo | telefono |
|---|---|---|---|---|---|
| 1001456789 | Isabella | Henao Mejía | 2010-05-14 | NULL | 3101239876 |
| 1012345678 | Emiliano | Rincón Suárez | 2011-03-30 | NULL | 3206667788 |
| 1015678934 | Martina | Cárdenas Peña | 2013-12-05 | NULL | 3112224466 |
| 1023987456 | Samuel | Ortiz Galeano | 2004-11-02 | samuel.ortiz@gmail.com | 3008887766 |
| 1032789456 | Nicolás | Bermúdez Sierra | 2001-07-19 | nico.bermudez@hotmail.com | 3045671234 |
| 1034567812 | Valeria | Quiroga Ruiz | 2012-08-23 | NULL | 3135554433 |
| 1048765123 | Daniel | Fontalvo Rada | 2008-01-27 | NULL | 3013332211 |
| 1143987654 | Gabriela | Lozada Vidal | 1999-10-11 | gaby.lozada@gmail.com | 3168889900 |
| 43987123 | Patricia | Londoño Gómez | 1978-02-09 | patricia.londono@gmail.com | 3189990011 |

## MATRICULA (13 filas)

| id_matricula | documento_alumno | id_grupo | fecha_inicio | fecha_fin_estimada | estado | valor_pagado |
|---|---|---|---|---|---|---|
| 1 | 1001456789 | GR-01 | 2026-02-02 | 2026-11-30 | activa | 280000.00 |
| 2 | 1023987456 | GR-01 | 2026-02-02 | 2026-11-30 | activa | 250000.00 |
| 3 | 1034567812 | GR-01 | 2026-03-02 | 2026-12-15 | pausada | 280000.00 |
| 4 | 43987123 | GR-02 | 2026-01-19 | 2026-12-15 | activa | 320000.00 |
| 5 | 1001456789 | GR-02 | 2026-07-06 | 2027-01-30 | activa | 320000.00 |
| 6 | 1012345678 | GR-03 | 2026-02-07 | 2026-11-28 | activa | 250000.00 |
| 7 | 1015678934 | GR-03 | 2026-02-07 | 2026-11-28 | activa | 250000.00 |
| 8 | 1032789456 | GR-04 | 2026-04-07 | 2026-12-15 | activa | 380000.00 |
| 9 | 1143987654 | GR-05 | 2025-07-01 | 2025-12-05 | finalizada | 280000.00 |
| 10 | 1143987654 | GR-05 | 2026-05-07 | 2026-12-10 | activa | 300000.00 |
| 11 | 1048765123 | GR-06 | 2026-08-07 | 2027-02-26 | activa | 290000.00 |
| 12 | 1012345678 | GR-08 | 2025-08-02 | 2025-12-13 | finalizada | 240000.00 |
| 13 | 1015678934 | GR-08 | 2025-08-02 | 2025-12-13 | finalizada | 260000.00 |
