USE LosBollosHermanos;
GO
--Views
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
GO
---------------------------------------------------------------------

CREATE VIEW vw_TotalVendidoPorProducto AS
SELECT 
    P.IDProducto,
    P.Nombre AS NombreProducto,
    SUM(DV.Cantidad) AS TotalUnidadesVendidas,
    SUM(DV.Subtotal) AS TotalRecaudado
FROM DetallesVenta DV
JOIN Productos P ON DV.IDProducto = P.IDProducto
GROUP BY P.IDProducto, P.Nombre;
GO
---------------------------------------------------------------------
CREATE VIEW vw_totalRecaudadoPorVendedor AS
SELECT
E.IDEmpleado,
E.Nombre + ' ' + E.Apellido AS EMPLEADO,
SUM(DV.Subtotal) AS TotalRecaudado
FROM Ventas V
JOIN Empleados E ON V.IDEmpleado = E.IDEmpleado
JOIN DetallesVenta DV ON V.IDVenta = DV.IDVenta
GROUP BY E.IDEmpleado, E.Nombre, E.Apellido;
GO
---------------------------------------------------------------------
CREATE VIEW vw_totalRecaudadoPorCliente AS
SELECT
C.IDCliente,
C.Nombre + ' ' + C.Apellido AS CLIENTE,
SUM(DV.Subtotal) AS TotalGastado
FROM Ventas V
JOIN Clientes C ON V.IDCliente = C.IDCliente
JOIN DetallesVenta DV ON V.IDVenta = DV.IDVenta
GROUP BY C.IDCliente, C.Nombre, C.Apellido;
GO
---------------------------------------------------------------------
CREATE VIEW vw_productosConStockBajo AS
Select
IDProducto,
Nombre,
Stock
from Productos
Where Stock < 10
AND Activo = 1;
GO
---------------------------------------------------------------------
CREATE VIEW vw_productosSinStock AS
SELECT
IDProducto,
Nombre,
Stock
FROM Productos
WHERE Stock = 0 AND Activo = 1;
GO
---------------------------------------------------------------------
CREATE VIEW vw_productosConMasStock AS
SELECT TOP 10
IDProducto,
Nombre,
Stock
FROM Productos
ORDER BY Stock DESC;
GO
---------------------------------------------------------------------
CREATE VIEW vw_VentasPorDia AS
SELECT
CAST (FechaEmision AS DATE) AS Fecha,
COUNT (*) AS CantidadVentas,
SUM (Total) AS TotalFacturado
FROM Ventas
GROUP BY CAST(FechaEmision AS DATE);
GO
---------------------------------------------------------------------
CREATE VIEW vw_VentasPorMes AS
SELECT
YEAR(FechaEmision) AS Anio,
MONTH(FechaEmision) AS Mes,
COUNT (*) AS CantidadVentas,
SUM (Total) AS TotalFacturado
FROM Ventas
GROUP BY YEAR(FechaEmision), MONTH(FechaEmision);


