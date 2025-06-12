
Create database LosBollosHermanos
Collate Latin1_General_CI_AI

go
use LosBollosHermanos
go
Create table Categorias(
	IDCategoria smallint not null primary key identity (1,1),
	nombre varchar(50) not null
)
go
Create table Clientes (
		IDCliente int not null primary key identity(1,1),
		Nombre varchar(50) not null,
		Apellido varchar(50) not null,
		DNI varchar (15) not null UNIQUE CHECK (LEN(DNI) >= 8),
		Telefono varchar(20),
		Email varchar(100) UNIQUE,
		Direccion varchar(100),
		FechaAlta datetime not null default getdate(),
		Activo bit not null default 1
	)
go
Create table Empleados(
	IDEmpleado smallint not null primary key identity (1,1),
	Nombre varchar(50) not null,
	Apellido varchar(50) not null,
	DNI varchar (15) not null UNIQUE CHECK (LEN(DNI) >= 8),
	Telefono varchar(20),
	Puesto varchar(30),
	FechaIngreso datetime not null default getdate(),
	Activo bit not null default 1,
	Sueldo money not null check(Sueldo >0)
	)
go
Create table Productos(
	IDProducto int primary key not null identity (1,1),
	IDCategoria smallint not null, 
	Nombre varchar(50) not null,
	Precio money not null check(Precio > 0),
	Stock int not null default 0,
	Activo bit not null default 1,
	FOREIGN KEY (IDCategoria) references Categorias(IDCategoria)
)
go
Create table Ventas(
	IDVenta int not null primary key identity (1,1),
	FechaEmision datetime not null default getdate(),
	IDCliente int not null,
	IDEmpleado smallint not null,
	Total money not null check(Total > 0),
	FOREIGN KEY (IDCliente) references Clientes(IDCliente),
	FOREIGN KEY (IDEmpleado) references Empleados(IDEmpleado)
)
go

Create table DetallesVenta(
	IDDetalleVenta int not null primary key identity (1,1),
	IDVenta int not null,
	IDProducto int not null,
	Cantidad smallint not null check (cantidad > 0),
	PrecioUnitario money not null check (PrecioUnitario > 0),
	Subtotal AS (CAST(Cantidad AS MONEY) * PrecioUnitario) PERSISTED,
	FOREIGN KEY (IDVenta) references Ventas(IDVenta),
	FOREIGN KEY (IDProducto) references Productos(IDProducto)
	)
go
--Crear Views--



CREATE VIEW vw_VentasDetalladas AS
SELECT
    V.IDVenta,
    V.FechaEmision,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    E.Nombre + ' ' + E.Apellido AS Empleado,
    P.Nombre AS Producto,
    DV.Cantidad,
    DV.PrecioUnitario,
    DV.Subtotal,
    V.Total
FROM DetallesVenta DV
JOIN Ventas V ON DV.IDVenta = V.IDVenta
JOIN Clientes C ON V.IDCliente = C.IDCliente
JOIN Empleados E ON V.IDEmpleado = E.IDEmpleado
JOIN Productos P ON DV.IDProducto = P.IDProducto;

CREATE VIEW vw_TotalVendidoPorProducto AS
SELECT 
    P.IDProducto,
    P.Nombre AS NombreProducto,
    SUM(DV.Cantidad) AS TotalUnidadesVendidas,
    SUM(DV.Subtotal) AS TotalRecaudado
FROM DetallesVenta DV
JOIN Productos P ON DV.IDProducto = P.IDProducto
GROUP BY P.IDProducto, P.Nombre;



CREATE VIEW vw_totalRecaudadoPorVendedor AS
SELECT
E.IDEmpleado,
E.Nombre + ' ' + E.Apellido AS EMPLEADO,
SUM(DV.Subtotal) AS TotalRecaudado
FROM Ventas V
JOIN Empleados E ON V.IDEmpleado = E.IDEmpleado
JOIN DetallesVenta DV ON V.IDVenta = DV.IDVenta
GROUP BY E.IDEmpleado, E.Nombre, E.Apellido;

CREATE VIEW vw_totalRecaudadoPorCliente AS
SELECT
C.IDCliente,
C.Nombre + ' ' + C.Apellido AS CLIENTE,
SUM(DV.Subtotal) AS TotalGastado
FROM Ventas V
JOIN Clientes C ON V.IDCliente = C.IDCliente
JOIN DetallesVenta DV ON V.IDVenta = DV.IDVenta
GROUP BY C.IDCliente, C.Nombre, C.Apellido;


CREATE VIEW vw_productosConStockBajo AS
Select
IDProducto,
Nombre,
Stock
from Productos
Where Stock < 10
AND Activo = 1;

