CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Stock INT, @ReorderLevel INT, @ActualUnitPrice MONEY;

    SELECT @Stock = UnitsInStock, @ReorderLevel = ReorderLevel, @ActualUnitPrice = UnitPrice
    FROM Products
    WHERE ProductID = @ProductID;

    SET @UnitPrice = ISNULL(@UnitPrice, @ActualUnitPrice);

    IF @Quantity > @Stock
    BEGIN
        PRINT 'Insufficient stock. Order aborted.';
        RETURN;
    END

    INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    IF EXISTS (
        SELECT 1 FROM Products
        WHERE ProductID = @ProductID AND UnitsInStock < @ReorderLevel
    )
    BEGIN
        PRINT 'Warning: Stock below reorder level!';
    END
END;
GO

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQty INT, @NewQty INT;

    SELECT @OldQty = Quantity FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQty IS NULL
    BEGIN
        PRINT 'OrderID and ProductID combination not found.';
        RETURN;
    END

    SET @NewQty = ISNULL(@Quantity, @OldQty);
    SET @UnitPrice = ISNULL(@UnitPrice, (SELECT UnitPrice FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID));
    SET @Discount = ISNULL(@Discount, (SELECT Discount FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID));

    UPDATE OrderDetails
    SET Quantity = @NewQty, UnitPrice = @UnitPrice, Discount = @Discount
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    UPDATE Products
    SET UnitsInStock = UnitsInStock - (@NewQty - @OldQty)
    WHERE ProductID = @ProductID;
END;
GO

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM OrderDetails WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    SELECT * FROM OrderDetails WHERE OrderID = @OrderID;
END;
GO

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM OrderDetails
        WHERE OrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Error: Invalid OrderID or ProductID.';
        RETURN -1;
    END

    DELETE FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail successfully deleted.';
END;
GO
