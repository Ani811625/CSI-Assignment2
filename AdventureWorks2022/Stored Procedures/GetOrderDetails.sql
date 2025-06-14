CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the OrderID exists in Order Details
    IF NOT EXISTS (
        SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    -- If it exists, return all order details
    SELECT *
    FROM [Order Details]
    WHERE OrderID = @OrderID;
END