-- Crear Procedimientos Almacenados.
--El primer procedimiento almacenado se encargara de Agregar Clientes.

Create Procedure sp_AgregarClientes
@Nombre varchar(50),
@Apellido varchar(50),
@Dni varchar(15),
@Telefono varchar(20) = Null,
@Email varchar(100) = Null,
@Direccion varchar(100) = Null
As
Begin
	Set Nocount on;
	If Exists (Select 1 From Clientes Where DNI = @Dni)
	Begin
		Raiserror('El dni ingresado ya existe en la bd.',16,1);
		Return;
	End

	If @Email Is not Null and Exists(Select 1 From Clientes Where Email = @Email)
	Begin
		Raiserror('El mail ingresado ya existe en la bd.',16,1);
		Return;
	End
Insert into Clientes(Nombre,Apellido,DNI,Telefono,Email,Direccion)
Values(@Nombre,@Apellido,@Dni,@Telefono,@Email,@Direccion)
Print 'Cliente Agregado correctamente';
End

Go
CREATE PROCEDURE sp_ModificarCliente
@IDCliente int,
@Nombre varchar(50),
@Apellido varchar(50),
@Dni varchar(15),
@Telefono varchar(20) = NULL,
@Email varchar(100) = NULL,
@Direccion varchar(100) = NULL
AS
BEGIN		
	SET NOCOUNT ON;
	--verificamos que exista
	IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente)
	BEGIN
	RAISERROR('El cliente no existe.',16,1);
	RETURN;
	END
	--Validaciones
	IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
BEGIN
		RAISERROR('El nombre no puede estar vacio.',16,1);
	RETURN;
END
	IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
BEGIN
	RAISERROR('El apellido no puede estar vacio.',16,1);
	RETURN;
END
IF @Dni IS NULL OR LTRIM(RTRIM(@Dni)) = ''
BEGIN
	RAISERROR('El DNI no puede estar vacio.',16,1);
	RETURN;
END

	IF exists (SELECT 1 FROM Clientes WHERE DNI = @Dni AND IDCliente <> @IDCliente)
	BEGIN
		RAISERROR ('Ya existe otro cliente con este DNI.',16,1);
	RETURN;
END
	--actualizamos el estado
	UPDATE Clientes
	SET Nombre = @Nombre,
	Apellido = @Apellido,
	DNI = @Dni,
	Telefono = @Telefono,
	Email = @Email,
	Direccion = @Direccion
	WHERE IDCliente = @IDCliente;
	
	PRINT 'Cliente modificado correctamente.';
	END
	GO

Create Procedure sp_ListarClientes -- Segundo Sp para listar clientes.
As
Begin
Select * From Clientes
End

Go

--Agregar Clientes.
exec sp_AgregarClientes 'Gabriel','Dolce','35982274','47441212','gabriel@alumnos.utn.com','Av Monroe 2020';
exec sp_AgregarClientes 'Lisandro','Ferreira','31981223','47441234','lisandro@alumnos.utn.com','Av Cabildo 2030';
exec sp_AgregarClientes 'Valeria', 'Mendoza', '27890123', '1123456789', 'valeria.mendoza@email.com', 'Calle Falsa 123';
exec sp_AgregarClientes 'Rodrigo', 'Carrizo', '30456789', '1133344455', 'rodrigo.carrizo@email.com', 'Av Siempre Viva 742';
exec sp_AgregarClientes 'Martina', 'Paredes', '33222111', '1166677788', 'martina.paredes@email.com', 'Pasaje Las Rosas 450';
exec sp_AgregarClientes 'Tomás', 'Quiroga', '34567123', '1144556677', 'tomas.quiroga@email.com', 'Av Belgrano 1500';
exec sp_AgregarClientes 'Camila', 'López', '31234567', '1177889900', 'camila.lopez@email.com', 'Calle Mitre 987';
exec sp_AgregarClientes 'Julián', 'Escobar', '33669988', '1133221100', 'julian.escobar@email.com', 'Boulevard Oroño 202';

Go

exec sp_ListarClientes;


Create Procedure sp_BajaCliente
    @IDCliente int
as
Begin
    Set Nocount On;
    Update Clientes Set Activo = 0 Where IDCliente = @IDCliente;
    Print 'Cliente dado de baja.';
End

Go

CREATE PROCEDURE sp_AgregarEmpleado
@Nombre varchar(50),
@Apellido varchar(50),
@Dni varchar(15),
@Telefono varchar(20) = Null,
@Puesto varchar(30),
@Sueldo money,
@NuevoIDEmpleado smallint OUTPUT
AS
BEGIN			---LTRIM FUNCION QUE BORRA TODO LOS ESPACIOS EN BLANCO DEL INICIO 
				---RTRIM FUNCION QUE BORRA TODO LOS ESPACIOS EN BLANCO DEL FINAL
	SET NOCOUNT ON;
	IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
