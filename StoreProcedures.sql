	USE LosBollosHermanos;
-- Crear Procedimientos Almacenados.
--El primer procedimiento almacenado se encargara de Agregar Clientes.

--Clientes
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
---------------------------------------------------------------------
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
	---------------------------------------------------------------------
CREATE PROCEDURE sp_ListarClientes
AS
BEGIN
SELECT * FROM Clientes
END


Create Procedure sp_ListarClientesActivos
As
Begin
Select * From Clientes WHERE Activo = 1
End

Create Procedure sp_ListarClientesInactivos
As
Begin
Select * From Clientes WHERE Activo = 0
End

Go
---------------------------------------------------------------------
--Agregar Clientes.
exec sp_AgregarClientes 'Gabriel','Dolce','35982274','47441212','gabriel@alumnos.utn.com','Av Monroe 2020';
exec sp_AgregarClientes 'Lisandro','Ferreira','31981223','47441234','lisandro@alumnos.utn.com','Av Cabildo 2030';
exec sp_AgregarClientes 'Valeria', 'Mendoza', '27890123', '1123456789', 'valeria.mendoza@email.com', 'Calle Falsa 123';
exec sp_AgregarClientes 'Rodrigo', 'Carrizo', '30456789', '1133344455', 'rodrigo.carrizo@email.com', 'Av Siempre Viva 742';
exec sp_AgregarClientes 'Martina', 'Paredes', '33222111', '1166677788', 'martina.paredes@email.com', 'Pasaje Las Rosas 450';
exec sp_AgregarClientes 'Tomas', 'Quiroga', '34567123', '1144556677', 'tomas.quiroga@email.com', 'Av Belgrano 1500';
exec sp_AgregarClientes 'Camila', 'Lopez', '31234567', '1177889900', 'camila.lopez@email.com', 'Calle Mitre 987';
exec sp_AgregarClientes 'Julian', 'Escobar', '33669988', '1133221100', 'julian.escobar@email.com', 'Boulevard Orono 202';

Go

exec sp_ListarClientes;

CREATE PROCEDURE sp_AltaCliente
	@IDCliente int
	AS
	BEGIN
		SET NOCOUNT ON;
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente)
		BEGIN
			RAISERROR('El cliente no existe.',16,1);
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente AND Activo = 1)
		BEGIN
			RAISERROR('El cliente ya esta activo',16,1);
			RETURN;
		END

		UPDATE Clientes SET Activo = 1 WHERE IDCliente = @IDCliente;
		PRINT 'Cliente dado de alta con exito.';
	END TRY
	BEGIN CATCH

	DECLARE @Mensaje NVARCHAR(4000);
	SET @Mensaje = 'ERROR En el procedimiento alta de cliente (sp_AltaCliente). '
				+ 'Revise los datos o llame a los de sistemas. '
				+ 'Detalles: ' + ERROR_MESSAGE();

	RAISERROR(@Mensaje,16,1);

	END CATCH
END

		
---------------------------------------------------------------------
Create Procedure sp_BajaCliente
    @IDCliente int
as
Begin
    Set Nocount On;
	BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente)
	BEGIN
		RAISERROR('El cliente no existe.',16,1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente AND Activo = 0)
	BEGIN
		RAISERROR('El cliente ya estaba dado de baja.',16,1);
		RETURN;
	END

    Update Clientes Set Activo = 0 Where IDCliente = @IDCliente;
    Print 'Cliente dado de baja.';
	END TRY
	BEGIN CATCH
	
	DECLARE @Mensaje NVARCHAR(4000);
	SET @Mensaje = 'ERROR En el procedimiento baja de cliente (sp_BajaCliente). '
				+ 'Revise los datos o llame a los de sistemas. '
				+ 'Detalles: ' + ERROR_MESSAGE();

	RAISERROR(@Mensaje,16,1);
	END CATCH
End

Go
---------------------------------------------------------------------
 ---- EMPLEADOS
CREATE PROCEDURE sp_AgregarEmpleado
@Nombre varchar(50),
@Apellido varchar(50),
@Dni varchar(15),
@Telefono varchar(20) = Null,
@Puesto varchar(30),
@Sueldo money

