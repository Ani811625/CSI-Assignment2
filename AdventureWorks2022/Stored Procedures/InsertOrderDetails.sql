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

    -- Get stock and reorder level
    SELECT 
        @Stock = UnitsInStock, 
        @ReorderLevel = ReorderLevel,
        @ActualUnitPrice = UnitPrice
    FROM Products
    WHERE ProductID = @ProductID;

    -- If UnitPrice not given, use Product's UnitPrice
    SET @UnitPrice = ISNULL(@UnitPrice, @ActualUnitPrice);

    -- Check stock availability
    IF @Quantity > @Stock
    BEGIN
        PRINT 'Insufficient stock. Order aborted.';
        RETURN;
    END

    -- Insert into OrderDetails
    INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    -- Check if insert was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Update stock
    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    -- Check Reorder Level
    IF EXISTS (
        SELECT 1 FROM Products
        WHERE ProductID = @ProductID AND UnitsInStock < ReorderLevel
    )
    BEGIN
        PRINT 'Warning: Stock below reorder level!';
    END
END
