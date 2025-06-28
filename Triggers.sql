USE LosBollosHermanos;

---------------------------------------------------------------------
-- Primer Trigger de la BD, para actualizar stock.

CREATE TRIGGER tr_ActualizarStock
ON DetallesVenta
AFTER INSERT
AS
BEGIN
    UPDATE P
    SET Stock = Stock - I.Cantidad
    FROM Productos P
    JOIN inserted I ON P.IDProducto = I.IDProducto;
END;

GO
---------------------------------------------------------------------
CREATE TRIGGER tr_ActualizarTotalVenta
ON DetallesVenta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

	UPDATE V --Modifica la tabla ventas
	SET Total = (
	SELECT COALESCE (SUM(Subtotal),0)
	FROM DetallesVenta DV
	WHERE DV.IDVenta = V.IDVenta
	)--Calcula el nuevo total para esa venta, si no hay detalles da null con coalesce lo convierte en 0
	
	FROM Ventas V -- aplica el update solo a las ventas involucradas
	WHERE V.IDVenta IN (--Selecciona todas las ventas que los detalles se hayan tocado
	SELECT IDVenta FROM inserted--Los detalles nuevos 
	UNION--Se asegura que no se repita el mismo IDVenta
	SELECT IDVenta FROM deleted--Detalles que fueron borrados o modificados
	);
	END
	GO
---------------------------------------------------------------------
CREATE TRIGGER tr_NoVentasAClientesInactivos
ON Ventas
AFTER INSERT
	AS 
BEGIN
--Si algun cliente de los nuevos registros insertados esta inactivo, cancela la venta.
		IF EXISTS (
		SELECT 1
		FROM inserted i
		JOIN Clientes c ON i.IDCliente = c.IDCliente
		WHERE c.Activo = 0
		)
	BEGIN
		RAISERROR ('No se puede realizar una venta a un cliente inactivo.', 16,1);
		ROLLBACK TRANSACTION;--Cancela la transaccion, asi no inserta registro
		RETURN;
	END
END
GO
---------------------------------------------------------------------
CREATE TRIGGER tr_EvitarStockNegativo
ON DetallesVenta
AFTER INSERT
	AS
	BEGIN
		IF EXISTS (
			SELECT 1
			FROM inserted i
			JOIN Productos p ON i.IDProducto = p.IDProducto
			WHERE p.Stock - i.Cantidad <0
			)
		BEGIN
			RAISERROR('No se puede realizar la venta, ya que el stock sería negativo.',16,1)
			ROLLBACK TRANSACTION;
			RETURN;
		END
	END
GO
---------------------------------------------------------------------
CREATE TRIGGER tr_MarcarProductosSinStock
ON Productos
AFTER UPDATE
	AS
	BEGIN
	UPDATE Productos
	SET Activo = 0
	WHERE Stock = 0 AND Activo = 1
	AND IDProducto IN (
		SELECT IDProducto FROM inserted WHERE Stock = 0
	);
END
GO

