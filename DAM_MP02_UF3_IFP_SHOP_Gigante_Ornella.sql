/*  ------------------------------------------------------------------------------

ACTIVIDAD UF3 - PREGUNTAS

1. Creando usuario con expiración de un año

2.b) Sentencia que le asigna un rol de desarrollador R_DEV al usuario USER_IFP

------------------------------------------------------------------------------  */

1)

CREATE USER USER_IFP IDENTIFIED BY 'IFP1234';

ALTER USER USER_IFP PASSWORD EXPIRE INTERVAL 365 DAY; 


2.b) 

-- Primero se crea el rol R_DEV 

CREATE ROLE R_DEV;

-- Luego se le otorga ese rol al usuario 

GRANT R_DEV TO USER_IFP;


/*  ------------------------------------------------------------------------------






/*  ------------------------------------------------------------------------------

ACTIVIDAD UF3 - EJERCICIO 2

COMENTADRIOS:

Se crea una vista llamada "V_PRODUCTOS_PROMO" que combina datos de las siguientes tablas de la BBDD para obtener la info sobre 
los productos comprados por los clientes: 

* CLIENTES, 
* PEDIDOS, 
* DETALLES_PEDIDO, 
* PRODUCTOS, 
* TIPOS_PRODUCTOS,


La vista resultante mostraría: 

* el ID del cliente, 
* el ID del producto, 
* el ID del tipo de producto,
* la cantidad de productos comprados,
* el nombre del producto,
* el precio unitario, 
* el nombre del tipo de producto.

Luego, se realiza una consulta a la vista "V_PRODUCTOS_PROMO" 

filtrando por el ID del cliente = 3, lo cual muestra todos los productos comprados por el cliente con ID 3.



1.En primer lugar, se crea una vista llamada "v_productos_promo" utilizando la sentencia "CREATE VIEW v_productos_promo AS".
2 Dentro de la vista, se realiza una consulta utilizando la sentencia "SELECT" con varias tablas y criterios de unión.
3 Se seleccionan las columnas "c.ID_CLIENTE", "p.ID_PRODUCTO", "p.ID_TIPO_PRODUCTO", "SUM(dp.CANTIDAD_PRODUCTO) AS CANTIDAD_COMPRADA", 
  "p.NOM_PRODUCTO AS PRODUCTO", "p.PRECIO_UNITARIO", y "tp.NOM_TIPO_PRODUCTO".
4 Las tablas utilizadas en la consulta son "CLIENTES", "PEDIDOS", "DETALLES_PEDIDO", "PRODUCTOS" y "TIPOS_PRODUCTOS".
5 Los criterios de unión son "c.ID_CLIENTE = pe.ID_CLIENTE", "pe.ID_PEDIDO = dp.ID_PEDIDO", "dp.ID_PRODUCTO = p.ID_PRODUCTO",
   y "p.ID_TIPO_PRODUCTO = tp.ID_TIPO_PRODUCTO".
6 Se agrupa el resultado de la consulta utilizando la cláusula "GROUP BY" con las columnas "c.ID_CLIENTE", "p.ID_PRODUCTO", "p.ID_TIPO_PRODUCTO", 
  "p.NOM_PRODUCTO", "p.PRECIO_UNITARIO", y "tp.NOM_TIPO_PRODUCTO".
7. Luego, se realiza una segunda consulta utilizando la sentencia "SELECT * FROM v_productos_promo" para mostrar todos los registros de la vista creada.
8  Se aplica un filtro a la segunda consulta utilizando la cláusula "WHERE ID_CLIENTE=3" para mostrar únicamente los registros donde el valor de la columna
   "ID_CLIENTE" sea igual a 3.

------------------------------------------------------------------------------  */

 CREATE VIEW v_productos_promo AS SELECT c.ID_CLIENTE, p.ID_PRODUCTO, p.ID_TIPO_PRODUCTO,
 SUM(dp.CANTIDAD_PRODUCTO) AS CANTIDAD_COMPRADA, p.NOM_PRODUCTO AS PRODUCTO, p.PRECIO_UNITARIO, tp.NOM_TIPO_PRODUCTO 
 AS TIPO_PRODUCTO
 FROM CLIENTES c JOIN PEDIDOS pe ON c.ID_CLIENTE = pe.ID_CLIENTE 
 JOIN DETALLES_PEDIDO dp ON pe.ID_PEDIDO = dp.ID_PEDIDO JOIN PRODUCTOS p 
 ON dp.ID_PRODUCTO = p.ID_PRODUCTO JOIN TIPOS_PRODUCTOS tp ON p.ID_TIPO_PRODUCTO = tp.ID_TIPO_PRODUCTO GROUP BY c.ID_CLIENTE,
 p.ID_PRODUCTO, p.ID_TIPO_PRODUCTO, p.NOM_PRODUCTO, p.PRECIO_UNITARIO, tp.NOM_TIPO_PRODUCTO;
 
 SELECT * FROM v_productos_promo
 WHERE ID_CLIENTE=3;