AS
BEGIN			---LTRIM FUNCION QUE BORRA TODO LOS ESPACIOS EN BLANCO DEL INICIO 
				---RTRIM FUNCION QUE BORRA TODO LOS ESPACIOS EN BLANCO DEL FINAL
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
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

	COMMIT TRANSACTION;
	PRINT 'Empleado agregado correctamente.';
	END TRY
	BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	DECLARE @Mensaje NVARCHAR(4000);
	SET @Mensaje = 'ERROR En el procedimiento agregar un empleado (sp_AgregarEmpleado). '
				+ 'Revise los datos o llame a los de sistemas. '
				+ 'Detalles: ' + ERROR_MESSAGE();

	RAISERROR(@Mensaje,16,1);
	
	END CATCH
	END
	SELECT * FROM Empleados;
-------------------------------------------------------------------------------------------

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
	RAISERROR('El empleado no existe.',16,1);
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
	---------------------------------------------------------------------
	--Baja Logica Empleado
	CREATE PROCEDURE sp_BajaEmpleado
	@IDEmpleado SMALLINT
	AS
	BEGIN
		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IDEmpleado = @IDEmpleado)
	BEGIN
		RAISERROR('EL empleado no existe',16,1);
		RETURN;
	END

		IF EXISTS (SELECT 1 FROM Empleados WHERE IDEmpleado = @IDEmpleado AND Activo = 0)
	BEGIN 
		RAISERROR('El empleado ya estaba dado de baja.',16,1);
		RETURN;
	END
	UPDATE Empleados
	SET Activo = 0
	WHERE IDEmpleado = @IDEmpleado;
	
	PRINT 'Empleado dado de baja correctamente.';
END
---------------------------------------------------------------------
--ALTA LOGICO
	CREATE PROCEDURE sp_altaEmpleado
	@IDEmpleado SMALLINT
	AS
	BEGIN
		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IDEmpleado = @IDEmpleado)
	BEGIN
		RAISERROR('EL empleado no existe',16,1);
		RETURN;
	END

		IF EXISTS (SELECT 1 FROM Empleados WHERE IDEmpleado = @IDEmpleado AND Activo = 1)
	BEGIN 
		RAISERROR('El empleado ya estaba dado de alta.',16,1);
		RETURN;
	END
	UPDATE Empleados
	SET Activo = 1
	WHERE IDEmpleado = @IDEmpleado;
	
	PRINT 'Empleado dado de baja correctamente.';
END

--SELECT * FROM Empleados;
--exec sp_BajaEmpleado 1;
--exec sp_altaEmpleado 1;
	---------------------------------------------------------------------
	CREATE PROCEDURE sp_ListarEmpleadosActivos
AS
BEGIN
	SELECT * FROM Empleados WHERE Activo = 1
END
---------------------------------------------------------------------
CREATE PROCEDURE sp_ListarEmpleadosInactivos
AS
BEGIN
	SELECT * FROM Empleados WHERE Activo = 0
END
---------------------------------------------------------------------
exec sp_ListarEmpleadosActivos
exec sp_ListarEmpleadosInactivos
---------------------------------------------------------------------
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

---------------------------------------------------------------------



	-- Necesario para poder pasar varios productos (ID, cantidad, precio) 
	CREATE TYPE DetallesVentaType AS TABLE (
    IDProducto INT NOT NULL,
    Cantidad SMALLINT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario MONEY NOT NULL CHECK (PrecioUnitario > 0)
);

CREATE PROCEDURE sp_AgregarVenta
    @IDCliente INT,
    @IDEmpleado SMALLINT,
    @DetalleVenta DetallesVentaType READONLY,
    @NuevoIDVenta INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones.
    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IDCliente = @IDCliente AND Activo = 1)
    BEGIN

        RAISERROR('Cliente no valido o inactivo.', 16, 1);

        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IDEmpleado = @IDEmpleado AND Activo = 1)
    BEGIN

        RAISERROR('Empleado no valido o inactivo.', 16, 1);
        RETURN;
    END

    -- Calcular total
    DECLARE @Total MONEY;
    SELECT @Total = SUM(Cantidad * PrecioUnitario) FROM @DetalleVenta;

    IF @Total IS NULL OR @Total <= 0
    BEGIN
        RAISERROR('El total de la venta no puede ser cero o nulo.', 16, 1);
        RETURN;
    END

    -- Insertar venta
    INSERT INTO Ventas (IDCliente, IDEmpleado, Total)
    VALUES (@IDCliente, @IDEmpleado, @Total);

    SET @NuevoIDVenta = SCOPE_IDENTITY();

    -- Insertar detalles
    INSERT INTO DetallesVenta (IDVenta, IDProducto, Cantidad, PrecioUnitario)
    SELECT @NuevoIDVenta, IDProducto, Cantidad, PrecioUnitario
    FROM @DetalleVenta;

    PRINT 'Venta registrada correctamente.';
END
