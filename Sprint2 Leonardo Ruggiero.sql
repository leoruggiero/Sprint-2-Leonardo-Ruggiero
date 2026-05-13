-- Ejercicio 1
-- A partir de los documentos adjuntos (estructura_datos y datos_introducir), importa las dos tablas. 
-- Muestra las principales características del esquema creado y explica las diferentes tablas y variables que existen. 
-- Asegúrate de incluir un diagrama que ilustre la relación entre las distintas tablas y variables.

erDiagram
    COMPANY ||--o{ TRANSACTION : "realiza"
    COMPANY {
        varchar id PK
        varchar company_name
        varchar phone
        varchar email
        varchar country
        varchar website
    }
    TRANSACTION {
        varchar id PK
        varchar company_id FK
        varchar credit_card_id
        int user_id
        float lat
        float longitude
        timestamp timestamp
        decimal amount
        boolean declined
    }
    
    
-- Ejercicio 2
-- Utilizando JOIN realizarás las siguientes consultas:

-- 2.1 Listado de los países que están generando ventas.

SELECT DISTINCT country 
FROM company c
JOIN transaction t
ON c.id = t.company_id
where declined = 0;


-- 2.2 Desde cuántos países se generan las ventas.

SELECT COUNT(DISTINCT country)
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE declined = 0;


-- 2.3 Identifica a la compañía con la mayor media de ventas.

SELECT c.company_name, ROUND(AVG(amount),2) AS media
FROM transaction t
JOIN company c
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY company_id
ORDER BY media DESC
LIMIT 1;



-- Ejercicio 3

-- Utilizando sólo subconsultas (sin utilizar JOIN):

-- 3.1 Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT *
FROM transaction t
WHERE EXISTS (SELECT company_id FROM company c WHERE c.id = t.company_id AND c.country = 'Germany' AND t.declined = 0);



-- 3.2 Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT c.company_name
FROM company as c
WHERE EXISTS (
	SELECT id
    FROM transaction as t 
    WHERE t.company_id = c.id AND t.amount > (SELECT AVG(amount) FROM transaction) AND t.declined = 0);
    

-- 3.3 Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas 
-- empresas.

SELECT *
FROM company c
WHERE NOT EXISTS ( SELECT id FROM transaction t WHERE t.company_id = c.id AND t.declined = 1);


-- Ejercicio 4

-- Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
-- La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas 
-- ("transaction" y "company"). Después de crear la tabla será necesario que ingreses la información del documento 
-- denominado "datos_introducir_credit". Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

-- CUANDO CREAR TABLA PONER IF NOT EXISTS

-- SCREENSHOT SO DO DIAGRAMA SEM MAIS NADA
DROP TABLE credit_card;

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50),
    pan VARCHAR(20),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    expiring_date VARCHAR(10)
);



ALTER TABLE credit_card ADD COLUMN expiring_date DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card 
SET expiring_date_new = STR_TO_DATE(expiring_date, '%m/%d/%y')
WHERE id IS NOT NULL;

ALTER TABLE credit_card DROP COLUMN expiring_date;

ALTER TABLE credit_card CHANGE COLUMN expiring_date_new expiring_date DATE;

SET SQL_SAFE_UPDATES = 1;

-- Ejercicio 5
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938.
-- La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.

SELECT *
FROM credit_card
WHERE id = "CcU-2938";

UPDATE credit_card SET iban = "TR323456312213576817699999" where id = "CcU-2938";

SELECT *
FROM credit_card
WHERE id = "CcU-2938";

-- Ejercicio 6
-- En la tabla "transaction" ingresa una nueva transacción con la siguiente información:

INSERT INTO user (id) VALUES (9999);

INSERT INTO credit_card (id) VALUES ('CcU-9999');

INSERT INTO company (id, company_name) VALUES ("b-9999", "Barcelona Activa");

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", 9999, 829.999, -117.999, 111.11, 0); 



SELECT *
FROM transaction
WHERE company_id = "b-9999";


-- Ejercicio 7
-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.

SELECT pan
FROM credit_card;

ALTER TABLE credit_card DROP COLUMN pan;


-- Ejercicio 8
-- Descarga los archivos CSV que encontrarás en el apartado de recursos :

-- american_users.csv
-- european_users.csv
-- companies.csv
-- credit_cards.csv
-- transactions.csv

-- Estudia y diseña una base de datos con un esquema de estrella que contenga, al menos 4 tablas de las que puedas realizar las siguientes consultas:
-- COLOCAR NOT EXISTS

CREATE DATABASE IF NOT EXISTS ejercicio4;
USE ejercicio4;

CREATE TABLE user (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    birth_date VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);

CREATE TABLE company (
    id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE credit_card (
    id VARCHAR(15) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(20),
    pin VARCHAR(10),
    cvv VARCHAR(10),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date DATE
);

CREATE TABLE transaction (
    id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(15),
    business_id VARCHAR(15),
    timestamp TIMESTAMP,
    amount DECIMAL(10,2),
    declined TINYINT(1),
    product_ids VARCHAR(255),
    user_id INT,
    lat FLOAT,
    longitude FLOAT,
    FOREIGN KEY (card_id) REFERENCES credit_card(id),
    FOREIGN KEY (business_id) REFERENCES company(id),
    FOREIGN KEY (user_id) REFERENCES user(id)
);



USE ejercicio4; 

SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE '/tmp/N1-Ex.8__ american_users.csv' 
INTO TABLE user FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE '/tmp/N1.Ex.8__ european_users.csv' 
INTO TABLE user FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE '/tmp/N1.Ex.8__ companies.csv' 
INTO TABLE company FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA INFILE '/tmp/N1.Ex.8__ credit_cards.csv' 
INTO TABLE credit_card FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @v_expiring_date)
SET expiring_date = STR_TO_DATE(@v_expiring_date, '%m/%d/%y');

