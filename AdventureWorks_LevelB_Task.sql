
-- ============================================
-- DATABASE: AdventureWorks2022
-- SQL OBJECTS: Procedures, Functions, Views, Triggers
-- ============================================

USE AdventureWorks2022;
GO

-- ============================================
-- FUNCTION: Format Date as MM/DD/YYYY
-- ============================================
CREATE FUNCTION dbo.fn_FormatDate_MMDDYYYY (@InputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN RIGHT('0' + CAST(MONTH(@InputDate) AS VARCHAR), 2) + '/' +
           RIGHT('0' + CAST(DAY(@InputDate) AS VARCHAR), 2) + '/' +
           CAST(YEAR(@InputDate) AS VARCHAR)
END;
GO

-- ============================================
-- FUNCTION: Format Date as YYYYMMDD
-- ============================================
CREATE FUNCTION dbo.fn_FormatDate_YYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CAST(YEAR(@InputDate) AS VARCHAR) +
           RIGHT('0' + CAST(MONTH(@InputDate) AS VARCHAR), 2) +
           RIGHT('0' + CAST(DAY(@InputDate) AS VARCHAR), 2)
END;
GO

-- ============================================
-- PROCEDURE: InsertOrderDetails
-- ============================================
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

    SELECT @Stock = p.Quantity, @ActualUnitPrice = pr.ListPrice
    FROM Production.ProductInventory p
    JOIN Production.Product pr ON pr.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID AND p.LocationID = 1;

    SET @UnitPrice = ISNULL(@UnitPrice, @ActualUnitPrice);

    IF @Quantity > @Stock
    BEGIN
        PRINT 'Insufficient stock. Order aborted.';
        RETURN;
    END

    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, SpecialOfferID, rowguid, ModifiedDate)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice, 1, NEWID(), GETDATE());

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID AND LocationID = 1;

    IF EXISTS (
        SELECT 1 FROM Production.ProductInventory
        WHERE ProductID = @ProductID AND Quantity < 5
    )
    BEGIN
        PRINT 'Warning: Stock below reorder level!';
    END
END;
GO

-- ============================================
-- PROCEDURE: UpdateOrderDetails
-- ============================================
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQuantity INT, @NewQuantity INT;

    SELECT @OldQuantity = OrderQty
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQuantity IS NULL
    BEGIN
        PRINT 'OrderID and ProductID combination not found.';
        RETURN;
    END

    SET @NewQuantity = ISNULL(@Quantity, @OldQuantity);
    SET @UnitPrice = ISNULL(@UnitPrice, (SELECT UnitPrice FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID AND ProductID = @ProductID));
    SET @Discount = ISNULL(@Discount, 0);

    UPDATE Sales.SalesOrderDetail
    SET OrderQty = @NewQuantity, UnitPrice = @UnitPrice
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    UPDATE Production.ProductInventory
    SET Quantity = Quantity - (@NewQuantity - @OldQuantity)
    WHERE ProductID = @ProductID AND LocationID = 1;
END;
GO

-- ============================================
-- PROCEDURE: GetOrderDetails
-- ============================================
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID;
END;
GO

-- ============================================
-- PROCEDURE: DeleteOrderDetails
-- ============================================
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Error: Invalid OrderID or ProductID.';
        RETURN -1;
    END

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail successfully deleted.';
END;
GO

-- ============================================
-- VIEW: vwCustomerOrders (AdventureWorks Schema)
-- ============================================
CREATE VIEW vwCustomerOrders AS
SELECT 
    p.FirstName + ' ' + p.LastName AS CustomerName,
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    pr.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;
GO

-- ============================================
-- VIEW: vwCustomerOrders_Yesterday
-- ============================================
CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    p.FirstName + ' ' + p.LastName AS CustomerName,
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    pr.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE CAST(soh.OrderDate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);
GO

-- ============================================
-- VIEW: MyProducts
-- ============================================
CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Size AS QuantityPerUnit,
    p.ListPrice AS UnitPrice,
    v.Name AS CompanyName,
    pc.Name AS CategoryName
FROM Production.Product p
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL;
GO

-- ============================================
-- TRIGGER: Instead Of Delete on SalesOrderHeader
-- ============================================
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
END;
GO

-- ============================================
-- TRIGGER: Check Stock Before Insert on SalesOrderDetail
-- ============================================
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
    SELECT SalesOrderID, ProductID, OrderQty, UnitPrice, 1, NEWID(), GETDATE()
    FROM INSERTED;

    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID AND LocationID = @LocationID;

    PRINT 'Order detail inserted and stock updated.';
END;
GO
