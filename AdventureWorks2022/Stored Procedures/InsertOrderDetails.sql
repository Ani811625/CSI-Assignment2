CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Stock INT;
    DECLARE @ReorderLevel INT;
    DECLARE @ActualUnitPrice MONEY;

    
    SELECT 
        @Stock = UnitsInStock, 
        @ReorderLevel = ReorderLevel,
        @ActualUnitPrice = UnitPrice
    FROM Products
    WHERE ProductID = @ProductID;

   
    SET @UnitPrice = ISNULL(@UnitPrice, @ActualUnitPrice);

    
    IF @Quantity > @Stock
    BEGIN
        PRINT 'Insufficient stock. Order aborted.';
        RETURN;
    END

    
    INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
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
        WHERE ProductID = @ProductID AND UnitsInStock < ReorderLevel
    )
    BEGIN
        PRINT 'Warning: Stock below reorder level!';
    END
END