/*  ------------------------------------------------------------------------------

ACTIVIDAD UF3 - EJERCICIO 3

COMENTADRIOS:

* Se creará un usuario llamado USUARIO_UF3 con contraseña '1234' que sólo podrá leer la vista creada en el ejercicio anterior 

* Sedará permiso de lectura al usuario creado a través de un GRANT 

------------------------------------------------------------------------------  */

--  (escribe a continuacion las sentencias SQL que estimes oportunas)



CREATE USER USUARIO_UF3 IDENTIFIED BY '1234';

GRANT SELECT ON v_productos_promo TO USUARIO_UF3;


/*  ------------------------------------------------------------------------------

ACTIVIDAD UF3 - EJERCICIO 4

COMENTADRIOS:

Esta función calcula la frecuencia mensual de los pedidos de un cliente específico. Los pasos que se realizan son los siguientes:

1. Se declara e inicializa la variable "total_pedidos" como un entero.
2. Se declara e inicializa la variable "total_meses" como un entero.
3. Se declara e inicializa la variable "media" como un decimal.
4. Se realiza una consulta para obtener el número total de pedidos del cliente con el ID especificado
   y se asigna el resultado a la variable "total_pedidos".
5. Se realiza una consulta para obtener el número total de meses en los que se realizaron pedidos del cliente con el 
   ID especificado y se asigna el resultado a la variable "total_meses".
6. Si el valor de "total_meses" es igual a cero, se asigna cero a la variable "media".
7. De lo contrario, se calcula la media dividiendo "total_pedidos" entre "total_meses" y se asigna el resultado a la variable "media".
8. Se retorna el valor de la variable "media".


------------------------------------------------------------------------------  */

 --  (escribe a continuacion las sentencias SQL que estimes oportunas)



DELIMITER //