BEGIN
		RAISERROR('El nombre no puede estar vacio.',16,1);
	RETURN;
END
	IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
BEGIN
	RAISERROR('El apellido no puede estar vacio.',16,1);
	RETURN;
END
IF @Dni IS NULL OR LTRIM(RTRIM(@Dni)) = ''
BEGIN
	RAISERROR('El DNI no puede estar vacio.',16,1);
	RETURN;
END
IF @Puesto IS NULL OR LTRIM(RTRIM(@Puesto)) = ''
BEGIN
	RAISERROR('El puesto no puede estar vacio.',16,1);
	RETURN;
END
	IF @Sueldo IS NULL OR @Sueldo <=0
BEGIN
	RAISERROR ('El sueldo debe ser mayor de cero.',16,1);
	RETURN;
END
	IF exists (SELECT 1 FROM Empleados WHERE DNI = @Dni)
	BEGIN
		RAISERROR ('El DNI ingresado ya existe en la tabla empleados.',16,1);
	RETURN;
END
INSERT INTO Empleados(Nombre, Apellido, DNI, Telefono, Puesto, Sueldo)
VALUES (@Nombre,@Apellido,@Dni,@Telefono,@Puesto,@Sueldo);

	SET @NuevoIDEmpleado = SCOPE_IDENTITY();
	PRINT 'Empleado agregado correctamente.';
	END


CREATE PROCEDURE sp_ListarEmpleadosActivos
AS
BEGIN
	SELECT * FROM Empleados WHERE Activo = 1
END

CREATE PROCEDURE sp_ListarEmpleadosInactivos
AS
BEGIN
	SELECT * FROM Empleados WHERE Activo = 0
END

CREATE PROCEDURE sp_ModificarEmpleado
@IDEmpleado smallint,
@Nombre varchar(50),
@Apellido varchar(50),
@Dni varchar(15),
@Telefono varchar(20) = Null,
@Puesto varchar(30),
@Sueldo money
AS
BEGIN		
	SET NOCOUNT ON;
	--verificamos que exista
	IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IDEmpleado = @IDEmpleado)
	BEGIN
	RAISEERROR('El empleado no existe.',16,1);
	RETURN;
	END
	--Validaciones
	IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
BEGIN
		RAISERROR('El nombre no puede estar vacio.',16,1);
	RETURN;
END
	IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
BEGIN
	RAISERROR('El apellido no puede estar vacio.',16,1);
	RETURN;
END
IF @Dni IS NULL OR LTRIM(RTRIM(@Dni)) = ''
BEGIN
	RAISERROR('El DNI no puede estar vacio.',16,1);
	RETURN;
END
IF @Puesto IS NULL OR LTRIM(RTRIM(@Puesto)) = ''
BEGIN
	RAISERROR('El puesto no puede estar vacio.',16,1);
	RETURN;
END
	IF @Sueldo IS NULL OR @Sueldo <=0
BEGIN
	RAISERROR ('El sueldo debe ser mayor de cero.',16,1);
	RETURN;
END
	IF exists (SELECT 1 FROM Empleados WHERE DNI = @Dni AND IDEmpleado <> @IDEmpleado)
	BEGIN
		RAISERROR ('Ya existe otro empleado con este DNI.',16,1);
	RETURN;
END
	--actualizamos el estado
	UPDATE Empleados
	SET Nombre = @Nombre,
	Apellido = @Apellido,
	DNI = @Dni,
	Telefono = @Telefono,
	Puesto = @Puesto,
	Sueldo = @Sueldo
	WHERE IDEmpleado = @IDEmpleado;
	
	PRINT 'Empleado modificado correctamente.';
	END

CREATE PROCEDURE sp_AgregarCategoria
@Nombre VARCHAR(50),
@NuevoIDCategoria SMALLINT OUTPUT
AS
	BEGIN
	SET NOCOUNT ON;

	IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre))=''
	BEGIN
		RAISERROR('El nombre de la categoria no puede estar vacio.',16,1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Categorias WHERE LOWER(Nombre) = LOWER(@Nombre))
	BEGIN
	RAISERROR('Ya existe una categoria con ese nombre.',16,1);
	RETURN;
	END
	INSERT INTO Categorias (nombre)
	VALUES (@Nombre)

	SET @NuevoIDCategoria = SCOPE_IDENTITY();

	PRINT 'Categoria agregada correctamente.';
	END




