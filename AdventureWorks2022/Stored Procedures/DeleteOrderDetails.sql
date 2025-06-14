CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if OrderID and ProductID combination exists
    IF NOT EXISTS (
        SELECT 1 FROM [Order Details]
        WHERE OrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Error: Invalid OrderID or ProductID.';
        RETURN -1;
    END

    -- Delete the record
    DELETE FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail successfully deleted.';
END