CREATE FUNCTION FN_FREC_MENSUAL_PEDIDOS(ID_CL INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_pedidos INT;
    DECLARE total_meses INT;
    DECLARE media DECIMAL(10,2);
    
    SELECT COUNT(*) INTO total_pedidos
    FROM pedidos
    WHERE ID_CLIENTE = ID_CL;
    
    SELECT COUNT(DISTINCT EXTRACT(YEAR_MONTH FROM FECHA_PEDIDO)) INTO total_meses
    FROM pedidos
    WHERE ID_CLIENTE = ID_CL;
    
    IF total_meses = 0 THEN
        SET media = 0;
    ELSE
        SET media = total_pedidos / total_meses;
    END IF;
    
    RETURN media;
END //

DELIMITER ;

SELECT FN_FREC_MENSUAL_PEDIDOS(3) AS Media_Compras_Mensual;







/*  ------------------------------------------------------------------------------

ACTIVIDAD UF3 - EJERCICIO 5

COMENTARIOS:

1. Se crea el procedimiento "PR_CREAR_VISTA_PRODUCTOS_PROMOCION". Para ello, se utiliza la sentencia "CREATE PROCEDURE" seguido del nombre del procedimiento.
2. Dentro del procedimiento, se borra la vista existente, en caso de que exista, utilizando la sentencia "DROP VIEW IF EXISTS V_PRODUCTOS_PROMO". 
3. Se crea la vista "V_PRODUCTOS_PROMO" utilizando la sentencia "CREATE VIEW". Esta vista se crea seleccionando el descuento y todos los campos de la tabla "pedidos",
   uniéndola con la tabla "descuentos" utilizando la condición de que la frecuencia de compra sea igual a la frecuencia mensual de pedidos del cliente. 
4. Se define el delimitador como "//" para indicar el final del procedimiento. 
5. Se define nuevamente el delimitador como ";" para finalizar la sentencia. 
6: Se crea un evento programado llamado "eventoProgramado" utilizando la sentencia "CREATE EVENT IF NOT EXISTS". Este evento se ejecutará todos los días a 
   partir del 28 de noviembre de 2023 a las 00:00:00.
7: Dentro del evento, se llama al procedimiento "PR_CREAR_VISTA_PRODUCTOS_PROMOCION" utilizando la sentencia "CALL" y se seleccionan todos los registros de la 
   vista "V_PRODUCTOS_PROMO" utilizando la sentencia "SELECT * FROM V_PRODUCTOS_PROMO". 
9: Se utiliza el delimitador "//" para indicar el final del evento.

------------------------------------------------------------------------------  */

 --  (escribe a continuacion las sentencias SQL que estimes oportunas)


DELIMITER //

-- Se crea primero el procedimiento y, dentro de él, la vista


CREATE PROCEDURE PR_CREAR_VISTA_PRODUCTOS_PROMOCION()
BEGIN
    DROP VIEW IF EXISTS V_PRODUCTOS_PROMO;
    
    CREATE VIEW V_PRODUCTOS_PROMO AS
    SELECT d.DESCUENTO, p.*
    FROM pedidos p
    JOIN descuentos d ON d.FRECUENCIA_COMPRA = FN_FREC_MENSUAL_PEDIDOS(p.ID_CLIENTE);
END //

DELIMITER ;

-- Se crea un evento programado que se llamará "eventoProgramado" para que se actualice 
-- el procedimiento todas las noches se actualizará y mostrará una nueva vista actualizada

DELIMITER //
DROP EVENT IF EXISTS eventoProgramado;
CREATE EVENT IF NOT EXISTS eventoProgramado
ON SCHEDULE EVERY 1 DAY
STARTS '2023-11-28 00:00:00'
DO
BEGIN
    CALL PR_CREAR_VISTA_PRODUCTOS_PROMOCION();
    SELECT * FROM V_PRODUCTOS_PROMO;
END
 


/*  ------------------------------------------------------------------------------

ACTIVIDAD UF3 - EJERCICIO 6

COMENTADRIOS:

1. Se ejecuta primero la sentencia dada en el TP para poder crear los triggers correctamente 
2. El primer trigger, llamado "TR_PEDIDOS_INS_AUDIT", se ejecutará después de insertar una nueva fila en la tabla "pedidos". 
   Cada vez que se inserte una nueva fila, este trigger actualizará los valores de las columnas "FECHA_CREACION" (con la fecha actual), 
  "USUARIO_CREACION" (con el usuario actual), "FECHA_MODIFICACION" (con la fecha actual) y "USUARIO_MODIFICACION" (con el usuario actual).
3. El segundo trigger, llamado "TR_PEDIDOS_UPD_AUDIT", se ejecutará después de actualizar una fila existente en la tabla "pedidos". 
   Cada vez que se actualice una fila, este trigger actualizará los valores de las columnas "FECHA_MODIFICACION" (con la fecha actual) y 
  "USUARIO_MODIFICACION" (con el usuario actual).
4. Después de crear los triggers, se realiza una prueba para verificar su efectividad.

------------------------------------------------------------------------------  */

 --  (escribe a continuacion las sentencias SQL que estimes oportunas)


-- Se usan las sentencias para crear los campos de auditoría


ALTER TABLE `ifp_shop`.`pedidos`
ADD COLUMN `FECHA_CREACION` DATE NULL AFTER `ID_TRANSPORTISTA`,
ADD COLUMN `USUARIO_CREACION` VARCHAR(20) NULL AFTER `FECHA_CREACION`,
ADD COLUMN `FECHA_MODIFICACION` DATE NULL AFTER `USUARIO_CREACION`,
ADD COLUMN `USUARIO_MODIFICACION` VARCHAR(20) NULL AFTER `FECHA_MODIFICACION`;


-- Creando TRIGGER llamado TR_PEDIDOS_INS_AUDIT 

DELIMITER //

CREATE TRIGGER TR_PEDIDOS_INS_AUDIT BEFORE INSERT ON pedidos 
FOR EACH ROW
 BEGIN
 SET new.FECHA_CREACION = CURRENT_DATE();
 SET new.USUARIO_CREACION = CURRENT_USER(); 
 SET new.FECHA_MODIFICACION = CURRENT_DATE();
 SET new.USUARIO_MODIFICACION = CURRENT_USER();
 END //

DELIMITER ;


-- Creando TRIGGER llamado TR_PEDIDOS_UPD_AUDIT 

DELIMITER //

CREATE TRIGGER TR_PEDIDOS_UPD_AUDIT BEFORE UPDATE
 ON pedidos
 FOR EACH ROW
 BEGIN
 SET new.FECHA_MODIFICACION = CURRENT_DATE();
 SET new.USUARIO_MODIFICACION = CURRENT_USER(); 
 END //

DELIMITER ;


-- Comprobando efectividad de TR_PEDIDOS_INS_AUDIT insertando datos

 INSERT INTO pedidos (NUM_PEDIDO, FECHA_PEDIDO, FECHA_ENVIO, ESTADO_PEDIDO, ID_CLIENTE, ID_PAGO, ID_TRANSPORTISTA) 
 VALUES ('12', '2021-01-01', '2021-01-05', 'En Proceso', 1, 1, 1);


-- Comprobando efectividad TR_PEDIDOS_UPD_AUDIT 


UPDATE pedidos SET estado_pedido = 'Estado Modificado' WHERE ID_PEDIDO = 12;


-- Comprobando la efectividad ejecutando el procedimiento de carga


CALL  ifp_shop.PR_CARGA_PEDIDOS(12);


--Otra manera de comprobar haciendo una consulta SELECT sobre la tabla PEDIDOS para verificar 
  completamente que todos los datos hayan ingresado bien 


SELECT * FROM PEDIDOS