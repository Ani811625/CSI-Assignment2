CREATE TRIGGER trg_InsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM OrderDetails
    WHERE OrderID IN (SELECT OrderID FROM DELETED);

    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM DELETED);

    PRINT 'Order and its details deleted successfully.';
END;
GO

CREATE TRIGGER trg_CheckStockBeforeInsert
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @Stock INT;

    SELECT @ProductID = ProductID, @Quantity = Quantity FROM INSERTED;

    SELECT @Stock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

    IF @Stock < @Quantity
    BEGIN
        PRINT 'Not enough stock. Insert cancelled.';
        RETURN;
    END

    INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    SELECT OrderID, ProductID, UnitPrice, Quantity, Discount FROM INSERTED;

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    PRINT 'Order detail inserted and stock updated.';
END;
GO