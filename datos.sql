
		use LosBollosHermanos;
-- Categorías
INSERT INTO Categorias (nombre) VALUES 
    ('Panadería'),
    ('Pastelería'),
    ('Sandwichería'),
    ('Bebidas'),
    ('Confitería'),
    ('Pizzería'),
    ('Desayunos'),
    ('Vegano');


-- Productos
INSERT INTO Productos (IDCategoria, Nombre, Precio, Stock) VALUES 
    (1, 'Pan francés', 300, 80),
    (1, 'Pan de campo', 400, 60),
    (2, 'Torta de chocolate', 1800, 15),
    (2, 'Alfajor de maicena', 250, 50),
    (3, 'Sandwich de miga jamón y queso', 700, 40),
    (3, 'Sandwich de pollo', 850, 30),
    (4, 'Coca Cola 500ml', 500, 45),
    (4, 'Agua mineral 500ml', 350, 50),
    (5, 'Medialuna', 180, 100),
    (5, 'Pastelito de dulce', 200, 60),
    (6, 'Pizza muzzarella', 2000, 20),
    (6, 'Pizza napolitana', 2300, 18),
    (6, 'Tarta de jamón y queso', 950, 28),
    (7, 'Café con leche', 500, 40),
    (7, 'Tostadas integrales', 300, 35),
    (8, 'Budín vegano', 600, 16),
    (8, 'Medallón vegetal', 700, 15);

	INSERT INTO Productos (IDCategoria, Nombre, Precio, Stock) VALUES (6, 'Pizza Roquefort',2300,9);
	--Para probar el view de productos stock bajo;

-- Empleados
INSERT INTO Empleados (Nombre, Apellido, DNI, Telefono, Puesto, Sueldo) VALUES 
    ('Gabriel', 'Pérez', '30215875', '1122334455', 'Cajero', 350000),
    ('Sofía', 'López', '29456789', '1133445566', 'Vendedor', 330000),
    ('Ricardo', 'Méndez', '31234567', '1144556677', 'Repostero', 380000),
    ('Martina', 'Romero', '32654321', '1155667788', 'Cajero', 350000),
    ('Juan', 'Fernández', '30881234', '1166778899', 'Vendedor', 325000),
    ('Lucas', 'Martínez', '30123456', '1122112233', 'Vendedor', 320000),
    ('María', 'Gómez', '31123456', '1133442255', 'Encargada', 400000),
    ('Laura', 'Sosa', '33245678', '1177112233', 'Pastelera', 375000),
    ('Diego', 'Ríos', '34356789', '1155112233', 'Delivery', 310000);


-- Clientes
INSERT INTO Clientes (Nombre, Apellido, DNI, Telefono, Email, Direccion) VALUES 
    ('Ana', 'García', '32999111', '1177889900', 'ana.garcia@mail.com', 'Calle 123'),
    ('Carlos', 'Sánchez', '33000123', '1133221100', 'carlos.sanchez@mail.com', 'Av. Libertad 456'),
    ('Valeria', 'Ortiz', '32881122', '1166554433', 'valeria.ortiz@mail.com', 'Boulevard Oroño 789'),
    ('Bruno', 'Martínez', '32554477', '1155332211', 'bruno.martinez@mail.com', 'Ruta 8 Km 34'),
    ('Micaela', 'Torres', '32778899', '1177553311', 'mica.torres@mail.com', 'Las Heras 1998'),
    ('Esteban', 'Ramos', '33112233', '1166112233', 'esteban.ramos@mail.com', 'Castelli 3120'),
    ('Verónica', 'Morales', '33223344', '1155667788', 'vero.morales@mail.com', 'Alvear 2234'),
    ('Julieta', 'Silva', '32225577', '1122443311', 'julieta.silva@mail.com', 'French 776'),
    ('Gastón', 'Barrios', '33334455', '1133998877', 'gaston.barrios@mail.com', 'Pellegrini 900'),
    ('Rocío', 'Acosta', '32445566', '1155117799', 'rocio.acosta@mail.com', 'Echeverría 240');


-- Ventas
INSERT INTO Ventas (IDCliente, IDEmpleado, Total) VALUES 
    (1, 1, 950),
    (2, 2, 1450),
    (3, 3, 1200),
    (4, 4, 700),
    (5, 5, 1000),
    (6, 6, 1300),
    (7, 7, 800),
    (8, 8, 2100),
    (9, 9, 1700);


-- DetallesVenta
INSERT INTO DetallesVenta (IDVenta, IDProducto, Cantidad, PrecioUnitario) VALUES 
    (1, 1, 2, 300),
    (1, 4, 1, 250),
    (2, 2, 1, 400),
    (2, 3, 1, 1800),
    (3, 5, 2, 700),
    (3, 7, 1, 500),
    (4, 9, 4, 180),
    (5, 8, 2, 350),
    (5, 10, 3, 200),
    (6, 6, 2, 2300),
    (6, 15, 1, 700),
    (7, 12, 1, 1100),
    (7, 13, 2, 1200),
    (8, 16, 1, 1800),
    (8, 12, 2, 300),
    (9, 5, 1, 500),
    (9, 16, 2, 300);



	--Select * from Ventas;
	--delete from DetallesVenta;


	---funcion para reiniciar los contadores de los id autoincrementables.

	----DBCC CHECKIDENT ('DetallesVenta', RESEED, 0);
