CREATE TRIGGER trg_InsteadOfDeleteSalesOrder
ON Sales.SalesOrderHeader
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);

    
    DELETE FROM Sales.SalesOrderHeader
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);

    PRINT 'Order and its details successfully deleted.';
END
