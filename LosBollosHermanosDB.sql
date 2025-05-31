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

-- Crear 2 views.

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
