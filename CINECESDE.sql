CREATE DATABASE dbCineScriptCESDE;

USE dbCineScriptCESDE;

CREATE TABLE tblPeliculas
(
    peliculaId CHAR(20) PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    duracionMinutos INT,
    genero VARCHAR(30) NOT NULL,
    clasificacionEdad INT NOT NULL
);

ALTER TABLE tblPeliculas
ADD CONSTRAINT UQ_titulo UNIQUE (titulo);

ALTER TABLE tblPeliculas
ADD precioBase MONEY NOT NULL DEFAULT 20000;

CREATE TABLE tblSalas
(
    salaId INT PRIMARY KEY IDENTITY(1,1),
    nombreSala VARCHAR(30) NOT NULL,
    capacidad INT
);

CREATE TABLE tblFunciones
(
    funcionId VARCHAR(10) PRIMARY KEY,
    horario DATETIME2,
    peliculaId CHAR(20),
    salaId INT,

    CONSTRAINT FK_tblFunciones_tblPeliculas
    FOREIGN KEY (peliculaId)
    REFERENCES tblPeliculas(peliculaId),

    CONSTRAINT FK_tblFunciones_tblSalas
    FOREIGN KEY (salaId)
    REFERENCES tblSalas(salaId)
);

CREATE TABLE tblClientes
(
    clienteId INT PRIMARY KEY IDENTITY(1,1),
    correo VARCHAR(100) NOT NULL,
    nombreCliente VARCHAR(50) NOT NULL
);

CREATE TABLE tblBoletas
(
    boletaId INT PRIMARY KEY IDENTITY(1,1),
    fechaVenta DATETIME,
    precio MONEY NOT NULL,
    cantidadBoletas INT,
    clienteId INT,
    funcionId VARCHAR(10),

    CONSTRAINT FK_tblBoletas_tblFunciones
    FOREIGN KEY (funcionId)
    REFERENCES tblFunciones(funcionId),

    CONSTRAINT FK_tblBoletas_tblClientes
    FOREIGN KEY (clienteId)
    REFERENCES tblClientes(clienteId)
);

INSERT INTO tblPeliculas
(peliculaId, titulo, duracionMinutos, genero, clasificacionEdad)
VALUES
('CSC-001','Avatar El Camino del Agua',192,'Ciencia Ficcion',12),
('CSC-002','Oppenheimer',180,'Drama',15),
('CSC-003','Intensamente 2',96,'Animacion',0),
('CSC-004','Mision Imposible Sentencia Final',163,'Accion',13),
('CSC-005','Duna Parte Dos',166,'Ciencia Ficcion',13),
('CSC-006','El Conjuro 3',112,'Terror',18),
('CSC-007','Kung Fu Panda 4',94,'Comedia',0),
('CSC-008','Gladiador II',150,'Historica',15),
('CSC-009','Minecraft La Pelicula',110,'Aventura',7),
('CSC-010','Venom El Ultimo Baile',118,'Accion',12);

INSERT INTO tblSalas
(nombreSala, capacidad)
VALUES
('Sala Diamante',180),
('Sala Esmeralda',120),
('Sala Rubi',90),
('Sala Zafiro',200),
('Sala Platino',60),
('Sala Titanio',150),
('Sala Oro',80),
('Sala Perla',220),
('Sala Onix',170),
('Sala Cristal',130);

INSERT INTO tblFunciones
(funcionId, horario, peliculaId, salaId)
VALUES
('JUN1001','2026-06-10 10:00:00','CSC-001',1),
('JUN1002','2026-06-10 13:00:00','CSC-002',2),
('JUN1003','2026-06-10 15:30:00','CSC-003',3),
('JUN1004','2026-06-10 18:00:00','CSC-004',4),
('JUN1005','2026-06-11 11:00:00','CSC-005',5),
('JUN1006','2026-06-11 14:00:00','CSC-006',6),
('JUN1007','2026-06-11 16:30:00','CSC-007',7),
('JUN1008','2026-06-11 19:00:00','CSC-008',8),
('JUN1009','2026-06-12 15:00:00','CSC-009',9),
('JUN1010','2026-06-12 20:00:00','CSC-010',10);

INSERT INTO tblClientes
(correo, nombreCliente)
VALUES
('juan.perez@gmail.com','Juan Perez'),
('maria.gomez@gmail.com','Maria Gomez'),
('carlos.rodriguez@gmail.com','Carlos Rodriguez'),
('ana.martinez@gmail.com','Ana Martinez'),
('luis.garcia@gmail.com','Luis Garcia'),
('laura.hernandez@gmail.com','Laura Hernandez'),
('andres.moreno@gmail.com','Andres Moreno'),
('sofia.ramirez@gmail.com','Sofia Ramirez'),
('diego.castro@gmail.com','Diego Castro'),
('valentina.torres@gmail.com','Valentina Torres');

INSERT INTO tblBoletas
(precio, cantidadBoletas, clienteId, funcionId)
VALUES
(24000,2,1,'JUN1001'),
(18000,1,2,'JUN1002'),
(36000,3,3,'JUN1003'),
(48000,4,4,'JUN1004'),
(25000,1,5,'JUN1005'),
(50000,2,6,'JUN1006'),
(30000,2,7,'JUN1007'),
(60000,3,8,'JUN1008'),
(20000,1,9,'JUN1009'),
(75000,5,10,'JUN1010');

CREATE LOGIN Encargado
WITH PASSWORD = 'cinescript';

CREATE USER Encargado FOR LOGIN Encargado;

GRANT SELECT ON tblPeliculas TO Encargado;

SELECT genero, COUNT(*) AS CantidadPeliculas
FROM tblPeliculas
GROUP BY genero;

SELECT SUM(capacidad) AS CapacidadTotal
FROM tblSalas;

UPDATE tblSalas
SET capacidad = capacidad - 1
WHERE salaId = 1;

DELETE FROM tblClientes
WHERE clienteId NOT IN
(
    SELECT DISTINCT clienteId
    FROM tblBoletas
);

SELECT
    P.titulo AS Pelicula,
    F.horario AS Horario,
    S.nombreSala AS Sala,
    S.capacidad AS Capacidad
FROM tblPeliculas P
INNER JOIN tblFunciones F
    ON P.peliculaId = F.peliculaId
INNER JOIN tblSalas S
    ON F.salaId = S.salaId;

CREATE PROCEDURE usp_Registrar_Compra
(
    @clienteId INT,
    @funcionId VARCHAR(10),
    @cantidadBoletas INT,
    @precio MONEY
)
AS
BEGIN
    INSERT INTO tblBoletas
    (
        fechaVenta,
        precio,
        cantidadBoletas,
        clienteId,
        funcionId
    )
    VALUES
    (
        GETDATE(),
        @precio,
        @cantidadBoletas,
        @clienteId,
        @funcionId
    );
END;

EXEC usp_Registrar_Compra
    @clienteId = 1,
    @funcionId = 'JUN1001',
    @cantidadBoletas = 2,
    @precio = 24000;

SELECT * FROM tblBoletas;

CREATE PROCEDURE usp_ContarBoletasCliente
(
    @clienteId INT,
    @TotalBoletas INT OUTPUT
)
AS
BEGIN
    SELECT @TotalBoletas = COUNT(*)
    FROM tblBoletas
    WHERE clienteId = @clienteId;
END;

DECLARE @Resultado INT;

EXEC usp_ContarBoletasCliente
    @clienteId = 1,
    @TotalBoletas = @Resultado OUTPUT;

SELECT @Resultado AS TotalBoletas;