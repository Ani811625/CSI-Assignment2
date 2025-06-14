CREATE TRIGGER trg_CheckStockBeforeInsert
ON Sales.SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @Quantity INT, @LocationID INT = 1, @AvailableQty INT;
    DECLARE @SalesOrderID INT, @UnitPrice MONEY;

    
    SELECT 
        @ProductID = ProductID,
        @Quantity = OrderQty,
        @SalesOrderID = SalesOrderID,
        @UnitPrice = UnitPrice
    FROM INSERTED;

    
    SELECT @AvailableQty = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID AND LocationID = @LocationID;

    IF @AvailableQty IS NULL OR @AvailableQty < @Quantity
    BEGIN
        PRINT 'Order could not be placed: Insufficient stock.';
        RETURN;
    END

  
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, SpecialOfferID, rowguid, ModifiedDate)
    SELECT 
        SalesOrderID, ProductID, OrderQty, UnitPrice,
        1, -- Default SpecialOfferID
        NEWID(),
        GETDATE()
    FROM INSERTED;

    
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID AND LocationID = @LocationID;

    PRINT 'Order inserted successfully. Stock updated.';
END
