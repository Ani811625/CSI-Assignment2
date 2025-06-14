CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQuantity INT, @NewQuantity INT, @QuantityDiff INT;
    DECLARE @OldUnitPrice MONEY, @OldDiscount FLOAT;

    -- Get existing values
    SELECT 
        @OldQuantity = Quantity,
        @OldUnitPrice = UnitPrice,
        @OldDiscount = Discount
    FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQuantity IS NULL
    BEGIN
        PRINT 'OrderID and ProductID combination not found.';
        RETURN;
    END

    -- Retain original values if new ones are NULL
    SET @NewQuantity = ISNULL(@Quantity, @OldQuantity);
    SET @UnitPrice = ISNULL(@UnitPrice, @OldUnitPrice);
    SET @Discount = ISNULL(@Discount, @OldDiscount);

    -- Update Order Details
    UPDATE [Order Details]
    SET 
        UnitPrice = @UnitPrice,
        Quantity = @NewQuantity,
        Discount = @Discount
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Update stock (add back old quantity, then subtract new quantity)
    SET @QuantityDiff = @NewQuantity - @OldQuantity;

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @QuantityDiff
    WHERE ProductID = @ProductID;
END