LOAD DATA INFILE '/tmp/N1.Ex.8__ transactions.csv' 
IGNORE INTO TABLE transaction FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;

SELECT country, COUNT(*) as total 
FROM user 
GROUP BY country;


-- Ejercicio 9
-- Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.


SELECT id, name, surname, country
FROM user as u
WHERE EXISTS (
		SELECT user_id 
		FROM transaction as t
		WHERE t.user_id = u.id and declined = 0
		GROUP BY t.user_id 
		HAVING COUNT(*) > 80);


-- Ejercicio 10
-- Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.

SELECT * FROM transaction WHERE business_id = "b-2242";
 
SELECT AVG(AMOUNT) AS media_amount, iban, business_id
FROM transaction
JOIN credit_card ON transaction.card_id = credit_card.id
WHERE business_id = "b-2242" AND declined = 0 
GROUP BY iban;


-- Nivel 2

-- Ejercicio 1
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(timestamp) AS dias, SUM(amount) AS mayor_cantidad_de_ingresos
FROM transaction
WHERE declined = 0
GROUP BY dias
ORDER BY mayor_cantidad_de_ingresos DESC
LIMIT 5;

-- Ejercicio 2
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido 
-- entre 350 y 400 euros y en alguna de estas fechas:
-- 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.

SELECT company_name, phone, country, DATE(timestamp) as fecha, amount, declined
FROM transaction as t
JOIN company as c
ON t.business_id = c.id
WHERE t.amount BETWEEN 350 AND 400
AND (DATE(t.timestamp) = "2015-04-29" or DATE(t.timestamp) = "2018-07-20" or DATE(t.timestamp) = "2024-03-13")
AND t.declined = "0"
ORDER BY amount DESC;


-- Ejercicio 3
-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre la cantidad de transacciones 
-- que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques si tienen igual o más de 
-- 400 transacciones o menos.

SELECT c.company_name, COUNT(t.id) AS total_transaciones, 
    CASE 
        WHEN COUNT(t.id) >= 400 THEN 'Igual o más de 400' 
        ELSE 'Menos de 400' 
    END AS contaje_valores 
FROM company c 
JOIN transaction t ON t.business_id = c.id 
GROUP BY c.company_name 
ORDER BY total_transaciones;

-- Ejercicio 4
-- Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.


DELETE FROM transaction
where id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";


SELECT * FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';


-- Ejercicio 5
-- La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. Se ha solicitado crear una vista que proporcione 
-- detalles clave sobre las compañías y sus transacciones. Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: Nombre de la compañía.
-- Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.

CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country, AVG(amount) AS media_por_compania
FROM company
JOIN transaction ON company.id = transaction.business_id
WHERE declined = 0
GROUP BY company_name, phone, country;

SELECT * FROM VistaMarketing
ORDER BY media_por_compania DESC;	

-- Nivel 3
-- Ejercicio 1
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas transacciones han sido declinadas entonces es inactivo, si al menos una no 
-- es rechazada entonces es activo. Partiendo de esta tabla responde:
-- 👉 ¿Cuántas tarjetas están activas?

WITH UltimasTransacciones AS 
(SELECT card_id, declined, ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) as fila
    FROM transaction
)
SELECT status, COUNT(*) AS total_tarjetas
FROM (SELECT card_id,
	CASE WHEN SUM(declined) = COUNT(declined) AND COUNT(declined) >= 3 THEN 'Inactivo'
		ELSE 'Activo'
        END AS status
    FROM UltimasTransacciones
    WHERE fila <= 3
    GROUP BY card_id
) AS ResumenEstado
GROUP BY status;

-- Ejercicio 2
-- Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction tienes product_ids.
-- Genera la siguiente consulta: 👉 Necesitamos conocer el número de veces que se ha vendido cada producto.

CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price VARCHAR(50),
    colour VARCHAR(50),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(50)
);
LOAD DATA INFILE '/Users/leonardoruggiero/Documents/Curso Especializaçao 2026 SQL/N3.Ex.2__ products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, price, colour, weight, warehouse_id);


SELECT p.id AS product_id, p.product_name, t.id AS transaction_id
FROM transaction t
JOIN JSON_TABLE(CONCAT('[', t.product_ids, ']'), '$[*]' COLUMNS (product_id INT PATH '$')) AS jt ON TRUE
JOIN products p ON p.id = jt.product_id
WHERE t.declined = 0;


SELECT JSON_ARRAYAGG( JSON_OBJECT( 'product_id', product_id, 'product_name', product_name,'total_vendas', total_vendas)) AS resultado_json

FROM (SELECT p.id AS product_id,p.product_name,COUNT(*) AS total_vendas
    FROM transaction t
    JOIN JSON_TABLE( CONCAT('[', t.product_ids, ']'), '$[*]' COLUMNS (product_id INT PATH '$')) AS jt ON TRUE
    JOIN products p ON p.id = jt.product_id
    WHERE t.declined = 0
    GROUP BY p.id, p.product_name
    ORDER BY total_vendas DESC
) AS summary;






